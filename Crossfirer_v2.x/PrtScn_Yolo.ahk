#include Gdip_All.ahk
#NoEnv                           ;不检查空变量是否为环境变量
;#Warn                           ;(不)启用可能产生错误的特定状况时的警告
#Persistent                      ;让脚本持久运行
#MenuMaskKey, vkFF               ;改变用来掩饰(屏蔽)Win或Alt松开事件的按键
#MaxHotkeysPerInterval, 1000     ;与下行代码一起指定热键激活的速率(次数)
#HotkeyInterval, 1000            ;与上一行代码一起指定热键激活的速率(时间)
#SingleInstance, Force           ;跳过对话框并自动替换旧实例
#KeyHistory, 0                   ;禁用按键历史
ListLines, Off                   ;不显示最近执行的脚本行
SendMode, Input                  ;使用更速度和可靠方式发送键鼠点击
SetWorkingDir, %A_ScriptDir%     ;保证一致的脚本起始工作目录
Process, Priority, , H           ;进程高优先级
SetBatchLines, -1                ;全速运行,且因为全速运行,部分代码不得不调整
;==================================================================================
CheckPermission1()
CheckWindow(win_class, win_title)
MsgBox, %win_title% 出现!!!
global CapSave = False
If Not InStr(FileExist("Screenshots"), "D")
    FileCreateDir, Screenshots
;==================================================================================
~*PrintScreen Up::
    SoundBeep, 1000, 300
    CapSave := !CapSave
    If CapSave
        SetTimer, ShotAndSave, 1000
    Else
    {
        SetTimer, ShotAndSave, Off
        ToolTip, , , , 1
    }
