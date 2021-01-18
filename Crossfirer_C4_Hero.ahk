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
Xe := , Ye := , We := , He := 
C4_Time := 40
C4_Start := 0
Be_Hero := False

If WinExist("ahk_class CrossFire")
{
    WinMinimize, ahk_class ConsoleWindowClass
    WinGetPos, Xe, Ye, We, He, ahk_class CrossFire
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

    Gui, Human_Hero: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Human_Hero: Margin, 0, 0
    Gui, Human_Hero: Color, 00FF00 ;#333333
    Gui, Human_Hero: Font, s15, Microsoft YaHei
    Gui, Human_Hero: Add, Text, hwndhero, _ ;#00FF00
    GuiControlGet, P1, Pos, %hero%
    WinSet, ExStyle, +0x20
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

~*=::
    If WinActive("ahk_class CrossFire")
        Be_Hero := !Be_Hero
    
    If Be_Hero
    {
        SetTimer, UpdateHero, 50
        SetTimer, UpdateC4, off
        SetGuiPosition(XGui8, YGui8, "H", -P1W / 2, 0)
        Gui, Human_Hero: Show, x%XGui8% y%YGui8% NA, Listening
    }
    Else
    {
        SetTimer, UpdateHero, off
        Gui, Human_Hero: Show, Hide, Listening
    }
Return

~*RAlt::
    WinGetPos, Xe, Ye, We, He, ahk_class CrossFire
    SetGuiPosition(XGuiC, YGuiC, "M", -14, 50)
    SetGuiPosition(XGui, YGui, "H", -P1W / 2, 0)
    Gui, C4: Show, Hide, Listening
    Gui, Human_Hero: Show, Hide, Listening
Return

~C & ~4::
    If !Not_In_Game()
    {
        SetTimer, UpdateC4, 50
        SetTimer, UpdateHero, off
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
    global XGuiC, YGuiC, C4_Start, C4_Time
    C4Timer(XGuiC, YGuiC, C4_Start, C4_Time, "C4", "C4Status")
}

UpdateHero() ;精度0.1s 卡住时切换武器刷新
{
    global Xe, Ye, We, He, Be_Hero
    PixelSearch, HeroX1, HeroY1, Xe + We / 2 - 50, Ye + He / 3 * 2, Xe + We / 2 + 50, Ye + He / 11 * 8, 0x088BCE, 1, Fast ;#CE8B08 #088BCE
    If (!ErrorLevel && Be_Hero && !Not_In_Game())
    {
        press_key("E", 30, 30)
        PixelSearch, HeroX1, HeroY1, Xe + We / 2 - 50, Ye + He / 3 * 2, Xe + We / 2 + 50, Ye + He / 11 * 8, 0x088BCE, 1, Fast ;#CE8B08 #088BCE
        If ErrorLevel
        {
            SetTimer, UpdateHero, off
            Gui, Human_Hero: Show, Hide, Listening
        }
    }
}
;==================================================================================