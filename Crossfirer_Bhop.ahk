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
Process, Priority, , A  ;进程略高优先级
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
    WinMinimize, ahk_class ConsoleWindowClass
    Start:
    Gui, jump_mode: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, jump_mode: Margin, 0, 0
    Gui, jump_mode: Color, 333333 ;#333333
    Gui, jump_mode: Font, s15, Microsoft YaHei
    Gui, jump_mode: Add, Text, hwndGui_4 vModeJump c00FF00, 跳蹲准备 ;#00FF00
    WinSet, TransColor, 333333 155 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui4, YGui4, "M", -50, 250)
    Gui, jump_mode: Show, x%XGui4% y%YGui4% NA, Listening
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
    SetGuiPosition(XGui4, YGui4, "M", -50, 250)
    Gui, jump_mode: Show, x%XGui4% y%YGui4% NA, Listening
Return

~W & ~F:: ;基本鬼跳 间隔600 因t_accuracy=0.991调整
    If !Not_In_Game()
    {
        cnt := 0
        UpdateText("jump_mode", "ModeJump", "基本鬼跳", XGui4, YGui4)
        press_key("space", 100, 100)
        Send, {LCtrl Down}
        HyperSleep(300)
        Loop 
        {
            press_key("space", 10, 10)   
            cnt += 1
        } Until, (!GetKeyState("W", "P") || cnt >= 140)
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
        Send, {Blind}{LCtrl Up}
    }
Return 

~W & ~Alt:: ;空中连蹲跳 w+alt
    If !Not_In_Game()
    {
        UpdateText("jump_mode", "ModeJump", "空中连蹲", XGui4, YGui4)
        cnt:= 0
        press_key("space", 30, 30)
        HyperSleep(140)
        Loop
        {
            press_key("LCtrl", 15, 15)
            cnt += 1
        } Until, (!GetKeyState("W", "P") || cnt >= 15)
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~S & ~F:: ;跳蹲上墙
    If !Not_In_Game()
    {
        UpdateText("jump_mode", "ModeJump", "跳蹲上墙", XGui4, YGui4)
        Loop
        {
            press_key("space", 30, 30)
            press_key("LCtrl", 30, 30)
        } Until, (GetKeyState("E", "P") || GetKeyState("LButton", "P"))
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return
;==================================================================================
