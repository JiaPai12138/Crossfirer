#Include Crossfirer_Functions.ahk
Preset()
;==================================================================================
global BHP_Service_On := False
CheckPermission()
;==================================================================================
If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    Gui, jump_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, jump_mode: Margin, 0, 0
    Gui, jump_mode: Color, 333333 ;#333333
    Gui, jump_mode: Font, s15, Microsoft YaHei
    Gui, jump_mode: Add, Text, hwndGui_4 vModeJump c00FF00, 跳蹲准备 ;#00FF00
    GuiControlGet, P4, Pos, %Gui_4%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui4, YGui4, "M", -P4W // 2, Round(He / 2.7) - P4H // 2)
    Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
    OnMessage(0x1001, "ReceiveMessage")
    BHP_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp
~*Enter::
    Suspend, Toggle ;输入聊天时不受影响
    If A_IsSuspended
        ToolTip, 禁用热键
    Else
        ToolTip
Return

~*RAlt::
    Suspend, Off ;恢复热键
    ToolTip
    If BHP_Service_On
    {
        SetGuiPosition(XGui4, YGui4, "M", -P4W // 2, Round(He / 2.7) - P4H // 2)
        Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
    }
Return

~W & ~F:: ;基本鬼跳
    If BHP_Service_On
    {
        cnt := 0
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "基本鬼跳", XGui4, YGui4)
        press_key("space", 100, 100)
        Send, {LCtrl Down}
        HyperSleep(100)
        Loop 
        {
            press_key("space", 10, 0)   
            cnt += 1
        } Until, (!GetKeyState("W", "P") || cnt >= 250 || !WinActive("ahk_class CrossFire"))
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
        Send, {Blind}{LCtrl Up}
    }
Return 

~W & ~C:: ;前进上箱子
    If BHP_Service_On
    {
        cnt := 0
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "前跳跳蹲", XGui4, YGui4)
        Loop 
        {
            press_key("space", 10, 10)   
            cnt += 1
        } Until, (cnt >= 40 || !WinActive("ahk_class CrossFire"))
        press_key("LCtrl", 100, 20)
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~W & ~Space:: ;连跳,落地少掉血
    If BHP_Service_On
    {
        HyperSleep(200)
        While, GetKeyState("Space", "P") && WinActive("ahk_class CrossFire")
        {
            GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
            UpdateText("jump_mode", "ModeJump", "基础连跳", XGui4, YGui4)
            press_key("Space", 10, 0)
        }
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~W & ~LAlt:: ;空中连蹲跳 w+alt
    If BHP_Service_On
    {
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "空中连蹲", XGui4, YGui4)
        cnt := 0
        press_key("Space", 30, 30)
        HyperSleep(270)
        Loop
        {
            press_key("LCtrl", 30, 30)
            cnt += 1
        } Until, (!GetKeyState("W", "P") || cnt >= 8 || !WinActive("ahk_class CrossFire"))
        press_key("LCtrl", 270, 30)
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~S & ~F:: ;跳蹲上坡
    If BHP_Service_On
    {
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "跳蹲上坡", XGui4, YGui4)
        Loop
        {
            press_key("Space", 30, 30)
            press_key("LCtrl", 30, 30)
        } Until, (GetKeyState("E", "P") || GetKeyState("LButton", "P") || !WinActive("ahk_class CrossFire"))
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~S & ~C:: ;背Esc跳
    If BHP_Service_On
    {
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "ESC跳箱", XGui4, YGui4)
        press_key("Esc", 30, 30)
        Send, {Blind}{s Down}
        HyperSleep(30)
        Send, {Blind}{Space Down}
        HyperSleep(400)
        press_key("Esc", 30, 100)
        press_key("LCtrl", 700, 100)
        Send, {Blind}{s Up}
        Send, {Blind}{Space Up}
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~Z & ~X:: ;单纯滑步
    If BHP_Service_On
    {
        cnt := 0
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "前后滑步", XGui4, YGui4)
        Loop 
        {
            press_key("w", 30, 60)
            press_key("s", 30, 60)
            cnt += 1
        } Until, (cnt >= 20 || !WinActive("ahk_class CrossFire"))
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return 

~Z & ~C:: ;六级跳 需要特定角度和条件
    If BHP_Service_On
    {
        GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
        UpdateText("jump_mode", "ModeJump", "六级跳箱", XGui4, YGui4)
        Send, {Blind}{s Down}
        HyperSleep(100)
        Send, {Blind}{w Down}
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
        } Until, (cnt >= 40 || !WinActive("ahk_class CrossFire"))
        press_key("LCtrl", 100, 20)
        press_key("Space", 10, 10)
        Send, {Blind}{s Up}
        
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return
;==================================================================================