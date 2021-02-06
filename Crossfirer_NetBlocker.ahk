#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#SingleInstance, force
;#IfWinActive ahk_class Q360NetFosClass  ; Chrome_WidgetWin_1 CrossFire
#Include Crossfirer_Functions.ahk  
#KeyHistory 0
#Include Create_Limit_net_1_bmp.ahk
#Include Create_Limit_net_2_bmp.ahk
#Include Create_Restore_net_1_bmp.ahk
#Include Create_Restore_net_2_bmp.ahk
DetectHiddenWindows, On
SetTitleMatchMode, Regex
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
nb_block := False
nb_allow := False
Net_Text := "一键断天涯|"Net_Time
CheckPermission()
If WinExist("ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
{
    WinActivate, ahk_exe NLClientApp.exe
    启用规则1 := Create_Limit_net_1_bmp()
    启用规则2 := Create_Limit_net_2_bmp()
    禁用规则1 := Create_Restore_net_1_bmp()
    禁用规则2 := Create_Restore_net_2_bmp()
    Loop
    {
        CheckPosition(Xnb, Ynb, Wnb, Hnb, "HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        ImageSearch, Block_nbClickX, Block_nbClickY, Xnb, Ynb, Wnb, Hnb, *63 *TransFFFFFF HBITMAP:*%启用规则1%
        If !ErrorLevel
            nb_block := True
        Else
        {   
            ImageSearch, Block_nbClickX, Block_nbClickY, Xnb, Ynb, Wnb, Hnb, *63 *TransFFFFFF HBITMAP:*%启用规则2%
            If !ErrorLevel
                nb_block := True
        }
        ImageSearch, Allow_nbClickX, Allow_nbClickY, Xnb, Ynb, Wnb, Hnb, *63 *TransFFFFFF HBITMAP:*%禁用规则1%
        If !ErrorLevel
            nb_allow := True
        Else
        {   
            ImageSearch, Allow_nbClickX, Allow_nbClickY, Xnb, Ynb, Wnb, Hnb, *63 *TransFFFFFF HBITMAP:*%禁用规则2%
            If !ErrorLevel
                nb_allow := True
        }
        HyperSleep(1000)
    } Until (nb_block && nb_allow)
    DllCall("DeleteObject", "ptr", 启用规则1) ;free memory
    DllCall("DeleteObject", "ptr", 启用规则2) ;free memory
    DllCall("DeleteObject", "ptr", 禁用规则1) ;free memory
    DllCall("DeleteObject", "ptr", 禁用规则2) ;free memory
    Block_nbClickX += 31, Block_nbClickY += 12, Allow_nbClickX += 31, Allow_nbClickY += 12
    MouseClick, Left, Allow_nbClickX, Allow_nbClickY ;初始化状态
    MsgBox, NetLimiter版一键限速已就绪!`nNetLimiter version of onekey-bandwidth-limiter is ready!
    ;MsgBox, %Block_nbClickX%x%Block_nbClickY% %Allow_nbClickX%x%Allow_nbClickY%
}
Else If WinExist("ahk_class Q360NetFosClass")
{
    WinActivate, ahk_class Q360NetFosClass
    CheckPosition(X360, Y360, W360, H360, "Q360NetFosClass")
    clickx := Round(W360 / 5), clicky := Round(H360 / 2.8) ;右键位置
    MsgBox, 360版一键限速已就绪!`n360 version of onekey-bandwidth-limiter is ready!
}
Else
{
    MsgBox, 262160, 错误/Error, 未找到指定流量限速程序!辅助将退出!!`nUnable to find bandwidth limiter!The program will exit!!
    Exitapp
}
;==================================================================================
If (hwndcf := WinExist("ahk_class CrossFire"))
{
    CheckPosition(X3e, Y3e, W3e, H3e, "CrossFire")
    Start:
    Gui, net_status: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, net_status: Margin, 0, 0
    Gui, net_status: Color, 333333 ;#333333
    Gui, net_status: Font, s20, Microsoft YaHei
    Gui, net_status: Add, Text, hwndGui_9 vNetBlock c00FFFF, %Net_Text% ;#00FFFF
    GuiControlGet, P9, Pos, %Gui_9%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 ; 鼠标穿透
    SetGuiPosition(XGui9, YGui9, "H", -P9W // 2, 0)
    Gui, net_status: Show, Hide ;x%XGui9% y%YGui9% NA

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
        If !Net_On
            Gui, net_status: Show, x%XGui9% y%YGui9% NA
        Else
            Gui, net_status: Show, Hide
    }
Return

~*H::
    If NBK_Service_On && WinExist("ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
    {
        Net_On := !Net_On
        If !Net_On
        {
            Gui, net_status: Show, x%XGui9% y%YGui9% NA
            WinMinimize, ahk_exe NLClientApp.exe
            WinMinimize, ahk_class CrossFire
            WinActivate, ahk_exe NLClientApp.exe
            MouseClick, Left, Block_nbClickX, Block_nbClickY
            DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
            SetTimer, UpdateNet, 100
        }
        Else
        {
            SetTimer, UpdateNet, Off
            WinMinimize, ahk_exe NLClientApp.exe
            WinMinimize, ahk_class CrossFire
            WinActivate, ahk_exe NLClientApp.exe
            MouseClick, Left, Allow_nbClickX, Allow_nbClickY
            DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
            Net_Start := 0, Net_Time := 6
            Gui, net_status: Show, Hide
            Gui, net_count: Show, Hide
        }

    }
    Else If NBK_Service_On && (hwnd360 := WinExist("ahk_class Q360NetFosClass"))
    {
        Net_On := !Net_On
        If !Net_On
        {
            Gui, net_status: Show, x%XGui9% y%YGui9% NA
            WinMinimize, ahk_class CrossFire
            DllCall("SwitchToThisWindow", "UInt", hwnd360, "UInt", 1)
            ControlClick, x%clickx% y%clicky%, ahk_class Q360NetFosClass, , Right, , NA
            HyperSleep(50)
            press_key("Down", 10, 10)
            press_key("Enter", 10, 10)
            DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
            SetTimer, UpdateNet, 100
        }
        Else
        {
            SetTimer, UpdateNet, Off
            WinMinimize, ahk_class CrossFire
            DllCall("SwitchToThisWindow", "UInt", hwnd360, "UInt", 1)
            ControlClick, x%clickx% y%clicky%, ahk_class Q360NetFosClass, , Right, , NA
            HyperSleep(50)
            press_key("Down", 10, 10)
            press_key("Down", 10, 10)
            press_key("Enter", 10, 10)
            DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
            Net_Start := 0, Net_Time := 6
            Gui, net_status: Show, Hide
            Gui, net_count: Show, Hide
        }
    }
Return
;==================================================================================
UpdateNet() ;精度0.1s
{
    global XGui9, YGui9, Net_Start, Net_Time, clickx, clicky, Allow_nbClickX, Allow_nbClickY, hwndcf, hwnd360, H360
    Net_Timer(XGui9, YGui9, Net_On, Net_Start, Net_Time, Net_Text, "net_status", "NetBlock")
    If Net_On
    {
        Gui, net_status: Show, Hide
        SetTimer, UpdateNet, Off
        If WinExist("ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        {
            WinMinimize, ahk_exe NLClientApp.exe
            WinMinimize, ahk_class CrossFire
            WinActivate, ahk_exe NLClientApp.exe
            MouseClick, Left, Allow_nbClickX, Allow_nbClickY
            DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
        }
        Else If WinExist("ahk_class Q360NetFosClass")
        {
            WinMinimize, ahk_class CrossFire
            DllCall("SwitchToThisWindow", "UInt", hwnd360, "UInt", 1)
            ControlClick, x%clickx% y%clicky%, ahk_class Q360NetFosClass, , Right, , NA
            HyperSleep(50)
            press_key("Down", 10, 10)
            press_key("Down", 10, 10)
            press_key("Enter", 10, 10)
            DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
        }
    }
}
;==================================================================================
;断网计时器
Net_Timer(XGui9, YGui9, ByRef Net_On, ByRef Net_Start, ByRef Net_Time, ByRef Net_Text, Gui_Number, ControlID)
{
    If !Net_On
    {
        If Net_Start = 0
            Net_Start := SystemTime()
        Else
        {
            Net_Time := Round(6.5 - (SystemTime() - Net_Start) / 1000)
            If Net_Time = 6
                GuiControl, %Gui_Number%: +c00FFFF +Redraw, %ControlID% ;#00FFFF
            Else If (Net_Time <= 5 && Net_Time >= 3)
                GuiControl, %Gui_Number%: +cFFFF00 +Redraw, %ControlID% ;#FFFF00
            Else If (Net_Time < 3 && Net_Time > 0)
                GuiControl, %Gui_Number%: +cFF0000 +Redraw, %ControlID% ;#FF0000
            Else If Net_Time <= 0
            {
                Net_Start := 0
                Net_Time := 6
                Net_On := !Net_On
            }
            Net_Text := "一键断天涯|"Net_Time
            UpdateText(Gui_Number, ControlID, Net_Text, XGui9, YGui9)
        }
    }
}
;==================================================================================