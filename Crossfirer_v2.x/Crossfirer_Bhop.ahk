#Include Crossfirer_Functions.ahk
global BHP_Service_On := False
Preset("身")
CheckPermission("基础身法")
;==================================================================================
global BhopStatus := 0
global LCtrl_pressed := 0

If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    Gui, jump_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow +Hwndjm -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, jump_mode: Margin, 0, 0
    Gui, jump_mode: Color, 333333 ;#333333
    Gui, jump_mode: Font, S10 Q5, Microsoft YaHei
    Gui, jump_mode: Add, Text, hwndGui_4 vModeJump c00FF00, 跳蹲准备 ;#00FF00
    GuiControlGet, P4, Pos, %Gui_4%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, Transparent, 225, ahk_id %jm%
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui4, YGui4, "M", -P4W // 2, He // 4 - P4H // 2)
    Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
    OnMessage(0x1001, "ReceiveMessage")
    OnMessage(0x1002, "ReceiveMessage")
    BHP_Service_On := True
    Return
}
;==================================================================================
~*-::
    If !GetKeyState("-", "P")
        Return
ExitApp

#If BHP_Service_On ;以下的热键需要相应条件才能激活

~*CapsLock Up:: ;最小最大化窗口
    HyperSleep(100)
    If WinActive("ahk_class CrossFire")
        Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
    Else
        Gui, jump_mode: Show, Hide
    If GetKeyState("Capslock", "T")
        Send, {CapsLock}
Return

#If WinActive("ahk_class CrossFire") && BHP_Service_On ;以下的热键需要相应条件才能激活

~*Enter Up::
    Suspend, Off ;恢复热键,首行为挂起关闭才有效
    If Is_Chatting()
        Suspend, On
    Suspended()
Return

~*RAlt::
    If !GetKeyState("RAlt", "P")
        Return
    Suspend, Off ;恢复热键,双保险
    Suspended()
    SetGuiPosition(XGui4, YGui4, "M", -P4W // 2, He // 4 - P4H // 2)
    Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
Return

#If (WinActive("ahk_class CrossFire") && BHP_Service_On && CF_Now.GetStatus()) ;以下的热键需要相应条件才能激活

~*LCtrl:: ;减少误触
    If GetKeyState("LCtrl", "P")
        LCtrl_pressed := 1
Return

~W & ~LCtrl Up:: ;BUG小道,可能会掉血
    If !LCtrl_pressed || !GetKeyState("w", "P")
        Return
    BhopStatus := 1
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "Bug小道", XGui4, YGui4)
    HyperSleep(100)
    press_key("LShift", 50, 50)
    press_key("LCtrl", 50, 50)
    press_key("LShift", 50, 50)
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
    LCtrl_pressed := 0
Return

~W & ~F:: ;基本鬼跳,落地少掉血
    If !(GetKeyState("w", "P") || GetKeyState("f", "P"))
        Return
    cnt := 0, BhopStatus := 2
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "基本鬼跳", XGui4, YGui4)
    press_key("space", 100, 100)
    key_down("LCtrl")
    HyperSleep(100)
    Loop
    {
        press_key("space", 10, 0)
        cnt += 1
    } Until, (!GetKeyState("W", "P") || cnt >= 300 || !WinActive("ahk_class CrossFire") || BhopStatus != 2)
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    key_up("LCtrl")
    BhopStatus := 0
Return

~W & ~C:: ;前进上箱子
    If !(GetKeyState("w", "P") || GetKeyState("c", "P"))
        Return
    cnt := 0, BhopStatus := 3
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "前跳跳蹲", XGui4, YGui4)
    Loop
    {
        press_key("Space", 10, 10)
        cnt += 1
    } Until, (cnt >= 40 || !WinActive("ahk_class CrossFire") || BhopStatus != 3)
    press_key("LCtrl", 100, 20)
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return

~W & ~LAlt:: ;空中连蹲跳 w+alt
    If !(GetKeyState("w", "P") || GetKeyState("LAlt", "P"))
        Return
    cnt := 0, BhopStatus := 4
    press_key("Space", 40, 20)
    If GetKeyState("LButton", "P")
    {
        press_key("LCtrl", 200, 10)
        UpdateText("jump_mode", "ModeJump", "空蹲连蹲", XGui4, YGui4)
    }
    Else
    {
        HyperSleep(210)
        UpdateText("jump_mode", "ModeJump", "空中连蹲", XGui4, YGui4)
    }
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    While, (GetKeyState("LAlt", "P") && WinActive("ahk_class CrossFire") && BhopStatus = 4)
    {
        If cnt < 10
        {
            press_key("LCtrl", 30, 30)
            cnt += 1
        }
        Else
        {
            key_down("LCtrl")
            HyperSleep(30)
        }
    }
    key_up("LCtrl")
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return

