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
Process, Priority, , H  ;进程高优先级
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
;==================================================================================
global BHP_Service_On := False
CheckPermission()
;==================================================================================
If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He)
    Start:
    Gui, jump_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, jump_mode: Margin, 0, 0
    Gui, jump_mode: Color, 333333 ;#333333
    Gui, jump_mode: Font, s15, Microsoft YaHei
    Gui, jump_mode: Add, Text, hwndGui_4 vModeJump c00FF00, 跳蹲准备 ;#00FF00
    GuiControlGet, P4, Pos, %Gui_4%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui4, YGui4, "M", -P4W // 2, Round(He / 2.7) - P4H // 2)
    Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
    OnMessage(0x1001, "ReceiveMessage")
    BHP_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp

~*RAlt::
    If BHP_Service_On
    {
        SetGuiPosition(XGui4, YGui4, "M", -P4W // 2, Round(He / 2.7) - P4H // 2)
        Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
    }
Return

~W & ~F:: ;基本鬼跳
    If !Not_In_Game() && BHP_Service_On
    {
        cnt := 0
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "基本鬼跳", XGui4, YGui4)
        press_key("space", 100, 100)
        Send, {LCtrl Down}
        HyperSleep(100)
        Loop 
        {
            press_key("space", 10, 10)   
            cnt += 1
        } Until, (!GetKeyState("W", "P") || cnt >= 160)
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
        Send, {Blind}{LCtrl Up}
    }
Return 

~W & ~C:: ;前进上箱子
    If !Not_In_Game() && BHP_Service_On
    {
        cnt := 0
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "前跳跳蹲", XGui4, YGui4)
        Loop 
        {
            press_key("space", 10, 10)   
            cnt += 1
        } Until, (cnt >= 40)
        press_key("LCtrl", 100, 20)
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~W & ~Space:: ;连跳,落地不掉血
    If !Not_In_Game() && BHP_Service_On
    {
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "基础连跳", XGui4, YGui4)
        HyperSleep(200)
        While GetKeyState("Space", "P")
        {
            press_key("Space", 10, 10)   
        }
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~W & ~LAlt:: ;空中连蹲跳 w+alt
    If !Not_In_Game() && BHP_Service_On
    {
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "空中连蹲", XGui4, YGui4)
        cnt := 0
        press_key("Space", 30, 30)
        HyperSleep(140)
        Loop
        {
            press_key("LCtrl", 30, 30)
            cnt += 1
        } Until, (!GetKeyState("W", "P") || cnt >= 8)
        press_key("LCtrl", 270, 30)
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~S & ~F:: ;跳蹲上坡
    If !Not_In_Game() && BHP_Service_On
    {
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "跳蹲上坡", XGui4, YGui4)
        Loop
        {
            press_key("Space", 30, 30)
            press_key("LCtrl", 30, 30)
        } Until, (GetKeyState("E", "P") || GetKeyState("LButton", "P"))
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~S & ~C:: ;后退上箱子
    If !Not_In_Game() && BHP_Service_On
    {
        cnt := 0
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "后跳跳蹲", XGui4, YGui4)
        Loop 
        {
            press_key("Space", 10, 10)   
            cnt += 1
        } Until, (cnt >= 40)
        press_key("LCtrl", 100, 20)
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~Z & ~X:: ;单纯滑步
    If !Not_In_Game() && BHP_Service_On
    {
        cnt := 0
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "前后滑步", XGui4, YGui4)
        Loop 
        {
            press_key("w", 30, 60)
            press_key("s", 30, 60)
            cnt += 1
        } Until, (cnt >= 20)
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return 

~Z & ~C:: ;六级跳 需要特定角度和条件
    If !Not_In_Game() && BHP_Service_On
    {
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "六级跳箱", XGui4, YGui4)
        Send, {s Down}
        HyperSleep(100)
        Send, {w Down}
        Loop, 3
        {
            press_key("Space", 100, 200)
            press_key("LCtrl", 100, 100)
            HyperSleep(700)
        }
        HyperSleep(100)
        Send, {Blind}{w Up}
        cnt := 0
        Loop 
        {
            press_key("Space", 10, 10)
            cnt += 1
        } Until, (cnt >= 40)
        press_key("LCtrl", 100, 20)
        press_key("Space", 10, 10)
        Send, {Blind}{s Up}
        
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return
;==================================================================================