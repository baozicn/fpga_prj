# Wiring stubs for top-level integration

This folder adds:
- `axis_gray_from_raw10.v` – lightweight RAW10→8-bit converter (use ISP Y if available).
- `video_mux3_axis.v` – 3-way AXIS mux (original / sobel / frame-diff).

Hook plan in `system_top.v` (pseudo):
```verilog
// after uial2axis
wire src_tvalid, src_tuser, src_tlast;
wire [7:0] src_tdata; // if RAW10, insert axis_gray_from_raw10 first

axis_sobel3x3   u_sobel (... src_* -> sob_* );
axis_frame_diff u_fdiff (... src_* -> fd_*  );

video_mux3_axis u_mux   (.sel(sel),
  .a_tvalid(src_tvalid), .a_tdata(src_tdata), .a_tuser(src_tuser), .a_tlast(src_tlast),
  .b_tvalid(sob_tvalid), .b_tdata(sob_tdata), .b_tuser(sob_tuser), .b_tlast(sob_tlast),
  .c_tvalid(fd_tvalid),  .c_tdata(fd_tdata),  .c_tuser(fd_tuser),  .c_tlast(fd_tlast),
  .m_tvalid(hdmi_tvalid),.m_tdata(hdmi_tdata),.m_tuser(hdmi_tuser),.m_tlast(hdmi_tlast));
```

For DDR ping-pong in frame-diff, replace internal BRAM with `uiFDMA/uisetvbuf` readers/writers.
