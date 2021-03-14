#Include Crossfirer_Functions.ahk
Preset("猎")
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
    HEro_01 := New E_Hero
    Gui, C4: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, C4: Margin, 0, 0
    Gui, C4: Color, 333333 ;#333333
    Gui, C4: Font, s10 c00FFFF, Microsoft YaHei
    Gui, C4: Add, Text, hwndGui_3 vC4Status, %C4_Time% ;#00FFFF
    GuiControlGet, P3, Pos, %Gui_3%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGuiC, YGuiC, "M", -P3W // 2, Round(He / 8) - P3H // 2) ;避开狙击枪秒准线确认点
    Gui, C4: Show, Hide

    Gui, Human_Hero: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Human_Hero: Margin, 0, 0
    Gui, Human_Hero: Color, 333333 ;333333
    Gui, Human_Hero: Font, s10 c00FFFF, Microsoft YaHei ;#00FFFF
    Gui, Human_Hero: Add, Text, hwndhero vIMHero, 猎|_|_|手
    GuiControlGet, PH, Pos, %hero%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20
    SetGuiPosition(XGui8, YGui8, "M", -PHW // 2, Round(He / 8) - PHH // 2) ;避开狙击枪秒准线确认点
    Gui, Human_Hero: Show, Hide
    OnMessage(0x1001, "ReceiveMessage")
    C4H_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp

#IfWinActive, ahk_class CrossFire ;以下的热键需要CF窗口活跃才能激活
~*Enter::
    Suspend, Toggle
    Suspended()
Return

~*RAlt::
    Suspend, Off ;恢复热键
    Suspended()
    If C4H_Service_On
    {
        SetGuiPosition(XGuiC, YGuiC, "M", -P3W // 2, Round(He / 8) - P3H // 2)
        SetGuiPosition(XGui8, YGui8, "M", -PHW // 2, Round(He / 8) - PHH // 2)
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

~*=::
    If C4H_Service_On
    {
        If !GetKeyState("vk87")
            Be_Hero := !Be_Hero
    
        If (Be_Hero && !GetKeyState("vk87"))
        {
            C4_On := False
            HEro_01.Start()
            SetTimer, UpdateC4, Off
            Gui, C4: Show, Hide
            Gui, Human_Hero: Show, x%XGui8% y%YGui8% NA
        }
        Else If (!Be_Hero && !GetKeyState("vk87"))
        {
            HEro_01.Stop()
            Gui, Human_Hero: Show, Hide
        }
    }
Return

~C & ~4::
    If C4H_Service_On
    {
        Be_Hero := False
        C4_On := True
        SetTimer, UpdateC4, 100
        HEro_01.Stop()
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
        GuiControl, %Gui_Number%: +c00FFFF +Redraw, %ControlID% ;#00FFFF
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
;E键快速反应,可以及时补充弹药以及变成猎手
class E_Hero
{
    __New()
    {
        this.X := 0
        this.Y := 0
        this.W := 1600
        this.H := 900
        this.interval := 60
        this.IsReloading := 0
        this.EHero := ObjBindMethod(this, "UpdatE_Hero")
    }

    Start()
    {
        EKHero := this.EHero
        SetTimer, % EKHero, % this.interval
    }

    Stop()
    {
        EKHero := this.EHero
        SetTimer, % EKHero, Off
    }

    UpdatePos()
    {
        CheckPosition(aX, aY, aW, aH, "CrossFire")
        this.X := aX
        this.Y := aY
        this.W := aW
        this.H := aH
    }

    UpdatE_Hero() ;精度0.06s
    {
        global Be_Hero
        this.UpdatePos()
        If (Be_Hero && !GetKeyState("vk87") && WinActive("ahk_class CrossFire"))
        {
            PixelSearch, HeroX1, HeroY1, this.X + this.W // 2 - Round(this.W / 20), this.Y + Round(this.H / 8.5), this.X + this.W // 2 + Round(this.W / 20), this.Y + Round(this.H / 6.5), 0xFFFFFF, 0, Fast ;#FFFFFF 猎手vs幽灵数字
            If !ErrorLevel
            {
                PixelSearch, HeroX2, HeroY2, this.X + this.W // 2 - Round(this.W / 10), this.Y + Round(this.H / 3.1), this.X + this.W // 2 + Round(this.W / 10), this.Y + Round(this.H / 3), 0x1EB4FF, 0, Fast ;#FFB41E #1EB4FF 变猎手字样
                If !ErrorLevel
                    press_key("e", 10, 10)
            }

            PixelSearch, ReloadX1, ReloadY1, this.X + this.W // 2 - Round(this.W / 10), this.Y + Round(this.H / 4), this.X + this.W // 2 + Round(this.W / 10), this.Y + Round(this.H / 3), 0xB7780B, 0, Fast ;#0B78B7 #B7780B #2E81B1 #B1812E 补充弹药
            If !ErrorLevel
            {
                Send, {Blind}{e Down}
                this.IsReloading += 1
                If this.IsReloading > 2
                {
                    PixelSearch, IsReloadX, IsReloadY, this.X + this.W // 2 - Round(this.W / 8), this.Y + Round(this.H * 0.8), this.X + this.W // 2 + Round(this.W / 8), this.Y + this.H, 0xA09C8B, 0, Fast ;#8B9CA0 #A09C8B
                    If ErrorLevel
                    {
                        Send, {Blind}{e Up}
                        this.IsReloading := 0
                    }
                }
            }
            Else If ErrorLevel && GetKeyState("e")
            {
                Send, {Blind}{e Up}
                this.IsReloading := 0
            }
        }
    }
}
;==================================================================================