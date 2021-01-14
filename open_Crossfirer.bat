@echo off 
title Crossfirer Starter

:Start
CLS
echo 正在帮您运行脚本，请稍等............
echo Help you run the script, please wait............
echo         ╔═══════════════════════════╗
echo         ║  [1]Run All Scripts       ║
echo         ║  [2]Run Shooter only      ║
echo         ║  [3]Run C4 Timer only     ║
echo         ║  [4]Run Bhop only         ║
echo         ║  [5]Run Clicker only      ║
echo         ║  [6]Run Recoilless only   ║
echo         ╚═══════════════════════════╝
choice /C 123456 /M ">        Choose a menu option:    "

:: Note - list ERRORLEVELS in decreasing order
IF ERRORLEVEL 6 GOTO Run_RCL
IF ERRORLEVEL 5 GOTO Run_CLK
IF ERRORLEVEL 4 GOTO Run_BHP
IF ERRORLEVEL 3 GOTO Run_C4T
IF ERRORLEVEL 2 GOTO Run_SHT
IF ERRORLEVEL 1 GOTO Run_ALL

:Run_ALL
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_ALL.ps1'"
GOTO End

:Run_SHT
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_SHT.ps1'"
GOTO End

:Run_C4T
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_C4T.ps1'"
GOTO End

:Run_BHP
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_BHP.ps1'"
GOTO End

:Run_CLK
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_CLK.ps1'"
GOTO End

:Run_RCL
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_RCL.ps1'"
GOTO End

:End
echo.
echo        Keep cmd.exe running......
echo.
echo. & pause