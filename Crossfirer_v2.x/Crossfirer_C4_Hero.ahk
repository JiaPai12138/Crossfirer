#Include Crossfirer_Functions.ahk
Preset()
;==================================================================================
global C4H_Service_On := False
CheckPermission()
;==================================================================================
C4_Time := 40
C4_Start := 0
Be_Hero := False
C4_On := False

If WinExist("ahk_class CrossFire")
{
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
    OnMessage(0x1001, "ReceiveMessage")
    C4H_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp
~*Right::Suspend, Toggle ;输入聊天时不受影响

~*=::
    If C4H_Service_On
    {
        If WinActive("ahk_class CrossFire")
            Be_Hero := !Be_Hero
    
        If (Be_Hero && !GetKeyState("vk87"))
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
;==================================================================================
UpdateC4() ;精度0.1s
{
    global XGuiC, YGuiC, C4_Start, C4_Time, C4Status
    C4Timer(XGuiC, YGuiC, C4_Start, C4_Time, "C4", "C4Status")
}
;==================================================================================
UpdateHero() ;精度0.06s
{
    global Xe, Ye, We, He, Be_Hero, XGuiE, YGuiE, XGui8, YGui8
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    GuiControl, Human_Hero: +c00FF00 +Redraw, IMHero ;#00FF00
    UpdateText("Human_Hero", "IMHero", "猎手", XGui8, YGui8)
    If (Be_Hero && !GetKeyState("vk87"))
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
;C4倒计时辅助,精度0.1s
C4Timer(XGuiC, YGuiC, ByRef C4_Start, ByRef C4_Time, Gui_Number, ControlID)
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    If Is_C4_Time(X1, Y1, W1, H1) && !GetKeyState("vk87")
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