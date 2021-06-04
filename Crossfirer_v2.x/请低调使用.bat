@echo off
CHCP 936
title 辅助启动助手 名侦探柯南战队专用
::随机可读颜色
set /a rand=%random% %% 5
set HEX=9ABEF
CALL set hexcolors=%%HEX:~%rand%,1%%
color 0%hexcolors%

:Check
::检查是否为管理员权限
net session >nul 2>&1
IF %errorLevel% == 0 (
    echo         管理员你好
) ELSE (
    echo         未以管理员身份运行,无法启动编译版
)
Ping /n 3 127.0.0.1 >nul
GOTO Start

:Start
CLS
cd /d %~dp0
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
echo         ║ [4]Run Bhop only       运行普通身法
echo         ║ [5]Run Clicker only    运行连点助手
echo         ║ [6]Run Recoilless only 运行基础压枪
echo         ║ [7]Run NetBlocker only 运行一键限网
echo         ║ [8]Run Challenger only 运行无尽挂机
echo         ║ [9]Exit Starter now    退出启动助手
echo         ╚════════════════════════════════════╝
choice /C 123456789 /M ">        请选择/Choose a menu option:    "

:: Note - list ERRORLEVELS in decreasing order
IF ERRORLEVEL 9 GOTO Run_End
IF ERRORLEVEL 8 GOTO Run_CLG
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

:Run_CLG
CALL:Go_CLG
CALL:Go_CTL
GOTO Option

:Go_SHT
Ping /n 1 127.0.0.1 >nul
IF exist "Crossfirer_Shooter.ahk" (
    start "" "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "Crossfirer_Shooter.ahk"
) ELSE IF exist 自动开火.exe (
    Start "" "自动开火.exe"
) ELSE (
    echo         自动开火不存在!!!
    PowerShell "[console]::beep(1000,500)"
)
GOTO:EOF

:Go_C4H
Ping /n 1 127.0.0.1 >nul
IF exist "Crossfirer_C4_Hero.ahk" (
    start "" "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "Crossfirer_C4_Hero.ahk"
) ELSE IF exist 战斗助手.exe (
    Start "" "战斗助手.exe"
) ELSE (
    echo         战斗助手不存在!!!
    PowerShell "[console]::beep(1500,500)"
)
GOTO:EOF

:Go_BHP
Ping /n 1 127.0.0.1 >nul
IF exist "Crossfirer_Bhop.ahk" (
    start "" "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "Crossfirer_Bhop.ahk"
) ELSE IF exist 普通身法.exe (
    Start "" "普通身法.exe"
) ELSE (
    echo         普通身法不存在!!!
    PowerShell "[console]::beep(2000,500)"
)
GOTO:EOF

:Go_CLK
Ping /n 1 127.0.0.1 >nul
IF exist "Crossfirer_Clicker.ahk" (
    start "" "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "Crossfirer_Clicker.ahk"
) ELSE IF exist 连点助手.exe (
    Start "" "连点助手.exe"
) ELSE (
    echo         连点助手不存在!!!
    PowerShell "[console]::beep(2500,500)"
)
GOTO:EOF

:Go_RCL
Ping /n 1 127.0.0.1 >nul
IF exist "Crossfirer_Recoilless.ahk" (
    start "" "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "Crossfirer_Recoilless.ahk"
) ELSE IF exist 基础压枪.exe (
    Start "" "基础压枪.exe"
) ELSE (
    echo         基础压枪不存在!!!
    PowerShell "[console]::beep(3000,500)"
)
GOTO:EOF

:Go_NBK
Ping /n 1 127.0.0.1 >nul
IF exist "Crossfirer_NetBlocker.ahk" (
    start "" "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "Crossfirer_NetBlocker.ahk"
) ELSE IF exist 一键限网.exe (
    Start "" "一键限网.exe"
) ELSE (
    echo         一键限网不存在!!!
    PowerShell "[console]::beep(3500,500)"
)
GOTO:EOF

:Go_CLG
Ping /n 1 127.0.0.1 >nul
IF exist "Crossfirer_Challenger.ahk" (
    start "" "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "Crossfirer_Challenger.ahk"
) ELSE IF exist 无尽挂机.exe (
    Start "" "无尽挂机.exe"
) ELSE (
    echo         无尽挂机不存在!!!
    PowerShell "[console]::beep(4000,500)"
)
GOTO:EOF

:Go_CTL
Ping /n 1 127.0.0.1 >nul
IF exist "Crossfirer_Controller.ahk" (
    start "" "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "Crossfirer_Controller.ahk"
) ELSE IF exist 助手控制.exe (
    Start "" "助手控制.exe"
) ELSE (
    echo         助手控制不存在!!!
    PowerShell "[console]::beep(4500,500)"
)
GOTO:EOF

:Run_End
echo.
echo.
echo.
echo         启动助手即将退出/Crossfirer will Exit
echo         ......................................
::TIMEOUT /T 3
Ping /n 3 127.0.0.1 >nul
