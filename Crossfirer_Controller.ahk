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
CoordMode, Mouse, Screen
Process, Priority, , H  ;进程高优先级
DetectHiddenWindows, On
SetTitleMatchMode, 2
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
;==================================================================================
CheckPermission()
;==================================================================================
WinMinimize, ahk_class ConsoleWindowClass
SetTimer, UpdateGui, 100
;==================================================================================
~*-::
    If WinActive("ahk_class CrossFire")
    {
        WinClose, ahk_class ConsoleWindowClass
        Run, .\open_Crossfirer.bat
        ExitApp
    }
Return

CapsLock:: ;minimize window and replace origin use
    If WinActive("ahk_class CrossFire")
    {
        WinMinimize, ahk_class CrossFire
        HyperSleep(100)
        MouseMove, A_ScreenWidth // 2, A_ScreenHeight // 2 ;The middle of screen
    }
Return

UpdateGui() ;Gui 2 will be repositioned while modes changing
{
    If !WinExist("ahk_class CrossFire")
    {
        WinClose, ahk_class ConsoleWindowClass
        WinGetTitle, Gui_Title, ahk_class AutoHotkeyGUI
        Loop
        {
            PostMessage("Listening", 125638)
            HyperSleep(30) ;just for stability
        } Until, Not (WinExist("Crossfirer_Shooter.ahk") || WinExist("Crossfirer_C4_Hero.ahk") || WinExist("Crossfirer_Bhop.ahk") || WinExist("Crossfirer_Clicker.ahk") || WinExist("Crossfirer_Recoilless.ahk"))
        ExitApp
    }
}