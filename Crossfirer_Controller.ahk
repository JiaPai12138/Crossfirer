#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#SingleInstance, force
#IfWinActive ahk_class CrossFire  ; Only active while crossfire is running
#Include Crossfirer_Functions.ahk  
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Process, Priority, , H  ;进程高优先级
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
;==================================================================================
CheckPermission()
;==================================================================================
SetTimer, UpdateGui, 100
;==================================================================================
~*-::
    WinClose, ahk_class ConsoleWindowClass
    Run, .\open_Crossfirer.bat
ExitApp

~*CapsLock Up:: ;minimize window 
    WinMinimize, ahk_class CrossFire
Return

UpdateGui() ;Gui 2 will be repositioned while modes changing
{    
    If !WinExist("ahk_class CrossFire")
    {
        WinClose, ahk_class ConsoleWindowClass
        WinGetTitle, Gui_Title, ahk_class AutoHotkeyGUI
        Loop
        {
            PostMessage("Listening", 1)
            WinGetTitle, Gui_Title, ahk_class AutoHotkeyGUI
            HyperSleep(30) ;just for stability
        } Until Not Gui_Title
        ExitApp
    }
}