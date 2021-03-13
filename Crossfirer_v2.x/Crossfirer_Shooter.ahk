#Include Crossfirer_Functions.ahk
Preset("火")
;==================================================================================
global SHT_Service_On := False
CheckPermission()
;==================================================================================
AutoMode := False
XGui1 := 0, YGui1 := 0, XGui2 := 0, YGui2 := 0, Xch := 0, Ych := 0
Temp_Mode := "", Temp_Run := ""
crosshair = 34-35 2-35 2-36 34-36 34-60 35-60 35-36 67-36 67-35 35-35 ;35-11 34-11 ;For "T" type crosshair
game_title := 
GamePing :=

If WinExist("ahk_class CrossFire")
{
    WinGetTitle, game_title, ahk_class CrossFire
    CheckPosition(ValueX, ValueY, ValueW, ValueH, "CrossFire")
    Gui, fcn_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_mode: Margin, 0, 0
    Gui, fcn_mode: Color, 333333 ;#333333
    Gui, fcn_mode: Font, s10, Microsoft YaHei
    Gui, fcn_mode: Add, Text, hwndGui_1 vModeOfFcn cFFFF00, 已暂停加载 ;#FFFF00
    GuiControlGet, P1, Pos, %Gui_1%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui1, YGui1, "M", -Round(ValueW / 10) - P1W // 2, Round(ValueH / 9) - P1H // 2)
    Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA

    Gui, fcn_status: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, fcn_status: Margin, 0, 0
    Gui, fcn_status: Color, 333333 ;#333333
    Gui, fcn_status: Font, s10, Microsoft YaHei
    Gui, fcn_status: Add, Text, hwndGui_2 vStatusOfFun cFFFF00, 自火已关闭 ;#FFFF00
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

    OnMessage(0x1001, "ReceiveMessage")

    ;If game_title = CROSSFIRE 
    ;    GamePing := Test_Game_Ping("172.217.1.142") + Test_Game_Ping("172.217.9.168")
    ;Else If game_title = 穿越火线
    ;    GamePing := Test_Game_Ping("203.205.239.243")
        
    ;If GamePing = 0 ;延迟大于300或者连接不上就没有玩的必要
    ;    ExitApp
    FuncPing()
    SHT_Service_On := True
    WinActivate, ahk_class CrossFire ;激活该窗口
    Return
}
;==================================================================================
~*-::ExitApp
~*Enter::
    Suspend, Toggle ;输入聊天时不受影响
    Suspended()
Return

