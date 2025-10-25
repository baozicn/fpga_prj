// axis_sobel3x3.v
// AXIS-like 3x3 Sobel: 1 pixel/clk, tuser=SOF, tlast=EOL
module axis_sobel3x3 #(
    parameter IMG_W = 1920,
    parameter IMG_H = 1080,
    parameter THRESH = 80
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
    reg [15:0] x;
    reg [15:0] y;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin x<=0; y<=0; end
        else if(s_tvalid) begin
            if(s_tuser) begin x<=0; y<=0; end
            else if(s_tlast) begin x<=0; y<=y+1; end
            else x<=x+1;
        end
    end
    reg [7:0] line1 [0:IMG_W-1];
    reg [7:0] line2 [0:IMG_W-1];
`ifndef SYNTHESIS
    integer i_init; initial begin for(i_init=0;i_init<IMG_W;i_init=i_init+1) begin line1[i_init]=0; line2[i_init]=0; end end
`endif
    reg [7:0] c0,c1,c2; reg [15:0] col;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) col<=0;
        else if(s_tvalid) col <= s_tlast ? 0 : col+1;
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin c0<=0; c1<=0; c2<=0; end
        else if(s_tvalid) begin
            c0<=c1; c1<=c2; c2<=s_tdata;
            line2[col] <= line1[col];
            line1[col] <= s_tdata;
        end
    end
    wire [7:0] p11 = (y<2 || x<2)?8'd0:line2[col-2];
    wire [7:0] p12 = (y<2 || x<1)?8'd0:line2[col-1];
    wire [7:0] p13 = (y<2)?8'd0:line2[col];
    wire [7:0] p21 = (y<1 || x<2)?8'd0:line1[col-2];
    wire [7:0] p22 = (y<1 || x<1)?8'd0:line1[col-1];
    wire [7:0] p23 = (y<1)?8'd0:line1[col];
    wire [7:0] p31 = (x<2)?8'd0:c0;
    wire [7:0] p32 = (x<1)?8'd0:c1;
    wire [7:0] p33 = c2;
    wire signed [11:0] gx = -$signed({4'd0,p11}) + $signed({4'd0,p13})
                           - ($signed({4'd0,p21})<<<1) + ($signed({4'd0,p23})<<<1)
                           - $signed({4'd0,p31}) + $signed({4'd0,p33});
    wire signed [11:0] gy = -$signed({4'd0,p11}) - ($signed({4'd0,p12})<<<1) - $signed({4'd0,p13})
                           + $signed({4'd0,p31}) + ($signed({4'd0,p32})<<<1) + $signed({4'd0,p33});
    wire [11:0] ax = gx[11] ? (~gx + 12'd1) : gx;
    wire [11:0] ay = gy[11] ? (~gy + 12'd1) : gy;
    wire [12:0] sum = ax + ay;
    wire [7:0] grad = sum[12:3];
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin m_tvalid<=0; m_tdata<=0; m_tuser<=0; m_tlast<=0; end
        else if(s_tvalid) begin
            m_tvalid<=1;
            m_tdata <= (grad > THRESH)? 8'hFF : 8'h00;
            m_tuser <= s_tuser;
            m_tlast <= s_tlast;
        end else m_tvalid<=0;
    end
endmodule
