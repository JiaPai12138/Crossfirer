#Include Crossfirer_Functions.ahk
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
    Gui, recoil_mode: Font, s10, Microsoft YaHei
    Gui, recoil_mode: Add, Text, hwndGui_6 vModeClick c00FF00, 压枪准备中 ;#00FF00
    GuiControlGet, P6, Pos, %Gui_6%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui5, YGui5, "M", Round(Wrs / 10) - P6W // 2, Round(Hrs / 9) - P6H // 2)
    Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA

    Gui, gun_sel: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, gun_sel: Margin, 0, 0
    Gui, gun_sel: Color, 333333 ;#333333
    Gui, gun_sel: Font, s10, Microsoft YaHei
    Gui, gun_sel: Add, Text, hwndGui_7 vModeGun c00FF00, 暂未选枪械 ;#00FF00
    GuiControlGet, P7, Pos, %Gui_7%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui6, YGui6, "M", Round(Wrs / 10) - P7W // 2, Round(Hrs / 7.2) - P7H // 2)
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
    RCL_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp
~*Enter::
    Suspend, Toggle ;输入聊天时不受影响
    If A_IsSuspended
        ToolTip, 禁用热键
    Else
        ToolTip
Return

~*RAlt::
    Suspend, Off ;恢复热键
    ToolTip
    If RCL_Service_On
    {
        SetGuiPosition(XGui5, YGui5, "M", Round(Wrs / 10) - P6W // 2, Round(Hrs / 9) - P6H // 2)
        Gui, recoil_mode: Show, x%XGui5% y%YGui5% NA
        SetGuiPosition(XGui6, YGui6, "M", Round(Wrs / 10) - P7W // 2, Round(Hrs / 7.2) - P7H // 2)
        Gui, gun_sel: Show, x%XGui6% y%YGui6% NA
    }
Return

~*$LButton:: ;压枪 正在开发
    If RCL_Service_On && WinActive("ahk_class CrossFire")
    {
        SetGuiPosition(XGui7, YGui7, "M", -Radius, -Radius)
        Gui, circle: Show, x%XGui7% y%YGui7% w%Diameter% h%Diameter% NA
        If (!GetKeyState("vk87") && Gun_Chosen >= 0)
        {
            GuiControl, recoil_mode: +c00FFFF +Redraw, ModeClick ;#00FFFF
            RCL_Text := "自动压枪 " RCL_Down
            UpdateText("recoil_mode", "ModeClick", RCL_Text, XGui5, YGui5)
            Recoilless(Gun_Chosen, Ammo_Delay, RCL_Down)
        }
    }
Return

~*Lbutton Up:: ;保障新一轮压枪
    If RCL_Service_On
    {
        Gui, circle: Show, Hide
        If !GetKeyState("vk87")
        {
            GuiControl, recoil_mode: +c00FF00 +Redraw, ModeClick ;#00FF00
            UpdateText("recoil_mode", "ModeClick", "压枪准备中", XGui5, YGui5)
        }
    }
Return

~*RButton:: ;展示圆环
    If RCL_Service_On && WinActive("ahk_class CrossFire")
    {
        SetGuiPosition(XGui7, YGui7, "M", -Radius, -Radius)
        Gui, circle: Show, x%XGui7% y%YGui7% w%Diameter% h%Diameter% NA
    }
Return

~*Rbutton Up::
    If RCL_Service_On
        Gui, circle: Show, Hide
Return

~*NumpadAdd:: ;按级别压枪
    If RCL_Service_On
        RCL_Down := Mod(RCL_Down + 1, 4)
Return

~*NumpadIns::
~*Numpad0::
    If !GetKeyState("vk87") && RCL_Service_On && WinActive("ahk_class CrossFire")
    {
        GuiControl, gun_sel: +c00FF00 +Redraw, ModeGun ;#00FF00
        UpdateText("gun_sel", "ModeGun", "暂未选枪械", XGui6, YGui6)
        Gun_Chosen := -1
    }
Return

~*NumpadDot::
~*NumpadDel::
    If !GetKeyState("vk87") && RCL_Service_On && WinActive("ahk_class CrossFire")
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "通用压点射", XGui6, YGui6)
        Gun_Chosen := 0 ;, Ammo_Delay := 87.6
    }  
Return

~*NumpadEnd::
~*Numpad1::
    If !GetKeyState("vk87") && RCL_Service_On && WinActive("ahk_class CrossFire")
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "AK47-B 系", XGui6, YGui6)
        Gun_Chosen := 1, Ammo_Delay := 100
    }  
Return

~*NumpadDown::
~*Numpad2::
    If !GetKeyState("vk87") && RCL_Service_On && WinActive("ahk_class CrossFire")
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "M4A1-S系", XGui6, YGui6)
        Gun_Chosen := 2, Ammo_Delay := 87.6
    }
Return

~*NumpadPgDn::
~*Numpad3::
    If !GetKeyState("vk87") && RCL_Service_On && WinActive("ahk_class CrossFire")
    {
        GuiControl, gun_sel: +c00FFFF +Redraw, ModeGun ;#00FFFF
        UpdateText("gun_sel", "ModeGun", "HK417- 系", XGui6, YGui6)
        Gun_Chosen := 3, Ammo_Delay := 32
    }
Return
;==================================================================================
;压枪函数,对相应枪械,均能在中近距离上基本压成一条线,即将标准化
Recoilless(Gun_Chosen, Ammo_Delay, RCL_Down)
{
    StartTime := SystemTime()
    Ammo_Count := 0
    Loop
    {
        EndTime := Floor(SystemTime() - StartTime) ;确保非浮点
        Switch Gun_Chosen
        {
        Case 0: ;通用啥都压系列
            Ammo_Count := EndTime // Ammo_Delay ;确保每一发都压到
            If !GetKeyState("LButton")
                Send, {Blind}{LButton Down}
            HyperSleep(10)
            Send, {Blind}{LButton Up}
            HyperSleep(Ammo_Delay - 10)
            If RCL_Down && Ammo_Count < 10 && Ammo_Delay > 60
                mouseXY(0, RCL_Down)
            Else
            {
                If !Mod(Ammo_Count, 3) && Ammo_Count <= 80
                    mouseXY(0, 1) ;DPI 800,灵敏32
            }


        Case 1: ;AK47英雄级
            Ammo_Delay := 100
            Ammo_Count := EndTime // Ammo_Delay ;确保每一发都压到
            If (Ammo_Count < 1)
            {
                mouseXY(0, 3)
                HyperSleep(Ammo_Delay)
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
                HyperSleep(Ammo_Delay)
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