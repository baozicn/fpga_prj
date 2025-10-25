# Wiring alg_top_axis into official fpga_prj

## Where to tap (from `uisrc/01_rtl/system_top.v`)
- After `u_uial2axis`: signals `S_axis_tvalid`, `S_axis_tdata[39:0]`, `S_axis_tuser`, `S_axis_tlast` carry RAW10 packed stream.
- Already goes into `isp_top`, then ISP outputs 128-bit stream `S_ISP_O_*` to DDR writer `uisetvbuf`.

## Option A: Bypass ISP temporarily (quick demo)
1. Insert `axis_gray_from_raw10` to convert RAW10 to 8-bit gray.
2. Feed gray into `alg_top_axis` to get `orig/sobel/fdiff` (8-bit AXIS).
3. Use `axis8_to_axis128` to pack 16 pixels -> 128-bit, connect to `uisetvbuf` write ports (replace `S_ISP_O_*`).
4. Keep the read path and HDMI as-is; you will see the selected stream on HDMI.

### Port mapping sketch
```verilog
// RAW10 -> gray
axis_gray_from_raw10 u_raw2y(
  .clk(S_hs_rx_clk), .rst_n(S_pll_lock),
  .s_tvalid(S_axis_tvalid), .s_tdata(S_axis_tdata[9:0]),
  .s_tuser(S_axis_tuser), .s_tlast(S_axis_tlast),
  .m_tvalid(y_tvalid), .m_tdata(y_tdata), .m_tuser(y_tuser), .m_tlast(y_tlast)
);
// alg pipeline
alg_top_axis u_alg(
  .clk(S_hs_rx_clk), .rst_n(S_pll_lock), .s_tvalid(y_tvalid), .s_tdata(y_tdata), .s_tuser(y_tuser), .s_tlast(y_tlast),
  .sel(2'b01), // 00 orig, 01 sobel, 10 fdiff
  .m_tvalid(a_tvalid), .m_tdata(a_tdata), .m_tuser(a_tuser), .m_tlast(a_tlast)
);
// 8->128 packer to DDR writer
axis8_to_axis128 u_pack(
  .clk(S_hs_rx_clk), .rst_n(S_pll_lock),
  .s_tvalid(a_tvalid), .s_tdata(a_tdata), .s_tuser(a_tuser), .s_tlast(a_tlast),
  .m_tvalid(S_ISP_O_tvalid), .m_tdata(S_ISP_O_tdata), .m_tuser(S_ISP_O_tuser), .m_tlast(S_ISP_O_tlast)
);
```
> 注意：`S_ISP_O_tdata` 是 128-bit，总线已与 DDR 写口匹配；保持 `uisetvbuf` 连接不变即可。

## Option B: Keep ISP (future)
- 若要在 ISP 后对 Y 分量做处理，可在 `isp_top` 内部或其输出处分流出 Y8，再走 `alg_top_axis` + `axis8_to_axis128`；这需要了解你们 ISP 的 Y 输出位置，后续我们再做。

## Threshold/sel 控制
- 当前 `alg_top_axis` 以参数形式固定：`SOBEL_T=80`、`FDIFF_T=25`、`sel` 常量。
- 后续我会加 AXI-lite/寄存器映射，让你们在板上切换显示与阈值。
