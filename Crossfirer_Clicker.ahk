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
CoordMode, Pixel, Screen
;CoordMode, Mouse, Screen
Process, Priority, , H  ;进程高优先级
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
;==================================================================================
CheckPermission()
;==================================================================================
If WinExist("ahk_class CrossFire")
{
    Start:
    Gui, click_mode: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, click_mode: Margin, 0, 0
    Gui, click_mode: Color, 333333 ;#333333
    Gui, click_mode: Font, s15, Microsoft YaHei
    Gui, click_mode: Add, Text, hwndGui_4 vModeClick c00FF00, 连点准备 ;#00FF00
    WinSet, TransColor, 333333 155 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui3, YGui3, "M", -50, 200)
    Gui, click_mode: Show, x%XGui3% y%YGui3% NA, Listening
} 
Else 
{
    MsgBox, , 错误/Error, CF未运行!脚本将退出!!`nCrossfire is not running!The script will exit!!
    ExitApp
}

OnMessage(0x1001, "ReceiveMessage")
Return
;==================================================================================
~*-::ExitApp

~*RAlt::
    SetGuiPosition(XGui3, YGui3, "M", -50, 200)
    Gui, click_mode: Show, x%XGui3% y%YGui3% NA, Listening
Return

~*MButton:: ;爆裂者轰炸
    If !Not_In_Game()
    {
        UpdateText("click_mode", "ModeClick", "右键连点", XGui3, YGui3)
        While, !(GetKeyState("R", "P") || GetKeyState("LButton", "P") || GetKeyState("`", "P"))
        {
            press_key("RButton", 10.0, 60.0)
        }
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{RButton Up}
    }
Return

~*XButton2:: ;半自动速点,适合救世主步枪
    If !Not_In_Game()
    {
        ;UpdateText("click_mode", "ModeClick", "左键连点", XGui3, YGui3)
        While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P") || GetKeyState("`", "P"))
        {
            press_key("LButton", 42.8, 42.8) ;FAL CAMO射速700
            ;press_key("LButton", 50.0, 50.0) ;For click test
            ;press_key("LButton", 43.8, 43.75) ;M4A1射速685
        }
        ;UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return

~*XButton1:: ;半自动速点,适合加特林速点,不适合USP
    If !Not_In_Game()
    {
        UpdateText("click_mode", "ModeClick", "左键速点", XGui3, YGui3)
        While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P") || GetKeyState("`", "P"))
        {
            press_key("LButton", 30.0, 29.75)
        }
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return

~*K:: ;粉碎者直射
    If !Not_In_Game()
    {
        UpdateText("click_mode", "ModeClick", "左键不放", XGui3, YGui3)
        Send, {Blind}{LButton Up}
        HyperSleep(30)
        Send, {LButton Down}
        While, !(GetKeyState("R", "P") || GetKeyState("`", "P") || GetKeyState("RButton", "P"))
        {
            HyperSleep(100)
        }
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return
;==================================================================================