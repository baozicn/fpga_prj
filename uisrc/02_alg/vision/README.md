# Vision 1080p Algorithms (Sobel + FrameDiff)

This folder contains AXIS-friendly image preprocessing modules for 1920x1080 video pipelines.

- `axis_sobel3x3.v`: 3x3 Sobel with internal 2-line buffers; outputs 0/255 binary edge map.
- `axis_frame_diff.v`: frame-to-frame absdiff with threshold; simulation uses BRAM; board version switches to DDR ping-pong.

```verilog
// Example wiring after uial2axis (AXIS: tvalid/tdata[7:0]/tuser(SOF)/tlast(EOL))
axis_sobel3x3 #(.IMG_W(1920), .IMG_H(1080), .THRESH(80)) u_sobel (...);
axis_frame_diff #(.IMG_W(1920), .IMG_H(1080), .THRESH(25)) u_fdiff (...);
```

See `docs/INTEGRATE_FPGA_PRJ.md` for integration steps.