Return
;==================================================================================
;找到并由使用者确认游戏窗口
CheckWindow(ByRef ClassName, ByRef TitleName)
{
    hwnd_id := 0
    confirmed := False
    Loop
    {
        HyperSleep(3000)
        hwnd_id := WinExist("A")
        WinGetClass, Class_Name, ahk_id %hwnd_id%
        WinGetTitle, Title_Name, ahk_class %Class_Name%
        MsgBox, 262148, 确认框/Confirm Box, %Title_Name% 是您需要的窗口标题吗?`nIs %Title_Name% the window title you want?
        IfMsgBox, Yes
            confirmed = True
            ClassName := Class_Name, TitleName := Title_Name
    } Until (confirmed && ClassName && TitleName)
    ;CrossFire Valve001 LaunchUnrealUWindowsClient
}
;==================================================================================
;重复截图
ShotAndSave()
{
    global win_class
    CheckPosition1(PX, PY, PW, PH, win_class)
    ToolTip, 正在截图中:%PX%|%PY%|%PW%|%PH%, PX, PY, 1
    cap_zoom := (PX + PW // 2 - 304) . "|" . (PY + PH // 2 - 304) . "|" . 608 . "|" . 608
    Screenshot(A_ScriptDir . "\Screenshots\Screenshot_" . win_class . "_" . A_Now ".jpg", cap_zoom)
}
;==================================================================================
;截图存图,screen: X|Y|W|H
Screenshot(outfile, screen)
{
    pToken := Gdip_Startup()
    pBitmap := Gdip_BitmapFromScreen(screen)
    E1 := Gdip_LockBits(pBitmap, 0, 0, Gdip_GetImageWidth(pBitmap), Gdip_GetImageHeight(pBitmap), Stride, Scan0, BitmapData)
    Gdip_SaveBitmapToFile(pBitmap, outfile, 100)
    Gdip_UnlockBits(pBitmap, BitmapData)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
}
;==================================================================================
;检查脚本执行权限,只有以管理员权限或以UI Access运行才能正常工作
CheckPermission1()
{
    If A_OSVersion in WIN_NT4, WIN_95, WIN_98, WIN_ME, WIN_2000, WIN_2003, WIN_XP, WIN_VISTA ;检测操作系统版本
    {
        MsgBox, 262160, 错误/Error, 此辅助需要Win 7及以上操作系统!!!`nThis program requires Windows 7 or later!!!
        ExitApp
    }

    If !A_Is64bitOS ;检测操作系统是否为64位
    {
        MsgBox, 262160, 错误/Error, 此辅助需要64位操作系统!!!`nThis program requires 64-bit OS!!!
        ExitApp
    }

    If Not (CheckAdmin1() || CheckUIA1())
    {
        Try
        {
            If A_IsCompiled ;编译时请用加密减少侦测几率
                Run, *RunAs "%A_ScriptFullPath%" ;管理员权限运行
            Else
            {
                MsgBox, 262148, 警告/Warning, 请问你开启UIA了吗?`nDo you have UIAccess enabled?
                IfMsgBox Yes
                    Run, "%A_ProgramFiles%\AutoHotkey\AutoHotkeyU64_UIA.exe" "%A_ScriptFullPath%"
                Else
                    Run, *RunAs "%A_ScriptFullPath%"
                ExitApp
            }
        }
        Catch
        {
            MsgBox, 262160, 错误/Error, 未正确运行!辅助将退出!!`nUnable to start correctly!The program will exit!!
            ExitApp
        }
    }
}
;==================================================================================
;检查脚本是否由管理员权限运行
CheckAdmin1()
{
    If A_IsAdmin
        Return True
    Return False
}
;==================================================================================
;检查脚本是否由指定的UIA权限运行
CheckUIA1()
{
    process_id := ProcessInfo_GetCurrentProcessID()
    process_name := GetProcessName(process_id)
    If InStr(process_name, "AutoHotkeyU64_UIA.exe")
        Return True
    Return False
}
;==================================================================================
;拷贝自 https://github.com/camerb/AHKs/blob/master/thirdParty/ProcessInfo.ahk ,检测脚本运行的进程ID
ProcessInfo_GetCurrentProcessID()
{
    Return DllCall("GetCurrentProcessId")
}
;==================================================================================
;拷贝自 https://www.reddit.com/r/AutoHotkey/comments/6zftle/process_name_from_pid/ ,通过进程ID得到进程完整路径
GetProcessName(ProcessID)
{
    If (hProcess := DllCall("OpenProcess", "uint", 0x0410, "int", 0, "uint", ProcessID, "ptr"))
    {
        size := VarSetCapacity(buf, 0x0104 << 1, 0)
        If (DllCall("psapi\GetModuleFileNameEx", "ptr", hProcess, "ptr", 0, "ptr", &buf, "uint", size))
            Return StrGet(&buf), DllCall("CloseHandle", "ptr", hProcess)
        DllCall("CloseHandle", "ptr", hProcess)
    }
    Return False
}
;==================================================================================
;检查游戏界面真正位置,不包括标题栏和边缘等等,既Client位置
CheckPosition1(ByRef Xcp, ByRef Ycp, ByRef Wcp, ByRef Hcp, class_name)
{
    WinGet, Win_ID, ID, ahk_class %class_name%

    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "ptr", Win_ID, "ptr", &rect) ;内在宽高
    Wcp := NumGet(rect, 8, "int")
    Hcp := NumGet(rect, 12, "int")

    VarSetCapacity(WINDOWINFO, 60, 0)
    DllCall("GetWindowInfo", "ptr", Win_ID, "ptr", &WINDOWINFO) ;内在XY
    Xcp := NumGet(WINDOWINFO, 20, "Int")
    Ycp := NumGet(WINDOWINFO, 24, "Int")

    VarSetCapacity(Screen_Info, 156)
    DllCall("EnumDisplaySettingsA", Ptr, 0, UInt, -1, UInt, &Screen_Info) ;真实分辨率
    Mon_Width := NumGet(Screen_Info, 108, "int")
    Mon_Hight := NumGet(Screen_Info, 112, "int")

    If (Wcp >= Mon_Width) || (Hcp >= Mon_Hight) ;全屏检测,未知是否适应UHD不放大
    {
        CoordMode, Pixel, Client ;坐标相对活动窗口的客户端
        CoordMode, Mouse, Client
        CoordMode, ToolTip, Client
    }
    Else
    {
        CoordMode, Pixel, Screen ;坐标相对全屏幕
        CoordMode, Mouse, Screen
        CoordMode, ToolTip, Screen
    }
}
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度时钟
SystemTime()
{
    freq := 0, tick := 0
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", tick)
    Return tick / freq * 1000
}
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度睡眠
HyperSleep(value)
{
    s_begin_time := SystemTime()
    freq := 0, t_current := 0
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    s_end_time := (s_begin_time + value) * freq / 1000
    While, (t_current < s_end_time)
    {
        If (s_end_time - t_current) > 20000 ;大于二毫秒时不暴力轮询,以减少CPU占用
        {
            DllCall("Winmm.dll\timeBeginPeriod", UInt, 1)
            DllCall("Sleep", "UInt", 1)
            DllCall("Winmm.dll\timeEndPeriod", UInt, 1)
            ;以上三行代码为相对ahk自带sleep函数稍高精度的睡眠
        }
        DllCall("QueryPerformanceCounter", "Int64*", t_current)
    }
}
;==================================================================================
