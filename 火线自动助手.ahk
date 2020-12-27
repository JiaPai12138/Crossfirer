#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#MenuMaskKey vkFF  ; vkFF is no mapping
#SingleInstance, force
#IfWinActive ahk_exe crossfire.exe  ; Only active while crossfire is running
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
Process, Priority, , H
;==================================================================
global PosColor1 := "0x353796 0x353797 0x353798 0x353799 0x343799 0x34379A 0x34389A 0x34389B 0x34389C 0x33389C 0x33389D 0x33389E 0x33389F 0x32389F 0x32399F 0x3239A0 0x3239A1 0x3239A2 0x3139A2 0x3139A3 0x3139A4 0x313AA4 0x313AA5 0x303AA5 0x303AA6 0x303AA7 0x303AA8 0x2F3AA8 0x2F3AA9 0x2F3BA9 0x2F3BAA 0x2F3BAB 0x2E3BAB 0x2E3BAC 0x2E3BAD 0x2E3BAE 0x2E3CAE 0x2D3CAE 0x2D3CAF 0x2D3CB0 0x2D3CB1 0x2C3CB1 0x2C3CB2 0x2C3CB3 0x2C3DB3 0x2C3DB4 0x2B3DB4 0x2B3DB5 0x2B3DB6 0x2B3DB7 0x2A3DB7 0x2A3EB7 0x2A3EB8 0x2A3EB9 0x2A3EBA 0x293EBA 0x293EBB 0x293EBC 0x293FBC 0x293FBC 0x293FBD 0x283FBD 0x283FBE 0x283FBF 0x283FC0 0x273FC0 0x273FC1 0x2740C1 0x2740C2 0x2740C3 0x2640C4 0x2640C5 0x2640C6 0x2641C6 0x2641C7 0x2541C7 0x2541C8 0x2541C9 0x2541CA 0x2441CA 0x2441CB 0x2442CB 0x2442CC 0x2442CD 0x2342CD 0x2342CE 0x2342CF 0x2342D0 0x2343D0 0x2243D0 0x2243D1 0x2243D2 0x2243D3 0x2143D3 0x2143D4 0x2144D4 0x2144D5 0x2144D6 0x2044D6 0x2044D7 0x2044D8 0x2044D9 0x1F44D9 0x1F45D9 0x1F45DA 0x1F45DB 0x1F45DC 0x1E45DC 0x1E45DD 0x1E45DE 0x1E46DE 0x1D46DF 0x1D46E0 0x1D46E1 0x1D46E2 0x1C46E3 0x1C47E3 0x1C47E4 0x1C47E5 0x1B47E5 0x1B47E6 0x1B47E7 0x1B48E8 0x1A48E8 0x1A48E9 0x1A48EA 0x1A48EB 0x1948EC 0x1948ED 0x1949ED 0x1949EE 0x1849EF 0x1849F0 0x1849F1 0x174AF2" ;all detected values of color hex since it is changing
global PosColor2 := "0x232323 0x101010 0x0F0F0F 0x070707 0x2F2F31 0x2A2A2A 0x4C4741 0x4C4841 0x4C4941"
global PosColor_snipe := "0x000000"
crosshair = 34-35 10-35 10-36 34-36 34-60 35-60 35-36 59-36 59-35 35-35 35-11 34-11
global AutoMode := 0 ;on/off switch
global ExitMode := True
global RunningMode := "加载模式"
global Fcn_Status := "脚本状态"
global Gun_Using := "暂未选枪械"
global Gun_Chosen := 0
global NewText := "自动: " AutoMode "|" RunningMode "|" Fcn_Status "|" Gun_Using

WinGetPos, X, Y, W, H, ahk_exe crossfire.exe ;get top left position of the window
global X, Y, W, H
;easier to change data
global XGui1 := X + 568
global YGui1 := Y
global XGui2 := X + 2
global YGui2 := Y + 210
global Xch := X + W // 2 - 34
global Ych := Y + H // 2 - 20
global cnt
global color_get := 0xFFFFFF

