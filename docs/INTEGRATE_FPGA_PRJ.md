# Integration steps for `fpga_prj`

1. Place RTL modules under `uisrc/02_alg/vision/`:
   - `axis_sobel3x3.v`
   - `axis_frame_diff.v`
2. In `uisrc/01_rtl/system_top.v`, right after `uial2axis` outputs, wire algorithms (AXIS: `tvalid,tdata[7:0],tuser,tlast`).
3. For RAW10, convert to 8-bit gray (e.g. `[9:2]`) or take ISP Y plane.
4. For frame-diff on board, replace BRAM `prev[]` with DDR ping-pong via `uiFDMA/uisetvbuf`.
5. MUX one stream (original/sobel/fdiff) to HDMI for quick on-board visual check.
