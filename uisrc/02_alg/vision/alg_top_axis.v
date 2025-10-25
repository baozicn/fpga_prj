// alg_top_axis.v
// Drop-in AXIS wrapper: feeds gray stream into Sobel + FrameDiff, then muxes to 1 output.
module alg_top_axis #(
    parameter IMG_W = 1920,
    parameter IMG_H = 1080,
    parameter SOBEL_T = 80,
    parameter FDIFF_T = 25
)(
    input  wire        clk,
    input  wire        rst_n,
    // AXIS in (8-bit gray already)
    input  wire        s_tvalid,
    input  wire [7:0]  s_tdata,
    input  wire        s_tuser,
    input  wire        s_tlast,
    // control
    input  wire [1:0]  sel,     // 00:orig 01:sobel 10:fdiff
    // AXIS out
    output wire        m_tvalid,
    output wire [7:0]  m_tdata,
    output wire        m_tuser,
    output wire        m_tlast
);
    // Sobel
    wire        sob_tvalid; wire [7:0] sob_tdata; wire sob_tuser; wire sob_tlast;
    axis_sobel3x3 #(.IMG_W(IMG_W), .IMG_H(IMG_H), .THRESH(SOBEL_T)) u_sobel (
        .clk(clk), .rst_n(rst_n),
        .s_tvalid(s_tvalid), .s_tdata(s_tdata), .s_tuser(s_tuser), .s_tlast(s_tlast),
        .m_tvalid(sob_tvalid), .m_tdata(sob_tdata), .m_tuser(sob_tuser), .m_tlast(sob_tlast)
    );
    // Frame-diff (sim/BRAM; on-board: swap to DDR ping-pong)
    wire        fd_tvalid; wire [7:0] fd_tdata; wire fd_tuser; wire fd_tlast;
    axis_frame_diff #(.IMG_W(IMG_W), .IMG_H(IMG_H), .THRESH(FDIFF_T)) u_fdiff (
        .clk(clk), .rst_n(rst_n),
        .s_tvalid(s_tvalid), .s_tdata(s_tdata), .s_tuser(s_tuser), .s_tlast(s_tlast),
        .m_tvalid(fd_tvalid), .m_tdata(fd_tdata), .m_tuser(fd_tuser), .m_tlast(fd_tlast)
    );
    // Mux: orig/sobel/fdiff
    video_mux3_axis u_mux (
        .clk(clk), .rst_n(rst_n), .sel(sel),
        .a_tvalid(s_tvalid), .a_tdata(s_tdata), .a_tuser(s_tuser), .a_tlast(s_tlast),
        .b_tvalid(sob_tvalid), .b_tdata(sob_tdata), .b_tuser(sob_tuser), .b_tlast(sob_tlast),
        .c_tvalid(fd_tvalid),  .c_tdata(fd_tdata),  .c_tuser(fd_tuser),  .c_tlast(fd_tlast),
        .m_tvalid(m_tvalid), .m_tdata(m_tdata), .m_tuser(m_tuser), .m_tlast(m_tlast)
    );
endmodule
