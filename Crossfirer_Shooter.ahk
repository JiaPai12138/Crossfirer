#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#SingleInstance, force
#IfWinActive ahk_class CrossFire  ; Chrome_WidgetWin_1 CrossFire
#Include Crossfirer_Functions.ahk  
#KeyHistory 0
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;CoordMode, Pixel, Screen ;Client 
CoordMode, Mouse, Screen
Process, Priority, , H  ;进程高优先级
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
;==================================================================================
global SHT_Service_On := False
CheckPermission()
;==================================================================================
AutoMode := False
XGui1 := 0, YGui1 := 0, XGui2 := 0, YGui2 := 0, Xch := 0, Ych := 0
Temp_Mode := "", Temp_Run := ""
crosshair = 34-35 2-35 2-36 34-36 34-60 35-60 35-36 67-36 67-35 35-35 ;35-11 34-11 ;For "T" type crosshair
game_title := 
GamePing :=

If WinExist("ahk_class CrossFire")
{
    WinGetTitle, game_title, ahk_class CrossFire
    CheckPosition(ValueX, ValueY, ValueW, ValueH)
    Start:
    Gui, fcn_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_mode: Margin, 0, 0
    Gui, fcn_mode: Color, 333333 ;#333333
    Gui, fcn_mode: Font, s15, Microsoft YaHei
    Gui, fcn_mode: Add, Text, hwndGui_1 vModeOfFcn cFFFF00, 暂停加载 ;#FFFF00
    GuiControlGet, P1, Pos, %Gui_1%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui1, YGui1, "M", -Round(ValueW / 8) - P1W // 2, Round(ValueH / 9) - P1H // 2)
    Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA

    Gui, fcn_status: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_status: Margin, 0, 0
    Gui, fcn_status: Color, 333333 ;#333333
    Gui, fcn_status: Font, s15, Microsoft YaHei
    Gui, fcn_status: Add, Text, hwndGui_2 vStatusOfFun cFFFF00, 自火关闭 ;#FFFF00
    GuiControlGet, P2, Pos, %Gui_2%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui2, YGui2, "M", -Round(ValueW / 8) - P2W // 2, Round(ValueH / 6) - P2H // 2)
    Gui, fcn_status: Show, x%XGui2% y%YGui2% NA

    Gui, cross_hair: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Hwndcr -DPIScale, Listening
    Gui, cross_hair: Color, FFFF00 ;#FFFF00
    SetGuiPosition(Xch, Ych, "M", -34, -35)
    Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    WinSet, Region, %crosshair%, ahk_id %cr%
    WinSet, Transparent, 255, ahk_id %cr%
    WinSet, ExStyle, +0x20 ; 鼠标穿透

    OnMessage(0x1001, "ReceiveMessage")

    ;If game_title = CROSSFIRE 
    ;    GamePing := Test_Game_Ping("172.217.1.142") + Test_Game_Ping("172.217.9.168")
    ;Else If game_title = 穿越火线
    ;    GamePing := Test_Game_Ping("203.205.239.243")
        
    ;If GamePing = 0 ;延迟大于300或者连接不上就没有玩的必要
    ;    ExitApp
    FuncPing()
    SHT_Service_On := True
    WinActivate, ahk_class CrossFire ;激活该窗口
    Return
}
;==================================================================================
~*-::ExitApp

~*RAlt::
    If SHT_Service_On
    {
        SetGuiPosition(XGui1, YGui1, "M", -Round(ValueW / 8) - P1W // 2, Round(ValueH / 9) - P1H // 2)
        SetGuiPosition(XGui2, YGui2, "M", -Round(ValueW / 8) - P2W // 2, Round(ValueH / 6) - P2H // 2)
        SetGuiPosition(Xch, Ych, "M", -34, -35)
        Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA
        Gui, fcn_status: Show, x%XGui2% y%YGui2% NA
        Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    }
Return

~*` Up::
    If SHT_Service_On
        ChangeMode("fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", AutoMode, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
Return

~*1 Up:: ;还原模式
    If (SHT_Service_On && AutoMode && !Not_In_Game() && StrLen(Temp_Run) > 0)
    {
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", Temp_Run, XGui1, YGui1)
        AutoFire(Temp_Mode, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }
Return

~*2 Up:: ;手枪模式
    If (SHT_Service_On && AutoMode && !Not_In_Game())
    {
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载手枪", XGui1, YGui1)
        AutoFire(2, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }
Return

~*Tab Up:: ;通用模式
    If (SHT_Service_On && AutoMode && !Not_In_Game())
    {
        Temp_Mode := 0
        Temp_Run := "加载通用"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载通用", XGui1, YGui1)
        AutoFire(0, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }  
Return

~*J Up:: ;瞬狙模式,M200效果上佳
    If (SHT_Service_On && AutoMode && !Not_In_Game())
    {
        Temp_Mode := 8
        Temp_Run := "加载狙击"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载狙击", XGui1, YGui1)
        AutoFire(8, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }
Return

~*L Up:: ;连点模式
    If (SHT_Service_On && AutoMode && !Not_In_Game())
    {
        Temp_Mode := 111
        Temp_Run := "加载速点"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载速点", XGui1, YGui1)
        AutoFire(111, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }  
Return
;==================================================================================
FuncPing()
{
	Gui, Ping_Ev: New, +LastFound +AlwaysOnTop -DPIScale
    Gui, Ping_Ev: Font, s12, Microsoft YaHei
    Gui, Ping_Ev: Add, Text, , 请输入游戏稳定延迟(ping值)
	Gui, Ping_Ev: Add, Edit, vPing_Input w255
	Gui, Ping_Ev: Add, Button, gPingCheck w255, 提交/Submit
	Gui, Ping_Ev: Show, Center, Ping
}

PingCheck() 
{
	global Ping_Input, GamePing
	Gui, Ping_Ev: Submit
	If !Ping_Is_Valid(Ping_Input)
	{
		MsgBox, 16, 错误输入/Invalid Input, %Ping_Input%
		FuncPing()
	}
    Else
    {
        Gui, Ping_Ev: Destroy
        GamePing := Ping_Input
    }
}
;==================================================================================