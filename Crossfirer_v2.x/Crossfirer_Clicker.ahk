#Include Crossfirer_Functions.ahk
global CLK_Service_On := False
Preset("点")
CheckPermission("连点助手")
SysGet, Mouse_Buttons, 43 ;检测鼠标按键数量
If Mouse_Buttons < 5
{
    MsgBox, 262144, 鼠标按键数量不足/Not enough buttons on mouse, 请考虑更换鼠标,不然无法使用本连点辅助/Please consider getting a new mouse, or you will not able to use this auto clicker
    ;ExitApp
}
;==================================================================================
global CLKStatus := 0
global CapsLock_pressed := 0

If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    Gui, click_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow +Hwndcm -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, click_mode: Margin, 0, 0
    Gui, click_mode: Color, 333333 ;#333333
    Gui, click_mode: Font, S10 Q5, Microsoft YaHei
    Gui, click_mode: Add, Text, hwndGui_5 vModeClick c00FF00, 连点准备 ;#00FF00
    GuiControlGet, P5, Pos, %Gui_5%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, Transparent, 225, ahk_id %cm%
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui3, YGui3, "M", -P5W // 2, He // 3.6 - P5H // 2)
    Gui, click_mode: Show, x%XGui3% y%YGui3% NA
    OnMessage(0x1001, "ReceiveMessage")
    OnMessage(0x1002, "ReceiveMessage")
    CLK_Service_On := True
    global AccRem := 1.0
    Return
}
;==================================================================================
~*-::
    If !GetKeyState("-", "P")
        Return
ExitApp

#If CLK_Service_On ;以下的热键需要相应条件才能激活

~*CapsLock::
    If GetKeyState("CapsLock", "P")
        CapsLock_pressed := 1
Return

~*CapsLock Up:: ;最小最大化窗口
    If !CapsLock_pressed
        Return
    HyperSleep(100)
    If WinActive("ahk_class CrossFire")
        Gui, click_mode: Show, x%XGui3% y%YGui3% NA
    Else
        Gui, click_mode: Show, Hide
    CapsLock_pressed := 0
    If GetKeyState("Capslock", "T")
        press_key("Capslock", 50, 50)
Return

#If WinActive("ahk_class CrossFire") && CLK_Service_On ;以下的热键需要相应条件才能激活

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
    SetGuiPosition(XGui3, YGui3, "M", -P5W // 2, He // 3.6 - P5H // 2)
    Gui, click_mode: Show, x%XGui3% y%YGui3% NA
Return

~*F9::
    If !GetKeyState("F9", "P")
        Return
    AccRem := 2.0 / AccRem
Return

~*MButton:: ;爆裂者轰炸
    If !GetKeyState("MButton", "P")
        Return
    CLKStatus := 1
    GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
    UpdateText("click_mode", "ModeClick", "右键速点", XGui3, YGui3)
    While, StayLoop("LButton") && CLKStatus = 1 ;避免切换窗口时影响
    {
        Random, RanClick1, (10.0 - AccRem), (10.0 + AccRem)
        press_key("RButton", RanClick1, 60.0 - RanClick1)
    }
    GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
    UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    mouse_up("RButton")
    CLKStatus := 0
Return

~*XButton2:: ;炼狱连刺
    If !GetKeyState("XButton2", "P")
        Return
    CLKStatus := 2
    GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
    UpdateText("click_mode", "ModeClick", "炼狱连刺", XGui3, YGui3)
    cnt := 0
    While, StayLoop("LButton") && cnt <= 10 && CLKStatus = 2
    {
        press_key("RButton", 10.0, 290.0) ;炼狱右键
        press_key("LButton", 10.0, 10.0) ;炼狱左键枪刺归位
        cnt += 1
    }
    GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
    UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    CLKStatus := 0
Return

~*T:: ;防止鼠标不符合要求
~*XButton1:: ;半自动速点,适合加特林速点,适合USP
    If !(GetKeyState("XButton1", "P") || GetKeyState("t", "P"))
        Return
    CLKStatus := 3, GetE := 0, estart := SystemTime(), stime := 0
    GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
    UpdateText("click_mode", "ModeClick", "左键速点", XGui3, YGui3)
    clicknow := 0
    While, StayLoop("RButton") && CLKStatus = 3
    {
        If GetKeyState("e") && !clicknow
            clicknow := 1
        Else If GetKeyState("e") && clicknow
			clicknow += 1
        Else If !GetKeyState("e")
            clicknow := 0
        If clicknow < 3
        {
            Random, RanClick2, (90.0 - AccRem), (90.0 + AccRem)
            press_key("LButton", RanClick2, 120.0 - RanClick2) ;略微增加散布的代价大幅降低被检测几率
        }
        Else
            HyperSleep(120)
    }
    GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
    UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    mouse_up()
    CLKStatus := 0
Return

~*":: ;大宝剑二段连击
~*'::
    If !GetKeyState("'", "P")
        Return
    CLKStatus := 4
    GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
    UpdateText("click_mode", "ModeClick", "二段连击", XGui3, YGui3)
    press_key("RButton", 1050, 150)
    press_key("RButton", 90, 10)
    While, StayLoop("LButton") && CLKStatus = 4
    {
        press_key("RButton", 490, 10)
    }
    GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
    UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    CLKStatus := 0
Return

~*|:: ;左键直射
~*\::
    If GetKeyState("\", "P")
        Return
    CLKStatus := 5
    GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
    UpdateText("click_mode", "ModeClick", "左键不放", XGui3, YGui3)
    mouse_up()
    mouse_down()
    While, StayLoop("RButton") && CLKStatus = 5
    {
        If !GetKeyState("LButton")
            mouse_down()
        HyperSleep(100)
    }
    GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
    UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    mouse_up()
    CLKStatus := 0
Return

~*::: ;炼狱热管
~*;::
    If GetKeyState(";", "P")
        Return
    CLKStatus := 6
    GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
    UpdateText("click_mode", "ModeClick", "炼狱热管", XGui3, YGui3)
    While, (StayLoop("LButton") && !GetKeyState("XButton1", "P") && CLKStatus = 6) ;炼狱速点时结束
    {
        press_key("LButton", 10.0, 110.0)
    }
    GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
    UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    CLKStatus := 0
Return
;==================================================================================
;跳出连点循环
StayLoop(KeyClicker)
{
    If !(GetKeyState("E", "P") || GetKeyState("R", "P") || GetKeyState(KeyClicker, "P")) && WinActive("ahk_class CrossFire") && CF_Now.GetStatus() != 0
        Return True
    Return False
}
;==================================================================================