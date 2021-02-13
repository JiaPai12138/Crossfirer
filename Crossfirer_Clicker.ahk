#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#SingleInstance, force
#IfWinExist ahk_class CrossFire  ; Chrome_WidgetWin_1 CrossFire
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
global CLK_Service_On := False
CheckPermission()
SysGet, Mouse_Buttons, 43 ;检测鼠标按键数量
If Mouse_Buttons < 5
{
    MsgBox, 262144, 鼠标按键数量不足/Not enough buttons on mouse, 请考虑更换鼠标,不然无法使用本连点辅助/Please consider getting a new mouse, or you will not able to use this auto clicker
    ;ExitApp
}
;==================================================================================
If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    Start:
    Gui, click_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, click_mode: Margin, 0, 0
    Gui, click_mode: Color, 333333 ;#333333
    Gui, click_mode: Font, s15, Microsoft YaHei
    Gui, click_mode: Add, Text, hwndGui_5 vModeClick c00FF00, 连点准备 ;#00FF00
    GuiControlGet, P5, Pos, %Gui_5%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui3, YGui3, "M", -P5W // 2, Round(He / 3) - P5H // 2)
    Gui, click_mode: Show, x%XGui3% y%YGui3% NA
    OnMessage(0x1001, "ReceiveMessage")
    CLK_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp
~*Right::Suspend, Toggle ;输入聊天时不受影响

~*RAlt::
    If CLK_Service_On
    {
        SetGuiPosition(XGui3, YGui3, "M", -P5W // 2, Round(He / 3) - P5H // 2)
        Gui, click_mode: Show, x%XGui3% y%YGui3% NA
    }
Return

~*MButton:: ;爆裂者轰炸
    If !Not_In_Game() && CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "右键连点", XGui3, YGui3)
        While, !(GetKeyState("R", "P") || GetKeyState("LButton", "P") || GetKeyState("`", "P") || !WinActive("ahk_class CrossFire"))
        {
            press_key("RButton", 10.0, 50.0)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{RButton Up}
    }
Return

~*XButton2:: ;半自动速点,适合救世主步枪
    If !Not_In_Game() && CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "左键连点", XGui3, YGui3)
        While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P") || GetKeyState("`", "P") || !WinActive("ahk_class CrossFire"))
        {
            ;press_key("LButton", 42.8, 42.8) ;FAL CAMO射速700
            press_key("LButton", 50.0, 50.0)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return

~*XButton1:: ;半自动速点,适合加特林速点,不适合USP
    If !Not_In_Game() && CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "左键速点", XGui3, YGui3)
        While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P") || GetKeyState("`", "P") || !WinActive("ahk_class CrossFire"))
        {
            press_key("LButton", 30.0, 30.0)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return

~*K:: ;粉碎者直射
    If !Not_In_Game() && CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "左键不放", XGui3, YGui3)
        Send, {Blind}{LButton Up}
        HyperSleep(30)
        Send, {LButton Down}
        While, !(GetKeyState("R", "P") || GetKeyState("`", "P") || GetKeyState("RButton", "P") || !WinActive("ahk_class CrossFire"))
        {
            If !GetKeyState("LButton")
                Send, {LButton Down}
            HyperSleep(100)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return
;==================================================================================