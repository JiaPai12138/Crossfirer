#Include, CrossHirer_Functions.ahk  
Preset()
;==================================================================================
global RCL_Service_On := False
RCL_Down := 0
CheckPermission()
;==================================================================================
Gun_Chosen := -1
XGui5 := 0, YGui5 := 0, XGui6 := 0, YGui6 := 0, XGui7 := 0, YGui7 := 0
Vertices := 40
Radius := 0
Diameter := 2 * Radius
Angle := 8 * ATan(1) / Vertices
Hole = 

If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xrs, Yrs, Wrs, Hrs, "CrossFire")
    Radius := Round(Hrs / 18)
    Diameter := 2 * Radius
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
    OnMessage(0x1001, "ReceiveMessage")
    OnMessage(0x1001, "ReceiveActionR")
    RCL_Service_On := True
}
;==================================================================================
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
        Default:
            Continue
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
;学习自AHK论坛中的多脚本间通过端口简单通信函数,接受其他信息
ReceiveActionR(Message) 
{
    global
    If (Message = 123865) && RCL_Service_On
    {
        SetGuiPosition(XGui5, YGui5, "M", Round(Wrs / 8) - P6W // 2, Round(Hrs / 9) - P6H // 2)
        Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA
        SetGuiPosition(XGui6, YGui6, "M", Round(Wrs / 8) - P7W // 2, Round(Hrs / 6) - P7H // 2)
        Gui, gun_sel: Show, x%XGui6% y%YGui6% NA
    }
}
;==================================================================================