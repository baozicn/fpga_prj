// axis_gray_from_raw10.v
module axis_gray_from_raw10 #(
    parameter IMG_W=1920, IMG_H=1080
)(
    input wire clk, rst_n,
    input wire s_tvalid,
    input wire [9:0] s_tdata,
    input wire s_tuser, s_tlast,
    output reg m_tvalid,
    output reg [7:0] m_tdata,
    output reg m_tuser, m_tlast
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin m_tvalid<=0; m_tdata<=0; m_tuser<=0; m_tlast<=0; end
        else if(s_tvalid) begin
            m_tvalid<=1; m_tdata<=s_tdata[9:2]; m_tuser<=s_tuser; m_tlast<=s_tlast;
        end else m_tvalid<=0;
    end
endmodule
