#Include Crossfirer_Functions.ahk
#Include Create_Limit_net_1_bmp.ahk
#Include Create_Limit_net_2_bmp.ahk
#Include Create_Restore_net_1_bmp.ahk
#Include Create_Restore_net_2_bmp.ahk
#IfWinExist ahk_class CrossFire
Preset()
DetectHiddenWindows, On
SetTitleMatchMode, Regex
;==================================================================================
global NBK_Service_On := False
global Net_On := True
Net_Start := 0
nb_block := False
nb_allow := False
CheckPermission()
WinGetTitle, CF_Title, ahk_class CrossFire
If CF_Title = CROSSFIRE
    Net_Time := 6
Else If CF_Title = 穿越火线
    Net_Time := 8
Net_Allowed := Net_Time
Net_Text := "一键断天涯|"Net_Time
hwndcf := WinExist("ahk_class CrossFire")
If ProcessExist("NLClientApp.exe")
{
    WinActivate, ahk_exe NLClientApp.exe
    启用规则1 := Create_Limit_net_1_bmp()
    启用规则2 := Create_Limit_net_2_bmp()
    禁用规则1 := Create_Restore_net_1_bmp()
    禁用规则2 := Create_Restore_net_2_bmp()
    Loop
    {
        CheckPosition(Xnb, Ynb, Wnb, Hnb, "HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        CoordMode, Pixel, Client
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
    CoordMode, Mouse, Client
    MouseClick, Left, Allow_nbClickX, Allow_nbClickY ;初始化状态
    MsgBox, NetLimiter版一键限速已就绪!`nNetLimiter version of onekey-bandwidth-limiter is ready!
    DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
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
If (WinExist("ahk_class CrossFire"))
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
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui9, YGui9, "H", -P9W // 2, 0)
    Gui, net_status: Show, Hide ;x%XGui9% y%YGui9% NA
    OnMessage(0x1001, "ReceiveMessage")
    NBK_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp
~*Right::Suspend, Toggle ;输入聊天时不受影响

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

~*H Up::
    If NBK_Service_On && WinExist("ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
    {
        Net_On := !Net_On
        Gui, net_status: Show, x%XGui9% y%YGui9% NA
        Release_All_Keys()
        If !Net_On
            FlashClick(Block_nbClickX, Block_nbClickY, "ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        Else
            FlashClick(Allow_nbClickX, Allow_nbClickY, "ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        If !Net_On
            SetTimer, UpdateNet, 100
        Else
        {
            SetTimer, UpdateNet, Off
            Net_Start := 0, Net_Time := Net_Allowed
            Gui, net_status: Show, Hide
            Gui, net_count: Show, Hide
        }
    }
    Else If NBK_Service_On && (hwnd360 := WinExist("ahk_class Q360NetFosClass"))
    {
        Net_On := !Net_On
        
        Gui, net_status: Show, x%XGui9% y%YGui9% NA
        Release_All_Keys()
        FlashPress(clickx, clicky, "ahk_class Q360NetFosClass", "ahk_class #32768")
        If !Net_On
            SetTimer, UpdateNet, 100
        Else
        {
            SetTimer, UpdateNet, Off
            Net_Start := 0, Net_Time := Net_Allowed
            Gui, net_status: Show, Hide
            Gui, net_count: Show, Hide
        }
    }
Return
;==================================================================================
UpdateNet() ;精度0.1s
{
    global XGui9, YGui9, Net_Start, Net_Time, clickx, clicky, Allow_nbClickX, Allow_nbClickY, hwndcf, hwnd360, H360, Net_Text
    Net_Timer(XGui9, YGui9, Net_On, Net_Start, Net_Time, Net_Text, "net_status", "NetBlock")
    If Net_On
    {
        Gui, net_status: Show, Hide
        SetTimer, UpdateNet, Off
        If WinExist("ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        {
            Release_All_Keys()
            FlashClick(Allow_nbClickX, Allow_nbClickY, "ahk_class HwndWrapper\[NLClientApp.exe;;[\da-f\-]+]")
        }
        Else If WinExist("ahk_class Q360NetFosClass")
        {
            Release_All_Keys()
            FlashPress(clickx, clicky, "ahk_class Q360NetFosClass", "ahk_class #32768")
        }
    }
}
;==================================================================================
;断网计时器
Net_Timer(XGui9, YGui9, ByRef Net_On, ByRef Net_Start, ByRef Net_Time, ByRef Net_Text, Gui_Number, ControlID)
{
    global Net_Allowed
    If !Net_On
    {
        If Net_Start = 0
            Net_Start := SystemTime()
        Else
        {
            Net_Time := Round(Net_Allowed + 0.5 - (SystemTime() - Net_Start) / 1000)
            If Net_Time >= 6
                GuiControl, %Gui_Number%: +c00FFFF +Redraw, %ControlID% ;#00FFFF
            Else If (Net_Time <= 5 && Net_Time > 2)
                GuiControl, %Gui_Number%: +cFFFF00 +Redraw, %ControlID% ;#FFFF00
            Else If (Net_Time <= 2 && Net_Time > 0)
                GuiControl, %Gui_Number%: +cFF0000 +Redraw, %ControlID% ;#FF0000
            Else If Net_Time <= 0
            {
                Net_Start := 0
                Net_Time := Net_Allowed
                Net_On := !Net_On
            }
            Net_Text := "一键断天涯|"Net_Time
            UpdateText(Gui_Number, ControlID, Net_Text, XGui9, YGui9)
        }
    }
}
;==================================================================================
;模拟点击界面指定位置,代替controlclick
FlashClick(clickx1, clicky1, winID)
{
    global hwndcf, Xnb, Ynb, Wnb, Hnb
    CheckPosition(Xnb, Ynb, Wnb, Hnb, winID)
    BlockInput, On
    WinMinimize, ahk_class CrossFire
    lParam := clickx1 & 0xFFFF | (clicky1 & 0xFFFF) << 16
    WinActivate, %winID%
    If hwndnt4 := WinExist(winID) ;确保窗口置顶...
        DllCall("SwitchToThisWindow", "UInt", hwndnt4, "UInt", 1)
    WinSet, ExStyle, +0x8, %winID% ;确保窗口置顶...
    CoordMode, Mouse, Screen
    MouseClick, Left, Xnb + Wnb - 10, Ynb + Hnb - 10 ;确保窗口置顶...
    CoordMode, Mouse, Client
    PostMessage, 0x201, 1, %lParam%, , %winID% ;WM_RBUTTONDOWN
    PostMessage, 0x202, 0, %lParam%, , %winID% ;WM_LBUTTONUP
    ControlSend, , {Enter}, %winiD%
    DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
    BlockInput, Off
}
;==================================================================================
;模拟指定界面按键
FlashPress(clickx1, clicky1, winID, menuID)
{
    global Net_On, hwndcf
    BlockInput, On
    WinActivate, %winID%
    ControlClick, x%clickx1% y%clicky1%, %winID%, , Right, , NA
    Loop
    {
        HyperSleep(1)
    } Until WinExist(menuID)
    ControlSend, , {Down}, %menuID%
    If Net_On
        ControlSend, , {Down}, %menuID%
    ControlSend, , {Enter}, %menuID%
    DllCall("SwitchToThisWindow", "UInt", hwndcf, "UInt", 1)
    BlockInput, Off
}
;==================================================================================