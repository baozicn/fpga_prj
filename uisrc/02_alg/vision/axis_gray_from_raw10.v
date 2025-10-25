// axis_gray_from_raw10.v
// Convert RAW10 (packed or 10-bit sample expanded to 8-bit) to 8-bit grayscale.
// This is a *placeholder* simple truncation [9:2]. If your pipeline already has ISP Y, use that instead.
module axis_gray_from_raw10 #(
    parameter IMG_W = 1920,
    parameter IMG_H = 1080
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        s_tvalid,
    input  wire [9:0]  s_tdata, // assume unpacked 10-bit sample per pixel for simplicity
    input  wire        s_tuser,
    input  wire        s_tlast,
    output reg         m_tvalid,
    output reg  [7:0]  m_tdata,
    output reg         m_tuser,
    output reg         m_tlast
);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin m_tvalid<=0; m_tdata<=0; m_tuser<=0; m_tlast<=0; end
        else if(s_tvalid) begin
            m_tvalid<=1'b1;
            m_tdata <= s_tdata[9:2]; // simple truncate for now
            m_tuser <= s_tuser;
            m_tlast <= s_tlast;
        end else begin
            m_tvalid<=1'b0;
        end
    end
endmodule
