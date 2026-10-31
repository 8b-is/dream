// ============================================================================
// 8B Architecture Hardware Primitive: 64-Wide Complex Ternary Contraction PE
// Target: Architecture-Agnostic FPGA Fabric (LUT6 + Fast Carry Chains, 0 DSPs)
// Throughput: 64 Complex Ternary Nodes / Clock Cycle (Pipelined, II = 1)
// ============================================================================
`default_nettype none

module eightb_complex_ternary_pe64 (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         valid_in,
    input  wire         row_start,   // Asserts on first word (w = 0) of a row
    input  wire         row_last,    // Asserts on final word (w = W-1) of a row

    // Compacted Semantic Wavefield Word W_{m,w} (128 bits = 64 complex nodes)
    input  wire [63:0]  w_r_pos,
    input  wire [63:0]  w_r_neg,
    input  wire [63:0]  w_i_pos,
    input  wire [63:0]  w_i_neg,

    // Waking Query Wavevector Word X_{w} (128 bits = 64 complex nodes)
    input  wire [63:0]  x_r_pos,
    input  wire [63:0]  x_r_neg,
    input  wire [63:0]  x_i_pos,
    input  wire [63:0]  x_i_neg,

    // Canonical Block Scale Factor \gamma in signed Q16.16 format
    input  wire signed [31:0] gamma_q16_16,

    // Hardware Parity Trap & Scaled Waking Output (Q16.16 Fixed-Point)
    output reg          parity_fault,
    output reg          valid_out,
    output reg  signed [31:0] out_re_q16_16,
    output reg  signed [31:0] out_im_q16_16
);

    // ------------------------------------------------------------------------
    // Pipeline Stage 1: LUT6 Quadrature Boolean Masks & Hardware Parity Trap
    // ------------------------------------------------------------------------
    reg [63:0] p_re_pos, q_re_pos, p_re_neg, q_re_neg;
    reg [63:0] p_im_pos, q_im_pos, p_im_neg, q_im_neg;
    reg        s1_valid, s1_start, s1_last;
    reg        s1_fault;

    wire [63:0] w_corrupt = (w_r_pos & w_r_neg) | (w_i_pos & w_i_neg);
    wire [63:0] x_corrupt = (x_r_pos & x_r_neg) | (x_i_pos & x_i_neg);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_valid <= 1'b0;
            s1_start <= 1'b0;
            s1_last  <= 1'b0;
            s1_fault <= 1'b0;
            p_re_pos <= 64'd0; q_re_pos <= 64'd0;
            p_re_neg <= 64'd0; q_re_neg <= 64'd0;
            p_im_pos <= 64'd0; q_im_pos <= 64'd0;
            p_im_neg <= 64'd0; q_im_neg <= 64'd0;
        end else begin
            s1_valid <= valid_in;
            s1_start <= row_start;
            s1_last  <= row_last;
            s1_fault <= (|w_corrupt) | (|x_corrupt);

            // Real Quadrature Excitations & Inhibitions
            p_re_pos <= (w_r_pos & x_r_pos) | (w_r_neg & x_r_neg);
            q_re_pos <= (w_i_pos & x_i_neg) | (w_i_neg & x_i_pos);
            p_re_neg <= (w_r_pos & x_r_neg) | (w_r_neg & x_r_pos);
            q_re_neg <= (w_i_pos & x_i_pos) | (w_i_neg & x_i_neg);

            // Imaginary Quadrature Excitations & Inhibitions
            p_im_pos <= (w_r_pos & x_i_pos) | (w_r_neg & x_i_neg);
            q_im_pos <= (w_i_pos & x_r_pos) | (w_i_neg & x_r_neg);
            p_im_neg <= (w_r_pos & x_i_neg) | (w_r_neg & x_i_pos);
            q_im_neg <= (w_i_pos & x_r_neg) | (w_i_neg & x_r_pos);
        end
    end

    // ------------------------------------------------------------------------
    // Combinational Fused 128-Bit Compressor Function (Synthesizes to LUT6 Tree)
    // Computes popcnt(A) + popcnt(B) in a balanced binary reduction tree
    // ------------------------------------------------------------------------
    function automatic [7:0] popcnt128(input [63:0] a, input [63:0] b);
        integer i;
        reg [7:0] acc;
        begin
            acc = 8'd0;
            for (i = 0; i < 64; i = i + 1) begin
                acc = acc + a[i] + b[i];
            end
            popcnt128 = acc;
        end
    endfunction

    // ------------------------------------------------------------------------
    // Pipeline Stage 2: Parallel Population Count & Net Word Delta
    // ------------------------------------------------------------------------
    reg signed [8:0] s2_delta_re;
    reg signed [8:0] s2_delta_im;
    reg              s2_valid, s2_start, s2_last, s2_fault;

    wire [7:0] re_pos_cnt = popcnt128(p_re_pos, q_re_pos);
    wire [7:0] re_neg_cnt = popcnt128(p_re_neg, q_re_neg);
    wire [7:0] im_pos_cnt = popcnt128(p_im_pos, q_im_pos);
    wire [7:0] im_neg_cnt = popcnt128(p_im_neg, q_im_neg);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s2_valid    <= 1'b0;
            s2_start    <= 1'b0;
            s2_last     <= 1'b0;
            s2_fault    <= 1'b0;
            s2_delta_re <= 9'sd0;
            s2_delta_im <= 9'sd0;
        end else begin
            s2_valid    <= s1_valid;
            s2_start    <= s1_start;
            s2_last     <= s1_last;
            s2_fault    <= s1_fault;
            s2_delta_re <= $signed({1'b0, re_pos_cnt}) - $signed({1'b0, re_neg_cnt});
            s2_delta_im <= $signed({1'b0, im_pos_cnt}) - $signed({1'b0, im_neg_cnt});
        end
    end

    // ------------------------------------------------------------------------
    // Pipeline Stage 3: Row Accumulator & Outer Boundary Q16.16 Scaling
    // ------------------------------------------------------------------------
    reg signed [23:0] acc_re;
    reg signed [23:0] acc_im;

    wire signed [23:0] next_acc_re = (s2_start ? 24'sd0 : acc_re) + {{15{s2_delta_re[8]}}, s2_delta_re};
    wire signed [23:0] next_acc_im = (s2_start ? 24'sd0 : acc_im) + {{15{s2_delta_im[8]}}, s2_delta_im};

    // Single outer-boundary scale when row_last is asserted
    wire signed [55:0] prod_re = next_acc_re * gamma_q16_16;
    wire signed [55:0] prod_im = next_acc_im * gamma_q16_16;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_re        <= 24'sd0;
            acc_im        <= 24'sd0;
            valid_out     <= 1'b0;
            parity_fault  <= 1'b0;
            out_re_q16_16 <= 32'sd0;
            out_im_q16_16 <= 32'sd0;
        end else begin
            parity_fault <= s2_fault;
            if (s2_valid) begin
                acc_re <= next_acc_re;
                acc_im <= next_acc_im;
                if (s2_last) begin
                    valid_out     <= 1'b1;
                    out_re_q16_16 <= prod_re[31:0];
                    out_im_q16_16 <= prod_im[31:0];
                end else begin
                    valid_out <= 1'b0;
                end
            end else begin
                valid_out <= 1'b0;
            end
        end
    end

endmodule
`default_nettype wire
