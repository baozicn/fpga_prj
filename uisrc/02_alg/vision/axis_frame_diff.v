// axis_frame_diff.v
module axis_frame_diff #(
    parameter IMG_W = 1920, parameter IMG_H = 1080, parameter THRESH = 25
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        s_tvalid,
    input  wire [7:0]  s_tdata,
    input  wire        s_tuser,
    input  wire        s_tlast,
    output reg         m_tvalid,
    output reg  [7:0]  m_tdata,
    output reg         m_tuser,
    output reg         m_tlast
);
    localparam NUM_PIX = IMG_W*IMG_H;
    reg [31:0] addr; reg [15:0] x,y;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin x<=0; y<=0; addr<=0; end
        else if(s_tvalid) begin
            if(s_tuser) begin x<=0; y<=0; addr<=0; end
            else if(s_tlast) begin x<=0; y<=y+1; addr<=y*IMG_W; end
            else begin x<=x+1; addr<=addr+1; end
        end
    end
    reg [7:0] prev [0:NUM_PIX-1]; reg [7:0] diff;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin m_tvalid<=0; m_tdata<=0; m_tuser<=0; m_tlast<=0; diff<=0; end
        else if(s_tvalid) begin
            m_tvalid<=1; m_tuser<=s_tuser; m_tlast<=s_tlast;
            diff <= (s_tdata >= prev[addr]) ? (s_tdata - prev[addr]) : (prev[addr] - s_tdata);
            prev[addr] <= s_tdata;
            m_tdata <= (diff > THRESH)? 8'hFF : 8'h00;
        end else m_tvalid<=0;
    end
endmodule
