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
;==================================================================
CheckPermission()
;==================================================================
X := , Y := , W := , H := 
game_title := 
global C4_Time := 40
global C4_Start := 0

If WinExist("ahk_class CrossFire")
{
    WinMinimize, ahk_class ConsoleWindowClass
    Start:
    Gui, C4: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, C4: Margin, 0, 0
    Gui, C4: Color, 333333 ;#333333
    Gui, C4: Font, s15, Microsoft YaHei
    Gui, C4: Add, Text, hwndGui_3 vC4Status c00FF00, %C4_Time% ;#00FF00
    WinSet, TransColor, 333333 155 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGuiC, YGuiC, "M", -14, 50)
    Gui, C4: Show, Hide, Listening
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
GuiClose:
ExitApp

~*RAlt::
    SetGuiPosition(XGuiC, YGuiC, "M", -14, 50)
    Gui, C4: Show, Hide, Listening
Return

~C & ~4::
    If !Not_In_Game()
    {
        SetTimer, UpdateC4, 100
        Gui, C4: Show, x%XGuiC% y%YGuiC% NA, Listening
    }
Return

~C & ~5::
    If !Not_In_Game()
    {
        SetTimer, UpdateC4, off
        Gui, C4: Show, Hide, Listening
    }
Return
;==================================================================================
UpdateC4() ;精度0.1s 卡住时切换武器刷新
{
    global XGuiC, YGuiC
    C4Timer(XGuiC, YGuiC, C4_Start, C4_Time, "C4", "C4Status")
}
;==================================================================================