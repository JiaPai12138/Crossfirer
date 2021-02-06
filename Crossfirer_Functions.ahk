;Functions for Crossfirer;CF娱乐助手函数集合
;Please read https://www.autohotkey.com/docs/commands/PixelGetColor.htm for RGB vs. BGR format
;https://github.com/JacobHu0723/cps.github.io For click speed test
;==================================================================================
;检查脚本执行权限,只有以管理员权限或以UI Access运行才能正常工作
CheckPermission()
{
    If A_OSVersion in WIN_NT4, WIN_95, WIN_98, WIN_ME, WIN_2000, WIN_2003, WIN_XP, WIN_VISTA ;检测操作系统
    {
        MsgBox, 262160, 错误/Error, 此辅助需要Win 7及以上操作系统!!!`nThis program requires Windows 7 or later!!!
        ExitApp
    }

    If Not (A_IsAdmin || CheckUIA())
    {
        Try
        {
            If A_IsCompiled ;实际用自带编译器会被侦测,所以要加壳
                Run, *RunAs "%A_ScriptFullPath%" ;管理员权限运行
            Else
            {
                MsgBox, 262148, 警告/Warning, 请问你开启UIA了吗?`nDo you have UIAccess enabled?
                IfMsgBox Yes
                    Run, "%A_ProgramFiles%\AutoHotkey\AutoHotkeyU64_UIA.exe" "%A_ScriptFullPath%"
                Else
                    Run, *RunAs "%A_ScriptFullPath%"
            }
        }
        Catch
        {
            MsgBox, 262160, 错误/Error, 未正确运行!辅助将退出!!`nUnable to start correctly!The program will exit!!
            ExitApp
        }
    }
    Else
    {
        Loop
        {
            HyperSleep(3000)
        } Until WinExist("ahk_class CrossFire")
        HyperSleep(5000) ;等待客户端完整出现
    }
}
;==================================================================================
;检查是否存在指定的UIA权限辅助
CheckUIA()
{
    If ProcessExist("AutoHotkeyU64_UIA.exe")
    {
        DetectHiddenWindows, On
        WinGetTitle, AHK_Title, ahk_exe AutoHotkeyU64_UIA.exe
        WinGet, Process_Num, Count, ahk_exe AutoHotkeyU64_UIA.exe
        DetectHiddenWindows, Off
        If InStr(AHK_Title, "Crossfirer_") && Process_Num > 1
            Return True
        Else
            Return False
    }
    Else
        Return False
}
;==================================================================================
;检查游戏界面真正位置,不包括标题栏和边缘等等
CheckPosition(ByRef Xcp, ByRef Ycp, ByRef Wcp, ByRef Hcp, class_name)
{
    WinGet, CFID, ID, ahk_class %class_name%

    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "ptr", CFID, "ptr", &rect) ;内在宽高
    Wcp := NumGet(rect, 8, "int")
    Hcp := NumGet(rect, 12, "int")

    VarSetCapacity(WINDOWINFO, 60, 0)
    DllCall("GetWindowInfo", "ptr", CFID, "ptr", &WINDOWINFO) ;内在XY
    Xcp := NumGet(WINDOWINFO, 20, "Int")
    Ycp := NumGet(WINDOWINFO, 24, "Int")

    If InStr(class_name, "CrossFire")
    {
        VarSetCapacity(Screen_Info, 156)
        DllCall("EnumDisplaySettingsA", Ptr, 0, UInt, -1, UInt, &Screen_Info) ;真实分辨率
        Mon_Width := NumGet(Screen_Info, 108, "int")
        Mon_Hight := NumGet(Screen_Info, 112, "int")
        If (Wcp >= Mon_Width) || (Hcp >= Mon_Hight) ;全屏检测,未知是否适应UHD不放大
            CoordMode, Pixel, Client
        Else
            CoordMode, Pixel, Screen
    }
}
;==================================================================================
;检查进程是否存在
ProcessExist(Process_Name)
{
    Process, Exist, %Process_Name%
    Return ErrorLevel
}
;==================================================================================
;检测是否不再游戏中,目标为界面左上角火焰状字样以及附近的黑暗阴影
Not_In_Game() 
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4.5), Y1 + Round(H1 / 9), 0x3054FF, 5, Fast ;show color in editor: #3054FF #FF5430
    If !ErrorLevel
    {
        PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4.5), Y1 + Round(H1 / 9), 0x010101, 1, Fast ;show color in editor: #010101
        If !ErrorLevel
        {
            PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4.5), Y1 + Round(H1 / 9), 0xFFFFFF, 0, Fast ;show color in editor: #FFFFFF
            Return !ErrorLevel
        }
        Else
            Return False
    }
    Else
        Return False
}
;==================================================================================
;检测是否退出模式,由按键触发
ExitMode()
{
    Return (Not_In_Game() || GetKeyState("1", "P") || GetKeyState("Tab", "P") || GetKeyState("2", "P") || GetKeyState("3", "P") || GetKeyState("4", "P") || GetKeyState("J", "P") || GetKeyState("L", "P") || GetKeyState("`", "P") || GetKeyState("~", "P") || GetKeyState("RAlt", "P")) 
}
;==================================================================================
;检测点位颜色状态(颜色是否在颜色库中)
GetColorStatus(X, Y, CX1, CX2, color_lib)
{
    PixelGetColor, color_got, (X + CX1), (Y + CX2)
    Return InStr(color_lib, color_got)
}
;==================================================================================
;控制鼠标移动,上下左右
mouseXY(x1,y1)
{
    DllCall("mouse_event", uint, 1, int, x1, int, y1, uint, 0, int, 0)
}
;==================================================================================
;按键脚本,鉴于Input模式下单纯的send太快而开发
press_key(key, press_time, sleep_time)
{
    Send, {%key% DownTemp}
    HyperSleep(press_time)
    Send, {Blind}{%key% up}
    HyperSleep(sleep_time)
}
;==================================================================================
;设置图形界面位置
SetGuiPosition(ByRef XGui, ByRef YGui, GuiPosition, OffsetX, OffsetY)
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    If InStr("H", GuiPosition) ;顶部一栏横向
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + OffsetY
    }
    Else If InStr("V", GuiPosition) ;左侧一栏纵向
    {
        XGui := X1 + OffsetX
        YGui := Y1 + H1 // 2 + OffsetY
    }
    Else If InStr("M", GuiPosition) ;居中显示
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + H1 // 2 + OffsetY
    }
    Else ;从左上角为基准显示
    {
        XGui := X1 + OffsetX
        YGui := Y1 + OffsetY
    }
}
;==================================================================================
;学习自AHK自带的Windows Spy脚本,更新文字状态而减少引起闪烁
UpdateText(Gui_Number, ControlID, NewText, X, Y)
{
    static OldText := {}
    if (OldText[ControlID] != NewText)
    {
        GuiControl, %Gui_Number%: Text, %ControlID%, %NewText%
        OldText[ControlID] := NewText
        Gui, %Gui_Number%: Show, x%X% y%Y% NA
    }
}
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度时钟
SystemTime()
{
    freq := 0, tick := 0
    if (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", tick)
    Return tick / freq * 1000
} 
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度睡眠
HyperSleep(value)
{
	t_accuracy := 0.984 ;本机精度测试结果,通过JacobHu0723的CPS测试项目得出
	value *= t_accuracy
	s_begin_time := SystemTime()
	freq := 0, t_current := 0
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
	s_end_time := (s_begin_time + value) * freq / 1000 
    While (t_current <= s_end_time)
    {
        If (s_end_time - t_current) > 30000 ;大于三毫秒时不暴力轮询,以减少CPU占用
        {
            DllCall("Winmm.dll\timeBeginPeriod", UInt, 1)
			DllCall("Sleep", "UInt", 1)
			DllCall("Winmm.dll\timeEndPeriod", UInt, 1)
            ;以上三行代码为相对ahk自带sleep函数稍高精度的睡眠
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
        }
        Else ;小于三毫秒时开始暴力轮询,为更高精度睡眠
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
    }
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,接受信息
ReceiveMessage(Message) 
{
    If Message = 125638
        ExitApp ;退出当前脚本,未来可加其他动作
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,发送信息
PostMessage(Receiver, Message) ;接受方为GUI标题
{
    SetTitleMatchMode, 3
    DetectHiddenWindows, on
    PostMessage, 0x1001, %Message%, , , %Receiver% ahk_class AutoHotkeyGUI
}
;==================================================================================
;End