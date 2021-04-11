#Include Crossfirer_Functions.ahk
Preset("猎")
;==================================================================================
global C4H_Service_On := False
CheckPermission("战斗猎手")
;==================================================================================
C4_Time := 40
C4_Start := 0
Be_Hero := False
C4_On := False

If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xe, Ye, We, He, "CrossFire")
    HEro_01 := New E_Hero ;秒变猎手类初始化
    C4_Count := New C4Timer ;C4计时类初始化
    Gui, C4: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, C4: Margin, 0, 0
    Gui, C4: Color, 333333 ;#333333
    Gui, C4: Font, S10 Q5 C00FFFF, Microsoft YaHei
    Gui, C4: Add, Text, hwndGui_3 vC4Status, 剩余%C4_Time%秒钟 ;#00FFFF
    GuiControlGet, P3, Pos, %Gui_3%
    Gui, C4: Add, Progress, w%P3W% h4 c00FFFF Background333333 vC4Progress Range0-40, %C4_Time% ;#00FFFF
    
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGuiC, YGuiC, "M", -P3W // 2, Round(He / 8) - P3H // 2) ;避开狙击枪秒准线确认点
    Gui, C4: Show, Hide

    Gui, Human_Hero: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Human_Hero: Margin, 0, 0
    Gui, Human_Hero: Color, 333333 ;333333
    Gui, Human_Hero: Font, S10 Q5 C00FFFF, Microsoft YaHei ;#00FFFF
    Gui, Human_Hero: Add, Text, hwndhero vIMHero, 猎|▁|▁|手
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

#If WinActive("ahk_class CrossFire") && C4H_Service_On ;以下的热键需要相应条件才能激活

~*Enter Up::
    Suspend, Off ;恢复热键,首行为挂起关闭才有效
    If Is_Chatting()
        Suspend, On 
    Suspended()
Return

~*RAlt::
    Suspend, Off ;恢复热键,双保险
    Suspended()
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
Return

~*=::
    If !GetKeyState("vk87")
        Be_Hero := !Be_Hero

    If (Be_Hero && !GetKeyState("vk87"))
    {
        C4_On := False
        HEro_01.Start()
        C4_Count.Stop()
        Gui, C4: Show, Hide
        Gui, Human_Hero: Show, x%XGui8% y%YGui8% NA
    }
    Else If (!Be_Hero && !GetKeyState("vk87"))
    {
        HEro_01.Stop()
        Gui, Human_Hero: Show, Hide
    }
Return

~C & ~4::
    Be_Hero := False
    C4_On := True
    C4_Count.Start()
    HEro_01.Stop()
    Gui, C4: Show, x%XGuiC% y%YGuiC% NA
    Gui, Human_Hero: Show, Hide
Return

~C & ~5::
    C4_On := False
    C4_Count.Stop()
    Gui, C4: Show, Hide
Return
;==================================================================================
;C4计时
class C4Timer
{
    __New()
    {
        this.C4_Start := 0
        this.C4_Time := 40
        this.X := 0
        this.Y := 0
        this.W := 1600
        this.H := 900
        this.interval := 100
        this.IsReloading := 0
        this.C4T := ObjBindMethod(this, "UpdateC4")
    }

    Start()
    {
        C4_Timer := this.C4T
        SetTimer, % C4_Timer, % this.interval
    }

    Stop()
    {
        C4_Timer := this.C4T
        SetTimer, % C4_Timer, Off
    }

    UpdatePos()
    {
        CheckPosition(aX, aY, aW, aH, "CrossFire")
        this.X := aX
        this.Y := aY
        this.W := aW
        this.H := aH
    }

    UpdateC4()
    {
        global XGuiC, YGuiC
        If this.IsC4Time() && !GetKeyState("vk87")
        {
            If this.C4_Start = 0
                this.C4_Start := SystemTime()
            Else If this.C4_Start > 0
            {
                this.C4_Time := SubStr("00" . Format("{:.0f}", (40.5 - (SystemTime() - this.C4_Start) / 1000)), -1) ;强行显示两位数,00起爆
                If (this.C4_Time < 21 && this.C4_Time >= 11)
                {
                    GuiControl, C4: +cFFFF00 +Redraw, C4Status ;#FFFF00
                    GuiControl, C4: +cFFFF00 +Redraw, C4Progress ;#FFFF00
                }
                Else If this.C4_Time < 11
                {
                    GuiControl, C4: +cFF0000 +Redraw, C4Status ;#FF0000
                    GuiControl, C4: +cFF0000 +Redraw, C4Progress ;#FF0000
                }
                GuiControl, C4: , C4Progress, % this.C4_Time
                Gui, C4: Show, x%XGuiC% y%YGuiC% NA
                UpdateText("C4", "C4Status", "剩余" . this.C4_Time . "秒钟", XGuiC, YGuiC)
            }
        }
        Else
        {
            If this.C4_Start > 0
                this.C4_Start := 0
            If this.C4_Time != 40
                this.C4_Time := 40
            GuiControl, C4: +c00FFFF +Redraw, C4Status ;#00FFFF
            GuiControl, C4: , C4Progress, % this.C4_Time
            GuiControl, C4: +c00FFFF +Redraw, C4Progress ;#00FFFF
            Gui, C4: Show, x%XGuiC% y%YGuiC% NA
            UpdateText("C4", "C4Status", "剩余" . this.C4_Time . "秒钟", XGuiC, YGuiC)
        }
    }

    IsC4Time()
    {
        this.UpdatePos()
        PixelSearch, ColorX, ColorY, this.X + this.W // 2 - Round(this.W / 20), this.Y + Round(this.H / 8), this.X + this.W // 2 + Round(this.W / 20), this.Y + Round(this.H / 4), 0x0096E3, 0, Fast ;#E39600 #0096E3
        If !ErrorLevel
        {
            PixelSearch, ColorX, ColorY, this.X + this.W // 2 - Round(this.W / 20), this.Y + Round(this.H / 8), this.X + this.W // 2 + Round(this.W / 20), this.Y + Round(this.H / 4), 0xFFFFFF, 0, Fast ;#FFFFFF
            Return !ErrorLevel
        }
        Else
            Return False
    }
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
        this.interval := 50
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

    UpdatE_Hero() ;精度0.05s
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
            Else If ErrorLevel && GetKeyState("e") && !GetKeyState("e", "P")
            {
                Send, {Blind}{e Up}
                this.IsReloading := 0
            }
        }
    }
}
;==================================================================================