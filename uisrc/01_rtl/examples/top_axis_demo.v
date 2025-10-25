// top_axis_demo.v
// Example top-level showing how to insert alg_top_axis between a grayscale AXIS source and a sink.
module top_axis_demo #(
    parameter IMG_W = 1920,
    parameter IMG_H = 1080
)(
    input  wire clk,
    input  wire rst_n,
    // demo control
    input  wire [1:0] sel, // 00 orig, 01 sobel, 10 fdiff
    // source AXIS (e.g. from uial2axis + gray)
    input  wire        src_tvalid,
    input  wire [7:0]  src_tdata,
    input  wire        src_tuser,
    input  wire        src_tlast,
    // sink AXIS (e.g. to HDMI)
    output wire        out_tvalid,
    output wire [7:0]  out_tdata,
    output wire        out_tuser,
    output wire        out_tlast
);
    alg_top_axis #(.IMG_W(IMG_W), .IMG_H(IMG_H)) u_alg (
        .clk(clk), .rst_n(rst_n),
        .s_tvalid(src_tvalid), .s_tdata(src_tdata), .s_tuser(src_tuser), .s_tlast(src_tlast),
        .sel(sel),
        .m_tvalid(out_tvalid), .m_tdata(out_tdata), .m_tuser(out_tuser), .m_tlast(out_tlast)
    );
endmodule
