@echo off 
CHCP 936
title 辅助启动助手 名侦探柯南战队专用
::随机可读颜色
set /a rand=%random% %% 5
set HEX=9ABEF
CALL set hexcolors=%%HEX:~%rand%,1%%
color 0%hexcolors%

:Start
CLS
echo         请先仔细阅读说明!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo.
echo         请按任意键继续/Press any key to continue
echo         .........................................
pause >nul

:Option
echo.
echo.
echo.
echo       请选择需要运行的辅助/Please select an option
echo         ╔════════════════════════════════════╗
echo         ║ [1]Run All assistants  运行所有辅助
echo         ║ [2]Run Shooter only    运行自动开火  
echo         ║ [3]Run C4 Hero only    运行战斗猎手  
echo         ║ [4]Run Bhop only       运行基础身法  
echo         ║ [5]Run Clicker only    运行连点助手  
echo         ║ [6]Run Recoilless only 运行基础压枪  
echo         ║ [7]Run NetBlocker only 运行一键限网
echo         ║ [8]Exit Starter now    退出启动助手
echo         ╚════════════════════════════════════╝
choice /C 12345678 /M ">        Choose a menu option 请选择:    "

:: Note - list ERRORLEVELS in decreasing order
IF ERRORLEVEL 8 GOTO Run_End
IF ERRORLEVEL 7 GOTO Run_NBK
IF ERRORLEVEL 6 GOTO Run_RCL
IF ERRORLEVEL 5 GOTO Run_CLK
IF ERRORLEVEL 4 GOTO Run_BHP
IF ERRORLEVEL 3 GOTO Run_C4H
IF ERRORLEVEL 2 GOTO Run_SHT
IF ERRORLEVEL 1 GOTO Run_ALL

:Run_ALL
CALL:Go_SHT
CALL:Go_C4H
CALL:Go_BHP
CALL:Go_CLK
CALL:Go_RCL
CALL:Go_NBK
CALL:Go_CTL
GOTO Option

:Run_SHT
CALL:Go_SHT
CALL:Go_CTL
GOTO Option

:Run_C4H
CALL:Go_C4H
CALL:Go_CTL
GOTO Option

:Run_BHP
CALL:Go_BHP
CALL:Go_CTL
GOTO Option

:Run_CLK
CALL:Go_CLK
CALL:Go_CTL
GOTO Option

:Run_RCL
CALL:Go_RCL
CALL:Go_CTL
GOTO Option

:Run_NBK
CALL:Go_NBK
CALL:Go_CTL
GOTO Option

:Run_End
echo.
echo.
echo.
echo         启动助手即将退出/Crossfirer will Exit
echo         ......................................
::TIMEOUT /T 3
PING -n 4 127.0.0.1>nul

::————————————————-----------------------------------------------------------------------
:Go_SHT
IF exist %~dp0Start_Crossfirer_SHT.ps1 IF exist %~dp0Crossfirer_Shooter.ahk (
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_SHT.ps1'"
) ELSE IF exist %~dp0自动开火.exe (
    Start "" "%~dp0自动开火.exe"
) ELSE (
    echo         自动开火不存在!!!
    PowerShell "[console]::beep(1000,1000)"
)
GOTO:EOF

:Go_C4H
IF exist %~dp0Start_Crossfirer_C4H.ps1 IF exist %~dp0Crossfirer_C4_Hero.ahk (
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_C4H.ps1'"
) ELSE IF exist %~dp0战斗助手.exe (
    Start "" "%~dp0战斗助手.exe"
) ELSE (
    echo         战斗助手不存在!!!
    PowerShell "[console]::beep(2000,1000)"
)
GOTO:EOF

:Go_BHP
IF exist %~dp0Start_Crossfirer_BHP.ps1 IF exist %~dp0Crossfirer_Bhop.ahk (
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_BHP.ps1'"
) ELSE IF exist %~dp0基础身法.exe (
    Start "" "%~dp0基础身法.exe"
) ELSE (
    echo         基础身法不存在!!!
    PowerShell "[console]::beep(3000,1000)"
)
GOTO:EOF

:Go_CLK
IF exist %~dp0Start_Crossfirer_CLK.ps1 IF exist %~dp0Crossfirer_Clicker.ahk (
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_CLK.ps1'"
) ELSE IF exist %~dp0连点助手.exe (
    Start "" "%~dp0连点助手.exe"
) ELSE (
    echo         连点助手不存在!!!
    PowerShell "[console]::beep(4000,1000)"
)
GOTO:EOF

:Go_RCL
IF exist %~dp0Start_Crossfirer_RCL.ps1 IF exist %~dp0Crossfirer_Recoilless.ahk (
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_RCL.ps1'"
) ELSE IF exist %~dp0基础压枪.exe (
    Start "" "%~dp0基础压枪.exe"
) ELSE (
    echo         基础压枪不存在!!!
    PowerShell "[console]::beep(5000,1000)"
)
GOTO:EOF

:Go_NBK
IF exist %~dp0Start_Crossfirer_NBK.ps1 IF exist %~dp0Crossfirer_NetBlocker.ahk (
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_NBK.ps1'"
) ELSE IF exist %~dp0一键限网.exe (
    Start "" "%~dp0一键限网.exe"
) ELSE (
    echo         一键限网不存在!!!
    PowerShell "[console]::beep(6000,1000)"
)
GOTO:EOF

:Go_CTL
IF exist %~dp0Start_Crossfirer_CTL.ps1 IF exist %~dp0Crossfirer_Controller.ahk (
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_CTL.ps1'"
) ELSE IF exist %~dp0助手控制.exe (
    Start "" "%~dp0助手控制.exe"
) ELSE (
    echo         助手控制不存在!!!
    PowerShell "[console]::beep(7000,1000)"
)
GOTO:EOF