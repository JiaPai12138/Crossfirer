@echo off
title 制作Win10-CF烟雾头
CHCP 65001

color 0B&mode con cols=100 lines=10
>Win10-CF烟雾头.bat echo @echo off
>>Win10-CF烟雾头.bat echo title Win10-CF烟雾头
>>Win10-CF烟雾头.bat echo 作者:鲁汀LT
>>Win10-CF烟雾头.bat echo color 0B^&mode con cols=25 lines=6
echo 作者:鲁汀LT
echo 选择进行游戏时的分辨率
echo 1. 800*600
echo 2. 1024*768
echo 3. 1280*800
echo 4. 1366*768
echo 5. 1600*900
echo 6. 1920*1080

set /p game=请输入数字:
if %game% equ 1 >>Win10-CF烟雾头.bat  echo setres h800 v600
if %game% equ 2 >>Win10-CF烟雾头.bat  echo setres h1024 v768
if %game% equ 3 >>Win10-CF烟雾头.bat  echo setres h1280 v800
if %game% equ 4 >>Win10-CF烟雾头.bat  echo setres h1366 v768
if %game% equ 5 >>Win10-CF烟雾头.bat  echo setres h1600 v900
if %game% equ 6 >>Win10-CF烟雾头.bat  echo setres h1920 v1080

cls
set "FileName=crossfire.exe"
echo 输入搜索到的目录，不要输入文件名
echo.
echo 注意:符号均是英文输入,不区分大小写
echo.
echo 例:D:\WeGame\穿越火线\crossfire.exe
echo 目录:d:\wegame\穿越火线
echo.
echo 正在搜索程序目录，请稍候...
for %%a in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
  if exist %%a:\ (
    for /f "delims=" %%b in ('where /r %%a: "%FileName%" 2^>nul') do (
      if /i "%%~nxb" equ "%FileName%" (  
cls
echo 输入搜索到的目录，不要输入文件名
echo.
echo 注意:符号均是英文输入,不区分大小写
echo.
echo 例:D:\WeGame\穿越火线\crossfire.exe
echo 目录:d:\wegame\穿越火线
echo.
echo 搜索到的游戏路径:%%b
      )
    )
  )
)
echo.
set /p z=目录:
>>Win10-CF烟雾头.bat echo pushd %z%

cls
>>Win10-CF烟雾头.bat echo set S=0
>>Win10-CF烟雾头.bat echo set SUM=1000
>>Win10-CF烟雾头.bat echo :start1
>>Win10-CF烟雾头.bat echo set /a s=%%s%%+1
>>Win10-CF烟雾头.bat echo cls
>>Win10-CF烟雾头.bat echo echo 正在等待启动游戏
>>Win10-CF烟雾头.bat echo echo 1000次时程序自动退出
>>Win10-CF烟雾头.bat echo echo -------------------------
>>Win10-CF烟雾头.bat echo echo 已检查%%S%%次
>>Win10-CF烟雾头.bat echo if "%%s%%"=="%%Sum%%" goto start5
>>Win10-CF烟雾头.bat echo tasklist^|findstr /i "crossfire.exe"^|^|goto start1
>>Win10-CF烟雾头.bat echo :start2
>>Win10-CF烟雾头.bat echo cls
>>Win10-CF烟雾头.bat echo echo 游戏正在启动...1
>>Win10-CF烟雾头.bat echo tasklist^|findstr /i "crossfire.exe"^&^&goto start2
>>Win10-CF烟雾头.bat echo :start3
>>Win10-CF烟雾头.bat echo cls
>>Win10-CF烟雾头.bat echo echo 游戏正在启动...2
>>Win10-CF烟雾头.bat echo tasklist^|findstr /i "crossfire.exe"^|^|goto start3
>>Win10-CF烟雾头.bat echo set N=0
>>Win10-CF烟雾头.bat echo set Num=2000000000
>>Win10-CF烟雾头.bat echo :start4
>>Win10-CF烟雾头.bat echo set /a n=%%n%%+1
>>Win10-CF烟雾头.bat echo cls
>>Win10-CF烟雾头.bat echo echo 每三秒检查一次游戏进程
>>Win10-CF烟雾头.bat echo echo 当游戏进程结束时自动还原
>>Win10-CF烟雾头.bat echo echo -------------------------
>>Win10-CF烟雾头.bat echo echo 已检查%%N%%次
>>Win10-CF烟雾头.bat echo ping -n 3 127.0.1^>nul
>>Win10-CF烟雾头.bat echo if "%%n%%"=="%%Num%%" goto start5
>>Win10-CF烟雾头.bat echo tasklist^|findstr /i "crossfire.exe"^&^&goto start4
>>Win10-CF烟雾头.bat echo :start5

echo 选择游戏结束后要还原的分辨率
echo 1. 1366*768
echo 2. 1600*900
echo 3. 1920*1080
echo 4. 2560*1080
echo 5. 2560*1440
echo 6. 自定义分辨率
set /p Desktop=请输入数字:

if %Desktop% equ 1 >>Win10-CF烟雾头.bat  echo setres h1366 v768
if %Desktop% equ 2 >>Win10-CF烟雾头.bat  echo setres h1600 v900
if %Desktop% equ 3 >>Win10-CF烟雾头.bat  echo setres h1920 v1080
if %Desktop% equ 4 >>Win10-CF烟雾头.bat  echo setres h2560 v1080
if %Desktop% equ 5 >>Win10-CF烟雾头.bat  echo setres h2560 v1440
if %Desktop% equ 6 goto id1

:id2
cls
>>Win10-CF烟雾头.bat echo set T=0
>>Win10-CF烟雾头.bat echo set /a T=%%n%%/20
>>Win10-CF烟雾头.bat echo cls
>>Win10-CF烟雾头.bat echo echo 10秒钟后自动退出
>>Win10-CF烟雾头.bat echo echo -------------------------
>>Win10-CF烟雾头.bat echo echo 本次游戏时长%%T%%分钟
>>Win10-CF烟雾头.bat echo ping -n 10 127.0.1^>nul
echo 批处理已生成!
echo.
echo 文件名:Win10-CF烟雾头.bat
echo.
echo 在当前目录下寻找文件
echo.
set /p g=按任意键结束
exit

:id1
cls
echo 例:请输入屏幕长度:1920
echo 例:请输入屏幕宽度:1080
echo.
set /p h=请输入屏幕长度:
set /p v=请输入屏幕宽度:
>>Win10-CF烟雾头.bat echo setres h%h% v%v%
goto id2