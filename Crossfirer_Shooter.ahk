#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#SingleInstance, force
#IfWinActive ahk_class CrossFire  ; Chrome_WidgetWin_1 CrossFire
#Include Crossfirer_Functions.ahk  
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
Process, Priority, , H  ;进程高优先级
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
;==================================================================================
CheckPermission()
;==================================================================================
AutoMode := True
XGui1 := 0, YGui1 := 0, XGui2 := 0, YGui2 := 0, Xch := 0, Ych := 0
Temp_Mode := "", Temp_Run := ""
crosshair = 34-35 2-35 2-36 34-36 34-60 35-60 35-36 67-36 67-35 35-35 ;35-11 34-11 ;For "T" type crosshair
game_title := 

If WinExist("ahk_class CrossFire")
{
    WinMinimize, ahk_class ConsoleWindowClass
    WinGetTitle, game_title, ahk_class CrossFire
    ;global TempX := X, TempY := Y
    Start:
    Gui, fcn_mode: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_mode: Margin, 0, 0
    Gui, fcn_mode: Color, 333333 ;#333333
    Gui, fcn_mode: Font, s15, Microsoft YaHei
    Gui, fcn_mode: Add, Text, hwndGui_1 vModeOfFcn c00FF00, 加载模式 ;#00FF00
    WinSet, TransColor, 000000 255 ;#000000
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui1, YGui1, "H", -400, 0)
    Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA, Listening

    Gui, fcn_status: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_status: Margin, 0, 0
    Gui, fcn_status: Color, 333333 ;#333333
    Gui, fcn_status: Font, s15, Microsoft YaHei
    Gui, fcn_status: Add, Text, hwndGui_2 vStatusOfFun c00FF00, 自火开启
    WinSet, TransColor, 000000 255 ;#000000
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui2, YGui2, "H", -250, 0)
    Gui, fcn_status: Show, x%XGui2% y%YGui2% NA, Listening

    Gui, cross_hair: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Hwndcr -DPIScale
    Gui, cross_hair: Color, 00FF00 ;#00FF00
    SetGuiPosition(Xch, Ych, "M", -34, -38)
    Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA, Listening
    WinSet, Region, %crosshair%, ahk_id %cr%
    WinSet, Transparent, 255, ahk_id %cr%
    WinSet, ExStyle, +0x20 ; 鼠标穿透
} 
Else 
{
    MsgBox,, 错误/Error, CF未运行!脚本将退出!!`nCrossfire is not running!The script will exit!!
    ExitApp
}

OnMessage(0x1001, "ReceiveMessage")
Return
;==================================================================================
~*-::ExitApp

~*RAlt::
    SetGuiPosition(XGui1, YGui1, "H", -400, 0)
    SetGuiPosition(XGui2, YGui2, "H", -250, 0)
    SetGuiPosition(Xch, Ych, "M", -34, -38)
    Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA, Listening
    Gui, fcn_status: Show, x%XGui2% y%YGui2% NA, Listening
    Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA, Listening
Return

~*` Up::
    ChangeMode("fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", AutoMode, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
Return

~*1 Up::
    If (AutoMode && !Not_In_Game() && StrLen(Temp_Run) > 0)
    {
        UpdateText("fcn_mode", "ModeOfFcn", Temp_Run, XGui1, YGui1)
        AutoFire(Temp_Mode, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
    }
Return

~*2 Up::
    If (AutoMode && !Not_In_Game())
    {
        UpdateText("fcn_mode", "ModeOfFcn", "加载手枪", XGui1, YGui1)
        AutoFire(2, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
    }
Return

~*Tab Up::
    If (AutoMode && !Not_In_Game())
    {
        Temp_Mode := 0
        Temp_Run := "加载通用"
        UpdateText("fcn_mode", "ModeOfFcn", "加载通用", XGui1, YGui1)
        AutoFire(0, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
    }  
Return

~*J Up:: ;sniper 1 vs 1 mode
    If (AutoMode && !Not_In_Game())
    {
        Temp_Mode := 8
        Temp_Run := "加载狙击"
        UpdateText("fcn_mode", "ModeOfFcn", "加载狙击", XGui1, YGui1)
        AutoFire(8, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
    }
Return

~*L Up:: ;Gatling gun, sniper gun, shotgun
    If (AutoMode && !Not_In_Game())
    {
        Temp_Mode := 111
        Temp_Run := "加载速点"
        UpdateText("fcn_mode", "ModeOfFcn", "加载速点", XGui1, YGui1)
        AutoFire(111, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
    }  
Return
;==================================================================================