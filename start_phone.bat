

@echo off
:: --- Relaunch this script minimized ---
if not "%1"=="min" start /min "" "%~f0" min & exit

setlocal enabledelayedexpansion

:: --- Detect PC screen resolution ---
for /f "tokens=2 delims==" %%A in ('wmic path Win32_VideoController get CurrentHorizontalResolution /value ^| find "="') do set PC_W=%%A
for /f "tokens=2 delims==" %%A in ('wmic path Win32_VideoController get CurrentVerticalResolution /value ^| find "="') do set PC_H=%%A
echo PC Resolution: %PC_W%x%PC_H%

:: --- Detect usable screen height (screen minus taskbar) ---
for /f %%A in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height"') do set USABLE_H=%%A
set /a TASKBAR_H=%PC_H% - %USABLE_H%
echo Taskbar Height: %TASKBAR_H%
echo Usable Screen Height: %USABLE_H%

:: --- Detect device resolution ---
for /f "tokens=3 delims= " %%A in ('adb shell wm size ^| find "Physical size"') do set DEVICE_RES=%%A
for /f "tokens=1,2 delims=x" %%A in ("%DEVICE_RES%") do (
    set DEV_W=%%A
    set DEV_H=%%B
)
echo Device Resolution: %DEV_W%x%DEV_H%

:: --- Set device window height = usable screen height ---
set WIN_H=%USABLE_H%

:: --- Calculate width proportionally ---
for /f %%A in ('powershell -NoProfile -Command "[math]::Round(%DEV_W% * %WIN_H% / %DEV_H%)"') do set WIN_W=%%A

:: --- Right-align the window ---
for /f %%A in ('powershell -NoProfile -Command "[math]::Max(0, %PC_W% - %WIN_W%)"') do set WIN_X=%%A
set WIN_Y=0

echo Window size: %WIN_W%x%WIN_H%
echo Position: X=%WIN_X% Y=%WIN_Y%
echo.

:: --- Launch scrcpy ---
scrcpy ^
  --window-borderless ^
  --stay-awake ^
  --window-x=%WIN_X% ^
  --window-y=%WIN_Y% ^
  --window-width=%WIN_W% ^
  --window-height=%WIN_H% ^
  --video-bit-rate=8M

endlocal