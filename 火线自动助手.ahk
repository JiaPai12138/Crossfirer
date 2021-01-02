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
;==================================================================
If not (A_IsAdmin || ProcessExist("AutoHotkeyU64_UIA.exe"))
{
    MsgBox, 4, 警告/Warning, 请问你开启UIA了吗?`nDo you have UIAccess enabled?
    Try ;compiled program will be detected
    {
        IfMsgBox Yes
            Run, "%A_ProgramFiles%\AutoHotkey\AutoHotkeyU64_UIA.exe" "%A_ScriptFullPath%"
        Else
            Run, *RunAs "%A_ScriptFullPath%"
    }
    Catch ; Handles the first error/exception raised by the block above.
    {
        MsgBox,, 错误/Error, 未正确运行!脚本将退出!!`nUnable to start correctly!The script will exit!!
        ExitApp
    }
} 
;==================================================================
global PosColor1 := "0x353796 0x353797 0x353798 0x353799 0x343799 0x34379A 0x34389A 0x34389B 0x34389C 0x33389C 0x33389D 0x33389E 0x33389F 0x32389F 0x32399F 0x3239A0 0x3239A1 0x3239A2 0x3139A2 0x3139A3 0x3139A4 0x313AA4 0x313AA5 0x303AA5 0x303AA6 0x303AA7 0x303AA8 0x2F3AA8 0x2F3AA9 0x2F3BA9 0x2F3BAA 0x2F3BAB 0x2E3BAB 0x2E3BAC 0x2E3BAD 0x2E3BAE 0x2E3CAE 0x2D3CAE 0x2D3CAF 0x2D3CB0 0x2D3CB1 0x2C3CB1 0x2C3CB2 0x2C3CB3 0x2C3DB3 0x2C3DB4 0x2B3DB4 0x2B3DB5 0x2B3DB6 0x2B3DB7 0x2A3DB7 0x2A3EB7 0x2A3EB8 0x2A3EB9 0x2A3EBA 0x293EBA 0x293EBB 0x293EBC 0x293FBC 0x293FBC 0x293FBD 0x283FBD 0x283FBE 0x283FBF 0x283FC0 0x273FC0 0x273FC1 0x2740C1 0x2740C2 0x2740C3 0x2640C4 0x2640C5 0x2640C6 0x2641C6 0x2641C7 0x2541C7 0x2541C8 0x2541C9 0x2541CA 0x2441CA 0x2441CB 0x2442CB 0x2442CC 0x2442CD 0x2342CD 0x2342CE 0x2342CF 0x2342D0 0x2343D0 0x2243D0 0x2243D1 0x2243D2 0x2243D3 0x2143D3 0x2143D4 0x2144D4 0x2144D5 0x2144D6 0x2044D6 0x2044D7 0x2044D8 0x2044D9 0x1F44D9 0x1F45D9 0x1F45DA 0x1F45DB 0x1F45DC 0x1E45DC 0x1E45DD 0x1E45DE 0x1E46DE 0x1E46DF 0x1D46DF 0x1D46E0 0x1D46E1 0x1D46E2 0x1C46E2 0x1C46E3 0x1C47E3 0x1C47E4 0x1C47E5 0x1B47E5 0x1B47E6 0x1B47E7 0x1B47E8 0x1B48E8 0x1A48E8 0x1A48E9 0x1A48EA 0x1A48EB 0x1948EB 0x1948EC 0x1948ED 0x1949ED 0x1949EE 0x1849EE 0x1849EF 0x1849F0 0x1849F1 0x174AF2" ;all detected values of color hex since it is changing
global PosColor2 := "0x232323 0x101010 0x0F0F0F 0x070707 0x2F2F31 0x2A2A2A 0x4C4741 0x4C4841 0x4C4941"
global PosColor_snipe := "0x000000"
crosshair = 34-35 2-35 2-36 34-36 34-60 35-60 35-36 67-36 67-35 35-35 35-11 34-11
global freq, tick, begin_time, t_accuracy := 0.992
global AutoMode := 0 ;on/off switch
global ExitMode := True
global RunningMode := "加载模式"
global Fcn_Status := "脚本状态"
global Gun_Using := "暂未选枪械"
global Gun_Chosen := 0
global NewText := "自动: " AutoMode "|" RunningMode "|" Fcn_Status "|" Gun_Using
global X, Y, W, H
global cnt
global color_get := 0xFFFFFF

