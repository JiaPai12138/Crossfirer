;Functions for Crossfirer;CF娱乐助手函数集合
;Please read https://www.autohotkey.com/docs/commands/PixelGetColor.htm for RGB vs. BGR format
;https://github.com/JacobHu0723/cps.github.io For click speed test
;https://icons8.cn/icon Download icons
;https://www.designevo.com/cn/logo-maker/ https://www.pgyer.com/tools/appIcon Create logos
;https://www.bitbug.net/ Create icons
;http://www.ico51.cn/ Convert icons

脚本图标 := 0
global cfx := 0
global cfy := 0
global cfw := 1600
global cfh := 900
global CF_Now := New CF_Game_Status ;初始化显示游戏状态

;加载真正的屏幕大小,即使在UHD放大情况下
VarSetCapacity(Screen_Info, 156)
DllCall("EnumDisplaySettingsA", "Ptr", 0, "UInt", -1, "UInt", &Screen_Info) ;真实分辨率
global Mon_Width := NumGet(Screen_Info, 108, "Int")
global Mon_Hight := NumGet(Screen_Info, 112, "Int")
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
    #InstallMouseHook                ;强制无条件安装鼠标钩子
    #InstallKeybdHook                ;强制无条件安装键盘钩子
    ListLines, Off                   ;不显示最近执行的脚本行
    SendMode, Input                  ;使用更速度和可靠方式发送键鼠点击
    SetWorkingDir, %A_ScriptDir%     ;保证一致的脚本起始工作目录
    Process, Priority, , A           ;进程高于一般优先级
    SetBatchLines, -1                ;全速运行,且因为全速运行,部分代码不得不调整
    SetKeyDelay, -1, -1              ;设置每次Send和ControlSend发送键击后无延时
    SetMouseDelay, -1                ;设置每次鼠标移动或点击后无延时
    SetDefaultMouseSpeed, 0          ;设置移动鼠标速度时默认使用最快速度
    SetWinDelay, -1                  ;全速执行窗口命令
    SetControlDelay, -1              ;控件修改命令全速执行

    global 脚本图标
    If !FileExist("火线图标.dll")
    {
        MsgBox, 262160, 错误/Error, 图标文件丢失!!!`nIcon file lost!!!
        ExitApp
    }

    Switch Script_Icon
    {
        Case "断":
            脚本图标 := 2
            Menu, Tray, Tip, 火线一键限速

        Case "控":
            脚本图标 := 3
            Menu, Tray, Tip, 火线助手控制

        Case "身":
            脚本图标 := 4
            Menu, Tray, Tip, 火线基础身法

        Case "压":
            脚本图标 := 5
            Menu, Tray, Tip, 火线基础压枪

        Case "尽":
            脚本图标 := 6
            Menu, Tray, Tip, 火线无尽挂机

        Case "猎":
            脚本图标 := 7
            Menu, Tray, Tip, 火线战斗猎手

        Case "火":
            脚本图标 := 8
            Menu, Tray, Tip, 火线自动开火

        Case "点":
            脚本图标 := 9
            Menu, Tray, Tip, 火线连点助手
    }
    Menu, Tray, NoStandard
    Menu, Tray, Add, 关于, About
    Menu, Tray, Icon, 关于, 火线图标.dll, 1, 20
    Menu, Tray, Default, 关于
    Menu, Tray, Click, 1
    Menu, Tray, Icon, 火线图标.dll, %脚本图标%, 1
    Menu, Tray, Add, 重新加载, Re_load
    Menu, Tray, Icon, 重新加载, 火线图标.dll, 11, 20
    Menu, Tray, Add, 退出辅助, Exit_Script
    Menu, Tray, Icon, 退出辅助, 火线图标.dll, 10, 20
    Menu, Tray, Color, 0x00FFFF
}
;==================================================================================
;检查脚本执行权限,只有以管理员权限或以UI Access运行才能正常工作
CheckPermission(SectionName := "助手控制")
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

    FileRead, Output_Data, 助手数据.ini
    If ErrorLevel
        FileAppend, ########助手进程ID########, 助手数据.ini, UTF-16 ;创建一个新ini文件

    If Not (CheckAdmin(SectionName) || CheckUIA(SectionName))
    {
        Try
        {
            If A_IsCompiled ;编译时请用加密减少侦测几率
                Run, *RunAs "%A_ScriptFullPath%" ;管理员权限运行
            Else
            {
                MsgBox, 262148, 警告/Warning, 请问你开启UIA了吗?`nDo you have UIAccess enabled?
                IfMsgBox, Yes
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
        memory_used := GetProcessMemoryInMB(process_id)
        IniRead, LAST_PID, 助手数据.ini, %SectionName%, PID
        IniWrite, %LAST_PID%, 助手数据.ini, %SectionName%, LASTPID
        IniWrite, %process_id%, 助手数据.ini, %SectionName%, PID
        IniWrite, %memory_used%, 助手数据.ini, %SectionName%, MEMORY
        Return True
    }
    Return False
}
;==================================================================================
;检查脚本是否由指定的UIA权限运行
CheckUIA(SectionName)
{
    process_id := ProcessInfo_GetCurrentProcessID()
    process_name := GetProcessName(process_id)
    memory_used := GetProcessMemoryInMB(process_id)
    If InStr(process_name, "AutoHotkeyU64_UIA.exe")
    {
        IniRead, LAST_PID, 助手数据.ini, %SectionName%, PID
        IniWrite, %LAST_PID%, 助手数据.ini, %SectionName%, LASTPID
        IniWrite, %process_id%, 助手数据.ini, %SectionName%, PID
        IniWrite, %memory_used%MB, 助手数据.ini, %SectionName%, MEMORY
        Return True
    }
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
    If (hProcess := DllCall("OpenProcess", "Uint", 0x0410, "Int", 0, "Uint", ProcessID, "Ptr"))
    {
        size := VarSetCapacity(buf, 0x0104 << 1, 0)
        If (DllCall("psapi\GetModuleFileNameEx", "Ptr", hProcess, "Ptr", 0, "Ptr", &buf, "Uint", size))
            Return StrGet(&buf), DllCall("CloseHandle", "Ptr", hProcess)
        DllCall("CloseHandle", "Ptr", hProcess)
    }
    Return False
}
;==================================================================================
;拷贝自jNizM的htopmini.ahk v0.8.3,单位MB,精度两位小数
GetProcessMemoryInMB(PID)
{
    pu := "", memory_usage := ""
    hProcess := DllCall("OpenProcess", "UInt", 0x001F0FFF, "UInt", 0, "UInt", PID)
    if (hProcess)
    {
        static PMCEX, size := (A_PtrSize = 8 ? 80 : 44), init := VarSetCapacity(PMCEX, size, 0) && NumPut(size, PMCEX)
        if (DllCall("K32GetProcessMemoryInfo", "Ptr", hProcess, "UInt", &PMCEX, "UInt", size))
        {
            pu := { 10 : NumGet(PMCEX, (A_PtrSize = 8 ? 72 : 40), "Ptr") }
        }
        DllCall("CloseHandle", "Ptr", hProcess)
    }
    memory_usage := Round(pu[10] / (1024 ** 2), 2)
    return memory_usage
}
;==================================================================================
;检查游戏界面真正位置,不包括标题栏和边缘等等,既Client位置
CheckPosition(ByRef Xcp, ByRef Ycp, ByRef Wcp, ByRef Hcp, class_name)
{
    WinGet, CFID, ID, ahk_class %class_name%

    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "Ptr", CFID, "Ptr", &rect) ;内在宽高
    Wcp := NumGet(rect, 8, "Int")
    Hcp := NumGet(rect, 12, "Int")

    VarSetCapacity(WINDOWINFO, 60, 0)
    DllCall("GetWindowInfo", "Ptr", CFID, "Ptr", &WINDOWINFO) ;内在XY
    Xcp := NumGet(WINDOWINFO, 20, "Int")
    Ycp := NumGet(WINDOWINFO, 24, "Int")

    If InStr(class_name, "CrossFire")
    {
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
}
;==================================================================================
;检查进程是否存在
ProcessExist(Process_Name)
{
    Process, Exist, %Process_Name%
    Return ErrorLevel
}
;==================================================================================
;检测是否不在游戏中,目标为界面左上角以及界面顶端中部
In_Game(CF_Title)
{
    ;-1为既不在主界面也不在游戏房间内的状态
    ;0为主界面状态,可见左上角穿越火线字样
    ;1为游戏中状态,可见正上方x:x字样,包括生化/团竞/爆破模式
    ;2为游戏中状态,可见正上方x:x字样或者黑幕,专为挑战模式
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    Load_000000 := Create_000000_png()
    If CF_Title = 穿越火线
    {
        PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + W1 // 4, Y1 + H1 // 9, 0x7A91B1, 0, Fast ;show color in editor: #B1917A #7A91B1
        If !ErrorLevel
        {
            PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + W1 // 4, Y1 + H1 // 9, 0x4B4341, 0, Fast ;show color in editor: #41434B #4B4341
            If !ErrorLevel
            {
                PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + W1 // 4, Y1 + H1 // 9, 0x676665, 0, Fast ;show color in editor: #656667 #676665
                If !ErrorLevel
                    Return 0 ;在游戏开始界面
            }
        }

        ImageSearch, OutputVarX, OutputVarY, X1, Y1, X1 + W1, Y1 + H1, HBITMAP:*%Load_000000% ;#000000 160*90
        If !ErrorLevel
            Return 2 ;无尽挑战黑暗中

        PixelSearch, OutputVarX, OutputVarY, X1 + W1 // 2 - W1 // 8, Y1, X1 + W1 // 2 + W1 // 8, Y1 + H1 // 18, 0x89876C, 0, Fast ;#6C8789 #89876C
        If !ErrorLevel
            Return 1 ;非挑战房间中

        PixelSearch, OutputVarX, OutputVarY, X1 + W1 // 2 - W1 // 8, Y1, X1 + W1 // 2 + W1 // 8, Y1 + H1 // 18, 0xBDBDBD, 0, Fast ;#BDBDBD
        If !ErrorLevel
            Return 1 ;个人竞技

        PixelSearch, OutputVarX, OutputVarY, X1 + W1 // 2 - W1 // 8, Y1, X1 + W1 // 2 + W1 // 8, Y1 + H1 // 18, 0xEBE6CA, 0, Fast ;#CAE6EB #EBE6CA
        If !ErrorLevel
            Return 2 ;挑战房间中

        PixelSearch, OutputVarX, OutputVarY, X1 + W1 // 2 - W1 // 8, Y1, X1 + W1 // 2 + W1 // 8, Y1 + H1 // 18, 0xB6B6B6, 0, Fast ;#B6B6B6
        If !ErrorLevel
            Return 1 ;人机爆破

        Return -1 ;不在房间也不在活跃主界面也不是黑暗视觉
    }
    Else If CF_Title = CROSSFIRE
    {
        PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + W1 // 4, Y1 + H1 // 9, 0x959B95, 0, Fast ;show color in editor: #959B95
        If !ErrorLevel
        {
            PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + W1 // 4, Y1 + H1 // 9, 0x3C4B61, 0, Fast ;show color in editor: #614B3C #3C4B61
            If !ErrorLevel
            {
                PixelSearch, OutputVarX, OutputVarY, X1, Y1, X1 + W1 // 4, Y1 + H1 // 9, 0x4B53F4, 0, Fast ;show color in editor: #F4534B #4B53F4
                If !ErrorLevel
                    Return 0 ;在游戏开始界面
            }
        }

        ImageSearch, OutputVarX, OutputVarY, X1, Y1, X1 + W1, Y1 + H1, HBITMAP:*%Load_000000% ;#000000 160*90
        If !ErrorLevel
            Return 2 ;无尽挑战黑暗中

        PixelSearch, OutputVarX, OutputVarY, X1 + W1 // 2 - W1 // 6, Y1, X1 + W1 // 2 + W1 // 6, Y1 + H1 // 18, 0x89876C, 0, Fast ;#6C8789 #89876C
        If !ErrorLevel
            Return 1 ;非挑战房间中

        PixelSearch, OutputVarX, OutputVarY, X1 + W1 // 2 - W1 // 8, Y1, X1 + W1 // 2 + W1 // 8, Y1 + H1 // 18, 0xBDBDBD, 0, Fast ;#BDBDBD
        If !ErrorLevel
            Return 1 ;个人竞技

        PixelSearch, OutputVarX, OutputVarY, X1 + W1 // 2 - W1 // 6, Y1, X1 + W1 // 2 + W1 // 6, Y1 + H1 // 18, 0xEBE6CA, 0, Fast ;#CAE6EB #EBE6CA
        If !ErrorLevel
            Return 2 ;挑战房间中

        PixelSearch, OutputVarX, OutputVarY, X1 + W1 // 2 - W1 // 6, Y1, X1 + W1 // 2 + W1 // 6, Y1 + H1 // 18, 0xB6B6B6, 0, Fast ;#B6B6B6
        If !ErrorLevel
            Return 1 ;人机爆破

        Return -1 ;不在房间也不在活跃主界面
    }
}
;==================================================================================
;检测点位颜色状态(颜色是否在颜色库中)
GetColorStatus(X, Y, color_lib)
{
    PixelGetColor, color_got, X, Y
    Return InStr(color_lib, color_got)
}
;==================================================================================
;鼠标左右键按下(SendInput方式)
mouse_sendinput_down(key_name := "LButton")
{
    If !Instr(key_name, "Button")
        Return False
    StructSize := A_PtrSize + 4*4 + A_PtrSize*2
    WhichDown := Instr(key_name, "L") ? 0x0002 : 0x0008
    ;MOUSEEVENTF_LEFTDOWN := 0x0002, MOUSEEVENTF_RIGHTDOWN := 0x0008
    VarSetCapacity(Key_Down, StructSize)
    NumPut(0, Key_Down, "UInt") ;4 bit
    NumPut(0, Key_Down, A_PtrSize, "UInt")
    NumPut(0, Key_Down, A_PtrSize + 4, "UInt")
    NumPut(WhichDown, Key_Down, A_PtrSize + 4*3, "UInt")
    DllCall("SendInput", "UInt", 1, "Ptr", &Key_Down, "Int", StructSize)
    VarSetCapacity(Key_Down, 0) ;释放内存
}
;==================================================================================
;鼠标左右键抬起(SendInput方式)
mouse_sendinput_up(key_name := "LButton")
{
    If !Instr(key_name, "Button")
        Return False
    StructSize := A_PtrSize + 4*4 + A_PtrSize*2
    WhichDown := Instr(key_name, "L") ? 0x0004 : 0x0010
    ;MOUSEEVENTF_LEFTUP := 0x0004, MOUSEEVENTF_RIGHTUP := 0x0010
    VarSetCapacity(Key_Up, StructSize)
    NumPut(0, Key_Up, "UInt") ;4 bit
    NumPut(0, Key_Up, A_PtrSize, "UInt")
    NumPut(0, Key_Up, A_PtrSize + 4, "UInt")
    NumPut(WhichDown, Key_Up, A_PtrSize + 4*3, "UInt")
    DllCall("SendInput", "UInt", 1, "Ptr", &Key_Up, "Int", StructSize)
    VarSetCapacity(Key_Up, 0) ;释放内存
}
;==================================================================================
;鼠标相对移动(SendInput方式)
mouse_sendinput_xy(x2, y2, Absolute := False)
{
    global Mon_Width, Mon_Hight
    ;绝对坐标从0~65535,所以我们要转换到像素坐标
    static SysX, SysY
    SysX := 65535 // Mon_Width, SysY := 65535 // Mon_Hight
    static INPUT_MOUSE := 0, MOUSEEVENTF_MOVE := 0x0001, MOUSEEVENTF_ABSOLUTEMOVE := 0x8001
    Origin_Status := SPI_GETMOUSE(), PrevSpeed := SPI_GETMOUSESPEED()
    StructSize := A_PtrSize + 4*4 + A_PtrSize*2
    VarSetCapacity(MouseInput_Move, StructSize)
    NumPut(INPUT_MOUSE, MouseInput_Move, "UInt")

    If Absolute
        x2 *= SysX, y2 *= SysY
    Else
    {
        DPI_Ratio := Round(A_ScreenDPI / 96, 3)
        x2 := (x2 != 0) ? (x2 / Abs(x2) * Ceil(Abs(x2) / DPI_Ratio)) : 0
        y2 := (y2 != 0) ? (y2 / Abs(y2) * Ceil(Abs(y2) / DPI_Ratio)) : 0

        Random, RandXY, -1, 1
        If (x2 = 0) && (y2 > 2)
            x1 := RandXY
        Else If (y2 = 0) && (x2 > 2)
            y2 := RandXY
    }

    NumPut(x2, MouseInput_Move, A_PtrSize, "UInt")
    NumPut(y2, MouseInput_Move, A_PtrSize + 4, "UInt")
    If Absolute
        NumPut(MOUSEEVENTF_ABSOLUTEMOVE, MouseInput_Move, A_PtrSize + 4*3, "UInt")
    Else
        NumPut(MOUSEEVENTF_MOVE, MouseInput_Move, A_PtrSize + 4*3, "UInt")

    If Origin_Status
        SPI_SETMOUSE(0)
    If PrevSpeed != 10
        SPI_SETMOUSESPEED()

    DllCall("SendInput", "UInt", 1, "Ptr", &MouseInput_Move, "Int", StructSize)
    VarSetCapacity(MouseInput_Move, 0) ;释放内存

    If Origin_Status
        SPI_SETMOUSE(1)
    If PrevSpeed != 10
        SPI_SETMOUSESPEED(PrevSpeed)
}
;==================================================================================
;鼠标左右键按下
mouse_down(key_name := "LButton", sendinput_method := True)
{
    If sendinput_method
    {
        mouse_sendinput_down(key_name)
        Return
    }
    If !Instr(key_name, "Button")
        Return False
    Switch key_name
    {
        Case "LButton": DllCall("mouse_event", "UInt", 0x02) ;左键按下
        Case "RButton": DllCall("mouse_event", "UInt", 0x08) ;右键按下
    }
}
;==================================================================================
;鼠标左右键抬起
mouse_up(key_name := "LButton", sendinput_method := True)
{
    If sendinput_method
    {
        mouse_sendinput_up(key_name)
        Return
    }
    If !Instr(key_name, "Button")
        Return False
    Switch key_name
    {
        Case "LButton": DllCall("mouse_event", "UInt", 0x04) ;左键弹起
        Case "RButton": DllCall("mouse_event", "UInt", 0x10) ;右键弹起
    }
}
;==================================================================================
;控制鼠标尽量精确上下左右相对/绝对移动,减少大幅度纵横直线移动的几率以避免16-2
mouseXY(x1, y1, Absolute := False, sendinput_method := True)
{
    If sendinput_method
    {
        mouse_sendinput_xy(x1, y1, Absolute)
        Return
    }
    global Mon_Width, Mon_Hight
    ;绝对坐标从0~65535,所以我们要转换到像素坐标
    static SysX, SysY
    SysX := 65535 // Mon_Width, SysY := 65535 // Mon_Hight
    static MOUSEEVENTF_MOVE := 0x0001, MOUSEEVENTF_ABSOLUTEMOVE := 0x8000
    dwFlags := (!Absolute ? MOUSEEVENTF_MOVE : MOUSEEVENTF_ABSOLUTEMOVE)
    Origin_Status := SPI_GETMOUSE()
    PrevSpeed := SPI_GETMOUSESPEED()

    If Absolute
        x1 *= SysX, y1 *= SysY
    Else
    {
        DPI_Ratio := Round(A_ScreenDPI / 96, 3)
        x1 := (x1 != 0) ? (x1 / Abs(x1) * Ceil(Abs(x1) / DPI_Ratio)) : 0
        y1 := (y1 != 0) ? (y1 / Abs(y1) * Ceil(Abs(y1) / DPI_Ratio)) : 0

        Random, RandXY, -1, 1
        If (x1 = 0) && (y1 > 2)
            x1 := RandXY
        Else If (y1 = 0) && (x1 > 2)
            y1 := RandXY
    }

    If Origin_Status
        SPI_SETMOUSE(0)
    If PrevSpeed != 10
        SPI_SETMOUSESPEED()

    DllCall("mouse_event", "UInt", dwFlags, "Int", x1, "Int", y1, "UInt", 0, "Int", 0)

    If Origin_Status
        SPI_SETMOUSE(1)
    If PrevSpeed != 10
        SPI_SETMOUSESPEED(PrevSpeed)
}
;==================================================================================
;获取鼠标移动速度
SPI_GETMOUSESPEED()
{
    PrevSpeed :=
    DllCall("SystemParametersInfo", "UInt", 0x70, "UInt", 0, "UIntP", PrevSpeed, "UInt", 0)
    Return PrevSpeed
}
;==================================================================================
;设置鼠标移动速度
SPI_SETMOUSESPEED(MOUSESPEED := 10)
{
    DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "Ptr", MOUSESPEED, "UInt", 0)
}
;==================================================================================
;检测鼠标加速状态,拷贝自 https://autohotkey.com/board/topic/43700-mouse-acceleration-onoff/
SPI_GETMOUSE()
{
    VarSetCapacity(SpeedValue, 12)
    If !DllCall("SystemParametersInfo", "Uint", 3, "Uint", 0, "Uint", &SpeedValue, "Uint", 0)
        Return False ;失败
    Return NumGet(SpeedValue, 4) ;最大临界点
}
;==================================================================================
;设置鼠标加速,拷贝自 https://autohotkey.com/board/topic/43700-mouse-acceleration-onoff/
;fWinIni:(0),(1:更新用户资料),(2:通知程序),(3:1与2)
SPI_SETMOUSE(accel, low := "", high := "", fWinIni := 0)
{
    VarSetCapacity(SpeedValue, 12)
    , NumPut(accel
    , NumPut(high != "" ? high : accel ? 10 : 0
    , NumPut(low != "" ? low : accel ? 6 : 0, SpeedValue)))
    Return 0 != DllCall("SystemParametersInfo", "Uint", 4, "Uint", 0, "Uint", &SpeedValue, "Uint", 0)
}
;==================================================================================
;键位按下(SendInput方式)
key_sendinput_down(key_name)
{
    static INPUT_KEYBOARD := 1, KEYEVENTF_KEYUP := 2, KEYEVENTF_SCANCODE := 8, InputSize := 16 + A_PtrSize*3
    Input_Index := (StrLen(key_name) == 1 && Ord(key_name) > 64 && Ord(key_name) < 91) ? 2 : 1
    VarSetCapacity(INPUTS, InputSize*Input_Index, 0)
    addr := &INPUTS, Scancode := GetKeySC(key_name)
    If Input_Index = 2
        addr := NumPut(0 | KEYEVENTF_SCANCODE | 0
                , NumPut(0x2A & 0xFF
                , NumPut(INPUT_KEYBOARD, addr + 0) + 2, "UShort"), "UInt" ) + 8 + A_PtrSize*2
    addr := NumPut(0 | KEYEVENTF_SCANCODE | 0
            , NumPut(Scancode & 0xFF
            , NumPut(INPUT_KEYBOARD, addr + 0) + 2, "UShort"), "UInt" ) + 8 + A_PtrSize*2
    DllCall("SendInput", "UInt", Input_Index, "Ptr", &INPUTS, "Int", InputSize)
    VarSetCapacity(INPUTS, 0) ;释放内存
}
;==================================================================================
;键位弹起(SendInput方式)
key_sendinput_up(key_name)
{
    static INPUT_KEYBOARD := 1, KEYEVENTF_KEYUP := 2, KEYEVENTF_SCANCODE := 8, InputSize := 16 + A_PtrSize*3
    Input_Index := (StrLen(key_name) == 1 && Ord(key_name) > 64 && Ord(key_name) < 91) ? 2 : 1
    VarSetCapacity(INPUTS, InputSize*Input_Index, 0)
    addr := &INPUTS, Scancode := GetKeySC(key_name)
    If Input_Index = 2
        addr := NumPut(2 | KEYEVENTF_SCANCODE | 0
                , NumPut(0x2A & 0xFF
                , NumPut(INPUT_KEYBOARD, addr + 0) + 2, "UShort"), "UInt" ) + 8 + A_PtrSize*2
    addr := NumPut(2 | KEYEVENTF_SCANCODE | 0
            , NumPut(Scancode & 0xFF
            , NumPut(INPUT_KEYBOARD, addr + 0) + 2, "UShort"), "UInt" ) + 8 + A_PtrSize*2
    DllCall("SendInput", "UInt", Input_Index, "Ptr", &INPUTS, "Int", InputSize)
    VarSetCapacity(INPUTS, 0) ;释放内存
}
;==================================================================================
;键位按下
key_down(key_name, sendinput_method := True)
{
    If sendinput_method
    {
        key_sendinput_down(key_name)
        Return
    }
    If StrLen(key_name) == 1
    {
        If (Ord(key_name) > 64 && Ord(key_name) < 91)
            DllCall("keybd_event", "Int", 16, "Int", 42, "Int", 0, "Int", 0) ;Shift
    }
    VirtualKey := GetKeyVK(key_name)
    ScanCode := GetKeySC(key_name)
    DllCall("keybd_event", "Int", VirtualKey, "Int", ScanCode, "Int", 0, "Int", 0)
}
;==================================================================================
;键位弹起
key_up(key_name, sendinput_method := True)
{
    If sendinput_method
    {
        key_sendinput_up(key_name)
        Return
    }
    If StrLen(key_name) == 1
    {
        If (Ord(key_name) > 64 && Ord(key_name) < 91)
            DllCall("keybd_event", "Int", 16, "Int", 42, "Int", 2, "Int", 0) ;Shift
    }
    VirtualKey := GetKeyVK(key_name)
    ScanCode := GetKeySC(key_name)
    DllCall("keybd_event", "Int", VirtualKey, "Int", ScanCode, "Int", 2, "Int", 0)
}
;==================================================================================
;按键函数,鉴于Input模式下单纯的send速度不合要求而开发
press_key(key_name, press_time, sleep_time, sendinput_method := True)
{
    ;本机鼠标延迟测试,包括按下弹起
    If InStr(key_name, "Button")
        press_time -= 0.56, sleep_time -= 0.56
    Else
        press_time -= 0.24, sleep_time -= 0.24

    If !GetKeyState(key_name)
    {
        If InStr(key_name, "Button")
            sendinput_method ? mouse_sendinput_down(key_name) : mouse_down(key_name)
        Else
            sendinput_method ? key_sendinput_down(key_name) : key_down(key_name)
    }
    HyperSleep(press_time)

    If !GetKeyState(key_name, "P")
    {
        If InStr(key_name, "Button")
            sendinput_method ? mouse_sendinput_up(key_name) : mouse_up(key_name)
        Else
            sendinput_method ? key_sendinput_up(key_name) : key_up(key_name)
    }
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
    Else If InStr("L", GuiPosition) ;左下角显示
    {
        XGui := X1 + OffsetX
        YGui := Y1 + H1 + OffsetY
    }
    Else If InStr("_", GuiPosition) ;下方显示
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + H1 + OffsetY
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
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", tick)
    Return tick / freq * 1000
}
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度睡眠
HyperSleep(value)
{
    If value <= 0.0
        Return
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
;学习自AHK论坛中的多脚本间通过端口简单通信函数,接受信息
ReceiveMessage(Message)
{
    Switch Message
    {
        Case 125638:
            ExitApp ;退出当前脚本

        Case 109999:
            CF_Now.SetStatus(-1)

        Case 110000:
            CF_Now.SetStatus(0)

        Case 110001:
            CF_Now.SetStatus(1)

        Case 110002:
            CF_Now.SetStatus(2)

        Case 110003:
            CF_Now.SetHuman(1)

        Case 110004:
            CF_Now.SetHuman(0)

        Case 110005:
            CF_Now.Set无尽(1)

        Case 110006:
            CF_Now.Set无尽(0)
    }
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
;学习自AHK论坛中的多脚本间通过端口简单通信函数,发送信息
PostStatus(Message)
{
    SetTitleMatchMode, 3
    DetectHiddenWindows, On

    IniRead, PID1, 助手数据.ini, 一键限网, PID
    IniRead, PID2, 助手数据.ini, 基础压枪, PID
    IniRead, PID3, 助手数据.ini, 基础身法, PID
    IniRead, PID4, 助手数据.ini, 战斗猎手, PID
    IniRead, PID5, 助手数据.ini, 自动开火, PID
    IniRead, PID6, 助手数据.ini, 连点助手, PID
    IniRead, PID7, 助手数据.ini, 无尽挂机, PID

    Loop, 7
    {
        CurrentPID := PID%A_Index%
        If CurrentPID != ERROR
            PostMessage, 0x1002, %Message%, , , ahk_pid %CurrentPID%
    }
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,发送信息
PostBack(Message)
{
    SetTitleMatchMode, 3
    DetectHiddenWindows, On
    IniRead, PID0, 助手数据.ini, 助手控制, PID
    If PID0 != ERROR
        PostMessage, 0x1003, %Message%, , , ahk_pid %PID0%
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
    Return False
}
;==================================================================================
;复制自VxE的函数,转换10进制整数为16进制,"pad"变量可能是应该出现在0x右侧的最小位数
DecToHex(int, pad := 0)
{
	Static hx := "0123456789ABCDEF"
	If !(0 < int |= 0)
		Return !int ? "0x0" : "-" DecToHex(-int, pad)
	s := 1 + Floor(Ln(int) / Ln(16))
	h := SubStr("0x0000000000000000", 1, pad := pad < s ? s + 2 : pad < 16 ? pad + 2 : 18)
	u := A_IsUnicode = 1
	Loop % s
		NumPut(*(&hx + ((int & 15) << u)), h, pad - A_Index << u, "UChar"), int >>= 4
	Return h
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
    static thanks, timenow
    FormatTime, show_time
    Gui, icon_about: New, +LastFound +AlwaysOnTop -DPIScale +Border, 关于
    Gui, icon_about: Color, 333333 ;#333333
    Gui, icon_about: Add, Picture, icon12, 火线图标.dll ;512*512
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
    global 脚本图标

    If A_IsSuspended
    {
        ToolTip, 禁用热键, , , 20
        Menu, Tray, Icon, 火线图标.dll, 1
    }
    Else
    {
        ToolTip, , , , 20
        Menu, Tray, Icon, 火线图标.dll, %脚本图标%
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
    PixelSearch, chatx, chaty, controlX, controlY + controlH // 1.67, controlX + controlW // 16, controlY + controlH // 1.2, %Chat_Color%, 0, Fast
    If !ErrorLevel
        Return True
    Return False
}
;==================================================================================
;返回游戏状态
class CF_Game_Status
{
    ;-1为既不在主界面也不在游戏房间内的状态
    ;0为主界面状态,可见左上角穿越火线字样
    ;1为游戏中状态,可见正上方x:x字样,包括生化/团竞/爆破模式
    ;2为游戏中状态,可见正上方x:x字样或者黑幕,专为挑战模式

    __New()
    {
        this.status := 0
        this.Human := False
        this.无尽 := False
    }

    SetStatus(newvar)
    {
        If this.status != newvar
            this.status := newvar
        If newvar <= 0
            this.Human := False
    }

    GetStatus()
    {
        Return this.status
    }

    SetHuman(newhuman)
    {
        If newhuman
            this.Human := True
        Else
            this.Human := False
    }

    GetHuman()
    {
        Return this.Human
    }

    Set无尽(无尽中)
    {
        If 无尽中
            this.无尽 := True
        Else
            this.无尽 := False
    }

    Get无尽()
    {
        Return this.无尽
    }
}
;==================================================================================
;##################################################################################
;# This #Include file was generated by Image2Include.ahk, you must not change it! #
;##################################################################################
Create_000000_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
    hBitmap := 0
If (hBitmap)
    Return hBitmap
VarSetCapacity(B64, 192 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAAKAAAABaCAIAAACwpMoFAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAQElEQVR42u3BAQ0AAADCoPdPbQ8HFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8GOpGgABnzC42wAAAABJRU5ErkJggg=="
DecLen := 0, pStream := "", pBitmap := "", pToken := ""
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
    Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
    Return False
; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}
;==================================================================================
;End