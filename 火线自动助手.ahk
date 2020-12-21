#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#MenuMaskKey vkFF  ; vkFF is no mapping
#SingleInstance, force
#IfWinActive ahk_exe crossfire.exe  ; Only active while crossfire is running
CoordMode, Pixel, Screen
Process, Priority, , H
;══════════════════════════════════════════════════════════════════
global PosColor1 := "0x353796 0x353797 0x353798 0x353799 0x343799 0x34379A 0x34389A 0x34389B 0x34389C 0x33389C 0x33389D 0x33389E 0x33389F 0x32389F 0x32399F 0x3239A0 0x3239A1 0x3239A2 0x3139A2 0x3139A3 0x3139A4 0x313AA4 0x313AA5 0x303AA5 0x303AA6 0x303AA7 0x303AA8 0x2F3AA8 0x2F3AA9 0x2F3BA9 0x2F3BAA 0x2F3BAB 0x2E3BAB 0x2E3BAC 0x2E3BAD 0x2E3BAE 0x2E3CAE 0x2D3CAE 0x2D3CAF 0x2D3CB0 0x2D3CB1 0x2C3CB1 0x2C3CB2 0x2C3CB3 0x2C3DB3 0x2C3DB4 0x2B3DB4 0x2B3DB5 0x2B3DB6 0x2B3DB7 0x2A3DB7 0x2A3EB7 0x2A3EB8 0x2A3EB9 0x2A3EBA 0x293EBA 0x293EBB 0x293EBC 0x293FBC 0x293FBC 0x293FBD 0x283FBD 0x283FBE 0x283FBF 0x283FC0 0x273FC0 0x273FC1 0x2740C1 0x2740C2 0x2740C3 0x2640C4 0x2640C5 0x2640C6 0x2641C6 0x2641C7 0x2541C7 0x2541C8 0x2541C9 0x2541CA 0x2441CA 0x2441CB 0x2442CB 0x2442CC 0x2442CD 0x2342CD 0x2342CE 0x2342CF 0x2342D0 0x2343D0 0x2243D0 0x2243D1 0x2243D2 0x2243D3 0x2143D3 0x2143D4 0x2144D4 0x2144D5 0x2144D6 0x2044D6 0x2044D7 0x2044D8 0x2044D9 0x1F44D9 0x1F45D9 0x1F45DA 0x1F45DB 0x1F45DC 0x1E45DC 0x1E45DD 0x1E45DE 0x1E46DE 0x1D46DF 0x1D46E0 0x1D46E1 0x1D46E2 0x1C46E3 0x1C47E3 0x1C47E4 0x1C47E5 0x1B47E5 0x1B47E6 0x1B47E7 0x1B48E8 0x1A48E8 0x1A48E9 0x1A48EA 0x1A48EB 0x1948EC 0x1948ED 0x1949ED 0x1949EE 0x1849EF 0x1849F0 0x1849F1 0x174AF2" ;all detected values of color hex since it is changing
global PosColor2 := "0x000000 0x232323 0x101010 0x0F0F0F 0x070707 0x2F2F31"
crosshair = 34-35 10-35 10-36 34-36 34-60 35-60 35-36 59-36 59-35 35-35 35-11 34-11
global AutoMode := 1 ;on/off switch
global RunningMode := "加载脚本"

WinGetPos, X, Y, W, H, ahk_exe crossfire.exe ;get top left position of the window
global X, Y, W, H
;easier to change data
global XGui1 := X + 694
global YGui1 := Y
global XGui2 := X + 2
global YGui2 := Y + 264
global Xch := X + W // 2 - 34
global Ych := Y + H // 2 - 20

