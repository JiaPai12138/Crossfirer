#Include Crossfirer_Functions.ahk
global SHT_Service_On := False
Preset("火")
CheckPermission("自动开火")
;==================================================================================
global AutoMode := False
global mo_shi := -1
XGui1 := 0, YGui1 := 0, XGui2 := 0, YGui2 := 0, Xch := 0, Ych := 0
Temp_Mode := "", Temp_Run := ""
crosshair = 34-35 2-35 2-36 34-36 34-60 35-60 35-36 67-36 67-35 35-35 ;35-11 34-11 ;For "T" type crosshair
game_title :=
global GamePing := 40 ;默认40,涵盖至少85%以上我所常见的国服游戏延迟

If WinExist("ahk_class CrossFire")
{
    WinGetTitle, game_title, ahk_class CrossFire
    CheckPosition(ValueX, ValueY, ValueW, ValueH, "CrossFire")
    Gui, fcn_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_mode: Margin, 0, 0
    Gui, fcn_mode: Color, 333333 ;#333333
    Gui, fcn_mode: Font, S10 Q5, Microsoft YaHei
    Gui, fcn_mode: Add, Text, hwndGui_1 vModeOfFcn cFFFF00, 已暂停加载 ;#FFFF00
    GuiControlGet, P1, Pos, %Gui_1%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui1, YGui1, "M", -Round(ValueW / 10) - P1W // 2, Round(ValueH / 9) - P1H // 2)
    Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA

    Gui, fcn_status: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_status: Margin, 0, 0
    Gui, fcn_status: Color, 333333 ;#333333
    Gui, fcn_status: Font, S10 Q5, Microsoft YaHei
    Gui, fcn_status: Add, Text, hwndGui_2 vStatusOfFcn cFFFF00, 自火已关闭 ;#FFFF00
    GuiControlGet, P2, Pos, %Gui_2%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui2, YGui2, "M", -Round(ValueW / 10) - P2W // 2, Round(ValueH / 7.2) - P2H // 2)
    Gui, fcn_status: Show, x%XGui2% y%YGui2% NA

    Gui, cross_hair: New, +lastfound +ToolWindow -Caption +AlwaysOnTop +Hwndcr -DPIScale, Listening
    Gui, cross_hair: Color, FFFF00 ;#FFFF00
    SetGuiPosition(Xch, Ych, "M", -34, -35)
    Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    WinSet, Region, %crosshair%, ahk_id %cr%
    WinSet, Transparent, 255, ahk_id %cr%
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端

    Snipe_000000 := Create_000000_snipe()

    OnMessage(0x1001, "ReceiveMessage")
    OnMessage(0x1002, "ReceiveMessage")

    ;If game_title = 穿越火线
    ;    GamePing := Test_Game_Ping("cf.qq.com")

    ;If GamePing = 0 ;延迟大于300或者连接不上就没有开启本辅助的必要
    ;    ExitApp
    ;FuncPing() ;有设定默认延迟就不必一开始再要求输入
    SHT_Service_On := True
    WinActivate, ahk_class CrossFire ;激活该窗口
    Return
}
;==================================================================================
~*-::ExitApp

#If SHT_Service_On ;以下的热键需要相应条件才能激活

~*CapsLock Up:: ;最小最大化窗口
    HyperSleep(100)
    If WinActive("ahk_class CrossFire")
    {
        Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA
        Gui, fcn_status: Show, x%XGui2% y%YGui2% NA
        Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    }
    Else
    {
        Gui, fcn_mode: Show, Hide
        Gui, fcn_status: Show, Hide
        Gui, cross_hair: Show, Hide
    }
Return

#If WinActive("ahk_class CrossFire") && SHT_Service_On ;以下的热键需要相应条件才能激活

~*Enter Up::
    Suspend, Off ;恢复热键,首行为挂起关闭才有效
    If Is_Chatting()
        Suspend, On
    Suspended()
Return

