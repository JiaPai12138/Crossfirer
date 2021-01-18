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
Gun_Chosen := 0
Radius := 30
Vertices := 40
Angle := 8 * ATan(1) / Vertices
Hole = 

If WinExist("ahk_class CrossFire")
{
    WinMinimize, ahk_class ConsoleWindowClass
    WinGetPos, ValueX, ValueY, ValueW, ValueH, ahk_class CrossFire
    Start:
    Gui, recoil_mode: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, recoil_mode: Margin, 0, 0
    Gui, recoil_mode: Color, 333333 ;#333333
    Gui, recoil_mode: Font, s15, Microsoft YaHei
    Gui, recoil_mode: Add, Text, hwndGui_5 vModeClick c00FF00, 压枪准备 ;#00FF00
    WinSet, TransColor, 000000 255 ;#000000
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui5, YGui5, "H", 50, 0)
    Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA, Listening

    Gui, gun_sel: +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, gun_sel: Margin, 0, 0
    Gui, gun_sel: Color, 333333 ;#333333
    Gui, gun_sel: Font, s15, Microsoft YaHei
    Gui, gun_sel: Add, Text, hwndGui_5 vModeGun c00FF00, 暂未选枪械 ;#00FF00
    WinSet, TransColor, 000000 255 ;#000000
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui6, YGui6, "H", 200, 0)
    Gui, gun_sel: Show, x%XGui6% y%YGui6% NA, Listening

    Gui, circle: +lastfound +ToolWindow -Caption +AlwaysOnTop +Hwndcc -DPIScale
    Gui, circle: Color, FFFF00 ;#FFFF00
    SetGuiPosition(XGui7, YGui7, "C", 0, 0)
    Gui, circle: Show, x%XGui7% y%YGui7% w%ValueW% h%ValueH% NA, Listening
    WinSet, Transparent, 63, ahk_id %cc%
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    Xcc := ValueW / 2, Ycc := ValueH / 2 + 15 ;483
    Loop, %Vertices%
        Hole .= Floor(Xcc + Radius * Cos(A_Index * Angle)) "-" Floor(Ycc + Radius * Sin(A_Index * Angle)) " "
    Hole .= Floor(Xcc + Radius * Cos(Angle)) "-" Floor(Ycc + Radius * Sin(Angle))
    WinSet, Region, %Hole%, ahk_id %cc% 
    Hole = ;free memory
    Gui, circle: Show, Hide, Listening
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
    SetGuiPosition(XGui5, YGui5, "H", 50, 0)
    Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA, Listening
    SetGuiPosition(XGui6, YGui6, "H", 200, 0)
    Gui, gun_sel: Show, x%XGui6% y%YGui6% NA, Listening
    SetGuiPosition(XGui7, YGui7, "C", 0, 0)
Return

~*LButton:: ;压枪 正在开发
    Gui, circle: Show, x%XGui7% y%YGui7% w%ValueW% h%ValueH% NA
    If (!Not_In_Game() && Gun_Chosen > 0)
    {
        UpdateText("recoil_mode", "ModeClick", "自动压枪", XGui5, YGui5)
        Recoilless(Gun_Chosen)
    }
Return

~*Lbutton Up:: ;保障新一轮压枪
    Gui, circle: Show, Hide, Listening
    If !Not_In_Game()
        UpdateText("recoil_mode", "ModeClick", "压枪准备", XGui5, YGui5)
Return

~*Numpad0::
    If !Not_In_Game()
    {
        UpdateText("gun_sel", "ModeGun", "暂未选枪械", XGui6, YGui6)
        Gun_Chosen := 0
    }
Return

~*Numpad1::
    If !Not_In_Game()
    {
        UpdateText("gun_sel", "ModeGun", "AK英雄级", XGui6, YGui6)
        Gun_Chosen := 1
    }  
Return

~*Numpad2::
    If !Not_In_Game()
    {
        UpdateText("gun_sel", "ModeGun", "M4英雄级", XGui6, YGui6)
        Gun_Chosen := 2
    }
Return