If (W + H) > 0
{
    Start:
    Gui, 1: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, 1: Margin, 0, 0
    Gui, 1: Color, 333333
    Gui, 1: Font, s16, Verdana  
    Gui, 1: Add, Text, vMyText c00FF00, 延长显示框长度~
    Gui, 1: Show, x%XGui1% y%YGui1% NA
    WinSet, ExStyle, +0x20  ; 鼠标穿透
    SetTimer, ShowMode, 200 
    Gosub, ShowMode 

    Gui, 2: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, 2: Margin, 0, 0
    Gui, 2: Color, 333333
    Gui, 2: Font, s12 c00FF00, Verdana  
    Gui, 2: add, Text,, ╔════使用══说明════╗
    Gui, 2: add, Text,, ║按大写锁定开关脚本
    Gui, 2: add, Text,, ║按1236JKL选择模式
    Gui, 2: add, Text,, ║按1═══步枪模式═══
    Gui, 2: add, Text,, ║按2═══手枪模式═══
    Gui, 2: add, Text,, ║按3═══关闭模式═══
    Gui, 2: add, Text,, ║按6═══机枪模式═══
    Gui, 2: add, Text,, ║按J═══狙击关镜═══
    Gui, 2: add, Text,, ║按K═══连发模式═══
    Gui, 2: add, Text,, ║按L═══速点模式═══
    Gui, 2: add, Text,, ║按0═══重新加载═══
    Gui, 2: add, Text,, ╚════使用══说明════╝
    WinSet, TransColor, 333333 150
    Gui, 2: Show, x%XGui2% y%YGui2% NA
    WinSet, ExStyle, +0x20  ; 鼠标穿透

    Gui, crosshair: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Owner +E0x08000000
    Gui, crosshair: Margin, 0, 0
    Gui, crosshair: Color, 0000FF
    Gui, crosshair: Add, Progress, x0 y0 w52 h52 c00FFFF -border vCrosshair,100 ; 
    Gui, crosshair: Show, x%Xch% y%Ych% 
    WinSet, TransColor, 0000FF
    WinSet, Region, %crosshair%, A 
    WinSet, ExStyle, +0x20  ; 鼠标穿透
    return
}  
;══════════════════════════════════════════════════════════════════
~*0::Reload
~*Delete::ExitApp

;~*$LButton::
;    ReduceRecoil(0, 30, 30) 
;return

~*`::
    ;Suspend ;挂起热键
    ChangeMode(1)
return

~*1::
    ChangeMode(2)
    RunningMode := "加载步枪"
    AutoFire(1)
return
    
~*2::
    ChangeMode(2)
    RunningMode := "加载手枪"
    AutoFire(0)
return

~*J:: ;sniper 1 vs 1 mode
    ChangeMode(2)
    RunningMode := "加载狙击"
    AutoFire(8)
return

~*6:: ;machine gun
    ChangeMode(2)
    RunningMode := "加载机枪"
    AutoFire(11)
return

~*L:: ;Gatling gun, sniper gun, shotgun
    ChangeMode(2)
    RunningMode := "加载速点"
    AutoFire(111)
return
;══════════════════════════════════════════════════════════════════
~*W & ~*F:: ;地面连跳蹲
    cnt:= 0
    Send, {Space}
    Sleep, 6
    Send, {LCtrl Down}
    Loop
    {
        Send, {Space}
        Sleep, 6
        cnt ++
        If (GetKeyState("LButton", "P") || cnt >= 160)
        {
            break
        }
    }
    Send, {Blind}{LCtrl Up}
return

~*!W:: ;空中连蹲跳 alt+w
    cnt:= 0
    Send, {Space}
    Sleep, 240
    Loop
    {
        Send, {Ctrl}
        Sleep, 10
        cnt ++
        If (not GetKeyState("W", "P") || cnt >= 20)
        {
            break
        }
    }
return

~*S & ~*F:: ;跳蹲上墙
    While, Not (GetKeyState("E") || (GetKeyState("LButton", "P")))
	{
		Send, {Space}
        Sleep, 20
        Send, {Ctrl}
        Sleep, 20
	}
return
;══════════════════════════════════════════════════════════════════
~*MButton:: ;爆裂者轰炸
	If (AutoMode = 0)
    {
        While, Not (GetKeyState("R", "P") || GetKeyState("LButton", "P") || GetKeyState("`", "P"))
	    {
		    Send, {RButton Down}
		    Sleep, 10
		    Send, {Blind}{RButton Up}
		    Sleep, 60
	    }
	    Send, {Blind}{RButton Up}
    }
return

~*XButton2:: ;半自动速点
    If (AutoMode = 0)
    {
        While, Not (GetKeyState("E", "P") || GetKeyState("RButton", "P") || GetKeyState("`", "P"))
	    {
		    Random, rand, 58, 62
		    Send, {LButton Down}
		    Sleep, rand
		    Send, {Blind}{LButton Up}
		    Sleep, rand
	    }
	    Send, {Blind}{LButton Up}
    }
