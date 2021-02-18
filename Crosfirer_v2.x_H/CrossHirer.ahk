#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#SingleInstance, Force
#IfWinActive ahk_class CrossFire  ; Chrome_WidgetWin_1 CrossFire
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
DetectHiddenWindows, On
SetTitleMatchMode, Regex

CheckPermission()
global SHT_Service_On := False
global BHP_Service_On := False
global RCL_Service_On := False
global C4H_Service_On := False
global CLK_Service_On := False
global CTL_Service_On := False
global NBK_Service_On := False

WinGetTitle, CF_Title, ahk_class CrossFire
If CF_Title = CROSSFIRE
    Net_Time := 6
Else If CF_Title = 穿越火线
    Net_Time := 8
Net_Allowed := Net_Time
Net_Text := "一键断天涯|"Net_Time
hwndcf := WinExist("ahk_class CrossFire")

Gun_Chosen := -1
XGui5 := 0, YGui5 := 0, XGui6 := 0, YGui6 := 0, XGui7 := 0, YGui7 := 0
Vertices := 40
Radius := 0
Diameter := 2 * Radius
Angle := 8 * ATan(1) / Vertices
Hole =

AutoMode := False
XGui1 := 0, YGui1 := 0, XGui2 := 0, YGui2 := 0, Xch := 0, Ych := 0
Temp_Mode := "", Temp_Run := ""
crosshair = 34-35 2-35 2-36 34-36 34-60 35-60 35-36 67-36 67-35 35-35 ;35-11 34-11 ;For "T" type crosshair
game_title := 
GamePing :=

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

