// ============================================================================
// 8B Omni-Vietnam-FPGA Architecture: AXI4-Stream Complex Ternary Core
// Target: Xilinx Zynq UltraScale+ SOM on 6-Layer Omni Carrier PCB
// ISA: AGP-ISA v1.0 Balanced-Ternary Manifold (Zero DSP48E2 Utilization)
// ============================================================================
`default_nettype none

module omni_vietnam_axi_ternary_core #(
    parameter integer WORDS_PER_ROW = 64 // 64 words * 64 nodes = 4096 Complex Nodes/Row
)(
    input  wire         aclk,
    input  wire         aresetn,

    // AXI4-Stream Slave: Streaming Compacted Wavefield Tiles from DMA (256-bit bus)
    // tdata[63:0]=B^{R+}, [127:64]=B^{R-}, [191:128]=B^{I+}, [255:192]=B^{I-}
    input  wire [255:0] s_axis_w_tdata,
    input  wire         s_axis_w_tvalid,
    input  wire         s_axis_w_tlast,
    output wire         s_axis_w_tready,

    // AXI4-Stream Slave: Broadcast Waking Query Vector X_w (256-bit bus)
    input  wire [255:0] s_axis_x_tdata,
    input  wire         s_axis_x_tvalid,
    output wire         s_axis_x_tready,

    // Configuration & Phoenix Protocol Interlock Registers
    input  wire signed [31:0] cfg_gamma_q16_16,
    output wire               interlock_parity_fault,

    // AXI4-Stream Master: Contracted Complex Output Vector Y_m (64-bit: Re[31:0], Im[63:32])
    output wire [63:0]  m_axis_y_tdata,
    output wire         m_axis_y_tvalid,
    output wire         m_axis_y_tlast,
    input  wire         m_axis_y_tready
);

    // Handshake synchronization when both W and X streams are valid and downstream is ready
    wire step_enable = s_axis_w_tvalid && s_axis_x_tvalid && m_axis_y_tready;
    assign s_axis_w_tready = step_enable;
    assign s_axis_x_tready = step_enable;

    // Word counter along the inner contraction dimension N
    reg [15:0] word_cnt;
    wire       row_start = (word_cnt == 16'd0);
    wire       row_last  = (word_cnt == (WORDS_PER_ROW - 1)) || s_axis_w_tlast;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            word_cnt <= 16'd0;
        end else if (step_enable) begin
            if (row_last)
                word_cnt <= 16'd0;
            else
                word_cnt <= word_cnt + 16'd1;
        end
    end

    wire signed [31:0] pe_out_re;
    wire signed [31:0] pe_out_im;
    wire               pe_valid_out;

    // Instantiate the 0-DSP LUT6 Complex Ternary PE64
    eightb_complex_ternary_pe64 u_pe64 (
        .clk           (aclk),
        .rst_n         (aresetn),
        .valid_in      (step_enable),
        .row_start     (row_start),
        .row_last      (row_last),
        .w_r_pos       (s_axis_w_tdata[63:0]),
        .w_r_neg       (s_axis_w_tdata[127:64]),
        .w_i_pos       (s_axis_w_tdata[191:128]),
        .w_i_neg       (s_axis_w_tdata[255:192]),
        .x_r_pos       (s_axis_x_tdata[63:0]),
        .x_r_neg       (s_axis_x_tdata[127:64]),
        .x_i_pos       (s_axis_x_tdata[191:128]),
        .x_i_neg       (s_axis_x_tdata[255:192]),
        .gamma_q16_16  (cfg_gamma_q16_16),
        .parity_fault  (interlock_parity_fault),
        .valid_out     (pe_valid_out),
        .out_re_q16_16 (pe_out_re),
        .out_im_q16_16 (pe_out_im)
    );

    assign m_axis_y_tdata  = {pe_out_im, pe_out_re};
    assign m_axis_y_tvalid = pe_valid_out;
    assign m_axis_y_tlast  = pe_valid_out;

endmodule
`default_nettype wire
