;Functions for Crossfirer;CF娱乐助手函数集合
;Please read https://www.autohotkey.com/docs/commands/PixelGetColor.htm for RGB vs. BGR format
;https://github.com/JacobHu0723/cps.github.io For click speed test
;https://icons8.cn/icon Download icons
;https://www.designevo.com/cn/logo-maker/ https://www.pgyer.com/tools/appIcon Create logos
;https://www.bitbug.net/ Create icons
;http://www.ico51.cn/ Convert icons
#Include, Create_CF_ico.ahk
火线图标 := Create_CF_ico() ;加载图标
火线重载 := Create_Reload_ico()
火线退出 := Create_Exit_ico()
脚本图标 := ""
;==================================================================================
;预设参数
Preset(Script_Icon)
{
    #NoEnv                           ;不检查空变量是否为环境变量
    #Warn                            ;启用可能产生错误的特定状况时的警告
    #Persistent                      ;让脚本持久运行
    #MenuMaskKey, vkFF               ;改变用来掩饰(屏蔽)Win或Alt松开事件的按键
    #MaxHotkeysPerInterval, 1000     ;与下行代码一起指定热键激活的速率(次数)
    #HotkeyInterval, 1000            ;与上一行代码一起指定热键激活的速率(时间)
    #SingleInstance, Force           ;跳过对话框并自动替换旧实例
    #IfWinExist, ahk_class CrossFire ;热键仅当窗口存在时可以激活
    #KeyHistory, 0                   ;禁用按键历史
    ListLines, Off                   ;不显示最近执行的脚本行
    SendMode, Input                  ;使用更速度和可靠方式发送键鼠点击
    SetWorkingDir, %A_ScriptDir%     ;保证一致的脚本起始工作目录
    Process, Priority, , H           ;进程高优先级
    SetBatchLines, -1                ;全速运行,且因为全速运行,部分代码不得不调整
    SetKeyDelay, -1, -1              ;设置每次Send和ControlSend发送键击后无延时
    SetMouseDelay, -1                ;设置每次鼠标移动或点击后无延时
    SetDefaultMouseSpeed, 0          ;设置移动鼠标速度时默认使用最快速度
    SetWinDelay, -1                  ;全速执行窗口命令
    SetControlDelay, -1              ;控件修改命令全速执行

    global 火线图标, 脚本图标, 火线重载, 火线退出
    Switch Script_Icon
    {
        Case "断": 
            脚本图标 := Create_一键限速_ico()
            Menu, Tray, Tip, 火线一键限速

        Case "控": 
            脚本图标 := Create_助手控制_ico()
            Menu, Tray, Tip, 火线助手控制

        Case "身": 
            脚本图标 := Create_基础身法_ico()
            Menu, Tray, Tip, 火线基础身法

        Case "压": 
            脚本图标 := Create_基础压枪_ico()
            Menu, Tray, Tip, 火线基础压枪

        Case "猎": 
            脚本图标 := Create_战斗助手_ico()
            Menu, Tray, Tip, 火线战斗猎手

        Case "火": 
            脚本图标 := Create_自动开火_ico()
            Menu, Tray, Tip, 火线自动开火

        Case "点":
            脚本图标 := Create_连点助手_ico()
            Menu, Tray, Tip, 火线连点助手
        
        Case "尽": 
            脚本图标 := Create_无尽挂机_ico()
            Menu, Tray, Tip, 火线无尽挂机
    }
    Menu, Tray, NoStandard
    Menu, Tray, Add, 关于, About
    Menu, Tray, Icon, 关于, HICON:*%火线图标%, , 20
    Menu, Tray, Default, 关于
    Menu, Tray, Click, 1
    Menu, Tray, Icon, HICON:*%脚本图标%, , 1
    Menu, Tray, Add, 重新加载, Re_load
    Menu, Tray, Icon, 重新加载, HICON:*%火线重载%, , 20
    Menu, Tray, Add, 退出辅助, Exit_Script
    Menu, Tray, Icon, 退出辅助, HICON:*%火线退出%, , 20
    Menu, Tray, Color, 0x00FFFF
}
;==================================================================================
;检查脚本执行权限,只有以管理员权限或以UI Access运行才能正常工作
CheckPermission(SectionName := "助手控制")
{
    If A_OSVersion in WIN_NT4, WIN_95, WIN_98, WIN_ME, WIN_2000, WIN_2003, WIN_XP, WIN_VISTA ;检测操作系统
    {
        MsgBox, 262160, 错误/Error, 此辅助需要Win 7及以上操作系统!!!`nThis program requires Windows 7 or later!!!
        ExitApp
    }

    FileRead, Output_Data, 助手数据.ini
    If ErrorLevel
        FileAppend, , 助手数据.ini, UTF-16 ;创建一个新ini文件

    If Not (CheckAdmin(SectionName) || CheckUIA(SectionName))
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
;检查脚本是否由管理员权限运行
CheckAdmin(SectionName)
{
    If A_IsAdmin
    {
        process_id := ProcessInfo_GetCurrentProcessID()
        IniWrite, %process_id%, 助手数据.ini, %SectionName%, PID
        Return True
    }
    Else
        Return False
}
;==================================================================================
;检查脚本是否由指定的UIA权限运行
CheckUIA(SectionName)
{
    process_id := ProcessInfo_GetCurrentProcessID()
    process_name := GetProcessName(process_id)
    If InStr(process_name, "AutoHotkeyU64_UIA.exe")
    {
        IniWrite, %process_id%, 助手数据.ini, %SectionName%, PID
        Return True
    }
    Else
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
            CoordMode, Pixel, Client ;坐标相对活动窗口的客户端
        Else
            CoordMode, Pixel, Screen ;坐标相对全屏幕
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
;检测是否不在游戏中,目标为界面左上角
Not_In_Game(CF_Title) 
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    If CF_Title = 穿越火线
    {
        PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x7389A9, 0, Fast ;show color in editor: #A98973 #7389A9
        If !ErrorLevel
        {
            PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x38373E, 0, Fast ;show color in editor: #3E3738 #38373E
            If !ErrorLevel
            {
                PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x3D3C82, 0, Fast ;show color in editor: #823C3D #3D3C82
                Return !ErrorLevel
            }
        }
    }
    Else If CF_Title = CROSSFIRE
    {
        PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x959B95, 0, Fast ;show color in editor: #959B95
        If !ErrorLevel
        {
            PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x3C4B61, 0, Fast ;show color in editor: #614B3C #3C4B61
            If !ErrorLevel
            {
                PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x4B53F4, 0, Fast ;show color in editor: #F4534B #4B53F4
                Return !ErrorLevel
            }
        }
    }
    Else
        Return False
}
;==================================================================================
;检测是否退出模式,由按键触发
ExitMode()
{
    Return (GetKeyState("vk87") || GetKeyState("1", "P") || GetKeyState("Tab", "P") || GetKeyState("2", "P") || GetKeyState("3", "P") || GetKeyState("4", "P") || GetKeyState("J", "P") || GetKeyState("L", "P") || GetKeyState("`", "P") || GetKeyState("~", "P") || GetKeyState("RAlt", "P")) 
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
mouseXY(x1, y1)
{
    DllCall("mouse_event", uint, 1, int, x1, int, y1, uint, 0, int, 0)
}
;==================================================================================
;按键脚本,鉴于Input模式下单纯的send太快而开发
press_key(key_name, press_time, sleep_time)
{
    ;click_delay := 0.8 本机鼠标延迟测试,包括按下弹起
    press_time -= 0.4, sleep_time -= 0.4
    Send, {Blind}{%key_name% DownTemp}
    HyperSleep(press_time)
    Send, {Blind}{%key_name% Up}
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
    If (OldText[ControlID] != NewText)
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
    If (!freq)
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
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
        }
        Else ;小于二毫秒时开始暴力轮询,为更高精度睡眠
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
    }
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,接受信息
ReceiveMessage(Message) 
{
    If Message = 125638
        ExitApp ;退出当前脚本
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,发送信息
PostMessage(Receiver, Message) ;接受方为GUI标题
{
    SetTitleMatchMode, 3
    DetectHiddenWindows, On
    PostMessage, 0x1001, %Message%, , , %Receiver% ahk_class AutoHotkeyGUI
}
;==================================================================================
;释放所有按键,来自于https://www.autohotkey.com/boards/viewtopic.php?t=60762
Release_All_Keys()
{
    Loop, 0xFF
    {
        Key := Format("VK{:02X}", A_Index)
        If GetKeyState(Key)
            Send, {Blind}{%Key% Up}
    }
}
;==================================================================================
;计算一组数的中位数,必须以逗号隔开
Median(values)
{
    Sort, values, N D, ;以逗号为分界符
    VarArray := StrSplit(values, ",")
    Mid := Ceil(VarArray.Length() / 2)
    If Mod(VarArray.Length(), 2) ;奇数
        VarMedian := VarArray[Mid]
    Else ;偶数
        VarMedian := (VarArray[Mid] + VarArray[Mid + 1]) / 2
    Return VarMedian
}
;==================================================================================
;将指定数据与一个范围比较,有点多此一举
InRange(Min, x, Max) 
{
    If (x >= Min) && (x < Max)
        Return True
    Else
        Return False
}
;==================================================================================
;托盘退出选项
Exit_Script() 
{
    ExitApp
}
;==================================================================================
;托盘重新加载选项
Re_load() 
{
    Reload
}
;==================================================================================
;托盘关于选项
About()
{
    global 火线图标
    static thanks, timenow
    FormatTime, show_time
    Gui, icon_about: New, +LastFound +AlwaysOnTop -DPIScale +Border, 关于
    Gui, icon_about: Color, 333333 ;#333333
    Gui, icon_about: Add, Picture, , HICON:*%火线图标% ;512*512
    Gui, icon_about: Font, s12 Bold, Microsoft YaHei
    Gui, icon_about: Add, Text, vthanks c00FFFF +Center w512 ReadOnly, 2020-2021 开源项目 欢迎指导 ;%A_GuiWidth%
    Gui, icon_about: Add, Edit, vtimenow c00FFFF +Center w512 ReadOnly, %show_time% ;#00FFFF
    Gui, icon_about: Add, Button, gclose_gui w512, 好的/OK
    Gui, icon_about: Show
}
;==================================================================================
;关闭关于界面
close_gui()
{
    Gui, icon_about: Hide
}
;==================================================================================
;禁用/启用热键时修改图标
Suspended()
{
    global 火线图标, 脚本图标

    If A_IsSuspended
    {
        ToolTip, 禁用热键, , , 20
        Menu, Tray, Icon, HICON:*%火线图标%
    }
    Else
    {
        ToolTip, , , , 20
        Menu, Tray, Icon, HICON:*%脚本图标%
    }
}
;==================================================================================
;检测是否开启聊天框
Is_Chatting()
{
    count_chat := 0
    HyperSleep(30) ;稳定性
    WinGetTitle, cftitle, ahk_class CrossFire
    If cftitle = 穿越火线
        Chat_Color := "0x8AFBFF" ;#FFFB8A 
    Else If cftitle = CROSSFIRE
        Chat_Color := "0x43FFFF" ;#FFFF43
    CheckPosition(controlX, controlY, controlW, controlH, "CrossFire")
    PixelSearch, chatx, chaty, controlX, controlY + Round(controlH * 0.6), controlX + Round(controlW / 16), controlY + Round(controlH / 1.2), %Chat_Color%, 0, Fast
    If !ErrorLevel
        Return True
    Else
        Return False
}
;==================================================================================
;End