If (W + H) > 0
{
    Start:
    Gui, 1: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, 1: Margin, 0, 0
    Gui, 1: Color, 333333
    Gui, 1: Font, s16, Verdana  
    ;Gui, 1: Add, Text, vMyText c00FF00, 延长显示框长长长长长长长长长长度~
    Gui, 1: Add, Text, vMyText c00FF00, % NewText
    Gui, 1: Show, x%XGui1% y%YGui1% NA
    WinSet, ExStyle, +0x20  ; 鼠标穿透
    SetTimer, ShowMode, 100
    Gosub, ShowMode 

    Gui, 2: +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, 2: Margin, 0, 0
    Gui, 2: Color, 333333
    Gui, 2: Font, s12 c00FF00, Verdana  
    Gui, 2: add, Text,, ╔====使用==说明===╗
    Gui, 2: add, Text,, ║按大写锁定开关脚本
    Gui, 2: add, Text,, ║按34JLTab选择模式
    Gui, 2: add, Text,, ║按3/4=关闭模式===
    Gui, 2: add, Text,, ║按J===狙击关镜===
    Gui, 2: add, Text,, ║按L===速点模式===
    Gui, 2: add, Text,, ║按Tab键=通用模式=
    Gui, 2: add, Text,, ║==============
    Gui, 2: add, Text,, ║鼠标中间键右键连点
    Gui, 2: add, Text,, ║鼠标后退键左键连点
    Gui, 2: add, Text,, ║按W和F===基础鬼跳
    Gui, 2: add, Text,, ║按W和Alt=空中跳蹲    
    Gui, 2: add, Text,, ║按S和F===跳蹲上墙 
    Gui, 2: add, Text,, ║按-===重新加载===
    Gui, 2: add, Text,, ╚====使用==说明===╝
    WinSet, TransColor, 333333 255
    Gui, 2: Show, x%XGui2% y%YGui2% NA 
    WinSet, ExStyle, +0x20  ; 鼠标穿透

    Gui, crosshair: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Owner +E0x08000000
    Gui, crosshair: Margin, 0, 0
    Gui, crosshair: Color, 333333
    Gui, crosshair: Add, Progress, x0 y0 w52 h52 c00FFFF -border vCrosshair, 100 ; 
    Gui, crosshair: Show, x%Xch% y%Ych% 
    WinSet, TransColor, 333333
    WinSet, Region, %crosshair%, A 
    WinSet, ExStyle, +0x20  ; 鼠标穿透
}  
;==================================================================
Loop ;压枪 正在开发
{
    If (AutoMode = 0 && Gun_Chosen > 0)
    {
        Fcn_Status := "手动开火"
        If GetKeyState("LButton", "P") 
        {
            StartTime := A_TickCount
            EndTime := A_TickCount - StartTime
            Switch Gun_Chosen
            {
                Case 1:
                    While, EndTime < 100 && GetKeyState("LButton", "P")
                    {
                        Sleep, 50
                        mouseXY(0,1)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 100 && EndTime < 300 && GetKeyState("LButton", "P")
                    {
                        Sleep, 30
                        mouseXY(0, 2)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 300 && EndTime < 500 && GetKeyState("LButton", "P")
                    {
                        Sleep, 40
                        mouseXY(0, 3)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 300 && EndTime < 500 && GetKeyState("LButton", "P")
                    {
                        Sleep, 30
                        mouseXY(0, 3)
                        EndTime := A_TickCount - StartTime 
                    }
                    While, EndTime >= 500 && EndTime < 800 && GetKeyState("LButton", "P")
                    {
                        Sleep, 30
                        mouseXY(0, 1)
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 800 && GetKeyState("LButton", "P")
                    {
                        Sleep, 30 
                        EndTime := A_TickCount - StartTime 
                    }

                Case 2:
                    While, EndTime < 90 && GetKeyState("LButton", "P")
                    {
                        Sleep, 10
                        EndTime := A_TickCount - StartTime
                    }
                    While, EndTime >= 90 && EndTime < 530 && GetKeyState("LButton", "P")
                    {
                        Sleep, 37
                        mouseXY(0, 2)
                        EndTime := A_TickCount - StartTime 
                    }
                    While, EndTime >= 530 && GetKeyState("LButton", "P")
                    {
                        Sleep, 30
                        EndTime := A_TickCount - StartTime
                    }
                
                Default:
                    Sleep, 10
            }
        }
        Else If !GetKeyState("LButton", "P")
        {
            StartTime := A_TickCount ;保障新一轮压枪
        }
    }
    Sleep, 100
}
Return
;==================================================================
ShowMode:
    UpdateText("MyText", NewText)
Return 
;==================================================================
~*-::Reload
~*CapsLock:: ;minimize window
    press_key("Esc", "60")
    MouseMove, (X + W - 151), (Y + 16)
    Sleep, 30
    press_key("LButton", "30")
Return

~*`::
    ChangeMode(1)
Return

~*Tab Up::
    ChangeMode(2)
    RunningMode := "加载通用"
    If AutoMode
    {
        AutoFire(0) ;Default mode
    }  
Return

~*J Up:: ;sniper 1 vs 1 mode
    ChangeMode(2)
    RunningMode := "加载狙击"
    If AutoMode
    {
        AutoFire(8)
    }
Return

~*L Up:: ;Gatling gun, sniper gun, shotgun
    ChangeMode(2)
    RunningMode := "加载速点"
    If AutoMode
    {
        AutoFire(111)
    }  
Return

~*Numpad1 Up::
    Gun_Using := "AK英雄级" ;对火麒麟/机械迷城/黑武士 均能基本压在一条线附近
    Gun_Chosen := 1
Return

~*Numpad2 Up::
    Gun_Using := "M4英雄级" ;对雷神/黑骑士/死神 均能基本压在一条线附近
    Gun_Chosen := 2
Return
;==================================================================
~W & ~F:: ;基本鬼跳
    cnt:= 0
    press_key("space", "100")
    Send, {LCtrl Down}
    Temp_Status := Fcn_Status
    Fcn_Status := "基本鬼跳"
    Sleep, 350
    Loop
    {
        press_key("space", "15") ;Sleep, 375        
        cnt += 1
        If (!GetKeyState("W", "P") || cnt >= 50)
        {
            Fcn_Status := Temp_Status
            Break
        }
    }
    Send, {Blind}{LCtrl Up}
Return 

~W & ~Alt:: ;空中连蹲跳 alt+w
    cnt:= 0
    press_key("space", "30")
    Temp_Status := Fcn_Status
    Fcn_Status := "空中连蹲"
    Sleep, 150
    Loop
    {
        press_key("LCtrl", "10")
        cnt += 1
        If (!GetKeyState("W", "P") || cnt >= 15)
        {
            Fcn_Status := Temp_Status
            Break
        }
    }
Return

~S & ~F:: ;跳蹲上墙
    Temp_Status := Fcn_Status
    Fcn_Status := "跳蹲上墙"
    While, !(GetKeyState("E") || (GetKeyState("LButton", "P")))
	{
		press_key("space", "30")
        press_key("LCtrl", "30")
	}
    Fcn_Status := Temp_Status
Return
;==================================================================
~*MButton Up:: ;爆裂者轰炸
	If (AutoMode = 0)
    {
        Fcn_Status := "右键连点"
        While, !(GetKeyState("R", "P") || GetKeyState("LButton", "P") || GetKeyState("`", "P"))
	    {
		    press_key("RButton", "10")
		    Sleep, 50
	    }
        Fcn_Status := "自火关闭"
	    Send, {Blind}{RButton Up}
    }
Return

~*XButton2 Up:: ;半自动速点
    If (AutoMode = 0)
    {
        Fcn_Status := "左键连点"
        While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P") || GetKeyState("`", "P"))
	    {
		    Random, randVar, 58, 62
		    press_key("LButton", randVar)
	    }
        Fcn_Status := "自火关闭"
	    Send, {Blind}{LButton Up}
    }
Return

~*K Up:: ;粉碎者直射
    If (AutoMode = 0)
    {
        Fcn_Status := "左键不放"
	    Send, {Blind}{LButton Up}
	    Sleep, 30
        Send, {LButton Down}
        While, !(GetKeyState("R", "P") || GetKeyState("`", "P"))
	    {
		    Sleep, 300
		    If (GetKeyState("3", "P"))
		    {
			    Send, {Blind}{LButton Up}
                Fcn_Status := "自火关闭"
			    Break
		    }
	    }
        Send, {Blind}{LButton Up}
    }
Return
;==================================================================
ChangeMode(qie_huan)
{
    Loop, %qie_huan%
    {
        AutoMode := Abs(AutoMode - 1)
        ExitMode := !ExitMode
        Sleep, 300
    }

    If (AutoMode = 1)
    {
        Gui, 2: Hide
        Fcn_Status := "自火开启"
        Gun_Using := "暂未选枪械"
        Gun_Chosen := 0
    }
    Else
    {
        Gui, 2: Show, x%XGui2% y%YGui2% NA
        Fcn_Status := "自火关闭"
    }
}

AutoFire(mo_shi)
{
    While, (AutoMode = 1 && !GetColorStatus(1220, 52, color_get, PosColor2))
    {
        Var := 798
        Loop ;detect color in three lines where shows the enemy name
        {
            Fcn_Status := "搜寻敌人"
            If (ExitMode || GetKeyState("3", "P") || GetKeyState("4", "P"))
            {
                RunningMode := "目前暂无"
                Fcn_Status := "自火开启"
                Exit ;exit current thread
            }

            If (RunningMode = "瞬狙模式" && (GetColorStatus(1000, 483, color_get, PosColor_snipe) && GetColorStatus(801, 600, color_get, PosColor_snipe)))
            {
                press_key("RButton", "30")
            }
            
            While (GetColorStatus(Var, 538, color_get, PosColor1) || GetColorStatus(Var, 540, color_get, PosColor1) || GetColorStatus(Var, 542, color_get, PosColor1)) ;if detected color is found in string
            {
                Fcn_Status := "发现敌人"
                Random, rand, 58, 62 ;set random value trying to avoid VAC
                Switch mo_shi
                {
                    Case 8:
                        RunningMode := "瞬狙模式"
                        press_key("RButton", "30")
                        press_key("LButton", "30")
                        Sleep, 60
                    Break

                    Case 111:
                        RunningMode := "连发速点"
                        su_rand := rand
                        press_key("LButton", su_rand)
                    Break
                    
                    Default:
                        RunningMode := "通用模式"
                        small_rand := rand // 2
                        press_key("LButton", small_rand)
                        mouseXY(0, 1)
                    Break
                }
            }
            Var += 1
        } Until, ( Var = 808 )
    }
    Return
}

GetColorStatus(CX1, CX2, color_got, color_lib)
{
    PixelGetColor, color_get, (X + CX1), (Y + CX2)
    Return InStr(color_lib, color_got)
}

mouseXY(x1,y1)
{
    DllCall("mouse_event",uint,1,int,x1,int,y1,uint,0,int,0)
}

press_key(key, press_time)
{
    Send, {%key% DownTemp}
    Sleep %press_time%
    Send, {Blind}{%key% up}
    Sleep %press_time%
}

UpdateText(ControlID, NewText) ;Copy From AHK Windows Spy, preventing periodic flickering
{
	static OldText := {}
    NewText := "自动: " AutoMode "|" RunningMode "|" Fcn_Status "|" Gun_Using
	if (OldText[ControlID] != NewText)
	{
		GuiControl, 1:, % ControlID, % NewText
		OldText[ControlID] := NewText
	}
}
;==================================================================
;The end