~*RAlt::
    Suspend, Off ;恢复热键
    Suspended()
    If SHT_Service_On
    {
        SetGuiPosition(XGui1, YGui1, "M", -Round(ValueW / 10) - P1W // 2, Round(ValueH / 9) - P1H // 2)
        SetGuiPosition(XGui2, YGui2, "M", -Round(ValueW / 10) - P2W // 2, Round(ValueH / 7.2) - P2H // 2)
        SetGuiPosition(Xch, Ych, "M", -34, -35)
        Gui, fcn_mode: Show, x%XGui1% y%YGui1% NA
        Gui, fcn_status: Show, x%XGui2% y%YGui2% NA
        Gui, cross_hair: Show, x%Xch% y%Ych% w66 h66 NA
    }
Return

~*F7 Up::
    FuncPing() ;重新输入ping
Return

~*` Up::
~*~ Up::
    If SHT_Service_On
        ChangeMode("fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", AutoMode, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych)
Return

~*1 Up:: ;还原模式
    If (SHT_Service_On && AutoMode && !GetKeyState("vk87") && StrLen(Temp_Run) > 0)
    {
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", Temp_Run, XGui1, YGui1)
        AutoFire(Temp_Mode, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing, AutoMode)
    }
Return

~*2 Up:: ;手枪模式
    If (SHT_Service_On && AutoMode && !GetKeyState("vk87"))
    {
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载手枪中", XGui1, YGui1)
        AutoFire(2, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing, AutoMode)
    }
Return

~*Tab Up:: ;通用模式
    If (SHT_Service_On && AutoMode && !GetKeyState("vk87"))
    {
        Temp_Mode := 0
        Temp_Run := "加载通用中"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载通用中", XGui1, YGui1)
        AutoFire(0, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing, AutoMode)
    }  
Return

~*J Up:: ;瞬狙模式,M200效果上佳
    If (SHT_Service_On && AutoMode && !GetKeyState("vk87"))
    {
        Temp_Mode := 8
        Temp_Run := "加载狙击中"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载狙击中", XGui1, YGui1)
        AutoFire(8, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing, AutoMode)
    }
Return

~*L Up:: ;连点模式
    If (SHT_Service_On && AutoMode && !GetKeyState("vk87"))
    {
        Temp_Mode := 111
        Temp_Run := "加载速点中"
        GuiControl, fcn_mode: +c00FF00 +Redraw, ModeOfFcn ;#00FF00
        UpdateText("fcn_mode", "ModeOfFcn", "加载速点中", XGui1, YGui1)
        AutoFire(111, "fcn_mode", "fcn_status", "ModeOfFcn", "StatusOfFun", game_title, XGui1, YGui1, XGui2, YGui2, "cross_hair", Xch, Ych, GamePing, AutoMode)
    }  
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
    Runwait, %comspec% /c ping -w 500 -n 3 %URL_Or_Ping% >ping.log, ,Hide ;后台执行cmd ping三次,每次最多等待500毫秒
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
ChangeMode(Gui_Number1, Gui_Number2, ModeID, StatusID, ByRef AutoMode, XGui1, YGui1, XGui2, YGui2, CrID, Xch, Ych)
{
    AutoMode := !AutoMode

    If AutoMode
    {
        GuiControl, %Gui_Number1%: +c00FF00 +Redraw, %ModeID% ;#00FF00
        GuiControl, %Gui_Number2%: +c00FF00 +Redraw, %StatusID% ;#00FF00
        UpdateText(Gui_Number1, ModeID, "加载模式中", XGui1, YGui1)
        UpdateText(Gui_Number2, StatusID, "自火暂停中", XGui2, YGui2)
        Gui, %CrID%: Color, 00FF00 ;#00FF00
        Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
    }
    Else
    {
        GuiControl, %Gui_Number1%: +cFFFF00 +Redraw, %ModeID% ;#FFFF00
        GuiControl, %Gui_Number2%: +cFFFF00 +Redraw, %StatusID% ;#FFFF00
        UpdateText(Gui_Number1, ModeID, "已暂停加载", XGui1, YGui1)
        UpdateText(Gui_Number2, StatusID, "自火已关闭", XGui2, YGui2)
        Gui, %CrID%: Color, FFFF00 ;#FFFF00
        Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
    }
}
;==================================================================================
;自动开火函数,通过检测红名实现
AutoFire(mo_shi, Gui_Number1, Gui_Number2, ModeID, StatusID, game_title, XGui1, YGui1, XGui2, YGui2, CrID, Xch, Ych, GamePing, AutoMode)
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    static PosColor_snipe := "0x000000" ;#000000
    static Color_Delay := 7 ;本机i5-10300H测试结果,6.985毫秒上下约等于7,使用test_color.ahk测试
    Gui, %CrID%: Color, 00FFFF ;#00FFFF
    Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
    While, !GetKeyState("vk87")
    {
        Random, rand, 58.0, 62.0 ;设定随机值减少被检测概率
        small_rand := rand / 2
        Var := W1 // 2 - 15 ;788
        GuiControl, %Gui_Number2%: +c00FFFF +Redraw, %StatusID% ;#00FFFF
        UpdateText(Gui_Number2, StatusID, "搜寻敌人中", XGui2, YGui2)
        Loop
        {
            If ExitMode()
            {
                GuiControl, %Gui_Number2%: +c00FF00 +Redraw, %StatusID% ;#00FF00
                UpdateText(Gui_Number2, StatusID, "自火暂停中", XGui2, YGui2)
                GuiControl, %Gui_Number1%: +c00FF00 +Redraw, %ModeID% ;#00FF00
                UpdateText(Gui_Number1, ModeID, "加载模式中", XGui1, YGui1)
                Gui, %CrID%: Color, 00FF00 ;#00FF00
                Gui, %CrID%: Show, x%Xch% y%Ych% w66 h66 NA
                Exit ;退出自动开火循环
            }

            If Shoot_Time(X1, Y1, W1, H1, Var, game_title) ;当红名被扫描到时射击
            {
                GuiControl, %Gui_Number1%: +c00FFFF +Redraw, %ModeID% ;#00FFFF
                GuiControl, %Gui_Number2%: +cFF0000 +Redraw, %StatusID% ;#FF0000
                UpdateText(Gui_Number2, StatusID, "正对准敌人", XGui2, YGui2)
                Switch mo_shi
                {
                    Case 2:
                        UpdateText(Gui_Number1, ModeID, "手枪模式中", XGui1, YGui1)
                        press_key("LButton", 10, small_rand + rand - Color_Delay) ;控制USP射速
                        mouseXY(0, 1)

                    Case 8:
                        UpdateText(Gui_Number1, ModeID, "瞬狙模式中", XGui1, YGui1)
                        If Not GetColorStatus(X1, Y1, W1 // 2 + 1, H1 // 2 + Round(H1 / 9 * 2), PosColor_snipe) ;检测狙击镜准心
                        {
                            press_key("RButton", small_rand, small_rand)
                            press_key("LButton", small_rand - Color_Delay, small_rand - Color_Delay)
                        }
                        Else
                            press_key("LButton", small_rand - Color_Delay, small_rand - Color_Delay)
                        ;开镜瞬狙或连狙

                        If (GamePing <= 300) ;允许切枪减少换弹时间
                        {
                            GuiControl, %Gui_Number2%: +c00FF00 +Redraw, %StatusID% ;#00FF00
                            UpdateText(Gui_Number2, StatusID, "双切换弹中", XGui2, YGui2)
                            Send, {3 DownTemp}
                            HyperSleep(GamePing + 60)
                            press_key("LButton", 10, 10)
                            Send, {1 DownTemp}
                            
                            If (GetKeyState("1") && GetKeyState("3")) ;暴力查询是否上弹
                            {
                                Send, {Blind}{3 Up}
                                Send, {Blind}{1 Up}
                                Loop ;确保及时退出循环
                                {
                                    press_key("RButton", small_rand, small_rand - Color_Delay)
                                } Until, (GetColorStatus(X1, Y1, W1 // 2 + 1, H1 // 2 + Round(H1 / 9 * 2), PosColor_snipe) || GetKeyState("LButton", "P") || !WinActive("ahk_class CrossFire") || !AutoMode || mo_shi != 8 || GetKeyState("vk87"))

                                Loop
                                {
                                    press_key("RButton", small_rand, small_rand - Color_Delay)
                                } Until, (!GetColorStatus(X1, Y1, W1 // 2 + 1, H1 // 2 + Round(H1 / 9 * 2), PosColor_snipe) || GetKeyState("LButton", "P") || !WinActive("ahk_class CrossFire") || !AutoMode || mo_shi != 8 || GetKeyState("vk87"))
                            }
                        }

                    Case 111:
                        UpdateText(Gui_Number1, ModeID, "连发速点中", XGui1, YGui1)
                        press_key("LButton", 2 * rand, rand - Color_Delay) ;针对霰弹枪,冲锋枪和连狙,不压枪
                    
                    Default: ;通用模式不适合射速高的冲锋枪
                        UpdateText(Gui_Number1, ModeID, "通用模式中", XGui1, YGui1)
                        press_key("LButton", 10, small_rand + rand - Color_Delay) ;靠近600发每分的射速
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
        Return GetColorStatus(X, Y, Var, H // 2 + Round(H / 15), PosColor_red) ;图形界面一半+到红名的距离, 510 对应 1600*900
}
;==================================================================================