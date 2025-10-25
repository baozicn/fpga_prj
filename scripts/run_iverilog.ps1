Param(
  [string]$IverilogExe = "iverilog",
  [string]$VvpExe      = "vvp",
  [string]$PythonExe   = "python"
)
$ErrorActionPreference = "Stop"
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) | Out-Null
Set-Location ..
& $PythonExe tools\golden_gen.py
& $IverilogExe -g2005-sv -o sim\sim.vvp sim\tb_axis_1080p.v uisrc\02_alg\vision\axis_sobel3x3.v uisrc\02_alg\vision\axis_frame_diff.v
& $VvpExe sim\sim.vvp
& $PythonExe tools\check_outputs.py
Write-Host "Done." -ForegroundColor Green
