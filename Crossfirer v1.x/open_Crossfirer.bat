@echo off 
title Crossfirer Starter

:Start
CLS
echo 正在帮您运行脚本，请稍等............
echo Help you run the script, please wait............
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '.\Start_Crossfirer_AIO.ps1'"
echo.
echo Keep cmd.exe running......
echo.
echo. & pause
