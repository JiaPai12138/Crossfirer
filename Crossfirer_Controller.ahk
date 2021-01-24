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
Need_Help := False

If WinExist("ahk_class CrossFire")
{
    Start:
    Gui, Helper: +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Helper: Margin, 0, 0
    Gui, Helper: Color, 333333 ;#333333
    Gui, Helper: Font, s12 c00FF00, Microsoft YaHei ;#00FF00
    Gui, Helper: add, Text, hwndGui_8, ╔====使用==说明===╗`n     按~==开关自火===`n     按234JLTab选择模式`n     按2===手枪模式==`n     按3/4= 暂停模式==`n     按J===瞬狙模式==`n     按L===连发速点==`n     按Tab键=通用模式=`n================`n     鼠标中间键 右键连点`n     鼠标前进键 左键连点`n     鼠标后退键 左键速点`n     按W和F== 基础鬼跳`n     按W和Alt= 空中跳蹲`n     按S和F===跳蹲上墙`n================`n     按- =重新加载本脚本`n     按=  开关秒变猎手`n     大写锁定 最小化窗口`n╚====使用==说明===╝
    GuiControlGet, P2, Pos, %Gui_8%
    global P2H ;*= (A_ScreenDPI / 96)
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透

    Gui, Hint: +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Hint: Margin, 0, 0
    Gui, Hint: Color, 333333 ;#333333
    Gui, Hint: Font, s12 c00FF00, Microsoft YaHei ;#00FF00
    Gui, Hint: add, Text, hwndGui_9, 按`n右`nC`nt`nr`nl`n键`n开`n关`n帮`n助
    GuiControlGet, P3, Pos, %Gui_9%
    global P3H ;*= (A_ScreenDPI / 96)
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透

    SetGuiPosition(XGui9, YGui9, "V", 0, -P2H // 2)
    SetGuiPosition(XGui10, YGui10, "V", 0, -P3H // 2)
    Gui, Hint: Show, x%XGui10% y%YGui10% NA
    Gui, Helper: Show, Hide

    WinMinimize, ahk_class ConsoleWindowClass
    SetTimer, UpdateGui, 100
} 
Else 
{
    MsgBox, , 错误/Error, CF未运行!脚本将退出!!`nCrossfire is not running!The script will exit!!, 3
    ExitApp
}
;==================================================================================
~*-::
    If WinActive("ahk_class CrossFire")
    {
        WinClose, ahk_class ConsoleWindowClass
        Run, .\请低调使用.bat
        ExitApp
    }
Return

~*RAlt::
    SetGuiPosition(XGui9, YGui9, "V", 0, -P2H // 2)
    SetGuiPosition(XGui10, YGui10, "V", 0, -P3H // 2)
    ShowHelp(Need_Help, XGui9, YGui9, "Helper", XGui10, YGui10, "Hint", 0)
Return

~*RCtrl::
    ShowHelp(Need_Help, XGui9, YGui9, "Helper", XGui10, YGui10, "Hint", 1)
Return

CapsLock:: ;minimize window and replace origin use
    If WinActive("ahk_class CrossFire")
    {
        WinMinimize, ahk_class CrossFire
        HyperSleep(100)
        MouseMove, A_ScreenWidth // 2, A_ScreenHeight // 2 ;The middle of screen
    }
Return

UpdateGui()
{
    If !WinExist("ahk_class CrossFire")
    {
        WinClose, ahk_class ConsoleWindowClass
        Loop, 10
        {
            PostMessage("Listening", 125638)
            HyperSleep(100) ;just for stability
        }
        If ProcessExist("GameLoader.exe")
            Runwait, *RunAs %Comspec% /C taskkill /IM GameLoader.exe /F ;关闭游戏残留进程
        ExitApp
    }
}