~*RAlt::
    Suspend, Off ;恢复热键,双保险
    Suspended()
    SetGuiPosition(XGui1, YGui1, "M", -Round(ValueW / 10) - P1W // 2, Round(ValueH / 9) - P1H // 2)
    SetGuiPosition(XGui2, YGui2, "M", -Round(ValueW / 10) - P2W // 2, Round(ValueH / 7.2) - P2H // 2)
    SetGuiPosition(Xch, Ych, "M", -34, -35)
    Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA
    Gui, fcn_status: Show, x%XGui2% y%YGui2% NA
    Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
Return

~*F7 Up::
    FuncPing() ;重新输入ping
Return

~LCtrl & ~` Up::
~LCtrl & ~~ Up::
    ChangeMode(AutoMode, XGui1, YGui1, XGui2, YGui2, Xch, Ych)
Return

#If (WinActive("ahk_class CrossFire") && SHT_Service_On && AutoMode && CF_Now.GetStatus() && CF_Now.GetHuman()) ;以下的热键需要相应条件才能激活

~*Tab Up::
~*1 Up:: ;还原模式
    If StrLen(Temp_Run) > 0
    {
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", Temp_Run, XGui1, YGui1)
        mo_shi := Temp_Mode
        AutoFire(game_title, XGui1, YGui1, XGui2, YGui2, Xch, Ych)
    }
Return

~*2 Up:: ;手枪模式
    mo_shi := 2
    GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
    UpdateText("fcn_mode", "ModeOfFcn", "加载手枪中", XGui1, YGui1)
    AutoFire(game_title, XGui1, YGui1, XGui2, YGui2, Xch, Ych)
Return

~K Up:: ;通用模式
    Temp_Mode := 0
    mo_shi := 0
    Temp_Run := "加载通用中"
    GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
    UpdateText("fcn_mode", "ModeOfFcn", "加载通用中", XGui1, YGui1)
    AutoFire(game_title, XGui1, YGui1, XGui2, YGui2, Xch, Ych)
Return

~*J Up:: ;瞬狙模式,M200效果上佳
    Temp_Mode := 8
    mo_shi := 8
    Temp_Run := "加载狙击中"
    GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
    UpdateText("fcn_mode", "ModeOfFcn", "加载狙击中", XGui1, YGui1)
    AutoFire(game_title, XGui1, YGui1, XGui2, YGui2, Xch, Ych)
Return

~*L Up:: ;连点模式
    Temp_Mode := 111
    mo_shi := 111
    Temp_Run := "加载速点中"
    GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
    UpdateText("fcn_mode", "ModeOfFcn", "加载速点中", XGui1, YGui1)
    AutoFire(game_title, XGui1, YGui1, XGui2, YGui2, Xch, Ych)
Return
;==================================================================================
;检测ping的图形界面函数,因每次打开仅使用一次故做成函数
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
        ToolTip, 您输入了%Ping_Input%`nYou entered %Ping_Input%
        GamePing := Ping_Input
        HyperSleep(3000)
        ToolTip ;隐藏提示
    }
}
;==================================================================================
;测试ping值,但会被游戏加速器干扰,且游戏内已经提供ping查询,因此弃用但保留本函数
Test_Game_Ping(URL_Or_Ping)
{
    Runwait, %comspec% /c ping -w 500 -n 3 %URL_Or_Ping% >ping.log, , Hide ;后台执行cmd ping三次,每次最多等待500毫秒
    FileRead, StrTemp, ping.log
    If RegExMatch(StrTemp, "Average = (\d+)", result)
        speed := (SubStr(result, 11) > 300 ? 0 : SubStr(result, 11))
    Else
        speed := 0

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
ChangeMode(ByRef AutoMode, XGui1, YGui1, XGui2, YGui2, Xch, Ych)
{
    AutoMode := !AutoMode

    If AutoMode
    {
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        GuiControl, fcn_status: +c00FF00 +Redraw, StatusOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载模式中", XGui1, YGui1)
        UpdateText("fcn_status", "StatusOfFcn", "自火暂停中", XGui2, YGui2)
        Gui, cross_hair: Color, 00FF00 ;#00FF00
        Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    }
    Else
    {
        GuiControl, fcn_mode: +cFFFF00 +Redraw, ModeOfFcn ;#FFFF00
        GuiControl, fcn_status: +cFFFF00 +Redraw, StatusOfFcn ;#FFFF00
        UpdateText("fcn_mode", "ModeOfFcn", "已暂停加载", XGui1, YGui1)
        UpdateText("fcn_status", "StatusOfFcn", "自火已关闭", XGui2, YGui2)
        Gui, cross_hair: Color, FFFF00 ;#FFFF00
        Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    }
}
;==================================================================================
;自动开火函数,通过检测红名实现
AutoFire(game_title, XGui1, YGui1, XGui2, YGui2, Xch, Ych)
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    static Color_Delay := 7 ;本机i5-10300H测试结果,使用color_speed_test.ahk测试
    Gui, cross_hair: Color, 00FFFF ;#00FFFF
    Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    While, CF_Now.GetStatus() && AutoMode
    {
        Random, rand, 59.0, 61.0 ;设定随机值减少被检测概率
        small_rand := rand / 2
        Var := W1 // 2 - 15 ;788
        GuiControl, fcn_status: +c00FFFF +Redraw, StatusOfFcn ;#00FFFF
        UpdateText("fcn_status", "StatusOfFcn", "搜寻敌人中", XGui2, YGui2)
        Loop
        {
            If ExitMode()
            {
                GuiControl, fcn_status: +c00FF00 +Redraw, StatusOfFcn ;#00FF00
                UpdateText("fcn_status", "StatusOfFcn", "自火暂停中", XGui2, YGui2)
                GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
                UpdateText("fcn_mode", "ModeOfFcn", "加载模式中", XGui1, YGui1)
                Gui, cross_hair: Color, 00FF00 ;#00FF00
                Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
                Exit ;退出自动开火循环
            }

            If Shoot_Time(X1, Y1, W1, H1, Var, game_title) ;当红名被扫描到时射击
            {
                GuiControl, fcn_mode: +c00FFFF +Redraw, ModeOfFcn ;#00FFFF
                GuiControl, fcn_status: +cFF0000 +Redraw, StatusOfFcn ;#FF0000
                UpdateText("fcn_status", "StatusOfFcn", "正对准敌人", XGui2, YGui2)
                Switch mo_shi
                {
                    Case 2:
                        UpdateText("fcn_mode", "ModeOfFcn", "手枪模式中", XGui1, YGui1)
                        press_key("LButton", small_rand * 1.5, small_rand * 2.5 - Color_Delay) ;控制USP射速
                        mouseXY(0, 1)

                    Case 8:
                        UpdateText("fcn_mode", "ModeOfFcn", "瞬狙模式中", XGui1, YGui1)
                        If !CheckSnipe(X1, Y1, W1, H1)
                        {
                            press_key("RButton", small_rand * 1.5, small_rand)
                            press_key("LButton", small_rand * 1.5 - Color_Delay, small_rand - Color_Delay)
                        }
                        Else
                            press_key("LButton", small_rand * 1.5 - Color_Delay, small_rand - Color_Delay)
                        ;开镜瞬狙或连狙

                        If (GamePing <= 250) ;允许切枪减少换弹时间
                        {
                            GuiControl, fcn_status: +c00FF00 +Redraw, StatusOfFcn ;#00FF00
                            UpdateText("fcn_status", "StatusOfFcn", "双切换弹中", XGui2, YGui2)
                            Send, {3 DownTemp}
                            HyperSleep(GamePing + 80)
                            Send, {1 DownTemp}

                            If (GetKeyState("1") && GetKeyState("3")) ;暴力查询是否上弹
                            {
                                Send, {Blind}{3 Up}
                                Send, {Blind}{1 Up}
                                press_cnt := 0
                                Loop ;确保及时退出循环
                                {
                                    press_key("RButton", small_rand * 1.5, small_rand - Color_Delay)
                                    press_cnt += 1
                                } Until, (CheckSnipe(X1, Y1, W1, H1) || ExitSwitcher() || press_cnt >= 30)

                                Loop
                                {
                                    press_key("RButton", small_rand * 1.5, small_rand - Color_Delay)
                                } Until, (!CheckSnipe(X1, Y1, W1, H1) || ExitSwitcher())
                            }
                        }

                    Case 111:
                        UpdateText("fcn_mode", "ModeOfFcn", "连发速点中", XGui1, YGui1)
                        press_key("LButton", 3 * rand, small_rand - Color_Delay) ;针对霰弹枪,冲锋枪和连狙,不压枪

                    Default: ;通用模式不适合射速高的冲锋枪
                        UpdateText("fcn_mode", "ModeOfFcn", "通用模式中", XGui1, YGui1)
                        press_key("LButton", small_rand * 1.2, small_rand * 1.8 - Color_Delay) ;3.7*30=111
                        Random, rand_down, 1, 2
                        mouseXY(0, rand_down) ;小小随机压枪
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
    ;static PosColor_blue := "0x963735 0x973735 0x983735 0x993735 0x993734 0x9A3734 0x9A3834 0x9B3834 0x9C3834 0x9C3833 0x9D3833 0x9E3833 0x9F3833 0x9F3832 0x9F3932 0xA03932 0xA13932 0xA23932 0xA23931 0xA33931 0xA43931 0xA43A31 0xA53A31 0xA53A30 0xA63A30 0xA73A30 0xA83A30 0xA83A2F 0xA93A2F 0xA93B2F 0xAA3B2F 0xAB3B2F 0xAB3B2E 0xAC3B2E 0xAD3B2E 0xAE3B2E 0xAE3C2E 0xAE3C2D 0xAF3C2D 0xB03C2D 0xB13C2D 0xB13C2C 0xB23C2C 0xB33C2C 0xB33D2C 0xB43D2C 0xB43D2B 0xB53D2B 0xB63D2B 0xB73D2B 0xB73D2A 0xB73E2A 0xB83E2A 0xB93E2A 0xBA3E2A 0xBA3E29 0xBB3E29 0xBC3E29 0xBC3F29 0xBC3F29 0xBD3F29 0xBD3F28 0xBE3F28 0xBF3F28 0xC03F28 0xC03F27 0xC13F27 0xC14027 0xC24027 0xC34027 0xC44026 0xC54026 0xC64026 0xC64126 0xC74126 0xC74125 0xC84125 0xC94125 0xCA4125 0xCA4124 0xCB4124 0xCB4224 0xCC4224 0xCD4224 0xCD4223 0xCE4223 0xCF4223 0xD04223 0xD04323 0xD04322 0xD14322 0xD24322 0xD34322 0xD34321 0xD44321 0xD44421 0xD54421 0xD64421 0xD64420 0xD74420 0xD84420 0xD94420 0xD9441F 0xD9451F 0xDA451F 0xDB451F 0xDC451F 0xDC451E 0xDD451E 0xDE451E 0xDE461E 0xDF461E 0xDF461D 0xE0461D 0xE1461D 0xE2461D 0xE2461C 0xE3461C 0xE3471C 0xE4471C 0xE5471C 0xE5471B 0xE6471B 0xE7471B 0xE8471B 0xE8481B 0xE8481A 0xE9481A 0xEA481A 0xEB481A 0xEB4819 0xEC4819 0xED4819 0xED4919 0xEE4919 0xEE4918 0xEF4918 0xF04918 0xF14918 0xF24A17"
    ;show color in editor: #963735 #973735 #983735 #993735 #993734 #9A3734 #9A3834 #9B3834 #9C3834 #9C3833 #9D3833 #9E3833 #9F3833 #9F3832 #9F3932 #A03932 #A13932 #A23932 #A23931 #A33931 #A43931 #A43A31 #A53A31 #A53A30 #A63A30 #A73A30 #A83A30 #A83A2F #A93A2F #A93B2F #AA3B2F #AB3B2F #AB3B2E #AC3B2E #AD3B2E #AE3B2E #AE3C2E #AE3C2D #AF3C2D #B03C2D #B13C2D #B13C2C #B23C2C #B33C2C #B33D2C #B43D2C #B43D2B #B53D2B #B63D2B #B73D2B #B73D2A #B73E2A #B83E2A #B93E2A #BA3E2A #BA3E29 #BB3E29 #BC3E29 #BC3F29 #BC3F29 #BD3F29 #BD3F28 #BE3F28 #BF3F28 #C03F28 #C03F27 #C13F27 #C14027 #C24027 #C34027 #C44026 #C54026 #C64026 #C64126 #C74126 #C74125 #C84125 #C94125 #CA4125 #CA4124 #CB4124 #CB4224 #CC4224 #CD4224 #CD4223 #CE4223 #CF4223 #D04223 #D04323 #D04322 #D14322 #D24322 #D34322 #D34321 #D44321 #D44421 #D54421 #D64421 #D64420 #D74420 #D84420 #D94420 #D9441F #D9451F #DA451F #DB451F #DC451F #DC451E #DD451E #DE451E #DE461E #DF461E #DF461D #E0461D #E1461D #E2461D #E2461C #E3461C #E3471C #E4471C #E5471C #E5471B #E6471B #E7471B #E8471B #E8481B #E8481A #E9481A #EA481A #EB481A #EB4819 #EC4819 #ED4819 #ED4919 #EE4919 #EE4918 #EF4918 #F04918 #F14918 #F24A17
    static PosColor_NA_red := "0x174AF2" ;0xF24A17
    ;show color in editor: #F24A17 #174AF2

    HyperSleep(1) ;减小平均cpu占用
    If game_title = CROSSFIRE ;检测客户端标题来确定检测位置和颜色库
    {
        PixelSearch, ColorX, ColorY, X + W // 2 - Round(W / 20), Y + H // 2, X + W // 2 + Round(W / 20), Y + H // 2 + Round(H / 15 * 2), %PosColor_NA_red%, 0, Fast
        Return !ErrorLevel
    }
    Else If game_title = 穿越火线
        Return GetColorStatus(X + Var, Y + (H // 2) + Round(H / 15), PosColor_red) ;图形界面一半+到红名的距离, 510 对应 1600*900
}
;==================================================================================
;检测是否退出模式,由按键触发
ExitMode()
{
    Return (!CF_Now.GetStatus() || !CF_Now.GetHuman() || GetKeyState("1", "P") || GetKeyState("2", "P") || GetKeyState("3", "P") || GetKeyState("4", "P") || GetKeyState("J", "P") || GetKeyState("K", "P") || GetKeyState("L", "P") || GetKeyState("RAlt", "P") || GetKeyState("`", "P") || GetKeyState("~", "P") || GetKeyState("Tab", "P"))
}
;==================================================================================
;检测是否退出双切枪循环
ExitSwitcher()
{
    Return (GetKeyState("LButton", "P") || !WinActive("ahk_class CrossFire") || !AutoMode || mo_shi != 8 || !CF_Now.GetStatus())
}
;==================================================================================
;检测狙击镜瞄准线
CheckSnipe(Xvar, Yvar, Wvar, Hvar)
{
    global Snipe_000000
    If Wvar >= 1280
    {
        ImageSearch, sp_x, sp_y, (Xvar + Wvar // 2) - 3, Yvar + Hvar // 2, (Xvar + Wvar // 2) + 3, Yvar + Hvar // 2 + Round(Hvar / 9 * 2), HBITMAP:*%Snipe_000000% ;检测狙击镜准心 #000000
        Return !ErrorLevel
    }
    Else
        Return GetColorStatus(Xvar + (Wvar // 2) + 1, Yvar + (Hvar // 2) + Round(Hvar / 9 * 2), "0x000000")
    Return False
}
;==================================================================================
;##################################################################################
;# This #Include file was generated by Image2Include.ahk, you must not change it! #
;##################################################################################
Create_000000_snipe(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
    hBitmap := 0
If (hBitmap)
    Return hBitmap
VarSetCapacity(B64, 120 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAAAEAAAAKCAIAAAD6sKMdAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAADElEQVR42mNgIA4AAAAoAAELqaEoAAAAAElFTkSuQmCC"
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