return

~*K:: ;粉碎者直射
    If (AutoMode = 0)
    {
	    Send, {Blind}{LButton Up}
	    Sleep, 10
        Send, {LButton Down}
        While, Not (GetKeyState("R", "P") || GetKeyState("`", "P"))
	    {
		    Sleep, 300
		    If (GetKeyState("3", "P"))
		    {
			    Send, {Blind}{LButton Up}
			    break
		    }
	    }
        Send, {Blind}{LButton Up}
    }
return
;══════════════════════════════════════════════════════════════════
ChangeMode(qie_huan)
{
    Loop, %qie_huan%
    {
        AutoMode := Abs(AutoMode - 1)
        Sleep, 120
    }
    If (AutoMode = 1)
    {
        Gui, 2: hide
    }
    Else
    {
        Gui, 2: Show, x%XGui2% y%YGui2% NA
    }
}
;══════════════════════════════════════════════════════════════════
AutoFire(ya_qiang)
{
    PixelGetColor, color_edge, (X + 1130), (Y + 58)
    While, Not (AutoMode = 0 || InStr(PosColor2, color_edge))
    {
        Var := 798
        Loop ;detect color in three lines where shows the enemy name
        {
            PixelGetColor, color1, (X + Var), (Y + 538)
            PixelGetColor, color2, (X + Var), (Y + 540)
            PixelGetColor, color3, (X + Var), (Y + 542)
            Var ++

            If (GetKeyState("3", "P") || GetKeyState("4", "P"))
            {
                RunningMode := "目前暂无"
                Exit ;exit current thread
            }

            PixelGetColor, color4, (X + 1000), (Y + 483)
            PixelGetColor, color5, (X + 1565), (Y + 915)
            If (RunningMode = "瞬狙模式" && (color4 = 0x000000 || color5 = 0x000000))
            {
                Send, {RButton Down}
                Sleep, 10
                Send, {Blind}{RButton Up}
                Sleep, 60
            }

            If (InStr(PosColor1, color1) || InStr(PosColor1, color2) || InStr(PosColor1, color3)) ;if detected color is found in string
            {
                Random, rand, 118, 122 ;set random value trying to avoid VAC
                switch ya_qiang
                {
                    case 1:
                        RunningMode := "步枪模式" ;双重验证
                        Send, {LButton Down}
                        ReduceRecoil(5, 30, 30)
                        Send, {Blind}{LButton Up}
                        Sleep, (rand + 120)
                    break
                    
                    case 0:
                        RunningMode := "手枪模式"
                        Send, {LButton Down}
                        Sleep, (rand - 90)
                        Send, {LButton Up}
                        Sleep, (rand - 90)
                    break

                    case 8:
                        RunningMode := "瞬狙模式"
                        Send, {RButton Down}
                        Sleep, 5
                        Send, {Blind}{RButton Up}
                        Sleep, 5
                        Send, {LButton Down}
                        Sleep, 10
                        Send, {Blind}{LButton Up} 
                        Sleep, 60
                    break

                    case 11:
                        RunningMode := "机枪模式"
                        Send, {LButton Down}
                        ReduceRecoil(25, 40, 40)
                        Send, {Blind}{LButton Up}
                    break

                    case 111:
                        RunningMode := "连发速点"
                        Send, {LButton Down}
                        Sleep, (rand - 60)
                        Send, {Blind}{LButton Up}
                        Sleep, (rand - 60)
                    break
                    
                    Default:
                    break
                }
            }
        } Until ( Var = 808 )
    }
    return
}

ReduceRecoil(chong_fu, yan_chi, jian_ge) 
{
	cnt := 0
    Sleep, yan_chi
    while, (GetKeyState("Lbutton", "P") || (cnt < chong_fu))
	{
        Send, {LButton DownTemp}
        Sleep, jian_ge
        mouseXY(0, 1.5)
        Send, {Blind}{LButton Up}
        Sleep, jian_ge
		cnt ++
    }
	return
}

mouseXY(x1,y1)
{
    DllCall("mouse_event",uint,1,int,x1,int,y1,uint,0,int,0)
}

ShowMode:
    GuiControl,, MyText, 自动:%AutoMode% %RunningMode%
return 
;══════════════════════════════════════════════════════════════════
;The end
