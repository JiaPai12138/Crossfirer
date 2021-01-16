;Functions for Crossfirer;CF娱乐助手函数集合
;==================================================================================
;检查脚本执行权限,只有以管理员权限或以UI Access运行才能正常工作
CheckPermission()
{
    If Not (A_IsAdmin || ProcessExist("AutoHotkeyU64_UIA.exe"))
    { ;缺点是当另一个脚本以UI Access运行时,该检查机制会被跳过
        Try
        {
            If A_IsCompiled
                Run, *RunAs "%A_ScriptFullPath%" ;管理员权限运行
            Else
            {
                MsgBox, 4, 警告/Warning, 请问你开启UIA了吗?`nDo you have UIAccess enabled?
                IfMsgBox Yes
                    Run, "%A_ProgramFiles%\AutoHotkey\AutoHotkeyU64_UIA.exe" "%A_ScriptFullPath%"
                Else
                    Run, *RunAs "%A_ScriptFullPath%"
            }
        }
        Catch
        {
            MsgBox,, 错误/Error, 未正确运行!脚本将退出!!`nUnable to start correctly!The script will exit!!
            ExitApp
        }
    }
}
;==================================================================================
;通过按下快捷键显示/隐藏提示
ShowHelp(ByRef Need_Help, XGui, YGui, Gui_Number)
{
    Need_Help := !Need_Help
    If Need_Help
        Gui, %Gui_Number%: Show, x%XGui% y%YGui% NA
    Else
        Gui, %Gui_Number%: Hide
} 
;==================================================================================
;检查进程是否存在
ProcessExist(Process_Name)
{
    Process, Exist, %Process_Name%
    Return Errorlevel
}
;==================================================================================
;切换自火开/关
ChangeMode(Gui_Number1, Gui_Number2, ModeID, StatusID, ByRef AutoMode, XGui1, YGui1, XGui2, YGui2, CrID, Xch, Ych)
{
    AutoMode := !AutoMode

    If AutoMode
    {
        UpdateText(Gui_Number1, ModeID, "加载模式", XGui1, YGui1)
        UpdateText(Gui_Number2, StatusID, "自火开启", XGui2, YGui2)
        Gui, %CrID%: Color, 00FF00 ;#00FF00
        Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
    }
    Else
    {
        UpdateText(Gui_Number1, ModeID, "暂停加载", XGui1, YGui1)
        UpdateText(Gui_Number2, StatusID, "自火关闭", XGui2, YGui2)
        Gui, %CrID%: Color, FFFF00 ;#FFFF00
        Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
    }
}
;==================================================================================
;自动开火函数,通过检测红名实现
AutoFire(mo_shi, Gui_Number1, Gui_Number2, ModeID, StatusID, game_title, XGui1, YGui1, XGui2, YGui2, CrID, Xch, Ych)
{
    WinGetPos, X1, Y1, W1, , ahk_class CrossFire
    static PosColor_snipe := "0x000000"
    ;show color in editor: #000000
    While, (True)
    {
        Var := W1 // 2 - 5 ;798
        UpdateText(Gui_Number2, StatusID, "搜寻敌人", XGui2, YGui2)
        Gui, %CrID%: Color, 00FFFF ;#00FFFF
        Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
        Loop
        {
            If ExitMode()
            {
                UpdateText(Gui_Number2, StatusID, "自火暂停", XGui2, YGui2)
                UpdateText(Gui_Number1, ModeID, "加载模式", XGui1, YGui1)
                Gui, %CrID%: Color, 00FF00 ;#00FF00
                Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
                Exit ;退出自动开火循环
            }
            
            While Shoot_Time(X1, Y1, Var, game_title) ;当红名被扫描到时射击
            {
                UpdateText(Gui_Number2, StatusID, "发现敌人", XGui2, YGui2)
                Random, rand, 60.4, 62.0 ;设定随机值减少被检测概率
                small_rand := rand / 2
                Switch mo_shi
                {
                    Case 2:
                        press_key("LButton", (rand - 10), (rand - 10)) ;控制USP射速
                        mouseXY(0, 1)
                        UpdateText(Gui_Number1, ModeID, "手枪模式", XGui1, YGui1)
                    Break

                    Case 8:
                        If Not (GetColorStatus(X1, Y1, 955, 483, PosColor_snipe) || GetColorStatus(X1, Y1, 804, 600, PosColor_snipe)) ;检测狙击镜准心
                        {
                            press_key("RButton", small_rand, small_rand)
                            press_key("LButton", small_rand, small_rand)
                        }
                        Else
                            press_key("LButton", small_rand, small_rand)
                        ;开镜瞬狙或连狙
                        UpdateText(Gui_Number1, ModeID, "瞬狙模式", XGui1, YGui1)
                        HyperSleep(rand)
                    Break

                    Case 111:
                        press_key("LButton", 60.4, 30.2) ;用定值保证加特林速点稳定
                        UpdateText(Gui_Number1, ModeID, "连发速点", XGui1, YGui1)
                    Break
                    
                    Default: ;通用模式不适合射速高的冲锋枪
                        press_key("LButton", small_rand, small_rand)
                        mouseXY(0, 1)
                        UpdateText(Gui_Number1, ModeID, "通用模式", XGui1, YGui1)
                    Break
                }
            }
            Var += 1
        } Until, Var > (W1 // 2 + 5) ;808
        ;HyperSleep(1) ;减少工作频率,但似乎不需要
    }
}
;==================================================================================
;检测是否不再游戏中
Not_In_Game() 
{
    WinGetPos, X1, Y1,,, ahk_class CrossFire
    static PosColor_edge := "0x232323 0x101010 0x0F0F0F 0x070707 0x2F2F31 0x2A2A2A 0x4C4741 0x4C4841 0x4C4941"
    ;show color in editor: #232323 #101010 #0F0F0F #070707 #2F2F31 #2A2A2A #4C4741 #4C4841 #4C4941
    Return GetColorStatus(X1, Y1, 1220, 52, PosColor_edge)
}
;==================================================================================
;检测开火时机,既扫描红名位置
Shoot_Time(X, Y, Var, game_title) 
{
    static PosColor_red := "0x353796 0x353797 0x353798 0x353799 0x343799 0x34379A 0x34389A 0x34389B 0x34389C 0x33389C 0x33389D 0x33389E 0x33389F 0x32389F 0x32399F 0x3239A0 0x3239A1 0x3239A2 0x3139A2 0x3139A3 0x3139A4 0x313AA4 0x313AA5 0x303AA5 0x303AA6 0x303AA7 0x303AA8 0x2F3AA8 0x2F3AA9 0x2F3BA9 0x2F3BAA 0x2F3BAB 0x2E3BAB 0x2E3BAC 0x2E3BAD 0x2E3BAE 0x2E3CAE 0x2D3CAE 0x2D3CAF 0x2D3CB0 0x2D3CB1 0x2C3CB1 0x2C3CB2 0x2C3CB3 0x2C3DB3 0x2C3DB4 0x2B3DB4 0x2B3DB5 0x2B3DB6 0x2B3DB7 0x2A3DB7 0x2A3EB7 0x2A3EB8 0x2A3EB9 0x2A3EBA 0x293EBA 0x293EBB 0x293EBC 0x293FBC 0x293FBC 0x293FBD 0x283FBD 0x283FBE 0x283FBF 0x283FC0 0x273FC0 0x273FC1 0x2740C1 0x2740C2 0x2740C3 0x2640C4 0x2640C5 0x2640C6 0x2641C6 0x2641C7 0x2541C7 0x2541C8 0x2541C9 0x2541CA 0x2441CA 0x2441CB 0x2442CB 0x2442CC 0x2442CD 0x2342CD 0x2342CE 0x2342CF 0x2342D0 0x2343D0 0x2243D0 0x2243D1 0x2243D2 0x2243D3 0x2143D3 0x2143D4 0x2144D4 0x2144D5 0x2144D6 0x2044D6 0x2044D7 0x2044D8 0x2044D9 0x1F44D9 0x1F45D9 0x1F45DA 0x1F45DB 0x1F45DC 0x1E45DC 0x1E45DD 0x1E45DE 0x1E46DE 0x1E46DF 0x1D46DF 0x1D46E0 0x1D46E1 0x1D46E2 0x1C46E2 0x1C46E3 0x1C47E3 0x1C47E4 0x1C47E5 0x1B47E5 0x1B47E6 0x1B47E7 0x1B47E8 0x1B48E8 0x1A48E8 0x1A48E9 0x1A48EA 0x1A48EB 0x1948EB 0x1948EC 0x1948ED 0x1949ED 0x1949EE 0x1849EE 0x1849EF 0x1849F0 0x1849F1 0x174AF2" ;国内版的红名显示随时间变化,这里记录了几乎所有的颜色元素
    ;show color in editor: #353796 #353797 #353798 #353799 #343799 #34379A #34389A #34389B #34389C #33389C #33389D #33389E #33389F #32389F #32399F #3239A0 #3239A1 #3239A2 #3139A2 #3139A3 #3139A4 #313AA4 #313AA5 #303AA5 #303AA6 #303AA7 #303AA8 #2F3AA8 #2F3AA9 #2F3BA9 #2F3BAA #2F3BAB #2E3BAB #2E3BAC #2E3BAD #2E3BAE #2E3CAE #2D3CAE #2D3CAF #2D3CB0 #2D3CB1 #2C3CB1 #2C3CB2 #2C3CB3 #2C3DB3 #2C3DB4 #2B3DB4 #2B3DB5 #2B3DB6 #2B3DB7 #2A3DB7 #2A3EB7 #2A3EB8 #2A3EB9 #2A3EBA #293EBA #293EBB #293EBC #293FBC #293FBC #293FBD #283FBD #283FBE #283FBF #283FC0 #273FC0 #273FC1 #2740C1 #2740C2 #2740C3 #2640C4 #2640C5 #2640C6 #2641C6 #2641C7 #2541C7 #2541C8 #2541C9 #2541CA #2441CA #2441CB #2442CB #2442CC #2442CD #2342CD #2342CE #2342CF #2342D0 #2343D0 #2243D0 #2243D1 #2243D2 #2243D3 #2143D3 #2143D4 #2144D4 #2144D5 #2144D6 #2044D6 #2044D7 #2044D8 #2044D9 #1F44D9 #1F45D9 #1F45DA #1F45DB #1F45DC #1E45DC #1E45DD #1E45DE #1E46DE #1E46DF #1D46DF #1D46E0 #1D46E1 #1D46E2 #1C46E2 #1C46E3 #1C47E3 #1C47E4 #1C47E5 #1B47E5 #1B47E6 #1B47E7 #1B47E8 #1B48E8 #1A48E8 #1A48E9 #1A48EA #1A48EB #1948EB #1948EC #1948ED #1949ED #1949EE #1849EE #1849EF #1849F0 #1849F1 #174AF2 
    static PosColor_NA_red := "0xF24A17 0x174AF2"
    ;show color in editor: #F24A17 #174AF2
    If game_title = CROSSFIRE ;检测客户端标题来确定检测位置和颜色库
        Return (GetColorStatus(X, Y, Var, 528, PosColor_NA_red) || GetColorStatus(X, Y, Var, 530, PosColor_NA_red) || GetColorStatus(X, Y, Var, 532, PosColor_NA_red))
    Else If game_title = 穿越火线
        Return (GetColorStatus(X, Y, Var, 538, PosColor_red) || GetColorStatus(X, Y, Var, 540, PosColor_red) || GetColorStatus(X, Y, Var, 542, PosColor_red))
}
;==================================================================================
;C4倒计时辅助,精度0.1s
C4Timer(XGuiC, YGuiC, ByRef C4_Start, ByRef C4_Time, Gui_Number, ControlID)
{
    WinGetPos, X1, Y1, , , ahk_class CrossFire
    If Is_C4_Time(X1, Y1)
    {
        If C4_Start = 0
            C4_Start := SystemTime()
        Else If C4_Start > 0
        {
            C4_Time := SubStr("00" . Format("{:.0f}", (40 - (SystemTime() - C4_Start) / 1000)), -1) ;强行显示两位数
            UpdateText(Gui_Number, ControlID, C4_Time, XGuiC, YGuiC)
        }
    }
    Else
    {
        If C4_Start > 0
            C4_Start := 0
        If C4_Time != 40
            C4_Time := 40
        UpdateText(Gui_Number, ControlID, C4_Time, XGuiC, YGuiC)
    }
}
;==================================================================================
;循环检测C4提示图标
Is_C4_Time(X, Y)
{
    static PosColor_C4 := "0xE39600 0x0096E3 0xE6A11A 0x1AA1E6 0xFBEFD8 0xD8EFFB 0x926000 0x006092 0x523600 0x003652"
    ;show color in editor: #E39600 #0096E3 #E6A11A #1AA1E6 #FBEFD8 #D8EFFB #926000 #006092 #523600 #003652
    Return (GetColorStatus(X, Y, 773, 161, PosColor_C4) || GetColorStatus(X, Y, 774, 161, PosColor_C4) || GetColorStatus(X, Y, 818, 162, PosColor_C4) || GetColorStatus(X, Y, 819, 162, PosColor_C4) || GetColorStatus(X, Y, 803, 155, PosColor_C4) || GetColorStatus(X, Y, 803, 166, PosColor_C4) || GetColorStatus(X, Y, 803, 162, PosColor_C4) || GetColorStatus(X, Y, 803, 174, PosColor_C4)) ;用更多点位保证检测到
}
;==================================================================================
;检测是否退出模式,由按键触发
ExitMode()
{
    Return (Not_In_Game() || GetKeyState("1", "P") || GetKeyState("Tab", "P") || GetKeyState("2", "P") || GetKeyState("3", "P") || GetKeyState("4", "P") || GetKeyState("J", "P") || GetKeyState("L", "P") || GetKeyState("`", "P") || GetKeyState("~", "P")) 
}
;==================================================================================
;检测点位颜色状态(颜色是否在颜色库中)
GetColorStatus(X, Y, CX1, CX2, color_lib)
{
    PixelGetColor, color_got, (X + CX1), (Y + CX2)
    Return InStr(color_lib, color_got)
}
;==================================================================================
;压枪函数,对相应枪械 均能基本压在一各扁团内
Recoilless(Gun_Chosen)
{
    If GetKeyState("LButton", "P") 
    {
        StartTime := SystemTime()
        EndTime := SystemTime() - StartTime
        Switch Gun_Chosen
        {
            Case 1: ;AK47英雄级
                While, EndTime < 100 && GetKeyState("LButton", "P")
                {
                    HyperSleep(40)
                    mouseXY(0, 1)
                    EndTime := SystemTime() - StartTime
                }
                While, EndTime >= 100 && EndTime < 300 && GetKeyState("LButton", "P")
                {
                    HyperSleep(28)
                    mouseXY(0, 2)
                    EndTime := SystemTime() - StartTime
                }
                While, EndTime >= 300 && EndTime < 500 && GetKeyState("LButton", "P")
                {
                    HyperSleep(36)
                    mouseXY(0, 3)
                    EndTime := SystemTime() - StartTime
                }
                While, EndTime >= 500 && EndTime < 800 && GetKeyState("LButton", "P")
                {
                    HyperSleep(30)
                    mouseXY(0, 1)
                    EndTime := SystemTime() - StartTime
                }
                While, EndTime >= 800 && GetKeyState("LButton", "P")
                {
                    HyperSleep(30)
                    EndTime := SystemTime() - StartTime 
                }

            Case 2: ;M4A1英雄级
                While, EndTime < 90 && GetKeyState("LButton", "P")
                {
                    HyperSleep(10)
                    EndTime := SystemTime() - StartTime
                }
                While, EndTime >= 90 && EndTime < 530 && GetKeyState("LButton", "P")
                {
                    HyperSleep(35)
                    mouseXY(0, 2)
                    EndTime := SystemTime() - StartTime 
                }
                While, EndTime >= 530 && GetKeyState("LButton", "P")
                {
                    HyperSleep(30)
                    EndTime := SystemTime() - StartTime
                }
            Default:
                HyperSleep(30)
        }
    }
    Return ;复原StartTime
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
    static t_accuracy := 0.991 ;本机精度测试
    press_time *= t_accuracy
    sleep_time *= t_accuracy
    Send, {%key% DownTemp}
    HyperSleep(press_time)
    Send, {Blind}{%key% up}
    HyperSleep(sleep_time)
}
;==================================================================================
;设置图形界面位置
SetGuiPosition(ByRef XGui, ByRef YGui, GuiPosition, OffsetX, OffsetY)
{
    WinGetPos, X1, Y1, W1, H1, ahk_class CrossFire
    If InStr("H", GuiPosition) ;顶部一栏横向
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + OffsetY
    }
    Else If InStr("V", GuiPosition) ;左侧一栏纵向
    {
        XGui := X1 + 2 + OffsetX
        YGui := Y1 + H1 // 2 + OffsetY
    }
    Else If InStr("M", GuiPosition) ;居中显示
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + (H1 + 35) // 2 + OffsetY
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
    If value < 5 ;相对高精度睡眠
    {
        DllCall("Winmm.dll\timeBeginPeriod", UInt, 1)
        DllCall("Sleep", "UInt", value)
        DllCall("Winmm.dll\timeEndPeriod", UInt, 1)
    }
    Else ;相对更高精度睡眠
    {
        begin_time := SystemTime()
        freq := 0, t_current := 0
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
	    t_tmp := (begin_time + value) * freq / 1000 
        While (t_current < t_tmp)
        {
            If (t_tmp - t_current) > 30000 ;减少CPU占用
            {
                DllCall("Sleep", "UInt", 1)
                DllCall("QueryPerformanceCounter", "Int64*", t_current)
            }
            Else
                DllCall("QueryPerformanceCounter", "Int64*", t_current)
        }
    }
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,接受信息
ReceiveMessage(Message) 
{
    if Message = 1
    ExitApp ;退出当前脚本,未来可加其他动作
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,发送信息
PostMessage(Receiver, Message) ;接受方为GUI标题
{
    SetTitleMatchMode, 3
    DetectHiddenWindows, on
    PostMessage, 0x1001, %Message%,,, %Receiver% ahk_class AutoHotkeyGUI
}
;==================================================================================
;End