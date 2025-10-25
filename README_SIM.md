# Simulation (Windows & CI)

## Windows (PowerShell)
```powershell
.\scripts\run_iverilog.ps1 -IverilogExe "C:\iverilog\bin\iverilog.exe" -VvpExe "C:\iverilog\bin\vvp.exe" -PythonExe py
```
It will generate goldens, compile Icarus, run sim, and compare against goldens.

## CI
The workflow in `.github/workflows/sim.yml` runs the same steps on GitHub Actions.

## Files
- `tools/golden_gen.py`: synth two 1080p frames + goldens
- `tools/check_outputs.py`: pixel-compare RTL vs goldens
- `sim/tb_axis_1080p.v`: AXIS testbench
- `uisrc/02_alg/vision/axis_sobel3x3.v`: Sobel (3x3)
- `uisrc/02_alg/vision/axis_frame_diff.v`: frame-diff