If WinExist("ahk_class CrossFire")
{
    Start:
    CheckPosition(Xe, Ye, We, He, "CrossFire")

    Gui, C4: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, C4: Margin, 0, 0
    Gui, C4: Color, 333333 ;#333333
    Gui, C4: Font, s15 c00FF00, Microsoft YaHei
    Gui, C4: Add, Text, hwndGui_3 vC4Status, %C4_Time% ;#00FF00 
    GuiControlGet, P3, Pos, %Gui_3%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGuiC, YGuiC, "M", -P3W // 2, Round(He / 7.5) - P3H // 2) ;避开狙击枪秒准线确认点
    Gui, C4: Show, Hide

    Gui, Human_Hero: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Human_Hero: Margin, 0, 0
    Gui, Human_Hero: Color, 333333 ;333333
    Gui, Human_Hero: Font, s15 c00FF00, Microsoft YaHei ;#00FF00
    Gui, Human_Hero: Add, Text, hwndhero vIMHero, 猎手
    GuiControlGet, PH, Pos, %hero%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20
    SetGuiPosition(XGui8, YGui8, "M", -PHW // 2, Round(He / 7.5) - PHH // 2) ;避开狙击枪秒准线确认点
    Gui, Human_Hero: Show, Hide

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

    Gui, Helper: New, +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize -DPIScale, CTL ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Helper: Margin, 0, 0
    Gui, Helper: Color, 333333 ;#333333
    Gui, Helper: Font, s12 c00FF00, Microsoft YaHei ;#00FF00
    Gui, Helper: add, Text, hwndGui_8, ╔====使用==说明===╗`n     按~ =开关自火===`n     按2 ==手枪模式==`n     按3/4 =暂停模式==`n     按J ==瞬狙模式==`n     按L ==连发速点==`n     按Tab键 通用模式=`n================`n     鼠标中间键 右键连点`n     鼠标前进键 左键连点`n     鼠标后退键 左键速点`n     按W和F ==基础鬼跳`n     按W和Alt =空中跳蹲`n     按S和F ==跳蹲上墙`n     按W和C ==前跳跳蹲`n     按S和C ==后跳跳蹲`n     按Z和C ==六级跳箱`n================`n     按H =运行一键限速`n     按- =重新加载本脚本`n     按=  开关秒变猎手`n     大写锁定 最小化窗口`n     向右键 暂停所有按键`n╚====使用==说明===╝
    GuiControlGet, P8, Pos, %Gui_8%
    global P8H ;*= (A_ScreenDPI / 96)
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端

    Gui, Hint: New, +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize -DPIScale, CTL ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Hint: Margin, 0, 0
    Gui, Hint: Color, 333333 ;#333333
    Gui, Hint: Font, s12 c00FF00, Microsoft YaHei ;#00FF00
    Gui, Hint: add, Text, hwndGui_9, 按`n右`n c`n t`n r`n l`n键`n开`n关`n帮`n助
    GuiControlGet, P9, Pos, %Gui_9%
    global P9H ;*= (A_ScreenDPI / 96)
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端

    WinMinimize, ahk_class ConsoleWindowClass
    SetTimer, UpdateGui, 1000 ;不需要太频繁
    DPI_Initial := A_ScreenDPI

    SetGuiPosition(XGui9, YGui9, "V", 0, -P8H // 2)
    SetGuiPosition(XGui10, YGui10, "V", 0, -P9H // 2)
    Gui, Hint: Show, x%XGui10% y%YGui10% NA
    Gui, Helper: Show, Hide

    Radius := Round(Hrs / 18)
    Diameter := 2 * Radius
    Start:
    Gui, recoil_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, recoil_mode: Margin, 0, 0
    Gui, recoil_mode: Color, 333333 ;#333333
    Gui, recoil_mode: Font, s15, Microsoft YaHei
    Gui, recoil_mode: Add, Text, hwndGui_6 vModeClick c00FF00, 压枪准备中 ;#00FF00
    GuiControlGet, P6, Pos, %Gui_6%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui5, YGui5, "M", Round(Wrs / 8) - P6W // 2, Round(Hrs / 9) - P6H // 2)
    Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA

    Gui, gun_sel: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, gun_sel: Margin, 0, 0
    Gui, gun_sel: Color, 333333 ;#333333
    Gui, gun_sel: Font, s15, Microsoft YaHei
    Gui, gun_sel: Add, Text, hwndGui_7 vModeGun c00FF00, 暂未选枪械 ;#00FF00
    GuiControlGet, P7, Pos, %Gui_7%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui6, YGui6, "M", Round(Wrs / 8) - P7W // 2, Round(Hrs / 6) - P7H // 2)
    Gui, gun_sel: Show, x%XGui6% y%YGui6% NA

    Gui, circle: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Hwndcc -DPIScale, Listening
    Gui, circle: Color, FFFF00 ;#FFFF00
    SetGuiPosition(XGui7, YGui7, "M", -Radius, -Radius)
    Gui, circle: Show, x%XGui7% y%YGui7% w%Diameter% h%Diameter% NA
    WinSet, Transparent, 31, ahk_id %cc%
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    Xcc := Radius, Ycc := Radius
    Loop, %Vertices%
        Hole .= Floor(Xcc + Radius * Cos(A_Index * Angle)) "-" Floor(Ycc + Radius * Sin(A_Index * Angle)) " "
    Hole .= Floor(Xcc + Radius * Cos(Angle)) "-" Floor(Ycc + Radius * Sin(Angle))
    WinSet, Region, %Hole%, ahk_id %cc% 
    Hole = ;free memory
    Gui, circle: Show, Hide

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

    Gui, fcn_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_mode: Margin, 0, 0
    Gui, fcn_mode: Color, 333333 ;#333333
    Gui, fcn_mode: Font, s15, Microsoft YaHei
    Gui, fcn_mode: Add, Text, hwndGui_1 vModeOfFcn cFFFF00, 暂停加载 ;#FFFF00
    GuiControlGet, P1, Pos, %Gui_1%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui1, YGui1, "M", -Round(ValueW / 8) - P1W // 2, Round(ValueH / 9) - P1H // 2)
    Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA

    Gui, fcn_status: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_status: Margin, 0, 0
    Gui, fcn_status: Color, 333333 ;#333333
    Gui, fcn_status: Font, s15, Microsoft YaHei
    Gui, fcn_status: Add, Text, hwndGui_2 vStatusOfFun cFFFF00, 自火关闭 ;#FFFF00
    GuiControlGet, P2, Pos, %Gui_2%
    WinSet, TransColor, 333333 191 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui2, YGui2, "M", -Round(ValueW / 8) - P2W // 2, Round(ValueH / 6) - P2H // 2)
    Gui, fcn_status: Show, x%XGui2% y%YGui2% NA

    Gui, cross_hair: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Hwndcr -DPIScale, Listening
    Gui, cross_hair: Color, FFFF00 ;#FFFF00
    SetGuiPosition(Xch, Ych, "M", -34, -35)
    Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    WinSet, Region, %crosshair%, ahk_id %cr%
    WinSet, Transparent, 255, ahk_id %cr%
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端

    FuncPing()

    OnMessage(0x1001, "ReceiveMessage")
    C4H_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp
~*Right::Suspend, Toggle ;输入聊天时不受影响

~*RAlt::
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
            press_key("space", 10, 10)   
            cnt += 1
        } Until, (!GetKeyState("W", "P") || cnt >= 160)
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
        } Until, (cnt >= 40)
        press_key("LCtrl", 100, 20)
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~W & ~Space:: ;连跳,落地少掉血
    If BHP_Service_On
    {
        HyperSleep(200)
        While, GetKeyState("Space", "P")
        {
            GuiControl, jump_mode: +c00FFFF +Redraw, ModeJump ;#00FFFF
            UpdateText("jump_mode", "ModeJump", "基础连跳", XGui4, YGui4)
            press_key("Space", 10, 10)
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
    If BHP_Service_On
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
        } Until, (cnt >= 20)
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
        } Until, (cnt >= 40)
        press_key("LCtrl", 100, 20)
        press_key("Space", 10, 10)
        Send, {Blind}{s Up}
        
        GuiControl, jump_mode: +c00FF00 +Redraw, ModeJump ;#00FF00
        UpdateText("jump_mode", "ModeJump", "跳蹲准备", XGui4, YGui4)
    }
Return

~*=::
    If C4H_Service_On
    {
        If WinActive("ahk_class CrossFire")
            Be_Hero := !Be_Hero
    
        If (Be_Hero && !Not_In_Game())
        {
            C4_On := False
            SetTimer, UpdateHero, 60
            SetTimer, UpdateC4, Off
            Gui, C4: Show, Hide
            Gui, Human_Hero: Show, x%XGui8% y%YGui8% NA
        }
        Else
        {
            SetTimer, UpdateHero, Off
            Gui, Human_Hero: Show, Hide
        }
    }
Return

~*RAlt::
    If C4H_Service_On
    {
        SetGuiPosition(XGuiC, YGuiC, "M", -P3W // 2, Round(He / 7.5) - P3H // 2)
        SetGuiPosition(XGui8, YGui8, "M", -PHW // 2, Round(He / 7.5) - PHH // 2)
        If Be_Hero
        {
            Gui, Human_Hero: Show, x%XGui8% y%YGui8% NA
            Gui, C4: Show, Hide
        }
        Else
            Gui, Human_Hero: Show, Hide

        If C4_On
        {
            Gui, C4: Show, x%XGuiC% y%YGuiC% NA
            Gui, Human_Hero: Show, Hide
        }
        Else
            Gui, C4: Show, Hide
    }
Return

~C & ~4::
    If C4H_Service_On
    {
        Be_Hero := False
        C4_On := True
        SetTimer, UpdateC4, 100
        SetTimer, UpdateHero, Off
        Gui, C4: Show, x%XGuiC% y%YGuiC% NA
        Gui, Human_Hero: Show, Hide
    }
Return

~C & ~5::
    If C4H_Service_On
    {
        C4_On := False
        SetTimer, UpdateC4, Off
        Gui, C4: Show, Hide
    }
Return


~*RAlt::
    If CLK_Service_On
    {
        SetGuiPosition(XGui3, YGui3, "M", -P5W // 2, Round(He / 3) - P5H // 2)
        Gui, click_mode: Show, x%XGui3% y%YGui3% NA
    }
Return

~*MButton:: ;爆裂者轰炸
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "右键连点", XGui3, YGui3)
        While, !(GetKeyState("R", "P") || GetKeyState("LButton", "P")) && WinActive("ahk_class CrossFire") ;避免切换窗口时影响
        {
            press_key("RButton", 10.0, 50.0)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{RButton Up}
    }
Return

~*XButton2:: ;炼狱连刺
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "炼狱连刺", XGui3, YGui3)
        cnt := 0
        While, !(GetKeyState("E", "P") || GetKeyState("LButton", "P") || cnt > 10) && WinActive("ahk_class CrossFire")
        {
            press_key("RButton", 10.0, 270.0) ;炼狱右键
            press_key("LButton", 10.0, 10.0) ;炼狱左键枪刺归位
            cnt += 1
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    }
Return

~*XButton1:: ;半自动速点,适合加特林速点,不适合USP
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "左键速点", XGui3, YGui3)
        While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P")) && WinActive("ahk_class CrossFire")
        {
            press_key("LButton", 30.0, 30.0) ;炼狱射速1000/分
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
        Send, {Blind}{LButton Up}
    }
Return

~*8:: ;大宝剑二段连击
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "二段连击", XGui3, YGui3)
        press_key("RButton", 1050, 150)
        press_key("RButton", 90, 10)
        While, !(GetKeyState("E", "P") || GetKeyState("LButton", "P")) && WinActive("ahk_class CrossFire")
        {
            press_key("RButton", 490, 10)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    }
Return

~*9:: ;粉碎者直射
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "左键不放", XGui3, YGui3)
        Send, {Blind}{LButton Up}
        Send, {LButton Down}
        While, !(GetKeyState("R", "P") || GetKeyState("RButton", "P")) && WinActive("ahk_class CrossFire") && !Not_In_Game()
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

~*0:: ;炼狱热管
    If CLK_Service_On
    {
        GuiControl, click_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
        UpdateText("click_mode", "ModeClick", "炼狱热管", XGui3, YGui3)
        While, !(GetKeyState("E", "P") || GetKeyState("LButton", "P") || GetKeyState("XButton1", "P")) && WinActive("ahk_class CrossFire") && !Not_In_Game() ;炼狱速点时结束
        {
            press_key("LButton", 10.0, 110.0)
        }
        GuiControl, click_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
        UpdateText("click_mode", "ModeClick", "连点准备", XGui3, YGui3)
    }
Return

~*RAlt::
    If CTL_Service_On
    {
        SetGuiPosition(XGui9, YGui9, "V", 0, -P8H // 2)
        SetGuiPosition(XGui10, YGui10, "V", 0, -P9H // 2)
        ShowHelp(Need_Help, XGui9, YGui9, "Helper", XGui10, YGui10, "Hint", 0)
    }
Return

~*RCtrl::
    If CTL_Service_On
        ShowHelp(Need_Help, XGui9, YGui9, "Helper", XGui10, YGui10, "Hint", 1)
Return

~*CapsLock:: ;minimize window and replace origin use
    If CTL_Service_On
    {
        Need_Hide := !Need_Hide
        If (WinActive("ahk_class CrossFire") && Need_Hide)
        {
            WinMinimize, ahk_class CrossFire
            HyperSleep(100)
            MouseMove, A_ScreenWidth // 2, A_ScreenHeight // 2 ;The middle of screen
        }
        Else If (!WinActive("ahk_class CrossFire") && !Need_Hide)
            WinActivate, ahk_class CrossFire ;激活该窗口
    }
Return

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

~*RAlt::
    If RCL_Service_On
    {
        SetGuiPosition(XGui5, YGui5, "M", Round(Wrs / 8) - P6W // 2, Round(Hrs / 9) - P6H // 2)
        Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA
        SetGuiPosition(XGui6, YGui6, "M", Round(Wrs / 8) - P7W // 2, Round(Hrs / 6) - P7H // 2)
        Gui, gun_sel: Show, x%XGui6% y%YGui6% NA
    }
Return

~*$LButton:: ;压枪 正在开发
    If RCL_Service_On
    {
        SetGuiPosition(XGui7, YGui7, "M", -Radius, -Radius)
        Gui, circle: Show, x%XGui7% y%YGui7% w%Diameter% h%Diameter% NA
        If (!Not_In_Game() && Gun_Chosen >= 0)
        {
            GuiControl, recoil_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
            RCL_Text := "自动压枪 " RCL_Down
            UpdateText("recoil_mode", "ModeClick", RCL_Text, XGui5, YGui5)
            Recoilless(Gun_Chosen)
        }
    }
Return

~*Lbutton Up:: ;保障新一轮压枪
    If RCL_Service_On || !WinActive("ahk_class CrossFire")
    {
        Gui, circle: Show, Hide
        If !Not_In_Game()
        {
            GuiControl, recoil_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
            UpdateText("recoil_mode", "ModeClick", "压枪准备中", XGui5, YGui5)
        }
    }
Return

~*RButton:: ;展示圆环
    If RCL_Service_On
    {
        SetGuiPosition(XGui7, YGui7, "M", -Radius, -Radius)
        Gui, circle: Show, x%XGui7% y%YGui7% w%Diameter% h%Diameter% NA
    }
Return

~*Rbutton Up::
    If RCL_Service_On || !WinActive("ahk_class CrossFire")
        Gui, circle: Show, Hide
Return

~*NumpadAdd:: ;按级别压枪
    If RCL_Service_On
        RCL_Down := Mod(RCL_Down + 1, 4)
Return

~*NumpadIns::
~*Numpad0::
    If !Not_In_Game() && RCL_Service_On
    {
        GuiControl, gun_sel: +c00FF00 +Redraw, ModeGun ;#00FF00
        UpdateText("gun_sel", "ModeGun", "暂未选枪械", XGui6, YGui6)
        Gun_Chosen := -1
    }
Return

~*NumpadDot::
~*NumpadDel::
    If !Not_In_Game() && RCL_Service_On
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "通用压点射", XGui6, YGui6)
        Gun_Chosen := 0
    }  
Return

~*NumpadEnd::
~*Numpad1::
    If !Not_In_Game() && RCL_Service_On
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "AK47-B 系", XGui6, YGui6)
        Gun_Chosen := 1
    }  
Return

~*NumpadDown::
~*Numpad2::
    If !Not_In_Game() && RCL_Service_On
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "M4A1-S系", XGui6, YGui6)
        Gun_Chosen := 2
    }
Return

~*RAlt::
    If SHT_Service_On
    {
        SetGuiPosition(XGui1, YGui1, "M", -Round(ValueW / 8) - P1W // 2, Round(ValueH / 9) - P1H // 2)
        SetGuiPosition(XGui2, YGui2, "M", -Round(ValueW / 8) - P2W // 2, Round(ValueH / 6) - P2H // 2)
        SetGuiPosition(Xch, Ych, "M", -34, -35)
        Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA
        Gui, fcn_status: Show, x%XGui2% y%YGui2% NA
        Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    }
Return

~*` Up::
    If SHT_Service_On
        ChangeMode("fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", AutoMode, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
Return

~*1 Up:: ;还原模式
    If (SHT_Service_On && AutoMode && !Not_In_Game() && StrLen(Temp_Run) > 0)
    {
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", Temp_Run, XGui1, YGui1)
        AutoFire(Temp_Mode, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }
Return

~*2 Up:: ;手枪模式
    If (SHT_Service_On && AutoMode && !Not_In_Game())
    {
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载手枪", XGui1, YGui1)
        AutoFire(2, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }
Return

~*Tab Up:: ;通用模式
    If (SHT_Service_On && AutoMode && !Not_In_Game())
    {
        Temp_Mode := 0
        Temp_Run := "加载通用"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载通用", XGui1, YGui1)
        AutoFire(0, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }  
Return

~*J Up:: ;瞬狙模式,M200效果上佳
    If (SHT_Service_On && AutoMode && !Not_In_Game())
    {
        Temp_Mode := 8
        Temp_Run := "加载狙击"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载狙击", XGui1, YGui1)
        AutoFire(8, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }
Return

~*L Up:: ;连点模式
    If (SHT_Service_On && AutoMode && !Not_In_Game())
    {
        Temp_Mode := 111
        Temp_Run := "加载速点"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载速点", XGui1, YGui1)
        AutoFire(111, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing)
    }  
Return
;==================================================================================
;检查脚本执行权限,只有以管理员权限或以UI Access运行才能正常工作
CheckPermission()
{
    If A_OSVersion in WIN_NT4, WIN_95, WIN_98, WIN_ME, WIN_2000, WIN_2003, WIN_XP, WIN_VISTA ;检测操作系统
    {
        MsgBox, 262160, 错误/Error, 此辅助需要Win 7及以上操作系统!!!`nThis program requires Windows 7 or later!!!
        ExitApp
    }

    If Not A_IsAdmin
    {
        Try
        {
            Run, *RunAs "%A_ScriptFullPath%" ;管理员权限运行
        }
        Catch
        {
            MsgBox, 262160, 错误/Error, 未正确运行!辅助将退出!!`nUnable to start correctly!The program will exit!!
            ExitApp
        }
    }
    Else
    {
        Loop
        {
            HyperSleep(3000)
        } Until WinExist("ahk_class CrossFire")
        HyperSleep(5000) ;等待客户端完整出现
    }
}
;==================================================================================
;检查游戏界面真正位置,不包括标题栏和边缘等等
CheckPosition(ByRef Xcp, ByRef Ycp, ByRef Wcp, ByRef Hcp, class_name)
{
    WinGet, CFID, ID, ahk_class %class_name%

    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "ptr", CFID, "ptr", &rect) ;内在宽高
    Wcp := NumGet(rect, 8, "int")
    Hcp := NumGet(rect, 12, "int")

    VarSetCapacity(WINDOWINFO, 60, 0)
    DllCall("GetWindowInfo", "ptr", CFID, "ptr", &WINDOWINFO) ;内在XY
    Xcp := NumGet(WINDOWINFO, 20, "Int")
    Ycp := NumGet(WINDOWINFO, 24, "Int")

    If InStr(class_name, "CrossFire")
    {
        VarSetCapacity(Screen_Info, 156)
        DllCall("EnumDisplaySettingsA", Ptr, 0, UInt, -1, UInt, &Screen_Info) ;真实分辨率
        Mon_Width := NumGet(Screen_Info, 108, "int")
        Mon_Hight := NumGet(Screen_Info, 112, "int")
        If (Wcp >= Mon_Width) || (Hcp >= Mon_Hight) ;全屏检测,未知是否适应UHD不放大
            CoordMode, Pixel, Client
        Else
            CoordMode, Pixel, Screen
    }
}
;==================================================================================
;检查进程是否存在
ProcessExist(Process_Name)
{
    Process, Exist, %Process_Name%
    Return ErrorLevel
}
;==================================================================================
;检测是否不再游戏中,目标为界面左上角火焰状字样黄色部分以及附近的黑色阴影
Not_In_Game() 
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x72FFFF, 0, Fast ;show color in editor: #FFFF72 #72FFFF
    If !ErrorLevel
    {
        PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x000000, 0, Fast ;show color in editor: #000000
        Return !ErrorLevel
    }
    Else
        Return False
}
;==================================================================================
;检测是否退出模式,由按键触发
ExitMode()
{
    Return (Not_In_Game() || GetKeyState("1", "P") || GetKeyState("Tab", "P") || GetKeyState("2", "P") || GetKeyState("3", "P") || GetKeyState("4", "P") || GetKeyState("J", "P") || GetKeyState("L", "P") || GetKeyState("`", "P") || GetKeyState("~", "P") || GetKeyState("RAlt", "P")) 
}
;==================================================================================
;检测点位颜色状态(颜色是否在颜色库中)
GetColorStatus(X, Y, CX1, CX2, color_lib)
{
    PixelGetColor, color_got, (X + CX1), (Y + CX2)
    Return InStr(color_lib, color_got)
}
;==================================================================================
;控制鼠标移动,上下左右
mouseXY(x1,y1)
{
    DllCall("mouse_event", uint, 1, int, x1, int, y1, uint, 0, int, 0)
}
;==================================================================================
;按键脚本,鉴于Input模式下单纯的send太快而开发
press_key(key_name, press_time, sleep_time)
{
    Send, {Blind}{%key_name% DownTemp}
    HyperSleep(press_time)
    Send, {Blind}{%key_name% Up}
    HyperSleep(sleep_time)
}
;==================================================================================
;设置图形界面位置
SetGuiPosition(ByRef XGui, ByRef YGui, GuiPosition, OffsetX, OffsetY)
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    If InStr("H", GuiPosition) ;顶部一栏横向
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + OffsetY
    }
    Else If InStr("V", GuiPosition) ;左侧一栏纵向
    {
        XGui := X1 + OffsetX
        YGui := Y1 + H1 // 2 + OffsetY
    }
    Else If InStr("M", GuiPosition) ;居中显示
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + H1 // 2 + OffsetY
    }
    Else ;从左上角为基准显示
    {
        XGui := X1 + OffsetX
        YGui := Y1 + OffsetY
    }
}
;==================================================================================
;学习自AHK自带的Windows Spy脚本,更新文字状态而减少引起闪烁
UpdateText(Gui_Number, ControlID, NewText, X, Y)
{
    static OldText := {}
    If (OldText[ControlID] != NewText)
    {
        GuiControl, %Gui_Number%: Text, %ControlID%, %NewText%
        OldText[ControlID] := NewText
        Gui, %Gui_Number%: Show, x%X% y%Y% NA
    }
}
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度时钟
SystemTime()
{
    freq := 0, tick := 0
    If (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", tick)
    Return tick / freq * 1000
} 
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度睡眠
HyperSleep(value)
{
    t_accuracy := 0.991 ;本机精度测试结果,通过JacobHu0723的CPS测试项目得出
    value *= t_accuracy
    s_begin_time := SystemTime()
    freq := 0, t_current := 0
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    s_end_time := (s_begin_time + value) * freq / 1000 
    While, (t_current < s_end_time)
    {
        If (s_end_time - t_current) > 20000 ;大于二毫秒时不暴力轮询,以减少CPU占用
        {
            DllCall("Winmm.dll\timeBeginPeriod", UInt, 1)
            DllCall("Sleep", "UInt", 1)
            DllCall("Winmm.dll\timeEndPeriod", UInt, 1)
            ;以上三行代码为相对ahk自带sleep函数稍高精度的睡眠
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
        }
        Else ;小于三毫秒时开始暴力轮询,为更高精度睡眠
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
    }
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,接受信息
ReceiveMessage(Message) 
{
    If Message = 125638
        ExitApp ;退出当前脚本,未来可加其他动作
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,发送信息
PostMessage(Receiver, Message) ;接受方为GUI标题
{
    SetTitleMatchMode, 3
    DetectHiddenWindows, On
    PostMessage, 0x1001, %Message%, , , %Receiver% ahk_class AutoHotkeyGUI
}
;==================================================================================
;释放所有按键,来自于https://www.autohotkey.com/boards/viewtopic.php?t=60762
Release_All_Keys()
{
    Loop, 0xFF
    {
        Key := Format("VK{:02X}", A_Index)
        If GetKeyState(Key)
            Send, {Blind}{%Key% Up}
    }
}
;==================================================================================
;计算一组数的中位数,必须以逗号隔开
Median(values)
{
    Sort, values, N D, ;以逗号为分界符
    VarArray := StrSplit(values, ",")
    Mid := Ceil(VarArray.Length() / 2)
    If Mod(VarArray.Length(), 2) ;奇数
        VarMedian := VarArray[Mid]
    Else ;偶数
        VarMedian := (VarArray[Mid] + VarArray[Mid + 1]) / 2
    Return VarMedian
}
;==================================================================================
;启用规则蓝
;##################################################################################
;# This #Include file was generated by Image2Include.ahk, you must not change it! #
;##################################################################################
Create_Limit_net_1_bmp(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 6088 << !!A_IsUnicode)
    B64 := "Qk3WEQAAAAAAADYAAAAoAAAAPgAAABgAAAABABgAAAAAAKARAAB0EgAAdBIAAAAAAAAAAAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////7uD6+s+V////9v//56iW/+KU////////////////////////57W7/+KU////7uX/7a9R///h////////////9///66+j//7A////573P5ZsD7KkX//vN////8P//7Kht///Z////////5bW77KgD///Z////////58Ha5ZsE5ZsD8LQD///+9v//5aiW/89q////////////////6tD//89r////5bW75ZsD5ZsD9sE5////////AAD////u6P/pnk7/8rD2///lqJbmohfmpCjmpCjmpCjmpCjmpCjmpCjnnh3/4pT////2///mqJb903b////////////2///qqJb//rn////////2///nqJb/4pT////////nwdr/z2v////////////q0P/nmwX/4pT////ntbv/4pT2///qqJb//rn////2///lqJb2wTn////////w///wtG3///7////////////w///sqG3//9n///8AAP///////+e+0/S+Lfb//ueolv/ilP///////////////////////+e1u//ilP///////+nM8PC0EP//+f////////b//+qolv/+uf////////b//+eolv/ilP////////D//+qbbf/+uf////////////D//+qbbf/+uee1u//ilP///+e1u//ilP////////b//+Wolv/Pavb//+qolv/+uf////////////////D//+yobf//2f///wAA////////7ej/7KVI9v/S56iW/+KU////////////////////////57W7/+KU////////7/P/66Bb//7F////////9v//6qiW//65////////9v//56iW/+KU////////////58Ha/89r////7OL/9sFs////7OL/8LQ757W6/+KU////////////////////////7OL/8LQ757W6/+KU////////6tD/9sE6////8P//7Kht///Z////AAD////////z///opIf266Lmr6PmpCjmpCjmpCjmpCjmpCjmpCjmpCjopCj/5KH////////1///pp5L/8q3////////2///qqJb//rn////////2///nqJb/4pT////////////s4v/wtDvw//7qm23//rn////2///qqJbntGv/4pTnwdr/z2v////////nwdr/z2v2///qqJb//rn2///qqJb//rnq0P/2wTr////w///sqG3//9n///8AAP///////////+a1u//Vev////////////////////////////////////////////////n//+WtpOWbA+WbA+WbA+WbA+WbA+WbA+WbA+WbA+WbA+ebA//ilP////////////D//+yobefBuf/Pa+rQ//bBOv///+e1u//ilP///+fB2v/Pa////////+fB2v/Pa////+e1u//ilPb//+qolv/+uerQ//bBOv////D//+yobf//2f///wAA////////////573P5qEP5qQo5qQo5qQo5qQo5qQo5qQo5qQo5qQo66MP///O////////////57W7/+KU////////9v//6qiW//65////////9v//56iW/+KU////////////9v//6qiW//65////6tD/9sE6////58Ha/89r////58Ha/89r////////58Ha/89r////57W7/+KU9v//6qiW//656tD/9sE6////8P//7Kht///Z////AAD////////////nwdr/z2v////////////////////////////w///sqG3//9n////////////ntbv/2oX////////2///qqJb//rn////////2///nqJb/4pT////w///lm23lmwPlmwPlmwPlmwPqtGr2wTr////nwdr/z2v////nwdr/z2v////////nwdr/z2v////ntbv/4pT2///qqJb//rnq0P/2wTr////w///sqG3//9n///8AAP///////////+fB2v/Pa/////////////////////////////D//+yobf//2f///////////+W1u+WbA+WbA+WbA+WbA+WbA+WbA+WbA+WbA+WbA+ebA//ilP///////////////+e1u//ilP///+rQ//bBOv///+fB2v/Pa////+fB2v/Pa////////+fB2v/Pa////+e1u//ilPb//+qolv/+uerQ//bBOv////D//+yobf//2f///wAA////////////58Ha5qEQ5qQo5qQo5qQo5qQo5qQo5qQo5qQo5qQo7awo///V////////////5bW7/89q////////9v//6qiW//65////////9v//56iW/+KU////////////////57W7/+KU////6tD/9sE6////58Ha/89r////58Ha/89r////////58Ha/89r////57W7/+KU9v//6qiW//656tD/9sE6////8P//7Kht///Z////AAD////////////nwdr/z2v////////////////////////////////////////////////////ltbv/z2r////////2///qqJb//rn////////2///nqJb/4pT////////ltbvlmwPlmwPlmwPqmwPq0Ln2wTr////nwdr/z2v////nwdr/z2v////////nwdr/z2v////ntbv/4pT2///qqJb//rnq0P/2wTr////w///sqG3//9n///8AAP///////////+fB2uahEOakKOakKOmqKOq2c+y6c+/NqfbZvPvt5f//+v///////////////+W1u//Pav////////b//+qolv/+uf////////b//+eolv/ilP///////////////+e1u//ilP///+rQ//bBOv///////////////+fB2v/Pa////////+fB2v/Pa/////////////b//+qolv/+uerQ//bBOv////D//+yobf//2f///wAA////////////+/T6///2/////f//+Ort9url79HN7Mi06bZ/5qZO7q4k///Z////////////5bW75ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD55sD/+KU////////////////57W7/+KU////6tD/5ZsF5ZsD5ZsD5ZsD5ZsD5ZsD/89q////////58Ha5ZsE5ZsD5ZsD5ZsD5ZsD6psD//65////////////8P//7Kht///Z////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA"
    DecLen := 0, pStream := "", pBitmap := "", pToken := ""
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    VarSetCapacity(Dec, DecLen, 0)
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    ; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
    ; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
    hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
    pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
    DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
    DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
    hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
    VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
    DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
    DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
    DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
    DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
    DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
    Return hBitmap
}
;==================================================================================
;启用规则灰
;##################################################################################
;# This #Include file was generated by Image2Include.ahk, you must not change it! #
;##################################################################################
Create_Limit_net_2_bmp(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 6088 << !!A_IsUnicode)
    B64 := "Qk3WEQAAAAAAADYAAAAoAAAAPgAAABgAAAABABgAAAAAAKARAAB0EgAAdBIAAAAAAAAAAAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////yeX889TD////6P//oKDD/+fC////////////////////////oLLV/+fC////yer/yaqo///s////////////6v//uarJ///Y////mr3gkI6Ov6GU//zf////1f//wqCy///n////////j7LVwqCO///n////////oMPojo6Ojo6O1LGO////6P//jqDD/9Sx////////////////stX//9Sy////j7LVjo6Ojo6O58Kg////////AAD////J7f+tkqf/9c/o//+QoMOamJSampqampqampqampqampqampqgkpb/58L////o//+UoMP82bb////////////o//+xoMP//9T////////o//+goMP/58L///////+gw+j/1LH///////////+y1f+gjo//58L///+gstX/58Lo//+xoMP//9T////o//+OoMPnwqD////////V///UsrL////////////////V///CoLL//+f///8AAP///////5y/4+K+m+j//6Cgw//nwv///////////////////////6Cy1f/nwv///////67Q9tSxkv///P///////+j//7Ggw///1P///////+j//6Cgw//nwv///////9X//7GPsv//1P///////////9X//7GPsv//1KCy1f/nwv///6Cy1f/nwv///////+j//46gw//Usej//7Ggw///1P///////////////9X//8Kgsv//5////wAA////////x+3/vpyl6P/ioKDD/+fC////////////////////////oLLV/+fC////////z/b/t5Ws///a////////6P//saDD///U////////6P//oKDD/+fC////////////oMPo/9Sx////w+j/58Ky////w+j/1LGgoLLU/+fC////////////////////////w+j/1LGgoLLU/+fC////////stX/58Kg////1f//wqCy///n////AAD////////g//+mmr3q78maqsmampqampqampqampqampqampqampqpmpr/6cj////////l//+rn8H/9c7////////o//+xoMP//9T////////o//+goMP/58L////////////D6P/UsaDV//+xj7L//9T////o//+xoMOgsrL/58Kgw+j/1LH///////+gw+j/1LHo//+xoMP//9To//+xoMP//9Sy1f/nwqD////V///CoLL//+f///8AAP///////////5Wy1f/at/////////////////////////////////////////////////D//46nyY6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6OjqCOjv/nwv///////////9X//8KgsqDD1P/UsbLV/+fCoP///6Cy1f/nwv///6DD6P/Usf///////6DD6P/Usf///6Cy1f/nwuj//7Ggw///1LLV/+fCoP///9X//8Kgsv//5////wAA////////////mr3gmpaSmpqampqampqampqampqampqampqalpqavJqS///g////////////oLLV/+fC////////6P//saDD///U////////6P//oKDD/+fC////////////6P//saDD///U////stX/58Kg////oMPo/9Sx////oMPo/9Sx////////oMPo/9Sx////oLLV/+fC6P//saDD///UstX/58Kg////1f//wqCy///n////AAD///////////+gw+j/1LH////////////////////////////V///CoLL//+f///////////+astX/4Lz////////o//+xoMP//9T////////o//+goMP/58L////V//+Oj7KOjo6Ojo6Ojo6Ojo6ysrHnwqD///+gw+j/1LH///+gw+j/1LH///////+gw+j/1LH///+gstX/58Lo//+xoMP//9Sy1f/nwqD////V///CoLL//+f///8AAP///////////6DD6P/Usf///////////////////////////9X//8Kgsv//5////////////4+y1Y6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6OjqCOjv/nwv///////////////6Cy1f/nwv///7LV/+fCoP///6DD6P/Usf///6DD6P/Usf///////6DD6P/Usf///6Cy1f/nwuj//7Ggw///1LLV/+fCoP///9X//8Kgsv//5////wAA////////////oMPompaSmpqampqampqampqampqampqampqampqaxKWa///k////////////j7LV/9Sx////////6P//saDD///U////////6P//oKDD/+fC////////////////oLLV/+fC////stX/58Kg////oMPo/9Sx////oMPo/9Sx////////oMPo/9Sx////oLLV/+fC6P//saDD///UstX/58Kg////1f//wqCy///n////AAD///////////+gw+j/1LH///////////////////////////////////////////////////+PstX/1LH////////o//+xoMP//9T////////o//+goMP/58L///////+PstWOjo6Ojo6Ojo6xjo6y1NTnwqD///+gw+j/1LH///+gw+j/1LH///////+gw+j/1LH///+gstX/58Lo//+xoMP//9Sy1f/nwqD////V///CoLL//+f///8AAP///////////6DD6JqWkpqampqamqyjmrS0tMO5tNHRzOnf1vfx7////P///////////////4+y1f/Usf///////+j//7Ggw///1P///////+j//6Cgw//nwv///////////////6Cy1f/nwv///7LV/+fCoP///////////////6DD6P/Usf///////6DD6P/Usf///////////+j//7Ggw///1LLV/+fCoP///9X//8Kgsv//5////wAA////////////9/f8///5////+v//7+/06e/v0dbfw8zRsLS5lJ2ny6iY///n////////////j7LVjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6OoI6O/+fC////////////////oLLV/+fC////stX/jo6Pjo6Ojo6Ojo6Ojo6Ojo6O/9Sx////////oMPojo6Ojo6Ojo6Ojo6Ojo6OsY6O///U////////////1f//wqCy///n////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA"
    DecLen := 0, pStream := "", pBitmap := "", pToken := ""
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    VarSetCapacity(Dec, DecLen, 0)
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    ; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
    ; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
    hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
    pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
    DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
    DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
    hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
    VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
    DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
    DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
    DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
    DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
    DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
    Return hBitmap
}
;==================================================================================
;禁用规则蓝
; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_Restore_net_1_bmp(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 6216 << !!A_IsUnicode)
    B64 := "Qk02EgAAAAAAADYAAAAoAAAAPwAAABgAAAABABgAAAAAAAASAAB0EgAAdBIAAAAAAAAAAAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////+Pv/7sW//u3I////7eP95ZxB554G+tJ5////////////9vf/78S3//fW+v//6LrD+9WB////////////////69Tu98Zr////7+v/5Z9e554G+Mxq///9////6MLd+tBt////////7eT/5ps++tBt////////8fD/5aJv5ZsD55sD/+OX////6tHs7agh///b////////////9v//7bSZ///b7eT/5Zs+5ZsD6qID/++7////////AAAA/////////v//7NXp6KJH+teL///9////6s/q8bY5///t////8Or75qZz77g+/vPX////6tHs7awq//3d////////////6tHs9sJU////////////6tHs8LU6///r////8fD/7a5v///b////////9v//5amZ8LUg///r7eT/8LVV///r6tHs9sJU////////6tHs6qIh/++7////////6sLd/+OX////////////////6MLd+tBt////////AAAA////////////////8O396KZx+dSH///66tHs8LU6///r7+P16KZn+teL///9////////9Pn/6KiO/uKX////////////6tHs9sJU////////////6tHs8LU6///r////////58Ld9sI8////////////////58Ld9sI87eT/8LVV///r7eT/8LVV///r////////6tHs7agh///b6tHs9sJU////////////////////6MLd+tBt////////AAAA////////////////////8eP1++DB///96tHs8LU6///r8+r7/OPH/////////////////f//577S98dO////////////6tHs9sJU////////////6tHs8LU6///r////////8fD/7a5v///b+v//67u9/++7+v//6La97dCX8LVV///r////////////////////+v//6La97dCX8LVV///r////9v//6q+Z/++7////6MLd+tBt////////AAAA////////7eT/5Zs+5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD55sD/+OX////////6s/q9L1I///3////////6tHs9sJU////////////6tHs8LU6///r////////+v//6La9/+OX58Ld9sI8////////6tHs6rRU8LVV8fDr7a5v///b////8fD/7a5v///b6tHs9sJU////6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////////////////////////////////////////////////////////////////////69fy5Zss5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD8LUg///r////////////6MLd7sht7a5v9v/b6q+Z/++77eT/8LVV///r8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////////////58Ld5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD8LUg///r////////////7eT/8LVV///r////////6tHs9sJU////////////6tHs8LU6///r////////////6tHs9sJU////9v//6q+Z/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA/////P//6sXU9syB///16sfg+tOA////7tbs+tmm///96sfg+tOA/v//8OHx9cye///1////7eT/77BN///l////////6tHs9sJU////////////6tHs8LU6///r////58Ld5ZsD5ZsD5ZsD5ZsD6qgD6q9r/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////+fv/6cHJ8r5X6MHM9c9t677A+OGr6b/F9cdo6cLV+NV96cbU7rdV/enK///9////7eT/5Zs+5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD8LUg///r////////////7eT/8LVV///r9v//6q+Z/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA/////////////v//7NLo56RS6rFC+tma///9/v//68/k6Kpf67ZX+teV///9////////////7eT/7ag+///b////////6tHs9sJU////////////6tHs8LU6///r////////////7eT/8LVV///r9v//6q+Z/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////6tHs5Zsh5ZsD5ZsD5ZsD5ZsD7Ls85aJv5ZsD5ZsD5ZsD5ZsD5psD+tBt////////7eT/7ag+///b////////6tHs9sJU////////////6tHs8LU6///r////7eT/5Zs+5ZsD5ZsD5ZsD8MI86q+Z/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////////////////6MLd+tBt////////////////6MLd+tBt////////////////////7eT/7ag+///b////////6tHs9sJU////////////6tHs8LU6///r////////////7eT/8LVV///r9v//6q+Z/++7////////////8fD/7a5v///b////8fD/7a5v///b////////////6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA/////////////////v//6MHZ+cxh/////////////f//6L7S+cxh////////////////////7eT/5Zs+5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD8LUg///r////////////7eT/8LVV///r9v//5amZ5ZsD5ZsD5ZsD5ZsD5ZsD7agD///b////8fD/5aJv5ZsD5ZsD5ZsD5ZsD5ZsD9sI8////////////////6MLd+tBt////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA"
    DecLen := 0, pStream := "", pBitmap := "", pToken := ""
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    VarSetCapacity(Dec, DecLen, 0)
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    ; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
    ; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
    hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
    pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
    DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
    DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
    hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
    VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
    DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
    DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
    DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
    DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
    DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
    Return hBitmap
}
;==================================================================================
;禁用规则灰
; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_Restore_net_2_bmp(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 6216 << !!A_IsUnicode)
    B64 := "Qk02EgAAAAAAADYAAAAoAAAAPwAAABgAAAABABgAAAAAAAASAAB0EgAAdBIAAAAAAAAAAAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////7vz/ysfX/PHc////xOj+jo+inZKP8te3////////////6Pn/0MfT//nl9P//qbna9du6////////////////utr06smx////z+//jpStm5KP7dCx///+////qcTp8tWy////////xOn/l46h8tWy////////1vP/jpezjo6OoY6O/+nE////s9bzxKGX///p////////////6f//xLLE///pxOn/jo6hjo6OspeO//LV////////AAAA/////////P//v9vxo5il89y+///+////sdTy17Sg///0////1O78lpy1z7eh/vbm////s9bzyKaa//7q////////////s9bz6cSp////////////s9bz1bKg///y////1vP/xKmz///p////////6f//jqHE1bKX///yxOn/1bKp///ys9bz6cSp////////s9bzspeX//LV////////ssTp/+nE////////////////qcTp8tWy////////AAAA////////////////1fD+o5208dq9///8s9bz1bKg///yzuj5o52w89y+///+////////4/r/oqHA/ufE////////////s9bz6cSp////////////s9bz1bKg///y////////ocTp6cSh////////////////ocTp6cShxOn/1bKp///yxOn/1bKp///y////////s9bzxKGX///ps9bz6cSp////////////////////qcTp8tWy////////AAAA////////////////////2uj59ubY///+s9bz1bKg///y3u78+ejc////////////////+v//oL7i7Mqn////////////s9bz6cSp////////////s9bz1bKg///y////////1vP/xKmz///p8///urvW//LV8///qbPWxNTE1bKp///y////////////////////8///qbPWxNTE1bKp///y////6f//sqnE//LV////qcTp8tWy////////AAAA////////xOn/jo6hjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6OoY6O/+nE////////sdTy4b2l///6////////s9bz6cSp////////////s9bz1bKg///y////////8///qbPW/+nEocTp6cSh////////s9bzsrKp1bKp1vPyxKmz///p////1vP/xKmz///ps9bz6cSp////s9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////////////////////////////////////////////////////////////////////ud33jo6bjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6O1bKX///y////////////qcTpzMyyxKmz6f/psqnE//LVxOn/1bKp///y1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////////////ocTpjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6O1bKX///y////////////xOn/1bKp///y////////s9bz6cSp////////////s9bz1bKg///y////////////s9bz6cSp////6f//sqnE//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////+f//tcfj6NC6///5ssrr9Nm6////ydzz897K///+ssrr9Nm6/v//0ub25dDH///5////xOn/z6ym///v////////s9bz6cSp////////////s9bz1bKg///y////ocTpjo6Ojo6Ojo6Ojo6OsqGOsqmy//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////8fz/rcPd3L+qqcPf5dSyub7Y7ubNrL/b5cqwrMTk7tu4scnkyrWq+e7d///+////xOn/jo6hjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6O1bKX///y////////////xOn/1bKp///y6f//sqnE//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA/////////////v//vtjwm5uotayj897F///+/P//vNTuoqKtt7Oq89zD///+////////////xOn/xKGh///p////////s9bz6cSp////////////s9bz1bKg///y////////////xOn/1bKp///y6f//sqnE//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////s9bzjo6Xjo6Ojo6Ojo6Ojo6Ow7qhjpezjo6Ojo6Ojo6Ojo6Ol46O8tWy////////xOn/xKGh///p////////s9bz6cSp////////////s9bz1bKg///y////xOn/jo6hjo6Ojo6Ojo6O1MShsqnE//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////////////////qcTp8tWy////////////////qcTp8tWy////////////////////xOn/xKGh///p////////s9bz6cSp////////////s9bz1bKg///y////////////xOn/1bKp///y6f//sqnE//LV////////////1vP/xKmz///p////1vP/xKmz///p////////////s9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA/////////////////v//psLn8NGu////////////+v//pL7i8NGu////////////////////xOn/jo6hjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6O1bKX///y////////////xOn/1bKp///y6f//jqHEjo6Ojo6Ojo6Ojo6Ojo6OxKGO///p////1vP/jpezjo6Ojo6Ojo6Ojo6Ojo6O6cSh////////////////qcTp8tWy////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA"
    DecLen := 0, pStream := "", pBitmap := "", pToken := ""
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    VarSetCapacity(Dec, DecLen, 0)
    If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
        Return False
    ; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
    ; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
    hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
    pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
    DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
    DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
    DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
    hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
    VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
    DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
    DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
    DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
    DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
    DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
    Return hBitmap
}
;==================================================================================
;函数化标签,定期循环检测炸弹图标
UpdateC4() ;精度0.1s
{
    global XGuiC, YGuiC, C4_Start, C4_Time, C4Status
    C4Timer(XGuiC, YGuiC, C4_Start, C4_Time, "C4", "C4Status")
}
;==================================================================================
;函数化标签,定期循环检测变猎手时机
UpdateHero() ;精度0.06s
{
    global Xe, Ye, We, He, Be_Hero, XGuiE, YGuiE, XGui8, YGui8
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    GuiControl, Human_Hero: +c00FF00 +Redraw, IMHero ;#00FF00
    UpdateText("Human_Hero", "IMHero", "猎手", XGui8, YGui8)
    If (Be_Hero && !Not_In_Game())
    {
        PixelSearch, HeroX1, HeroY1, Xe + We // 2 - Round(We / 32 * 3), Ye + Round(He / 8.5), Xe + We // 2 + Round(We / 32 * 3), Ye + Round(He / 6.5), 0xFFFFFF, 0, Fast ;#FFFFFF 猎手vs幽灵数字
        If !ErrorLevel
        {
            PixelSearch, HeroX2, HeroY2, Xe + We // 2 - Round(We / 32 * 3), Ye + Round(He / 3) - 5, Xe + We // 2 + Round(We / 32 * 3), Ye + Round(He / 3), 0x1EB4FF, 0, Fast ;#FFB41E #1EB4FF 变猎手字样
            If !ErrorLevel
            {
                press_key("E", 10, 10)
                GuiControl, Human_Hero: +cFFFF00 +Redraw, IMHero ;#FFFF00
                UpdateText("Human_Hero", "IMHero", "猎手", XGui8, YGui8) ;猎手闪烁
            }
        }
    }
}
;==================================================================================
;C4倒计时
C4Timer(XGuiC, YGuiC, ByRef C4_Start, ByRef C4_Time, Gui_Number, ControlID)
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    If Is_C4_Time(X1, Y1, W1, H1)
    {
        If C4_Start = 0
            C4_Start := SystemTime()
        Else If C4_Start > 0
        {
            C4_Time := SubStr("00" . Format("{:.0f}", (40.5 - (SystemTime() - C4_Start) / 1000)), -1) ;强行显示两位数,00起爆
            If (C4_Time < 31 && C4_Time >= 11)
                GuiControl, %Gui_Number%: +cFFFF00 +Redraw, %ControlID% ;#FFFF00
            Else If C4_Time < 11
                GuiControl, %Gui_Number%: +cFF0000 +Redraw, %ControlID% ;#FF0000
            UpdateText(Gui_Number, ControlID, C4_Time, XGuiC, YGuiC)
        }
    }
    Else
    {
        If C4_Start > 0
            C4_Start := 0
        If C4_Time != 40
            C4_Time := 40
        GuiControl, %Gui_Number%: +c00FF00 +Redraw, %ControlID% ;#00FF00
        UpdateText(Gui_Number, ControlID, C4_Time, XGuiC, YGuiC)
    }
}
;==================================================================================
;循环检测C4提示图标
Is_C4_Time(X, Y, W, H)
{
    static PosColor_C4 := "0x0096E3" ;0xE39600 0x0096E3 ;show color in editor: #E39600 #0096E3
    PixelSearch, ColorX, ColorY, X + W // 2 - Round(W / 20), Y + Round(H / 8), X + W // 2 + Round(W / 20), Y + Round(H / 4), %PosColor_C4%, 0, Fast
    If !ErrorLevel
    {
        PixelSearch, ColorX, ColorY, X + W // 2 - Round(W / 20), Y + Round(H / 8), X + W // 2 + Round(W / 20), Y + Round(H / 4), 0xFFFFFF, 0, Fast ;show color in editor: #FFFFFF
        Return !ErrorLevel
    }
    Else
        Return False
}
;==================================================================================
;检测游戏进程是否存在
UpdateGui() ;精度1s
{
    global DPI_Initial
    If !InStr(A_ScreenDPI, DPI_Initial)
        MsgBox, 262144, 提示/Hint, 请按"-"键重新加载脚本`nPlease restart by pressing "-" key
    If !WinExist("ahk_class CrossFire")
    {
        WinClose, ahk_class ConsoleWindowClass
        Loop ;, 10
        {
            PostMessage("Listening", 125638)
            WinGetTitle, Gui_Title, ahk_class AutoHotkeyGUI
            ;MsgBox, , , %Gui_Title%
            If StrLen(Gui_Title) < 4
                Title_Blank += 1
            HyperSleep(100) ;just for stability
        } Until Title_Blank > 4
        If ProcessExist("GameLoader.exe")
            Run, *RunAs .\关闭TX残留进程.bat, , Hide
        ExitApp
    }
}
;==================================================================================
;通过按下快捷键显示/隐藏提示
ShowHelp(ByRef Need_Help, XGui1, YGui1, Gui_Number1, XGui2, YGui2, Gui_Number2, Changer)
{
    If Changer = 1
        Need_Help := !Need_Help
    If Need_Help
    {
        Gui, %Gui_Number1%: Show, x%XGui1% y%YGui1% NA
        Gui, %Gui_Number2%: Show, Hide
    }
    Else
    {
        Gui, %Gui_Number1%: Show, Hide
        Gui, %Gui_Number2%: Show, x%XGui2% y%YGui2% NA
    }
}
;==================================================================================
;函数化标签,定期循环检测断网状态
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
;压枪函数,对相应枪械,均能在中近距离上基本压成一条线,即将标准化
Recoilless(Gun_Chosen)
{
    static Color_Delay := 7 ;本机i5-10300H测试结果,6.985毫秒上下约等于7,使用test_color.ahk测试
    StartTime := SystemTime()
    Ammo_Count := 0
    Loop
    {
        EndTime := Floor(SystemTime() - StartTime + 3 * Color_Delay) ;确保非浮点
        Switch Gun_Chosen
        {
        Case 0: ;通用啥都压系列
            global RCL_Down
            If !GetKeyState("LButton")
                Send, {Blind}{LButton Down}
            If EndTime < 100
                HyperSleep(30 - 3 * Color_Delay)
            Else
                HyperSleep(30)
            Send, {Blind}{LButton Up}
            HyperSleep(70) ;600发/分标准射速
            If RCL_Down && EndTime < 1200
                mouseXY(0, RCL_Down)

        Case 1: ;AK47英雄级
            Ammo_Delay := 100
            Ammo_Count := EndTime // Ammo_Delay ;确保每一发都压到
            If (Ammo_Count < 1)
            {
                mouseXY(0, 3)
                HyperSleep(Ammo_Delay - 3 * Color_Delay)
            }
            Else
            {
                If InRange(1, Ammo_Count, 3)
                {
                    mouseXY(0, 7)
                }
                Else If InRange(3, Ammo_Count, 4)
                {
                    mouseXY(0, 9)
                }
                Else If InRange(4, Ammo_Count, 6)
                {
                    mouseXY(0, 6)
                }
                Else If InRange(6, Ammo_Count, 10)
                {
                    mouseXY(0, 2)
                }
                Else If Ammo_Count >= 10
                    mouseXY(0, 0) ;其实无用
                HyperSleep(Ammo_Delay)
            }

        Case 2: ;M4A1英雄级
            Ammo_Delay := 87.6
            Ammo_Count := EndTime // Ammo_Delay ;确保每一发都压到
            If (Ammo_Count < 1)
            {
                mouseXY(0, 1)
                HyperSleep(Ammo_Delay - 3 * Color_Delay)
            }
            Else
            {
                If InRange(1, Ammo_Count, 3)
                {
                    mouseXY(0, 3)
                }
                Else If InRange(3, Ammo_Count, 6)
                {
                    mouseXY(0, 5)
                }
                Else If InRange(6, Ammo_Count, 10)
                {
                    mouseXY(0, 1)
                }
                Else If Ammo_Count >= 10
                    mouseXY(0, 0) ;其实无用
                HyperSleep(Ammo_Delay)
            }
        }
    } Until !GetKeyState("LButton", "P") 
    Return ;复原StartTime
}
;==================================================================================
;将指定数据与一个范围比较,有点多此一举
InRange(Min, x, Max) 
{
    If (x >= Min) && (x < Max)
        Return True
    Else
        Return False
}
;==================================================================================
FuncPing() 
{
	Gui, Ping_Ev: New, +LastFound +AlwaysOnTop -DPIScale
    Gui, Ping_Ev: Font, s12, Microsoft YaHei
    Gui, Ping_Ev: Add, Text, , 请输入游戏稳定延迟(ping值)
	Gui, Ping_Ev: Add, Edit, vPing_Input w255
	Gui, Ping_Ev: Add, Button, gPingCheck w255, 提交/Submit
	Gui, Ping_Ev: Show, Center, Ping
}
;==================================================================================
;检测ping的图形界面中的按键函数
PingCheck() 
{
	global Ping_Input, GamePing
	Gui, Ping_Ev: Submit
	If !Ping_Is_Valid(Ping_Input)
	{
		MsgBox, 262160, 错误输入/Invalid Input, %Ping_Input%
		FuncPing()
	}
    Else
    {
        Gui, Ping_Ev: Destroy
        GamePing := Ping_Input
    }
}
;==================================================================================
;测试ping值,但会被游戏加速器干扰,且游戏内已经提供ping查询,因此弃用但保留本函数
Test_Game_Ping(URL_Or_Ping)
{
    Runwait, %comspec% /c ping -w 500 -n 3 %URL_Or_Ping% >ping.log, ,Hide ;后台执行cmd ping三次,每次最多等待500毫秒
    FileRead, StrTemp, ping.log
    If RegExMatch(StrTemp, "Average = (\d+)", result)
        speed := (SubStr(result, 11) > 300 ? -1 : SubStr(result, 11))
    Else
        speed := -1

    FileDelete, .\ping.log
    Return speed
}
;==================================================================================
;检测ping值输入是否合乎规范
Ping_Is_Valid(someping)
{
    If !someping
        Return False
    Else If someping Is Not Integer
        Return False
    Else If SubStr(someping, 1, 1) = 0 ;不存在0延迟
        Return False
	Else
		Return True
}
;==================================================================================
;切换自火开/关
ChangeMode(Gui_Number1, Gui_Number2, ModeID, StatusID, ByRef AutoMode, XGui1, YGui1, XGui2, YGui2, CrID, Xch, Ych)
{
    AutoMode := !AutoMode

    If AutoMode
    {
        GuiControl, %Gui_Number1%: +c00FF00 +Redraw, %ModeID% ;#00FF00
        GuiControl, %Gui_Number2%: +c00FF00 +Redraw, %StatusID% ;#00FF00
        UpdateText(Gui_Number1, ModeID, "加载模式", XGui1, YGui1)
        UpdateText(Gui_Number2, StatusID, "自火暂停", XGui2, YGui2)
        Gui, %CrID%: Color, 00FF00 ;#00FF00
        Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
    }
    Else
    {
        GuiControl, %Gui_Number1%: +cFFFF00 +Redraw, %ModeID% ;#FFFF00
        GuiControl, %Gui_Number2%: +cFFFF00 +Redraw, %StatusID% ;#FFFF00
        UpdateText(Gui_Number1, ModeID, "暂停加载", XGui1, YGui1)
        UpdateText(Gui_Number2, StatusID, "自火关闭", XGui2, YGui2)
        Gui, %CrID%: Color, FFFF00 ;#FFFF00
        Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
    }
}
;==================================================================================
;自动开火函数,通过检测红名实现
AutoFire(mo_shi, Gui_Number1, Gui_Number2, ModeID, StatusID, game_title, XGui1, YGui1, XGui2, YGui2, CrID, Xch, Ych, GamePing)
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    static PosColor_snipe := "0x000000" ;#000000
    static Color_Delay := 7 ;本机i5-10300H测试结果,6.985毫秒上下约等于7,使用test_color.ahk测试
    Gui, %CrID%: Color, 00FFFF ;#00FFFF
    Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
    While, WinActive("ahk_class CrossFire")
    {
        Random, rand, 58.0, 62.0 ;设定随机值减少被检测概率
        small_rand := rand / 2
        Var := W1 // 2 - 15 ;788
        GuiControl, %Gui_Number2%: +c00FFFF +Redraw, %StatusID% ;#00FFFF
        UpdateText(Gui_Number2, StatusID, "搜寻敌人", XGui2, YGui2)
        Loop
        {
            If ExitMode()
            {
                GuiControl, %Gui_Number2%: +c00FF00 +Redraw, %StatusID% ;#00FF00
                UpdateText(Gui_Number2, StatusID, "自火暂停", XGui2, YGui2)
                GuiControl, %Gui_Number1%: +c00FF00 +Redraw, %ModeID% ;#00FF00
                UpdateText(Gui_Number1, ModeID, "加载模式", XGui1, YGui1)
                Gui, %CrID%: Color, 00FF00 ;#00FF00
                Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
                Exit ;退出自动开火循环
            }

            If Shoot_Time(X1, Y1, W1, H1, Var, game_title) ;当红名被扫描到时射击
            {
                GuiControl, %Gui_Number1%: +c00FFFF +Redraw, %ModeID% ;#00FFFF
                GuiControl, %Gui_Number2%: +cFF0000 +Redraw, %StatusID% ;#FF0000
                UpdateText(Gui_Number2, StatusID, "发现敌人", XGui2, YGui2)
                Switch mo_shi
                {
                    Case 2:
                        UpdateText(Gui_Number1, ModeID, "手枪模式", XGui1, YGui1)
                        press_key("LButton", 10, small_rand + rand - 3 * Color_Delay) ;控制USP射速
                        mouseXY(0, 1)

                    Case 8:
                        UpdateText(Gui_Number1, ModeID, "瞬狙模式", XGui1, YGui1)
                        If Not GetColorStatus(X1, Y1, W1 // 2 + 1, H1 // 2 + Round(H1 / 9 * 2), PosColor_snipe) ;检测狙击镜准心
                        {
                            press_key("RButton", small_rand, small_rand)
                            press_key("LButton", small_rand - Color_Delay, small_rand - 3 * Color_Delay)
                        }
                        Else
                            press_key("LButton", small_rand - Color_Delay, small_rand - 3 * Color_Delay)
                        ;开镜瞬狙或连狙

                        If (GamePing <= 300) ;允许切枪减少换弹时间
                        {
                            GuiControl, %Gui_Number2%: +c00FF00 +Redraw, %StatusID% ;#00FF00
                            UpdateText(Gui_Number2, StatusID, "双切换弹", XGui2, YGui2)
                            Send, {3 DownTemp}
                            HyperSleep(GamePing + 75)
                            Send, {1 DownTemp}
                            
                            If (GetKeyState("1") && GetKeyState("3")) ;暴力查询是否上弹
                            {
                                Send, {Blind}{3 Up}
                                Send, {Blind}{1 Up}
                                Loop ;确保物理按1退出
                                {
                                    press_key("RButton", small_rand, small_rand - Color_Delay)
                                } Until, (GetColorStatus(X1, Y1, W1 // 2 + 1, H1 // 2 + Round(H1 / 9 * 2), PosColor_snipe) || GetKeyState("LButton", "P") || !WinActive("ahk_class CrossFire"))

                                Loop
                                {
                                    press_key("RButton", small_rand, small_rand - Color_Delay)
                                } Until, (!GetColorStatus(X1, Y1, W1 // 2 + 1, H1 // 2 + Round(H1 / 9 * 2), PosColor_snipe) || GetKeyState("LButton", "P") || !WinActive("ahk_class CrossFire"))
                            }
                        }

                    Case 111:
                        UpdateText(Gui_Number1, ModeID, "连发速点", XGui1, YGui1)
                        press_key("LButton", 2 * rand, rand - 3 * Color_Delay) ;针对霰弹枪,冲锋枪和连狙,不压枪
                    
                    Default: ;通用模式不适合射速高的冲锋枪
                        UpdateText(Gui_Number1, ModeID, "通用模式", XGui1, YGui1)
                        press_key("LButton", small_rand, 10 + rand - 3 * Color_Delay) ;靠近600发每分的射速
                        mouseXY(0, 2) ;小小压枪
                }
            }
            Var += 1
        } Until, Var > (W1 // 2 + 15) ;文字受缩放率影响不大，因此用定值
    }
}
;==================================================================================
;检测开火时机,既扫描红名位置,因国服采用变化红名颜色而使用不同方法
Shoot_Time(X, Y, W, H, Var, game_title) 
{
    static PosColor_red := "0x353796 0x353797 0x353798 0x353799 0x343799 0x34379A 0x34389A 0x34389B 0x34389C 0x33389C 0x33389D 0x33389E 0x33389F 0x32389F 0x32399F 0x3239A0 0x3239A1 0x3239A2 0x3139A2 0x3139A3 0x3139A4 0x313AA4 0x313AA5 0x303AA5 0x303AA6 0x303AA7 0x303AA8 0x2F3AA8 0x2F3AA9 0x2F3BA9 0x2F3BAA 0x2F3BAB 0x2E3BAB 0x2E3BAC 0x2E3BAD 0x2E3BAE 0x2E3CAE 0x2D3CAE 0x2D3CAF 0x2D3CB0 0x2D3CB1 0x2C3CB1 0x2C3CB2 0x2C3CB3 0x2C3DB3 0x2C3DB4 0x2B3DB4 0x2B3DB5 0x2B3DB6 0x2B3DB7 0x2A3DB7 0x2A3EB7 0x2A3EB8 0x2A3EB9 0x2A3EBA 0x293EBA 0x293EBB 0x293EBC 0x293FBC 0x293FBC 0x293FBD 0x283FBD 0x283FBE 0x283FBF 0x283FC0 0x273FC0 0x273FC1 0x2740C1 0x2740C2 0x2740C3 0x2640C4 0x2640C5 0x2640C6 0x2641C6 0x2641C7 0x2541C7 0x2541C8 0x2541C9 0x2541CA 0x2441CA 0x2441CB 0x2442CB 0x2442CC 0x2442CD 0x2342CD 0x2342CE 0x2342CF 0x2342D0 0x2343D0 0x2243D0 0x2243D1 0x2243D2 0x2243D3 0x2143D3 0x2143D4 0x2144D4 0x2144D5 0x2144D6 0x2044D6 0x2044D7 0x2044D8 0x2044D9 0x1F44D9 0x1F45D9 0x1F45DA 0x1F45DB 0x1F45DC 0x1E45DC 0x1E45DD 0x1E45DE 0x1E46DE 0x1E46DF 0x1D46DF 0x1D46E0 0x1D46E1 0x1D46E2 0x1C46E2 0x1C46E3 0x1C47E3 0x1C47E4 0x1C47E5 0x1B47E5 0x1B47E6 0x1B47E7 0x1B47E8 0x1B48E8 0x1A48E8 0x1A48E9 0x1A48EA 0x1A48EB 0x1948EB 0x1948EC 0x1948ED 0x1949ED 0x1949EE 0x1849EE 0x1849EF 0x1849F0 0x1849F1 0x174AF2" ;国内版的红名显示随时间变化,这里记录了几乎所有的颜色元素
    ;show color in editor: #353796 #353797 #353798 #353799 #343799 #34379A #34389A #34389B #34389C #33389C #33389D #33389E #33389F #32389F #32399F #3239A0 #3239A1 #3239A2 #3139A2 #3139A3 #3139A4 #313AA4 #313AA5 #303AA5 #303AA6 #303AA7 #303AA8 #2F3AA8 #2F3AA9 #2F3BA9 #2F3BAA #2F3BAB #2E3BAB #2E3BAC #2E3BAD #2E3BAE #2E3CAE #2D3CAE #2D3CAF #2D3CB0 #2D3CB1 #2C3CB1 #2C3CB2 #2C3CB3 #2C3DB3 #2C3DB4 #2B3DB4 #2B3DB5 #2B3DB6 #2B3DB7 #2A3DB7 #2A3EB7 #2A3EB8 #2A3EB9 #2A3EBA #293EBA #293EBB #293EBC #293FBC #293FBC #293FBD #283FBD #283FBE #283FBF #283FC0 #273FC0 #273FC1 #2740C1 #2740C2 #2740C3 #2640C4 #2640C5 #2640C6 #2641C6 #2641C7 #2541C7 #2541C8 #2541C9 #2541CA #2441CA #2441CB #2442CB #2442CC #2442CD #2342CD #2342CE #2342CF #2342D0 #2343D0 #2243D0 #2243D1 #2243D2 #2243D3 #2143D3 #2143D4 #2144D4 #2144D5 #2144D6 #2044D6 #2044D7 #2044D8 #2044D9 #1F44D9 #1F45D9 #1F45DA #1F45DB #1F45DC #1E45DC #1E45DD #1E45DE #1E46DE #1E46DF #1D46DF #1D46E0 #1D46E1 #1D46E2 #1C46E2 #1C46E3 #1C47E3 #1C47E4 #1C47E5 #1B47E5 #1B47E6 #1B47E7 #1B47E8 #1B48E8 #1A48E8 #1A48E9 #1A48EA #1A48EB #1948EB #1948EC #1948ED #1949ED #1949EE #1849EE #1849EF #1849F0 #1849F1 #174AF2 
    static PosColor_NA_red := "0x174AF2" ;0xF24A17
    ;show color in editor: #F24A17 #174AF2

    If game_title = CROSSFIRE ;检测客户端标题来确定检测位置和颜色库
    {
        PixelSearch, ColorX, ColorY, X + W // 2 - Round(W / 20), Y + H // 2, X + W // 2 + Round(W / 20), Y + H // 2 + Round(H / 15 * 2), %PosColor_NA_red%, 0, Fast
        Return !ErrorLevel
    }
    Else If game_title = 穿越火线
        Return GetColorStatus(X, Y, Var, H // 2 + Round(H / 15), PosColor_red) ;图形界面一半+到红名的距离, 542 对应 1600*900
}
;==================================================================================
;End