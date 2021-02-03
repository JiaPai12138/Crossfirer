#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#SingleInstance, force
;#IfWinActive ahk_class Q360NetFosClass  ; Chrome_WidgetWin_1 CrossFire
#Include Crossfirer_Functions.ahk  
#KeyHistory 0
DetectHiddenWindows, On
CoordMode, Pixel, Client
CoordMode, Mouse, Client
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
global NBK_Service_On := False
global Net_On := True
Net_Time := 6
Net_Start := 0
CheckPermission()
;==================================================================================
If WinExist("ahk_class CrossFire")
{
    CheckPosition(X3e, Y3e, W3e, H3e, "CrossFire")
    Start:
    Gui, net_status: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, net_status: Margin, 0, 0
    Gui, net_status: Color, 333333 ;#333333
    Gui, net_status: Font, s20, Microsoft YaHei
    Gui, net_status: Add, Text, hwndGui_9 vNetBlock c00FFFF, 一键断天涯 ;#00FFFF
    GuiControlGet, P9, Pos, %Gui_9%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui9, YGui9, "H", -P9W // 2, 0)
    Gui, net_status: Show, Hide ;x%XGui9% y%YGui9% NA

    Gui, net_count: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, net_count: Margin, 0, 0
    Gui, net_count: Color, 333333 ;#333333
    Gui, net_count: Font, s20, Microsoft YaHei
    Gui, net_count: Add, Text, hwndGui_10 vNetCount c00FFFF, %Net_Time% ;#00FFFF
    GuiControlGet, P10, Pos, %Gui_10%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui10, YGui10, "H", -P10W // 2, Round(H3e / 9))
    Gui, net_count: Show, Hide ;x%XGui10% y%YGui10% NA

    OnMessage(0x1001, "ReceiveMessage")
    NBK_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp

~*RAlt::
    If NBK_Service_On
    {
        SetGuiPosition(XGui9, YGui9, "H", -P9W // 2, 0)
        SetGuiPosition(XGui10, YGui10, "H", -P10W // 2, Round(H3e / 9))
        If !Net_On
        {
            Gui, net_status: Show, x%XGui9% y%YGui9% NA
            Gui, net_count: Show, x%XGui10% y%YGui10% NA
        }
        Else
        {
            Gui, net_status: Show, Hide
            Gui, net_count: Show, Hide
        }
    }
Return

~*H::
    If NBK_Service_On && WinExist("ahk_class Q360NetFosClass")
    {
        CheckPosition(X360, Y360, W360, H360, "Q360NetFosClass")
        clickx := Round(W360 / 1.5), clicky := Round(H360 / 2.8)
        clickx_offset := clickx + Round(W360 / 8.5) ;点击旁边使输入数值确认
        Net_On := !Net_On
        If !Net_On
        {
            Gui, net_status: Show, x%XGui9% y%YGui9% NA
            Gui, net_count: Show, x%XGui10% y%YGui10% NA
            ControlClick, x%clickx% y%clicky%, ahk_class Q360NetFosClass, , , , NA
            HyperSleep(50)
            ControlGetFocus, Control_Name, ahk_class Q360NetFosClass
            ControlSendRaw, %Control_Name%, 1, ahk_class Q360NetFosClass ;上传限速1
            HyperSleep(50)
            ControlClick, x%clickx_offset% y%clicky%, ahk_class Q360NetFosClass, , , , NA
            SetTimer, UpdateNet, 100
        }
        Else
        {
            SetTimer, UpdateNet, Off
            ControlClick, x%clickx% y%clicky%, ahk_class Q360NetFosClass, , , , NA
            Net_Start := 0, Net_Time := 6
            Gui, net_status: Show, Hide
            Gui, net_count: Show, Hide
        }
    }
Return
;==================================================================================
UpdateNet() ;精度0.1s
{
    global XGui10, YGui10, Net_Start, Net_Time, NetCount, clickx, clicky
    Net_Timer(XGui10, YGui10, Net_On, Net_Start, Net_Time, "net_count", "NetCount")
    If Net_On
    {
        Gui, net_status: Show, Hide
        Gui, net_count: Show, Hide
        SetTimer, UpdateNet, Off
        ControlClick, x%clickx% y%clicky%, ahk_class Q360NetFosClass, , , , NA
    }
}
;==================================================================================
;断网计时器
Net_Timer(XGui10, YGui10, ByRef Net_On, ByRef Net_Start, ByRef Net_Time, Gui_Number, ControlID)
{
    If !Net_On
    {
        If Net_Start = 0
            Net_Start := SystemTime()
        Else
        {
            Net_Time := Round(6.5 - (SystemTime() - Net_Start) / 1000)
            If (Net_Time <= 5 && Net_Time >= 3)
                GuiControl, %Gui_Number%: +cFFFF00 +Redraw, %ControlID% ;#FFFF00
            Else If (Net_Time < 3 && Net_Time > 0)
                GuiControl, %Gui_Number%: +cFF0000 +Redraw, %ControlID% ;#FF0000
            Else If Net_Time <= 0
            {
                Net_Start := 0
                Net_Time := 6
                Net_On := !Net_On
            }
            UpdateText(Gui_Number, ControlID, Net_Time, XGui10, YGui10)
        }
    }
}
;==================================================================================