if WinExist("ahk_class CrossFire")
{
    WinGetPos, X, Y, W, H, ahk_class CrossFire ;get top left position of the window
    global TempX := X, TempY := Y
    Start:
    SetGuiPosition()
    Gui, 1: +LastFound +AlwaysOnTop -Caption +ToolWindow ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, 1: Margin, 0, 0
    Gui, 1: Color, 333333
    Gui, 1: Font, s16, Verdana  
    Gui, 1: Add, Text, vMyText c00FF00, % NewText
    Gui, 1: Show, x%XGui1% y%YGui1% NA
    WinSet, ExStyle, +0x20 ; 鼠标穿透

    Gui, 2: +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, 2: Margin, 0, 0
    Gui, 2: Color, 333333
    Gui, 2: Font, s12 c00FF00, Microsoft YaHei
    Gui, 2: add, Text,, ╔====使用==说明===╗`n     按~==开关自火===`n     按234JLTab选择模式`n     按2===手枪模式==`n     按3/4= 关闭模式==`n     按J===狙击关镜==`n     按L===速点模式==`n     按Tab键=通用模式=`n================`n     鼠标中间键 右键连点`n     鼠标后退键 左键连点`n     按W和F== 基础鬼跳`n     按W和Alt= 空中跳蹲`n     按S和F===跳蹲上墙`n     按- =重新加载本脚本`n     大写锁定 最小化窗口`n╚====使用==说明===╝
    Gui, 2: Show, x%XGui2% y%YGui2% NA
    WinSet, TransColor, 333333 255
    WinSet, ExStyle, +0x20 ; 鼠标穿透

    Gui, crosshair: New, +lastfound +ToolWindow -Caption +AlwaysOnTop
    Gui, crosshair: Margin, 0, 0
    Gui, crosshair: Color, 333333
    Gui, crosshair: Add, Progress, x0 y0 w52 h52 c00FFFF -border vCrosshair, 100 ; 
    Gui, crosshair: Show, x%Xch% y%Ych%
    WinSet, TransColor, 333333
    WinSet, Region, %crosshair%, A 
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    WinSet, ExStyle, +0x08000000 ;NA
}  

SetTimer, ShowMode, 100
Gosub, ShowMode 
SetTimer, UpdateGui, 1000
Gosub, UpdateGui
;==================================================================
Loop ;压枪 正在开发
{
    If (!AutoMode && Gun_Chosen > 0)
    {
        AssignValue("Fcn_Status", "手动开火")
        If GetKeyState("LButton", "P") 
        {
            StartTime := A_TickCount
            EndTime := A_TickCount - StartTime
            Switch Gun_Chosen
            {
                Case 1:
                    While, EndTime < 100 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(50)
                        mouseXY(0, 1)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 100 && EndTime < 300 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(30)
                        mouseXY(0, 2)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 300 && EndTime < 500 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(40)
                        mouseXY(0, 3)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 300 && EndTime < 500 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(30)
                        mouseXY(0, 3)
                        EndTime := A_TickCount - StartTime 
                    }
                    While, EndTime >= 500 && EndTime < 800 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(30)
                        mouseXY(0, 1)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 800 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(30)
                        EndTime := A_TickCount - StartTime 
                    }

                Case 2:
                    While, EndTime < 90 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(10)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 90 && EndTime < 530 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(37)
                        mouseXY(0, 2)
                        EndTime := A_TickCount - StartTime 
                    }
                    While, EndTime >= 530 && GetKeyState("LButton", "P")
                    {
                        HyperSleep(30)
                        EndTime := A_TickCount - StartTime
                    }
                
                Default:
                    HyperSleep(10)
            }
        }
        Else If !GetKeyState("LButton", "P")
        {
            StartTime := A_TickCount ;保障新一轮压枪
        }
    }
    HyperSleep(30) ;just for stability
}
Return
;==================================================================
ShowMode:
    UpdateText("MyText", NewText)
Return 

