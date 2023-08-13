::关闭游戏残留进程

net file 1>NUL 2>NUL
if not '%errorlevel%' == '0' (
    powershell Start-Process -FilePath "%0" -ArgumentList "%cd%" -verb runas >NUL 2>&1
    exit /b
)

taskkill /IM GameLoader.exe /F
taskkill /IM TQMCenter.exe /F
taskkill /IM TenioDL.exe /F
taskkill /IM feedback.exe /F
taskkill /IM CrossProxy.exe /F