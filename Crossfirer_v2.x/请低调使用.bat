@echo off 
title Crossfirer Starter
CHCP 65001
::随机可读颜色
set /a rand=%random% %% 5
set HEX=9ABEF
call set hexcolors=%%HEX:~%rand%,1%%
color 0%hexcolors%

:Start
CLS
echo         请先仔细阅读说明!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo.
echo         请按任意键继续/Press any key to continue...
pause >nul

:Option
echo.
echo.
echo       请选择需要运行的脚本/Please select an option
echo         ╔════════════════════════════════════╗
echo         ║  [1]Run All Scripts     运行所有脚本  
echo         ║  [2]Run Shooter only    运行自火脚本  
echo         ║  [3]Run C4 Hero only    运行炸弹计时  
echo         ║  [4]Run Bhop only       运行基础身法  
echo         ║  [5]Run Clicker only    运行连点脚本  
echo         ║  [6]Run Recoilless only 运行压枪脚本  
echo         ║  [7]Run NetBlocker only 运行限速脚本  
echo         ║  [8]Exit Starter now    退出启动助手
echo         ╚════════════════════════════════════╝
choice /C 12345678 /M ">        请选择/Choose a menu option:    "

:: Note - list ERRORLEVELS in decreasing order
IF ERRORLEVEL 8 GOTO End
IF ERRORLEVEL 7 GOTO Run_NBK
IF ERRORLEVEL 6 GOTO Run_RCL
IF ERRORLEVEL 5 GOTO Run_CLK
IF ERRORLEVEL 4 GOTO Run_BHP
IF ERRORLEVEL 3 GOTO Run_C4H
IF ERRORLEVEL 2 GOTO Run_SHT
IF ERRORLEVEL 1 GOTO Run_ALL

:Run_ALL
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_ALL.ps1'"
GOTO Option

:Run_SHT
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_SHT.ps1'"
GOTO Option

:Run_C4H
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_C4H.ps1'"
GOTO Option

:Run_BHP
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_BHP.ps1'"
GOTO Option

:Run_CLK
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_CLK.ps1'"
GOTO Option

:Run_RCL
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_RCL.ps1'"
GOTO Option

:Run_NBK
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_NBK.ps1'"
GOTO Option

:End
echo.
echo.
echo.
echo         启动助手即将退出/Crossfirer will Exit
echo         ......................................
::TIMEOUT /T 3
PING -n 4 127.0.0.1>nul