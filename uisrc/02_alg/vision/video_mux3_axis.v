// video_mux3_axis.v
// 3-input AXIS stream mux, select by 2-bit 'sel' (00:a, 01:b, 10:c).
module video_mux3_axis #(
    parameter SEL_WIDTH = 2
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [SEL_WIDTH-1:0] sel,
    // A
    input  wire        a_tvalid,
    input  wire [7:0]  a_tdata,
    input  wire        a_tuser,
    input  wire        a_tlast,
    // B
    input  wire        b_tvalid,
    input  wire [7:0]  b_tdata,
    input  wire        b_tuser,
    input  wire        b_tlast,
    // C
    input  wire        c_tvalid,
    input  wire [7:0]  c_tdata,
    input  wire        c_tuser,
    input  wire        c_tlast,
    // M
    output reg         m_tvalid,
    output reg  [7:0]  m_tdata,
    output reg         m_tuser,
    output reg         m_tlast
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin m_tvalid<=0; m_tdata<=0; m_tuser<=0; m_tlast<=0; end
        else begin
            case(sel)
                2'b00: begin m_tvalid<=a_tvalid; m_tdata<=a_tdata; m_tuser<=a_tuser; m_tlast<=a_tlast; end
                2'b01: begin m_tvalid<=b_tvalid; m_tdata<=b_tdata; m_tuser<=b_tuser; m_tlast<=b_tlast; end
                default:begin m_tvalid<=c_tvalid; m_tdata<=c_tdata; m_tuser<=c_tuser; m_tlast<=c_tlast; end
            endcase
        end
    end
endmodule
