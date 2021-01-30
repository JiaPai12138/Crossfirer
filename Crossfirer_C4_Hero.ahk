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
global C4H_Service_On := False
CheckPermission()
CheckCompile()
;==================================================================================
Xe := , Ye := , We := , He := , Offset1Up := , Offset1Down :=
C4_Time := 40
C4_Start := 0
Be_Hero := False
C4_On := False

If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He, Offset1Up, Offset1Down)
    Start:
    Gui, C4: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, C4: Margin, 0, 0
    Gui, C4: Color, 333333 ;#333333
    Gui, C4: Font, s15 c00FF00, Microsoft YaHei
    Gui, C4: Add, Text, hwndGui_3 vC4Status, %C4_Time% ;#00FF00 
    GuiControlGet, P3, Pos, %Gui_3%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGuiC, YGuiC, "M", -P3W // 2, Round((He - Offset1Up - Offset1Down) / 7.5) - P3H // 2) ;避开狙击枪秒准线确认点
    Gui, C4: Show, Hide

    Gui, Human_Hero: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Human_Hero: Margin, 0, 0
    Gui, Human_Hero: Color, 333333 ;333333
    Gui, Human_Hero: Font, s15 c00FF00, Microsoft YaHei ;#00FF00
    Gui, Human_Hero: Add, Text, hwndhero vIMHero, 猎手
    GuiControlGet, PH, Pos, %hero%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20
    SetGuiPosition(XGui8, YGui8, "M", -PHW // 2, Round((He - Offset1Up - Offset1Down) / 7.5) - PHH // 2) ;避开狙击枪秒准线确认点
    Gui, Human_Hero: Show, Hide
    OnMessage(0x1001, "ReceiveMessage")
    C4H_Service_On := True
    Return
} 
Else If !WinExist("ahk_class CrossFire") && !A_IsCompiled
{
    MsgBox, 16, 错误/Error, CF未运行!脚本将退出!!`nCrossfire is not running!The script will exit!!, 3
    ExitApp
}
;==================================================================================
~*-::ExitApp

~*=::
    If C4H_Service_On
    {
        If WinActive("ahk_class CrossFire")
            Be_Hero := !Be_Hero
    
        If (Be_Hero && !Not_In_Game())
        {
            C4_On := False
            SetTimer, UpdateHero, 60
            SetTimer, UpdateC4, off
            Gui, C4: Show, Hide
            Gui, Human_Hero: Show, x%XGui8% y%YGui8% NA
        }
        Else
        {
            SetTimer, UpdateHero, off
            Gui, Human_Hero: Show, Hide
        }
    }
Return

~*RAlt::
    If C4H_Service_On
    {
        SetGuiPosition(XGuiC, YGuiC, "M", -P3W // 2, Round((He - Offset1Up - Offset1Down) / 7.5) - P3H // 2)
        SetGuiPosition(XGui8, YGui8, "M", -PHW // 2, Round((He - Offset1Up - Offset1Down) / 7.5) - PHH // 2)
        If Be_Hero
        {
            Gui, Human_Hero: Show, x%XGui8% y%YGui8% NA
            Gui, C4: Show, Hide
        }
        Else
            Gui, Human_Hero: Show, Hide

        If C4_On
        {
            Gui, C4: Show, x%XGuiC% y%YGuiC% NA
            Gui, Human_Hero: Show, Hide
        }
        Else
            Gui, C4: Show, Hide
    }
Return

~C & ~4::
    If !Not_In_Game() && C4H_Service_On
    {
        Be_Hero := False
        C4_On := True
        SetTimer, UpdateC4, 100
        SetTimer, UpdateHero, off
        Gui, C4: Show, x%XGuiC% y%YGuiC% NA
        Gui, Human_Hero: Show, Hide
    }
Return

~C & ~5::
    If !Not_In_Game() && C4H_Service_On
    {
        C4_On := False
        SetTimer, UpdateC4, off
        Gui, C4: Show, Hide
    }
Return
;==================================================================================
UpdateC4() ;精度0.1s
{
    global XGuiC, YGuiC, C4_Start, C4_Time, C4Status
    C4Timer(XGuiC, YGuiC, C4_Start, C4_Time, "C4", "C4Status")
}

UpdateHero() ;精度0.06s
{
    global Xe, Ye, We, He, Be_Hero, XGuiE, YGuiE, Offset1Up, Offset1Down, XGui8, YGui8
    CheckPosition(Xe, Ye, We, He, Offset1Up, Offset1Down)
    GuiControl, Human_Hero: +c00FF00 +Redraw, IMHero ;#00FF00
    UpdateText("Human_Hero", "IMHero", "猎手", XGui8, YGui8)
    If (Be_Hero && !Not_In_Game())
    {
        PixelSearch, HeroX1, HeroY1, Xe + We // 2 - Round(We / 32 * 3), Ye + Offset1Up + Round((He - Offset1Up - Offset1Down) / 8.5), Xe + We // 2 + Round(We / 32 * 3), Ye + Offset1Up + Round((He - Offset1Up - Offset1Down) / 6.5), 0xFFFFFF, 0, Fast ;#FFFFFF 猎手vs幽灵数字
        If !ErrorLevel
        {
            PixelSearch, HeroX2, HeroY2, Xe + We // 2 - Round(We / 32 * 3), Ye + Offset1Up + Round((He - Offset1Up - Offset1Down) / 3) - 5, Xe + We // 2 + Round(We / 32 * 3), Ye + Offset1Up + Round((He - Offset1Up - Offset1Down) / 3), 0x1EB4FF, 0, Fast ;#FFB41E #1EB4FF 变猎手字样
            If !ErrorLevel
            {
                press_key("E", 10, 10)
                GuiControl, Human_Hero: +cFFFF00 +Redraw, IMHero ;#FFFF00
                UpdateText("Human_Hero", "IMHero", "猎手", XGui8, YGui8) ;猎手闪烁
            }
        }
    }
}
;==================================================================================