UpdateGui: ;Gui 2 will be repositioned while modes changing
    If WinExist("ahk_class CrossFire")
    {
        WinGetPos, X, Y, W, H, ahk_class CrossFire ;get top left position of the window
        SetGuiPosition()
        If (!(TempX = X && TempY = Y) && !GetKeyState("LButton", "P"))
        {
            Gui, 1: Hide
            Gui, 1: Show, x%XGui1% y%YGui1% NA
            Gui, crosshair: Hide
            Gui, crosshair: Show, x%Xch% y%Ych% NA
            If !AutoMode
            {
                Gui, 2: Hide
                Gui, 2: Show, x%XGui2% y%YGui2% NA
            }
            Else
            {
                Gui, 2: Hide
            }
            TempX := X
            TempY := Y
        }
    }
    Else
    {
        Gui, 1: Hide
        Gui, 2: Hide
        Gui, crosshair: Hide
    }
Return
;==================================================================
~*-::Reload

~*CapsLock:: ;minimize window
    press_key("Esc", 60)
    MouseMove, (X + W - 151), (Y + 16), 1
    HyperSleep(30)
    press_key("LButton", 30)
Return

~*`::
    ChangeMode(1)
Return

~*2::
    ChangeMode(2) ;Default mode
    If (AutoMode && !GetColorStatus(1220, 52, color_get, PosColor2))
    {
        AssignValue("RunningMode", "加载手枪")
        AutoFire(2) 
    }
Return
~*Tab::
    ChangeMode(2) ;Default mode
    If (AutoMode && !GetColorStatus(1220, 52, color_get, PosColor2))
    {
        AssignValue("RunningMode", "加载通用")
        AutoFire(0) 
    }  
Return

~*J:: ;sniper 1 vs 1 mode
    ChangeMode(2)
    If (AutoMode && !GetColorStatus(1220, 52, color_get, PosColor2))
    {
        AssignValue("RunningMode", "加载狙击")
        AutoFire(8)
    }
Return

~*L:: ;Gatling gun, sniper gun, shotgun
    ChangeMode(2)   
    If (AutoMode && !GetColorStatus(1220, 52, color_get, PosColor2))
    {
        AssignValue("RunningMode", "加载速点")
        AutoFire(111)
    }  
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

~*Left:: ;恶趣味,代替鼠标控制
    Loop
    {    
        mouseXY(-4, 0)
        HyperSleep(30)
    } Until !GetKeyState("Left", "P")
Return

~*Right:: 
    Loop
    {
        mouseXY(4, 0)
        HyperSleep(30)
    } Until !GetKeyState("Right", "P")
Return

~*Up::
    Loop
    { 
        mouseXY(0, -3)
        HyperSleep(30)
    } Until !GetKeyState("Up", "P")    
Return

~*Down:: 
    Loop
    {
        mouseXY(0, 3)
        HyperSleep(30)
    } Until !GetKeyState("Down", "P")    
Return
;==================================================================
~W & ~F:: ;基本鬼跳 间隔600 因t_accuracy=0.992调整
    cnt := 0
    press_key("space", 100)
    Send, {LCtrl Down}
    AssignValue("Temp_Status", Fcn_Status)
    AssignValue("Fcn_Status", "基本鬼跳")
    HyperSleep(401) ;398
    While (cnt < 6 && GetKeyState("W", "P"))
    {
        press_key("space", 100)      
        HyperSleep(406 ) ;400
        cnt += 1
    }
    AssignValue("Fcn_Status", Temp_Status)
    Send, {Blind}{LCtrl Up}
Return 

~W & ~Alt:: ;空中连蹲跳 alt+w
    cnt:= 0
    press_key("space", 30)
    AssignValue("Temp_Status", Fcn_Status)
    AssignValue("Fcn_Status", "空中连蹲")
    HyperSleep(138)
    Loop
    {
        press_key("LCtrl", 15)
        cnt += 1
        If (!GetKeyState("W", "P") || cnt >= 15)
        {
            AssignValue("Fcn_Status", Temp_Status)
            Break
        }
    }
Return

~S & ~F:: ;跳蹲上墙
    AssignValue("Temp_Status", Fcn_Status)
    AssignValue("Fcn_Status", "跳蹲上墙")
    While, !(GetKeyState("E") || (GetKeyState("LButton", "P")))
    {
        press_key("space", 30)
        press_key("LCtrl", 30)
    }
    AssignValue("Fcn_Status", Temp_Status)
Return
;==================================================================
~*MButton:: ;爆裂者轰炸
    If !AutoMode
    {
        AssignValue("Fcn_Status", "右键连点")
        Fcn_Status := "右键连点"
        While, !(GetKeyState("R", "P") || GetKeyState("LButton", "P") || GetKeyState("`", "P"))
        {
            press_key("RButton", 10)
            HyperSleep(50)
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
            Random, randVar, 58, 62
            press_key("LButton", randVar)
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
;==================================================================
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
        AssignValue("ExitMode", !ExitMode)
        HyperSleep(500)
    }

    If (AutoMode)
    {
        Gui, 2: Hide
        HyperSleep(10)
        AssignValue("Fcn_Status", "自火开启")
        AssignValue("Gun_Using", "暂未选枪械")
        AssignValue("Gun_Chosen", 0)
    }
    Else
    {
        global XGui2, YGui2
        Gui, 2: Show, x%XGui2% y%YGui2% NA
        AssignValue("Fcn_Status", "自火关闭")
    }
}

