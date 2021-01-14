#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#SingleInstance, force
#IfWinActive ahk_class CrossFire  ; Only active while crossfire is running
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
Process, Priority, , H  ;进程高优先级
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
;Please install Color Highlight extension in VScode, easier to observe colors
;Detect colors are all inverted as you see, I don't know if it is bug...
;==================================================================================
If not (A_IsAdmin || ProcessExist("AutoHotkeyU64_UIA.exe"))
{
    Try
    {
        If A_IsCompiled
            Run, *RunAs "%A_ScriptFullPath%"
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
;==================================================================================
crosshair = 34-35 2-35 2-36 34-36 34-60 35-60 35-36 67-36 67-35 35-35 ;35-11 34-11
global AutoMode := 0 ;on/off switch
global RunningMode := "加载模式"
global Fcn_Status := "脚本状态"
global Gun_Using := "暂未选枪械"
global Need_Help := False
global C4_Time := 40
global Gun_Chosen := 0
global NewText := "自动: " AutoMode "|" RunningMode "|" Fcn_Status "|" Gun_Using "|" C4_Time
global X, Y, W, H
global XGui1, YGui1, XGui2, YGui2, Xch, Ych
global cnt :=
global Temp_Mode := 0
global Temp_Run := ""
global game_title :=
global KX := -34 ;for crosshair
global KY := -20 ;for crosshair

If WinExist("ahk_class CrossFire")
{
    WinMinimize, ahk_class ConsoleWindowClass
    WinGetTitle, game_title, ahk_class CrossFire
    WinGetPos, X, Y, W, H, ahk_class CrossFire ;get top left position of the window
    global TempX := X, TempY := Y
    Start:
    Gui, 1: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, 1: Margin, 0, 0
    Gui, 1: Color, 333333
    Gui, 1: Font, s16, Verdana  
    Gui, 1: Add, Text, hwndGui_1 vMyText c00FF00, % NewText
    GuiControlGet, P1, Pos, %Gui_1%
    global P1W ;*= (A_ScreenDPI / 96)
    WinSet, TransColor, 000000 255
    WinSet, ExStyle, +0x20 ; 鼠标穿透

    Gui, 2: +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, 2: Margin, 0, 0
    Gui, 2: Color, 333333
    Gui, 2: Font, s12 c00FF00, Microsoft YaHei
    Gui, 2: add, Text, hwndGui_2, ╔====使用==说明===╗`n     按~==开关自火===`n     按234JLTab选择模式`n     按2===手枪模式==`n     按3/4= 关闭模式==`n     按J===狙击关镜==`n     按L===速点模式==`n     按Tab键=通用模式=`n================`n     鼠标中间键 右键连点`n     鼠标后退键 左键连点`n     按W和F== 基础鬼跳`n     按W和Alt= 空中跳蹲`n     按S和F===跳蹲上墙`n     按- =重新加载本脚本`n     大写锁定 最小化窗口`n╚====使用==说明===╝
    GuiControlGet, P2, Pos, %Gui_2%
    global P2H ;*= (A_ScreenDPI / 96)
    WinSet, TransColor, 333333 255
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    
    Gui, cross_hair: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Hwndcr -DPIScale
    Gui, cross_hair: Color, FFFF00

    SetGuiPosition()
    Gui, 1: Show, x%XGui1% y%YGui1% NA
    ShowHelp() ;Gui, 2: Show, x%XGui2% y%YGui2% NA
    Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    WinSet, Region, %crosshair%, ahk_id %cr%
    WinSet, Transparent, 255, ahk_id %cr%
    WinSet, ExStyle, +0x20 ; 鼠标穿透
} 
Else 
{
    MsgBox,, 错误/Error, CF未运行!脚本将退出!!`nCrossfire is not running!The script will exit!!
    ExitApp
}

#Persistent
;SetTimer, UpdateC4, 100 
HyperSleep(33.3) ;separate
;SetTimer, ShowMode, 100
HyperSleep(33.3)
SetTimer, UpdateGui, 100
Return
;==================================================================================
~*-::
    WinClose, ahk_class ConsoleWindowClass
    HyperSleep(10)
    Run, .\open_Crossfirer.bat
ExitApp

~*CapsLock Up:: ;minimize window 
    WinMinimize, ahk_class CrossFire
Return

~*LButton:: ;压枪 正在开发 游戏内鼠标灵敏度=32
    If (!AutoMode && Gun_Chosen > 0)
    {
        AssignValue("Fcn_Status", "手动开火")
        If GetKeyState("LButton", "P") 
        {
            StartTime := SystemTime()
            EndTime := SystemTime() - StartTime
            Switch Gun_Chosen
            {
                Case 1:
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

                Case 2:
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
    }
Return

~*Lbutton Up:: ;保障新一轮压枪
    If (!AutoMode && Gun_Chosen > 0)
    {
        StartTime := 
        EndTime := 
    }
Return

~*`::
    ChangeMode(1)
Return

~*1 Up::
    ChangeMode(2) ;Restore mode
    If (AutoMode && !Not_In_Game() && StrLen(Temp_Run) > 0)
    {
        AssignValue("RunningMode", Temp_Run)
        AutoFire(Temp_Mode)
    }
Return

~*2 Up::
    ChangeMode(2) ;Pistol mode
    If (AutoMode && !Not_In_Game())
    {
        AssignValue("RunningMode", "加载手枪")
        AutoFire(2) 
    }
Return

~*Tab Up::
    ChangeMode(2) ;Default mode
    If (AutoMode && !Not_In_Game())
    {
        AssignValue("Temp_Mode", 0)
        AssignValue("RunningMode", "加载通用")
        AssignValue("Temp_Run", RunningMode)
        AutoFire(0) 
    }  
Return

~*J Up:: ;sniper 1 vs 1 mode
    ChangeMode(2)
    If (AutoMode && !Not_In_Game())
    {
        AssignValue("Temp_Mode", 8)
        AssignValue("RunningMode", "加载狙击")
        AssignValue("Temp_Run", RunningMode)
        AutoFire(8)
    }
Return

~*L Up:: ;Gatling gun, sniper gun, shotgun
    ChangeMode(2)   
    If (AutoMode && !Not_In_Game())
    {
        AssignValue("Temp_Mode", 111)
        AssignValue("RunningMode", "加载速点")
        AssignValue("Temp_Run", RunningMode)
        AutoFire(111)
    }  
Return

~*Numpad0::
    Need_Help := !Need_Help
Return

~*Numpad1::
    If !AutoMode
    {
        AssignValue("Gun_Using", "AK英雄级") ;对相应枪械 均能基本压在一条线附近
        AssignValue("Gun_Chosen", 1)
    }  
Return

~*Numpad2::
    If !AutoMode
    {
        AssignValue("Gun_Using", "M4英雄级") ;对相应枪械 均能基本压在一条线附近
        AssignValue("Gun_Chosen", 2)
    }
Return

~^Left:: ;reposition crosshair
    KX -= 1
Return

~^Right:: 
    KX += 1
Return

~^Up::
    KY -= 1   
Return

~^Down:: 
    Ky += 1
Return
;==================================================================================
~W & ~F:: ;基本鬼跳 间隔600 因t_accuracy=0.991调整
    cnt := 0
    press_key("space", 100, 100)
    Send, {LCtrl Down}
    AssignValue("Temp_Status", Fcn_Status)
    AssignValue("Fcn_Status", "基本鬼跳")
    HyperSleep(298) ;398
    Loop 
    {
        press_key("space", 10, 10) ;100 ;HyperSleep(450) 400   
        cnt += 1
    } Until, (!GetKeyState("W", "P") || cnt > 140)
    AssignValue("Fcn_Status", Temp_Status)
    Send, {Blind}{LCtrl Up}
Return 

~W & ~LAlt:: ;空中连蹲跳 w+alt
    cnt:= 0
    press_key("space", 30, 30)
    AssignValue("Temp_Status", Fcn_Status)
    AssignValue("Fcn_Status", "空中连蹲")
    HyperSleep(138)
    Loop
    {
        press_key("LCtrl", 15, 15)
        cnt += 1
    } Until, (!GetKeyState("W", "P") || cnt >= 15)
    AssignValue("Fcn_Status", Temp_Status)
Return

~S & ~F:: ;跳蹲上墙
    AssignValue("Temp_Status", Fcn_Status)
    AssignValue("Fcn_Status", "跳蹲上墙")
    Loop
    {
        press_key("space", 30, 30)
        press_key("LCtrl", 30, 30)
    } Until, (GetKeyState("E", "P") || GetKeyState("LButton", "P"))
    AssignValue("Fcn_Status", Temp_Status)
Return
;==================================================================================
~*MButton:: ;爆裂者轰炸
    If !AutoMode
    {
        AssignValue("Fcn_Status", "右键连点")
        While, !(GetKeyState("R", "P") || GetKeyState("LButton", "P") || GetKeyState("`", "P"))
        {
            press_key("RButton", 10, 60)
        }
        AssignValue("Fcn_Status", "自火关闭")
        Send, {Blind}{RButton Up}
    }
Return

~*XButton2:: ;半自动速点
    If !AutoMode
    {
        AssignValue("Fcn_Status", "左键连点")
        While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P") || GetKeyState("`", "P"))
        {
            press_key("LButton", 62, 42)
        }
        AssignValue("Fcn_Status", "自火关闭")
        Send, {Blind}{LButton Up}
    }
Return

~*K:: ;粉碎者直射
    If !AutoMode
    {
        AssignValue("Fcn_Status", "左键不放")
        Send, {Blind}{LButton Up}
        HyperSleep(30)
        Send, {LButton Down}
        While, !(GetKeyState("R", "P") || GetKeyState("`", "P") || GetKeyState("3", "P"))
        {
            HyperSleep(300)
        }
        AssignValue("Fcn_Status", "自火关闭")
        Send, {Blind}{LButton Up}
    }
Return
;==================================================================================
ShowMode()
{
    UpdateText("MyText", NewText)
}

UpdateC4() ;精度0.1s 卡住时切换武器刷新
{ 
    C4_Start :=
    C4_OnOFF := False
    If Is_C4_Time()
    {
        If !C4_OnOFF
        {
            C4_OnOFF := True
            C4_Start := SystemTime()
        }
        Else
            C4_Time := Format("{:.0f}", (40 - (SystemTime() - C4_Start) / 1000))
    }
    Else
    {
        If C4_Start > 0
            C4_Start := ;release memory
        If C4_Time != 40
            C4_Time := 40
        If C4_OnOFF
            C4_OnOFF := False
    }
}

UpdateGui() ;Gui 2 will be repositioned while modes changing
{    
    If WinExist("ahk_class CrossFire")
    {
        WinGetPos, X, Y, W, H, ahk_class CrossFire ;get top left position of the window
        SetGuiPosition()
        ShowHelp()
        If !(TempX = X && TempY = Y)
        {
            Gui, 1: Hide
            Gui, 1: Show, x%XGui1% y%YGui1% NA
            Gui, 2: Hide
            ShowHelp()
            Gui, cross_hair: Hide
            Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
            TempX := X
            TempY := Y
        }
        
        If !InStr("加载模式", RunningMode)
        {
            Gui, cross_hair: Hide
            Gui, cross_hair: Color, 00FFFF
            Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
        }
        Else If InStr("加载模式", RunningMode)
        {
            Gui, cross_hair: Hide
            Gui, cross_hair: Color, FFFF00
            Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
        }
    }
    Else
    {
        WinClose, ahk_class ConsoleWindowClass
        ExitApp
    }
}

ShowHelp()
{
    global XGui2, YGui2
    If Need_Help
        Gui, 2: Show, x%XGui2% y%YGui2% NA
    Else
        Gui, 2: Hide
}

ProcessExist(Process_Name)
{
    Process, Exist, %Process_Name%
    Return Errorlevel
}

ChangeMode(qie_huan)
{
    Loop, %qie_huan%
    {
        AssignValue("AutoMode", Abs(AutoMode - 1))
        HyperSleep(300)
    }

    If AutoMode
    {
        AssignValue("Fcn_Status", "自火开启")
        AssignValue("Gun_Using", "暂未选枪械")
        AssignValue("Gun_Chosen", 0)
    }
    Else
    {
        AssignValue("Fcn_Status", "自火关闭")
        AssignValue("RunningMode", "加载模式")
    }
}

AutoFire(mo_shi)
{
    static PosColor_snipe := "0x000000" ;wired part
    ;show color in editor: #000000
    While, (AutoMode)
    {
        Var := W // 2 - 5 ;798
        Fcn_Status := "搜寻敌人" ;war zone, need less HyperSleep
        Loop ;detect color in three lines where shows the enemy name
        {
            If (ExitMode() || GetKeyState("3", "P") || GetKeyState("4", "P"))
            {
                AssignValue("RunningMode", "加载模式")
                AssignValue("Fcn_Status", "自火开启")
                Exit ;exit current thread 
            }
            
            While Shoot_Time(Var) ;if detected color is found in string
            {
                Fcn_Status := "发现敌人"
                Random, rand, 60, 62 ;set random value trying to avoid VAC
                small_rand := rand // 2
                Switch mo_shi
                {
                    Case 2:
                        press_key("LButton", (rand - 10), (rand - 10)) ;控制usp射速
                        mouseXY(0, 1)
                        If !InStr("手枪模式", RunningMode) 
                            RunningMode := "手枪模式"
                    Break

                    Case 8:
                        If Not (GetColorStatus(955, 483, PosColor_snipe) || GetColorStatus(804, 600, PosColor_snipe))
                        {
                            press_key("RButton", small_rand, small_rand)
                            press_key("LButton", small_rand, small_rand)
                        }
                        Else
                            press_key("LButton", small_rand, small_rand)

                        If !InStr("瞬狙模式", RunningMode)
                            RunningMode := "瞬狙模式"
                        HyperSleep(3 * rand)
                    Break

                    Case 111:
                        press_key("LButton", 62, 42)
                        If !InStr("连发速点", RunningMode)
                            RunningMode := "连发速点"
                    Break
                    
                    Default:
                        press_key("LButton", small_rand, small_rand)
                        mouseXY(0, 1)
                        If !InStr("通用模式", RunningMode)
                            RunningMode := "通用模式"
                    Break
                }
            }
            Var += 1
        } Until, Var > (W / 2 + 5) ;808
        HyperSleep(1) ;trying to avoid vac with HyperSleep
    }
}

Not_In_Game()
{
    static PosColor_edge := "0x232323 0x101010 0x0F0F0F 0x070707 0x2F2F31 0x2A2A2A 0x4C4741 0x4C4841 0x4C4941"
    ;show color in editor: #232323 #101010 #0F0F0F #070707 #2F2F31 #2A2A2A #4C4741 #4C4841 #4C4941
    Return GetColorStatus(1220, 52, PosColor_edge)
}

Shoot_Time(Var)
{
    static PosColor_red := "0x353796 0x353797 0x353798 0x353799 0x343799 0x34379A 0x34389A 0x34389B 0x34389C 0x33389C 0x33389D 0x33389E 0x33389F 0x32389F 0x32399F 0x3239A0 0x3239A1 0x3239A2 0x3139A2 0x3139A3 0x3139A4 0x313AA4 0x313AA5 0x303AA5 0x303AA6 0x303AA7 0x303AA8 0x2F3AA8 0x2F3AA9 0x2F3BA9 0x2F3BAA 0x2F3BAB 0x2E3BAB 0x2E3BAC 0x2E3BAD 0x2E3BAE 0x2E3CAE 0x2D3CAE 0x2D3CAF 0x2D3CB0 0x2D3CB1 0x2C3CB1 0x2C3CB2 0x2C3CB3 0x2C3DB3 0x2C3DB4 0x2B3DB4 0x2B3DB5 0x2B3DB6 0x2B3DB7 0x2A3DB7 0x2A3EB7 0x2A3EB8 0x2A3EB9 0x2A3EBA 0x293EBA 0x293EBB 0x293EBC 0x293FBC 0x293FBC 0x293FBD 0x283FBD 0x283FBE 0x283FBF 0x283FC0 0x273FC0 0x273FC1 0x2740C1 0x2740C2 0x2740C3 0x2640C4 0x2640C5 0x2640C6 0x2641C6 0x2641C7 0x2541C7 0x2541C8 0x2541C9 0x2541CA 0x2441CA 0x2441CB 0x2442CB 0x2442CC 0x2442CD 0x2342CD 0x2342CE 0x2342CF 0x2342D0 0x2343D0 0x2243D0 0x2243D1 0x2243D2 0x2243D3 0x2143D3 0x2143D4 0x2144D4 0x2144D5 0x2144D6 0x2044D6 0x2044D7 0x2044D8 0x2044D9 0x1F44D9 0x1F45D9 0x1F45DA 0x1F45DB 0x1F45DC 0x1E45DC 0x1E45DD 0x1E45DE 0x1E46DE 0x1E46DF 0x1D46DF 0x1D46E0 0x1D46E1 0x1D46E2 0x1C46E2 0x1C46E3 0x1C47E3 0x1C47E4 0x1C47E5 0x1B47E5 0x1B47E6 0x1B47E7 0x1B47E8 0x1B48E8 0x1A48E8 0x1A48E9 0x1A48EA 0x1A48EB 0x1948EB 0x1948EC 0x1948ED 0x1949ED 0x1949EE 0x1849EE 0x1849EF 0x1849F0 0x1849F1 0x174AF2" ;all detected values of color hex since it is changing
    ;show color in editor: #353796 #353797 #353798 #353799 #343799 #34379A #34389A #34389B #34389C #33389C #33389D #33389E #33389F #32389F #32399F #3239A0 #3239A1 #3239A2 #3139A2 #3139A3 #3139A4 #313AA4 #313AA5 #303AA5 #303AA6 #303AA7 #303AA8 #2F3AA8 #2F3AA9 #2F3BA9 #2F3BAA #2F3BAB #2E3BAB #2E3BAC #2E3BAD #2E3BAE #2E3CAE #2D3CAE #2D3CAF #2D3CB0 #2D3CB1 #2C3CB1 #2C3CB2 #2C3CB3 #2C3DB3 #2C3DB4 #2B3DB4 #2B3DB5 #2B3DB6 #2B3DB7 #2A3DB7 #2A3EB7 #2A3EB8 #2A3EB9 #2A3EBA #293EBA #293EBB #293EBC #293FBC #293FBC #293FBD #283FBD #283FBE #283FBF #283FC0 #273FC0 #273FC1 #2740C1 #2740C2 #2740C3 #2640C4 #2640C5 #2640C6 #2641C6 #2641C7 #2541C7 #2541C8 #2541C9 #2541CA #2441CA #2441CB #2442CB #2442CC #2442CD #2342CD #2342CE #2342CF #2342D0 #2343D0 #2243D0 #2243D1 #2243D2 #2243D3 #2143D3 #2143D4 #2144D4 #2144D5 #2144D6 #2044D6 #2044D7 #2044D8 #2044D9 #1F44D9 #1F45D9 #1F45DA #1F45DB #1F45DC #1E45DC #1E45DD #1E45DE #1E46DE #1E46DF #1D46DF #1D46E0 #1D46E1 #1D46E2 #1C46E2 #1C46E3 #1C47E3 #1C47E4 #1C47E5 #1B47E5 #1B47E6 #1B47E7 #1B47E8 #1B48E8 #1A48E8 #1A48E9 #1A48EA #1A48EB #1948EB #1948EC #1948ED #1949ED #1949EE #1849EE #1849EF #1849F0 #1849F1 #174AF2 
    static PosColor_NA_red := "0xF24A17 0x174AF2"
    ;show color in editor: #F24A17 #174AF2
    If game_title = CROSSFIRE
        Return (GetColorStatus(Var, 528, PosColor_NA_red) || GetColorStatus(Var, 530, PosColor_NA_red) || GetColorStatus(Var, 532, PosColor_NA_red))
    Else If game_title = 穿越火线
        Return (GetColorStatus(Var, 538, PosColor_red) || GetColorStatus(Var, 540, PosColor_red) || GetColorStatus(Var, 542, PosColor_red))
}

Is_C4_Time()
{
    static PosColor_C4 := "0xE39600 0x0096E3 0xE6A11A 0x1AA1E6 0xFBEFD8 0xD8EFFB 0x926000 0x006092 0x523600 0x003652"
    ;show color in editor: #E39600 #0096E3 #E6A11A #1AA1E6 #FBEFD8 #D8EFFB #926000 #006092 #523600 #003652
    Return (GetColorStatus(773, 161, PosColor_C4) || GetColorStatus(774, 161, PosColor_C4) || GetColorStatus(818, 162, PosColor_C4) || GetColorStatus(819, 162, PosColor_C4) || GetColorStatus(803, 155, PosColor_C4) || GetColorStatus(803, 166, PosColor_C4) || GetColorStatus(803, 162, PosColor_C4) || GetColorStatus(803, 174, PosColor_C4)) ;more points to ensure
}

ExitMode()
{
    Return (GetKeyState("1", "P") || GetKeyState("Tab", "P") || GetKeyState("2", "P") || GetKeyState("J", "P") || GetKeyState("L", "P")) 
}

GetColorStatus(CX1, CX2, color_lib)
{
    PixelGetColor, color_got, (X + CX1), (Y + CX2)
    Return InStr(color_lib, color_got)
}

mouseXY(x1,y1)
{
    DllCall("mouse_event", uint, 1, int, x1, int, y1, uint, 0, int, 0)
}

press_key(key, press_time, sleep_time)
{
    static t_accuracy := 0.991
	press_time *= t_accuracy
    sleep_time *= t_accuracy
    Send, {%key% DownTemp}
	HyperSleep(press_time)
    Send, {Blind}{%key% up}
	HyperSleep(sleep_time)
}

SetGuiPosition()
{
    global XGui1 := X + (W - P1W) // 2
    global YGui1 := Y
    global XGui2 := X + 2
    global YGui2 := Y + (H - P2H) // 2
    global Xch := X + W // 2 + KX
    global Ych := Y + H // 2 + KY
}

UpdateText(ControlID, NewText) ;Copy From AHK Windows Spy, preventing periodic flickering
{
    static OldText := {}
    AssignValue("NewText", NewText := "自动: " AutoMode "|" RunningMode "|" Fcn_Status "|" Gun_Using "|" C4_Time)
    if (OldText[ControlID] != NewText)
    {
        GuiControl, 1:, % ControlID, % NewText
        HyperSleep(10)
        OldText[ControlID] := NewText
    }
}

AssignValue(target, value) ;due to max speed
{
    %target% := value
    HyperSleep(1)
}

SystemTime() 
{
	freq := 0, tick := 0
	if (!freq)
		DllCall("QueryPerformanceFrequency", "Int64*", freq)
		DllCall("QueryPerformanceCounter", "Int64*", tick)
	Return tick / freq * 1000
} 

HyperSleep(value) 
{
    If value < 10 ;相对高精度睡眠
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
            If (t_tmp - t_current) > 30000
            {
                DllCall("Sleep", "UInt", 1)
                DllCall("QueryPerformanceCounter", "Int64*", t_current)
            }
            Else
                DllCall("QueryPerformanceCounter", "Int64*", t_current)
        }
        begin_time := , freq := , t_tmp := , t_current := ;free memory
    }
}
;==================================================================================
;The end
