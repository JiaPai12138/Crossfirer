#Include Crossfirer_Functions.ahk
Preset("尽")
;==================================================================================
global CLG_Service_On := False
CheckPermission("无尽挂机")
;==================================================================================
global cstage := 0
global 挂机 := False
global 准备 := False
global Xj := 0, Yj := 0, Wj := 1600, Hj := 900
global Sel_Level := 6
global Show_Sel_Level := SubStr("00" . Sel_Level, -1)

If WinExist("ahk_class CrossFire")
{
    CheckPosition(Xj, Yj, Wj, Hj, "CrossFire")
    Gui, challen_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, challen_mode: Margin, 0, 0
    Gui, challen_mode: Color, 333333 ;#333333
    Gui, challen_mode: Font, S10 Q5, Microsoft YaHei
    Gui, challen_mode: Add, Text, hwndGui_10 vModeChallen c00FF00, 无尽挂机准备%Show_Sel_Level% ;#00FF00
    GuiControlGet, P10, Pos, %Gui_10%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui10, YGui10, "H", -P10W // 2, Round(Hj / 18) - P10H // 2)
    Gui, challen_mode: Show, x%XGui10% y%YGui10% NA
    OnMessage(0x1001, "ReceiveMessage")
    CLG_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp

#If WinActive("ahk_class CrossFire") && CLG_Service_On ;以下的热键需要相应条件才能激活

~*Enter Up::
    Suspend, Off ;恢复热键,首行为挂起关闭才有效
    If Is_Chatting()
        Suspend, On 
    Suspended()
Return

~*RAlt::
    Suspend, Off ;恢复热键,双保险
    Suspended()
    SetGuiPosition(XGui10, YGui10, "H", -P10W // 2, Round(Hj / 18) - P10H // 2)
    Gui, challen_mode: Show, x%XGui10% y%YGui10% NA
Return

~*F8::
    Send, {Blind}{vk86 Down}
    GuiControl, challen_mode: +c00FFFF +Redraw, ModeChallen ;#00FFFF
    UpdateText("challen_mode", "ModeChallen", "开始无尽挂机" . Show_Sel_Level, XGui10, YGui10)
    挂机 := True
    While, WinExist("ahk_class CrossFire") && 挂机
    {
        If !准备
            无尽准备()
        Else
        {
            等级调整()
            无尽挑战挂机()
            无尽收尾()
        }
        HyperSleep(1000)
    }
    GuiControl, challen_mode: +c00FF00 +Redraw, ModeChallen ;#00FF00
    UpdateText("challen_mode", "ModeChallen", "无尽挂机准备" . Show_Sel_Level, XGui10, YGui10)
    挂机 := False
    Send, {Blind}{vk86 Up}
Return

~*Left::
    Sel_Level -= 1
    If Sel_Level < 1
        Sel_Level := 1
    Show_Sel_Level := SubStr("00" . Sel_Level, -1)
    If !挂机
        UpdateText("challen_mode", "ModeChallen", "无尽挂机准备" . Show_Sel_Level, XGui10, YGui10)
    Else
        UpdateText("challen_mode", "ModeChallen", "开始无尽挂机" . Show_Sel_Level, XGui10, YGui10)
Return

~*Right::
    Sel_Level += 1
    If Sel_Level > 10
        Sel_Level := 10
    Show_Sel_Level := SubStr("00" . Sel_Level, -1)
    If !挂机
        UpdateText("challen_mode", "ModeChallen", "无尽挂机准备" . Show_Sel_Level, XGui10, YGui10)
    Else
        UpdateText("challen_mode", "ModeChallen", "开始无尽挂机" . Show_Sel_Level, XGui10, YGui10)
Return

~*Esc::
    挂机 := False
    准备 := False
    UpdateText("challen_mode", "ModeChallen", "无尽挂机准备" . Show_Sel_Level, XGui10, YGui10)
Exit ;退出当前线程
;==================================================================================
;执行无尽挑战挂机,需要目前背包选择的武器或者背包1位主武器为神圣爆裂者
无尽挑战挂机()
{
    If GetKeyState("vk87")
    {
        ClickWait(0.94, 0.823) ;点击开始游戏
        ClickWait(0.5, 0.648) ;离开原本退出的比赛
        游戏即将开始 := False, 进入游戏x := 0, 进入游戏y := 0, Char_Dead := False

        Loop
        {
            ToolTip, 等待进入游戏, , , 19
            HyperSleep(1000)
            PixelSearch, 进入游戏x, 进入游戏y, Xj + Round(Wj / 8), Yj, Xj + Round(Wj / 4), Yj + Round(Hj / 9), 0x836F54, 0, Fast ;#546F83 #836F54
            If !ErrorLevel
                游戏即将开始 := True
        } Until, (!GetKeyState("vk87") && 游戏即将开始) || JumpLoop() ;等待进入游戏
        ToolTip, 进入房间界面, , , 19
        HyperSleep(15000) ;进入地图大约15秒

        Game_Start_Min := A_Min, Game_Start_Sec := A_Sec
        
        确认成绩x := 0, 确认成绩y := 0, 确认成绩a := 0, 确认成绩b := 0, 升级x := 0, 升级y := 0
        Boss_Come := False, Boss_x := 0, Boss_y := 0, Boss_x1 := 0, Boss_y1 := 0
        Loop
        {
            确认死亡x := 0, 确认死亡y := 0
            CheckPosition(Xj, Yj, Wj, Hj, "CrossFire")
            PixelSearch, 确认死亡x, 确认死亡y, Xj + Wj // 2 - Round(Wj * 0.05), Yj + Round(Hj / 3), Xj + Wj // 2 + Round(Wj * 0.05), Yj + Hj // 2, 0x00FFFF, 0, Fast ;#FFFF00 #00FFFF 确认死亡
            If !ErrorLevel
            {
                Char_Dead := True
                ToolTip, 玩家死亡, , , 19
                HyperSleep(500)
            }
            Else
                Char_Dead := False

            PixelSearch, Boss_x, Boss_y, Xj + Wj // 2 - Round(Wj // 16), Yj + Hj // 2, Xj + Wj // 2 + Round(Wj // 16), Yj + Round(Hj / 3 * 2), 0x18FFFF, 0, Fast ;#FFFF18 #18FFFF 确认Boss
            If !ErrorLevel
                Boss_Come := True
            
            If GetKeyState("LAlt") ;偶发按键影响
                Send, {Blind}{LAlt Up}

            If !Mod(A_Sec, 10) && !Char_Dead ;增强佣兵,因死亡时界面消失而分开两个颜色识别
            {
                press_key("~", 30, 30)
                PixelSearch, 佣兵管理x, 佣兵管理y, Xj + Wj // 2 - Round(Wj // 32), Yj + Round(Hj * 0.2), Xj + Wj // 2 + Round(Wj // 32), Yj + Round(Hj * 0.25), 0xFFF9D8, 0, Fast ;#D8F9FF #FFF9D8 佣兵管理
                If !ErrorLevel
                {
                    If Mod(A_Min, 2)
                        press_key("1", 30, 30)
                    Else
                        press_key("3", 30, 30)
                    press_key("Space", 30, 30)
                }
                PixelSearch, 佣兵管理x, 佣兵管理y, Xj + Wj // 2 - Round(Wj // 32), Yj + Round(Hj * 0.2), Xj + Wj // 2 + Round(Wj // 32), Yj + Round(Hj * 0.25), 0xFFF9D8, 0, Fast ;#D8F9FF #FFF9D8 佣兵管理
                If !ErrorLevel
                    press_key("~", 30, 30)
            }

            If !Char_Dead && !Boss_Come
            {
                If GetKeyState("LButton")
                    Send, {Blind}{LButton Up}
                Random, RanTurn, -3, 3
                mouseXY(RanTurn * 50, 0)
                Loop, 15
                {
                    Random, RanClick, 8, 12
                    press_key("RButton", RanClick, 60 - RanClick)
                    ToolTip, 爆裂轰炸, , , 19
                }
            }
            Else If !Char_Dead && Boss_Come
            {
                Send, {Blind}{LButton Up}
                Send, {Blind}{LButton Down}
                LRMoveX := 0, LRMoveY := 0
                PixelSearch, Boss_x1, Boss_y1, Xj, Yj, Xj + Wj, Yj + Hj, 0x18FFFF, 0, Fast ;锁定Boss #FFFF18 #18FFFF
                If !ErrorLevel
                {
                    LRMoveX := ((Xj + Wj // 2) - Boss_x) ** 1/3
                    LRMoveY := ((Yj + Round(Hj * 0.4)) - Boss_y) ** 1/3 ;枪口上抬
                }
                Else If !Boss_x1 || !Boss_y1 ;未确认boss位置时转身寻找
                    mouseXY(600, 0)

                mouseXY(LRMoveX, LRMoveY)

                Loop, 9
                {
                    If !GetKeyState("LButton")
                        Send, {Blind}{LButton Down}
                    HyperSleep(100)
                }
                ToolTip, 立地成佛, , , 19
            }

            ;确认所用时间并显示
            Time_Minute := (A_Min - Game_Start_Min) >= 0 ? (A_Min - Game_Start_Min) : (A_Min + 60 - Game_Start_Min)
            Time_Sec := (A_Sec - Game_Start_Sec) >= 0 ? (A_Sec - Game_Start_Sec) : (A_Sec + 60 - Game_Start_Sec)
            If (A_Sec - Game_Start_Sec) < 0
            {
                Time_Minute -= 1
            }
            Time_Minute := SubStr("00" . Time_Minute, -1) ;格式
            Time_Sec := SubStr("00" . Time_Sec, -1) ;格式
            ToolTip, 目前用时约: %Time_Minute%分%Time_Sec%秒, Xj, Yj, 18

            PixelSearch, 升级x, 升级y, Xj + Wj // 2 - Round(Wj / 20), Yj + Round(Hj * 0.54), Xj + Wj // 2 + Round(Wj / 20), Yj + Round(Hj * 0.62), 0x00D4FF, 0, Fast ;#FFD400 #00D4FF 挑战升级
            If !ErrorLevel
            {
                Loop
                {
                    ClickWait(0.44, 0.765)
                    PixelSearch, 升级x, 升级y, Xj + Wj // 2 - Round(Wj / 20), Yj + Round(Hj * 0.54), Xj + Wj // 2 + Round(Wj / 20), Yj + Round(Hj * 0.62), 0x00D4FF, 0, Fast ;#FFD400 #00D4FF 挑战升级
                } Until, GetKeyState("vk87") || JumpLoop() || ErrorLevel
            }

            PixelSearch, 确认成绩x, 确认成绩y, Xj + Round(Wj * 0.7), Yj + Round(Hj * 0.85), Xj + Round(Wj * 0.85), Yj + Round(Hj * 0.95), 0x4E332E, 0, Fast ;#2E334E #4E332E 确认按钮

            PixelSearch, 确认成绩a, 确认成绩b, Xj + Round(Wj * 0.7), Yj + Round(Hj * 0.85), Xj + Round(Wj * 0.85), Yj + Round(Hj * 0.95), 0xFFFFFF, 0, Fast ;#FFFFFF 确认字样
        } Until, (确认成绩x > 0 && 确认成绩y > 0 && 确认成绩a > 0 && 确认成绩b > 0) || JumpLoop() || GetKeyState("vk87") || Time_Minute > 19 ;游戏内部总倒计时24分50秒,因为cf无尽内置倒计时精度太差而减少实际时间
        ToolTip, 本局完毕, , , 19
        ToolTip, , , , 18
        Send, {Blind}{LButton Up}
        
        If Time_Minute > 19 && !(确认成绩x > 0 && 确认成绩y > 0 && 确认成绩a > 0 && 确认成绩b > 0) && !JumpLoop() && !GetKeyState("vk87") ;超时无法通关则降低等级
        {
            press_key("Esc", 100, 100)
            press_key("Enter", 100, 100)
            press_key("Enter", 100, 100)
            Sel_Level -= 1
            If Sel_Level < 1
                Sel_Level := 1
            Show_Sel_Level := SubStr("00" . Sel_Level, -1)
            UpdateText("challen_mode", "ModeChallen", "开始无尽挂机" . Show_Sel_Level, XGui10, YGui10)
        }
    }
}
;==================================================================================
;初始化挑战环境
无尽准备()
{
    global 准备, Sel_Level
    地图选择x := 0, 地图选择y := 0
    If GetKeyState("vk87")
    {
        ToolTip, 选择模式, , , 19
        Loop ;确认是否进入模式/地图选择界面
        {
            ClickWait(0.2, 0.03) ;进行游戏
            ClickWait(0.09, 0.117) ;新版大厅
            ClickWait(0.8125, 0.805) ;选择模式
            ClickWait(0.4125, 0.141) ;挑战模式
            ClickWait(0.1, 0.25) ;无尽挑战
            PixelSearch, 地图选择x, 地图选择y, Xj + Wj // 2 - Round(Wj / 16), Yj, Xj + Wj // 2 + Round(Wj / 16), Yj + Round(Hj / 9), 0x4CCDFF, 0, Fast ;#FFCD4C #4CCDFF
        } Until, (地图选择x > 0 && 地图选择y > 0) || JumpLoop()
        
        Loop
        {
            ClickWait(0.844, 0.95) ;点击确认
        } Until, GetKeyState("vk87") || JumpLoop()

        准备 := True
        ToolTip, 准备完毕, , , 19
    }
}
;==================================================================================
;更新等级
等级调整()
{
    global Sel_Level, 准备
    If GetKeyState("vk87") && 准备
    {
        ToolTip, 选择等级, , , 19
        ClickWait(0.8, 0.85) ;打开级别选择
        ClickWait(0.8, 0.62 + 35 / 900 * (Sel_Level - 6)) ;默认六级
    }
}
;==================================================================================
;确认分数返回主界面
无尽收尾()
{
    ToolTip, 点击确认称号, , , 19
    称号升级 := True
    Loop
    {
        ClickWait(0.589, 0.913) ;确认称号
        PixelSearch, 称号升级X, 称号升级Y, Xj + Wj // 2 - Round(Wj / 8), Yj + Hj // 2 - Round(Hj / 20), Xj + Wj // 2 + Round(Wj / 8), Yj + Hj // 2 + Round(Hj / 20), 0xFF972F, 0, Fast ;#2F97FF #FF972F
        If ErrorLevel
            称号升级 := False
    } Until, JumpLoop() || !称号升级

    ToolTip, 点击确认军衔, , , 19
    军衔提升 := True
    Loop
    {
        ClickWait(0.51, 0.63) ;确认军衔
        PixelSearch, 军衔提升X, 军衔提升Y, Xj + Round(Wj / 2.1), Yj + Round(Hj / 2.7), Xj + Round(Wj / 1.5), Yj + Round(Hj / 2.4), 0x91FFFF, 0, Fast ;#FFFF91 #91FFFF
        If ErrorLevel
            军衔提升 := False
    } Until, JumpLoop() || !军衔提升

    ToolTip, 点击确认成绩, , , 19
    Loop
    {
        ClickWait(0.775, 0.9) ;点击确认键
    } Until, GetKeyState("vk87") || JumpLoop()
    ToolTip, , , , 19
}
;==================================================================================
;退出循环
JumpLoop()
{
    If !WinExist("ahk_class CrossFire") || GetKeyState("Esc", "P") || !挂机
        Return True
    Return False
}
;==================================================================================
;鼠标点击指定位置并等待
ClickWait(a, b, SleepWait := 500)
{
    CheckPosition(Xj, Yj, Wj, Hj, "CrossFire")
    MouseClick, Left, Xj + Round(Wj * a), Yj + Round(Hj * b)
    HyperSleep(SleepWait)
}
;==================================================================================