AutoFire(mo_shi)
{
    While, (AutoMode && !ExitMode)
    {
        Var := 798
        Fcn_Status := "搜寻敌人" ;war zone, need less HyperSleep
        Loop ;detect color in three lines where shows the enemy name
        {
            If (ExitMode || GetKeyState("3", "P") || GetKeyState("4", "P"))
            {
                AssignValue("RunningMode", "加载模式")
                AssignValue("Fcn_Status", "自火开启")
                Exit ;exit current thread 
            }

            If (RunningMode = "瞬狙模式" && (GetColorStatus(1000, 483, color_get, PosColor_snipe) && GetColorStatus(801, 600, color_get, PosColor_snipe)))
            {
                Random, rand, 58, 62
                press_key("RButton", rand)
            }
            
            While (GetColorStatus(Var, 538, color_get, PosColor1) || GetColorStatus(Var, 540, color_get, PosColor1) || GetColorStatus(Var, 542, color_get, PosColor1)) ;if detected color is found in string
            {
                Fcn_Status := "发现敌人"
                Random, rand, 58, 62 ;set random value trying to avoid VAC
                small_rand := rand // 2
                Switch mo_shi
                {
                    Case 2:
                        press_key("LButton", rand) ;控制usp射速
                        mouseXY(0, 1)
                        If (RunningMode != "手枪模式") 
                        {
                            RunningMode := "手枪模式"
                        }
                    Break

                    Case 8:
                        press_key("RButton", small_rand)
                        press_key("LButton", small_rand)
                        If (RunningMode != "瞬狙模式")
                        {
                            RunningMode := "瞬狙模式"
                        }
                        HyperSleep(rand)
                    Break

                    Case 111:
                        press_key("LButton", rand)
                        If (RunningMode != "连发速点")
                        {
                            RunningMode := "连发速点"
                        }
                    Break
                    
                    Default:
                        press_key("LButton", small_rand)
                        mouseXY(0, 1)
                        If (RunningMode != "通用模式")
                        {
                            RunningMode := "通用模式"
                        }
                    Break
                }
            }
            Var := Var + 1
        } Until, ( Var > 808 )
        HyperSleep(1) ;trying to avoid vac with HyperSleep
    }
}

GetColorStatus(CX1, CX2, color_got, color_lib)
{
    PixelGetColor, color_get, (X + CX1), (Y + CX2)
    Return InStr(color_lib, color_got)
}

mouseXY(x1,y1)
{
    DllCall("mouse_event", uint, 1, int, x1, int, y1, uint, 0, int, 0)
}

press_key(key, press_time)
{
	press_time *= t_accuracy
    Send, {%key% DownTemp}
	HyperSleep(press_time)
    Send, {Blind}{%key% up}
	HyperSleep(press_time)
}

SetGuiPosition()
{
    global XGui1 := X + 568
    global YGui1 := Y
    global XGui2 := X + 2
    global YGui2 := Y + 264
    global Xch := X + W // 2 - 34
    global Ych := Y + H // 2 - 20
}

UpdateText(ControlID, NewText) ;Copy From AHK Windows Spy, preventing periodic flickering
{
    static OldText := {}
    AssignValue("NewText", "自动: " AutoMode "|" RunningMode "|" Fcn_Status "|" Gun_Using)
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
    }
}
;==================================================================
;The end
