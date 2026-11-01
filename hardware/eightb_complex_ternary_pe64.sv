// ============================================================================
// 8B Architecture Hardware Primitive: 64-Wide Complex Ternary Contraction PE
// & Omni-Vietnam-FPGA Zero-DSP AXI4-Stream Wrapper (UltraDreamState v2.0)
// Target: Architecture-Agnostic FPGA Fabric (LUT6 + Fast Carry Chains, 0 DSPs)
// Throughput: 64 Complex Ternary Nodes / Clock Cycle (Pipelined, II = 1)
// ============================================================================
`default_nettype none

(* use_dsp = "no" *)
module eightb_complex_ternary_pe64 (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               valid_in,
    input  wire               row_start,
    input  wire               row_last,
    input  wire [63:0]        w_r_pos, w_r_neg, w_i_pos, w_i_neg,
    input  wire [63:0]        x_r_pos, x_r_neg, x_i_pos, x_i_neg,
    output reg                parity_fault,
    output reg                valid_out,
    output reg  signed [23:0] out_acc_re,
    output reg  signed [23:0] out_acc_im
);
    reg [63:0] p_re_pos, q_re_pos, p_re_neg, q_re_neg;
    reg [63:0] p_im_pos, q_im_pos, p_im_neg, q_im_neg;
    reg        s1_valid, s1_start, s1_last, s1_fault;

    wire [63:0] w_corrupt = (w_r_pos & w_r_neg) | (w_i_pos & w_i_neg);
    wire [63:0] x_corrupt = (x_r_pos & x_r_neg) | (x_i_pos & x_i_neg);

    // Stage 1: Gated LUT6_2 boolean masks & O(1) parity trap detection
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_valid <= 1'b0; s1_start <= 1'b0;
            s1_last  <= 1'b0; s1_fault <= 1'b0;
            p_re_pos <= 64'd0; q_re_pos <= 64'd0;
            p_re_neg <= 64'd0; q_re_neg <= 64'd0;
            p_im_pos <= 64'd0; q_im_pos <= 64'd0;
            p_im_neg <= 64'd0; q_im_neg <= 64'd0;
        end else if (valid_in) begin
            s1_valid <= 1'b1;
            s1_start <= row_start;
            s1_last  <= row_last;
            s1_fault <= (|w_corrupt) | (|x_corrupt);
            p_re_pos <= (w_r_pos & x_r_pos) | (w_r_neg & x_r_neg);
            q_re_pos <= (w_i_pos & x_i_neg) | (w_i_neg & x_i_pos);
            p_re_neg <= (w_r_pos & x_r_neg) | (w_r_neg & x_r_pos);
            q_re_neg <= (w_i_pos & x_i_pos) | (w_i_neg & x_i_neg);
            p_im_pos <= (w_r_pos & x_i_pos) | (w_r_neg & x_i_neg);
            q_im_pos <= (w_i_pos & x_r_pos) | (w_i_neg & x_r_neg);
            p_im_neg <= (w_r_pos & x_i_neg) | (w_r_neg & x_i_pos);
            q_im_neg <= (w_i_pos & x_r_neg) | (w_i_neg & x_r_pos);
        end else begin
            s1_valid <= 1'b0;
        end
    end

    // Synthesizable compressor behavioral model (maps to LUT6 6:3 + CARRY8)
    function automatic [7:0] popcnt128(input [63:0] a, input [63:0] b);
        integer i;
        reg [7:0] acc;
        begin
            acc = 8'd0;
            for (i = 0; i < 64; i = i + 1)
                acc = acc + a[i] + b[i];
            popcnt128 = acc;
        end
    endfunction

    reg signed [8:0] s2_delta_re, s2_delta_im;
    reg              s2_valid, s2_start, s2_last, s2_fault;

    wire [7:0] re_pos_cnt = popcnt128(p_re_pos, q_re_pos);
    wire [7:0] re_neg_cnt = popcnt128(p_re_neg, q_re_neg);
    wire [7:0] im_pos_cnt = popcnt128(p_im_pos, q_im_pos);
    wire [7:0] im_neg_cnt = popcnt128(p_im_neg, q_im_neg);

    // Stage 2: Gated 128-to-8 compressor reduction & signed word delta
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_valid <= 1'b0; s2_start <= 1'b0;
            s2_last  <= 1'b0; s2_fault <= 1'b0;
            s2_delta_re <= 9'sd0; s2_delta_im <= 9'sd0;
        end else if (s1_valid) begin
            s2_valid <= 1'b1;
            s2_start <= s1_start;
            s2_last  <= s1_last;
            s2_fault <= s1_fault;
            s2_delta_re <= $signed({1'b0, re_pos_cnt}) - $signed({1'b0, re_neg_cnt});
            s2_delta_im <= $signed({1'b0, im_pos_cnt}) - $signed({1'b0, im_neg_cnt});
        end else begin
            s2_valid <= 1'b0;
        end
    end

    // Stage 3: Stall-safe 24-bit integer accumulation & sticky row fault latch
    reg signed [23:0] acc_re, acc_im;
    wire signed [23:0] next_acc_re = (s2_start ? 24'sd0 : acc_re)
                                   + {{15{s2_delta_re[8]}}, s2_delta_re};
    wire signed [23:0] next_acc_im = (s2_start ? 24'sd0 : acc_im)
                                   + {{15{s2_delta_im[8]}}, s2_delta_im};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_re <= 24'sd0; acc_im <= 24'sd0;
            valid_out <= 1'b0; parity_fault <= 1'b0;
            out_acc_re <= 24'sd0; out_acc_im <= 24'sd0;
        end else if (s2_valid) begin
            acc_re <= next_acc_re;
            acc_im <= next_acc_im;
            parity_fault <= (s2_start ? s2_fault : (parity_fault | s2_fault));
            valid_out <= s2_last;
            if (s2_last) begin
                out_acc_re <= next_acc_re;
                out_acc_im <= next_acc_im;
            end
        end else begin
            valid_out <= 1'b0;
        end
    end
endmodule

module omni_vietnam_axi_ternary_core #(
    parameter integer ROW_WORDS = 64
)(
    input  wire         aclk,
    input  wire         aresetn,
    input  wire         s_axis_x_tvalid,
    input  wire [255:0] s_axis_x_tdata,
    input  wire [5:0]   s_axis_x_tuser,
    input  wire         s_axis_w_tvalid,
    output wire         s_axis_w_tready,
    input  wire [255:0] s_axis_w_tdata,
    input  wire         s_axis_w_tuser,
    input  wire         s_axis_w_tlast,
    output wire         m_axis_y_tvalid,
    output wire [63:0]  m_axis_y_tdata,
    output wire         m_axis_y_tuser
);
    reg [255:0] x_uram [0:ROW_WORDS-1];
    reg [5:0]   word_idx;
    assign s_axis_w_tready = 1'b1;

    always @(posedge aclk) begin
        if (s_axis_x_tvalid)
            x_uram[s_axis_x_tuser] <= s_axis_x_tdata;
    end

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) word_idx <= 6'd0;
        else if (s_axis_w_tvalid)
            word_idx <= s_axis_w_tlast ? 6'd0 : (word_idx + 6'd1);
    end

    wire [255:0] x_cur = x_uram[word_idx];
    wire signed [23:0] raw_re, raw_im;
    eightb_complex_ternary_pe64 u_pe64 (
        .clk(aclk), .rst_n(aresetn),
        .valid_in(s_axis_w_tvalid),
        .row_start(s_axis_w_tuser), .row_last(s_axis_w_tlast),
        .w_r_pos(s_axis_w_tdata[63:0]),
        .w_r_neg(s_axis_w_tdata[127:64]),
        .w_i_pos(s_axis_w_tdata[191:128]),
        .w_i_neg(s_axis_w_tdata[255:192]),
        .x_r_pos(x_cur[63:0]),            .x_r_neg(x_cur[127:64]),
        .x_i_pos(x_cur[191:128]),         .x_i_neg(x_cur[255:192]),
        .parity_fault(m_axis_y_tuser),    .valid_out(m_axis_y_tvalid),
        .out_acc_re(raw_re),              .out_acc_im(raw_im)
    );
    assign m_axis_y_tdata = { {{8{raw_im[23]}}, raw_im}, {{8{raw_re[23]}}, raw_re} };
endmodule
`default_nettype wire
