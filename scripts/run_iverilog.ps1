Param(
  [string]$IverilogExe = "iverilog",
  [string]$VvpExe      = "vvp",
  [string]$PythonExe   = "python"
)
$ErrorActionPreference = "Stop"
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) | Out-Null
Set-Location ..

# 1) Generate goldens
& $PythonExe tools\golden_gen.py
if ($LASTEXITCODE -ne 0) { throw "golden_gen.py failed" }

# 2) Compile
& $IverilogExe -g2012 -o sim\sim.vvp sim\tb_axis_1080p.v uisrc\02_alg\vision\axis_sobel3x3.v uisrc\02_alg\vision\axis_frame_diff.v
if ($LASTEXITCODE -ne 0) { throw "iverilog compile failed" }

# 3) Run
& $VvpExe sim\sim.vvp
if ($LASTEXITCODE -ne 0) { throw "vvp run failed" }

# 4) Compare
& $PythonExe tools\check_outputs.py
if ($LASTEXITCODE -ne 0) { throw "check_outputs.py failed" }

Write-Host "Done." -ForegroundColor Green