~S & ~F:: ;跳蹲上坡
    If !(GetKeyState("s", "P") || GetKeyState("f", "P"))
        Return
    cnt := 0, BhopStatus := 5
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "跳蹲上坡", XGui4, YGui4)
    Loop
    {
        key_up("LCtrl")
        key_down("Space")
        HyperSleep(30)
        key_up("Shift")
        key_down("LCtrl")
        HyperSleep(30)
        key_up("Space")
        key_down("Shift")
        HyperSleep(30)
        cnt += 1
    } Until, (cnt > 50 || GetKeyState("LButton", "P") || !WinActive("ahk_class CrossFire") || BhopStatus != 5)
    key_up("Space")
    key_up("LCtrl")
    key_up("Shift")
    If Mod(cnt, 2)
        press_key("Shift", 30, 30)
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return

~S & ~C:: ;背Esc跳
    If !(GetKeyState("s", "P") || GetKeyState("c", "P"))
        Return
    BhopStatus := 6
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "ESC跳箱", XGui4, YGui4)
    press_key("Esc", 30, 30)
    key_down("s")
    HyperSleep(30)
    key_down("Space")
    HyperSleep(400)
    press_key("Esc", 30, 100)
    press_key("LCtrl", 700, 100)
    key_up("s")
    key_up("Space")
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return

~S & ~LAlt:: ;后跳闪蹲 s+alt
    If !(GetKeyState("s", "P") || GetKeyState("LAlt", "P"))
        Return
    BhopStatus := 7
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "后跳闪蹲", XGui4, YGui4)
    cnt := 0
    press_key("Space", 30, 30)
    press_key("LCtrl", 700, 20)
    While, (GetKeyState("LAlt", "P") && WinActive("ahk_class CrossFire") && BhopStatus = 7)
    {
        press_key("LCtrl", 20, 10)
    }
    key_up("LCtrl")
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return

~Z & ~X:: ;单纯滑步
    If !(GetKeyState("z", "P") || GetKeyState("x", "P"))
        Return
    cnt := 0, BhopStatus := 8
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "前后滑步", XGui4, YGui4)
    key_down("LCtrl")
    Loop
    {
        press_key("w", 30, 60)
        press_key("s", 30, 60)
        cnt += 1
    } Until, (cnt >= 20 || !WinActive("ahk_class CrossFire") || BhopStatus != 8)
    key_up("LCtrl")
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return

~Z & ~C:: ;六级跳 需要特定角度和条件
    If !(GetKeyState("z", "P") || GetKeyState("c", "P"))
        Return
    BhopStatus := 9
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "六级跳箱", XGui4, YGui4)
    key_down("s")
    HyperSleep(100)
    key_down("w")
    Loop, 3
    {
        press_key("Space", 100, 200)
        press_key("LCtrl", 100, 100)
        HyperSleep(700)
    }
    HyperSleep(100)
    key_up("w")
    cnt := 0
    Loop
    {
        press_key("Space", 10, 10)
        cnt += 1
    } Until, (cnt >= 40 || !WinActive("ahk_class CrossFire") || BhopStatus != 9)
    press_key("LCtrl", 100, 20)
    press_key("Space", 10, 10)
    key_up("s")

    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return

~*<::
~*,::
    If !(GetKeyState("<", "P") || GetKeyState(",", "P"))
        Return
    BhopStatus := 10
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "左旋转跳", XGui4, YGui4)
    key_down("s")
    HyperSleep(180)
    press_key("Space", 30, 30)
    mouseXY(-400, 0)
    key_down("d")
    key_down("LCtrl")
    If !GetKeyState("LButton", "P")
        HyperSleep(540)
    Else
        HyperSleep(240)
    press_key("Space", 30, 30)
    mouseXY(-400, 0)
    If !GetKeyState("LButton", "P")
        HyperSleep(880)
    Else
        HyperSleep(400)
    key_up("d")
    WHile GetKeyState("s", "P")
    {
        HyperSleep(10)
    }
    key_up("s")
    key_up("LCtrl")
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return

~*>::
~*.::
    If !(GetKeyState(">", "P") || GetKeyState(".", "P"))
        Return
    BhopStatus := 11
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "右旋转跳", XGui4, YGui4)
    key_down("s")
    HyperSleep(180)
    press_key("Space", 30, 30)
    mouseXY(400, 0)
    key_down("a")
    key_down("LCtrl")
    If !GetKeyState("LButton", "P")
        HyperSleep(540)
    Else
        HyperSleep(240)
    press_key("Space", 30, 30)
    mouseXY(-400, 0)
    If !GetKeyState("LButton", "P")
        HyperSleep(880)
    Else
        HyperSleep(400)
    key_up("a")
    WHile GetKeyState("s", "P")
    {
        HyperSleep(10)
    }
    key_up("s")
    key_up("LCtrl")
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    BhopStatus := 0
Return
;==================================================================================