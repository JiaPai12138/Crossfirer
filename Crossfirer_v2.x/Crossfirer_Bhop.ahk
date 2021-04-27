#Include Crossfirer_Functions.ahk
global BHP_Service_On := False
Preset("身")
CheckPermission("基础身法")
;==================================================================================
If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    Gui, jump_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, jump_mode: Margin, 0, 0
    Gui, jump_mode: Color, 333333 ;#333333
    Gui, jump_mode: Font, S10 Q5, Microsoft YaHei
    Gui, jump_mode: Add, Text, hwndGui_4 vModeJump c00FF00, 跳蹲准备 ;#00FF00
    GuiControlGet, P4, Pos, %Gui_4%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui4, YGui4, "M", -P4W // 2, Round(He / 4) - P4H // 2)
    Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
    OnMessage(0x1001, "ReceiveMessage")
    OnMessage(0x1002, "ReceiveMessage")
    BHP_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp

#If BHP_Service_On ;以下的热键需要相应条件才能激活

~*CapsLock Up:: ;最小最大化窗口
    HyperSleep(100)
    If WinActive("ahk_class CrossFire")
        Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
    Else
        Gui, jump_mode: Show, Hide
Return

#If WinActive("ahk_class CrossFire") && BHP_Service_On ;以下的热键需要相应条件才能激活

~*Enter Up::
    Suspend, Off ;恢复热键,首行为挂起关闭才有效
    If Is_Chatting()
        Suspend, On 
    Suspended()
Return

~*RAlt::
    Suspend, Off ;恢复热键,双保险
    Suspended()
    SetGuiPosition(XGui4, YGui4, "M", -P4W // 2, Round(He / 4) - P4H // 2)
    Gui, jump_mode: Show, x%XGui4% y%YGui4% NA
Return

#If (WinActive("ahk_class CrossFire") && BHP_Service_On && CF_Now.GetStatus()) ;以下的热键需要相应条件才能激活

~W & ~LCtrl Up:: ;BUG小道,可能会掉血
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "Bug小道", XGui4, YGui4)
    HyperSleep(100)
    press_key("LShift", 50, 50)
    press_key("LCtrl", 50, 50)
    press_key("LShift", 50, 50)
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
Return

~W & ~F:: ;基本鬼跳,落地少掉血
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
    } Until, (!GetKeyState("W", "P") || cnt >= 300 || !WinActive("ahk_class CrossFire"))
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    Send, {Blind}{LCtrl Up}
Return

~W & ~C:: ;前进上箱子
    cnt := 0
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "前跳跳蹲", XGui4, YGui4)
    Loop 
    {
        press_key("Space", 10, 10)
        cnt += 1
    } Until, (cnt >= 40 || !WinActive("ahk_class CrossFire"))
    press_key("LCtrl", 100, 20)
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
Return

~W & ~LAlt:: ;空中连蹲跳 w+alt
    cnt := 0
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
    While, GetKeyState("LAlt", "P") && WinActive("ahk_class CrossFire")
    {
        If cnt < 10
        {
            press_key("LCtrl", 30, 30)
            cnt += 1
        }
        Else
        {
            Send, {Blind}{LCtrl Down}
            HyperSleep(30)
        }
    }
    Send, {Blind}{LCtrl Up}
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
Return

~S & ~F:: ;跳蹲上坡
    cnt := 0
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "跳蹲上坡", XGui4, YGui4)
    Loop
    {
        Send, {Blind}{LCtrl Up}
        Send, {Blind}{Space Down}
        HyperSleep(30)
        Send, {Blind}{Shift Up}
        Send, {Blind}{LCtrl Down}
        HyperSleep(30)
        Send, {Blind}{Space Up}
        Send, {Blind}{Shift Down}
        HyperSleep(30)
        cnt += 1
    } Until, (cnt > 50 || GetKeyState("LButton", "P") || !WinActive("ahk_class CrossFire"))
    Send, {Blind}{Space Up}
    Send, {Blind}{LCtrl Up}
    Send, {Blind}{Shift Up}
    If Mod(cnt, 2)
        press_key("Shift", 30, 30)
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
Return

~S & ~C:: ;背Esc跳
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
Return

~S & ~LAlt:: ;后跳闪蹲 s+alt
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "后跳闪蹲", XGui4, YGui4)
    cnt := 0
    press_key("Space", 30, 30)
    press_key("LCtrl", 700, 20)
    While, GetKeyState("LAlt", "P") && WinActive("ahk_class CrossFire")
    {
        press_key("LCtrl", 20, 10)
    }
    Send, {Blind}{LCtrl Up}
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
Return

~Z & ~X:: ;单纯滑步
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
Return 

~Z & ~C:: ;六级跳 需要特定角度和条件
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
Return

~*<::
~*,::
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "左旋转跳", XGui4, YGui4)
    Send, {Blind}{s Down}
    HyperSleep(180)
    press_key("Space", 30, 30)
    mouseXY(-400, 0)
    Send, {Blind}{d Down}
    Send, {Blind}{LCtrl Down}
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
    Send, {Blind}{d Up}
    WHile GetKeyState("s", "P")
    {
        HyperSleep(10)
    }
    Send, {Blind}{s Up}
    Send, {Blind}{LCtrl Up}
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
Return

~*>::
~*.::
    GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
    UpdateText("jump_mode", "ModeJump", "右旋转跳", XGui4, YGui4)
    Send, {Blind}{s Down}
    HyperSleep(180)
    press_key("Space", 30, 30)
    mouseXY(400, 0)
    Send, {Blind}{a Down}
    Send, {Blind}{LCtrl Down}
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
    Send, {Blind}{a Up}
    WHile GetKeyState("s", "P")
    {
        HyperSleep(10)
    }
    Send, {Blind}{s Up}
    Send, {Blind}{LCtrl Up}
    GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
    UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
Return
;==================================================================================