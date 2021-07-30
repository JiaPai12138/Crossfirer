#Include Crossfirer_Functions.ahk
global CLG_Service_On := False
Preset("尽")
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
    Gui, challen_mode: New, +LastFound +AlwaysOnTop -Caption +ToolWindow +Hwndchm -DPIScale, Listening ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, challen_mode: Margin, 0, 0
    Gui, challen_mode: Color, 333333 ;#333333
    Gui, challen_mode: Font, S10 Q5, Microsoft YaHei
    Gui, challen_mode: Add, Text, hwndGui_10 vModeChallen c00FF00, 无尽挂机准备%Show_Sel_Level% ;#00FF00
    GuiControlGet, P10, Pos, %Gui_10%
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, Transparent, 225, ahk_id %chm%
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端
    SetGuiPosition(XGui10, YGui10, "H", -P10W // 2, Hj // 18 - P10H // 2)
    Gui, challen_mode: Show, x%XGui10% y%YGui10% NA
    OnMessage(0x1001, "ReceiveMessage")
    OnMessage(0x1002, "ReceiveMessage")
    CLG_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp

#If CLG_Service_On ;以下的热键需要相应条件才能激活

~*CapsLock Up:: ;最小最大化窗口
    HyperSleep(100)
    If WinActive("ahk_class CrossFire")
        Gui, challen_mode: Show, x%XGui10% y%YGui10% NA
    Else
        Gui, challen_mode: Show, Hide
Return

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
    SetGuiPosition(XGui10, YGui10, "H", -P10W // 2, Hj // 18 - P10H // 2)
    Gui, challen_mode: Show, x%XGui10% y%YGui10% NA
Return

~*F8::
    PostBack(110005) ;无尽中
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
    PostBack(110006)
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
    进入游戏x := 0, 进入游戏y := 0, Char_Dead := False, 正式游戏 := False
    Load_FFFF14 := Create_ffff14_png() ;Boss胸口黄灯
    Load_FAFA00 := Create_fafa00_png() ;黄金Boss胸口黄灯

    If CF_Now.GetStatus() = 0 ;主界面
    {
        ClickWait(0.94, 0.823) ;点击开始游戏
        ClickWait(0.5, 0.648) ;离开原本退出的比赛
        ClickWait(0.94, 0.823) ;点击开始游戏

        Loop
        {
            ToolTip, 等待进入游戏, , , 19
            HyperSleep(1000) ;等待真正进入游戏
        } Until, CF_Now.GetStatus() = 2 || JumpLoop()
        正式游戏 := True
    }
    Else If CF_Now.GetStatus() = 2
        正式游戏 := True

    If 正式游戏
    {
        Game_Start_Min := A_Min, Game_Start_Sec := A_Sec

        确认成绩x := 0, 确认成绩y := 0, 确认成绩a := 0, 确认成绩b := 0, 升级x := 0, 升级y := 0
        Boss_x := 0, Boss_y := 0, Boss_x1 := 0, Boss_y1 := 0, Found_Boss := False, 枪口上 := False, 后退 := False, Lose_Boss := 0
        Loop
        {
            确认死亡x := 0, 确认死亡y := 0, Boss_Come := 0, IsDead := 0
            CheckPosition(Xj, Yj, Wj, Hj, "CrossFire")
            PixelSearch, 确认死亡x, 确认死亡y, Xj + Wj // 2 - Wj // 20, Yj + Round(Hj * 0.39), Xj + Wj // 2 + Wj // 20, Yj + Round(Hj * 0.425), 0x00FFFF, 0, Fast ;#FFFF00 #00FFFF 确认死亡
            If !ErrorLevel
                IsDead += 1

            PixelSearch, 确认死亡x, 确认死亡y, Xj + Wj // 2 - Wj // 20, Yj + Round(Hj * 0.39), Xj + Wj // 2 + Wj // 20, Yj + Round(Hj * 0.425), 0x00E4E4, 0, Fast ;#E4E400 #00E4E4 确认死亡
            If !ErrorLevel
                IsDead += 1

            If IsDead
            {
                Lose_Boss := 0
                Char_Dead := True
                ToolTip, 玩家死亡, , Yj, 19
                枪口上 := False
                HyperSleep(500)
            }
            Else
                Char_Dead := False

            PixelSearch, Boss_x, Boss_y, Xj + Wj // 2.5, Yj + Round(Hj * 0.14), Xj + Round(Wj * 0.44), Yj + Hj // 5, 0x2E619A, 0, Fast ;#9A612E #2E619A 确认Boss
            If !ErrorLevel
                Boss_Come := 1

            PixelSearch, Boss_x, Boss_y, Xj + Wj // 2.5, Yj + Round(Hj * 0.14), Xj + Round(Wj * 0.44), Yj + Hj // 5, 0x0947C4, 0, Fast ;#C44709 #0947C4 确认黄金Boss
            If !ErrorLevel
                Boss_Come := 2

            Send, {Blind}{LAlt Up} ;偶发按键影响

            PixelSearch, 佣兵管理x, 佣兵管理y, Xj + Wj // 2 - Wj // 32, Yj + Hj // 5, Xj + Wj // 2 + Wj // 32, Yj + Hj // 4, 0xFFF9D8, 0, Fast ;#D8F9FF #FFF9D8 佣兵管理
            If !ErrorLevel
                press_key("~", 30, 30) ;退出佣兵管理界面

            If !Mod(A_Sec, 12) && !Char_Dead && !Boss_Come ;增强佣兵
            {
                press_key("~", 30, 30)
                PixelSearch, 佣兵管理x, 佣兵管理y, Xj + Wj // 2 - Wj // 32, Yj + Hj // 5, Xj + Wj // 2 + Wj // 32, Yj + Hj // 4, 0xFFF9D8, 0, Fast ;#D8F9FF #FFF9D8 佣兵管理
                If !ErrorLevel
                {
                    If Mod(A_Min, 2)
                        press_key("1", 30, 30)
                    Else
                        press_key("3", 30, 30)
                    press_key("Space", 30, 30)
                    press_key("~", 30, 30)
                }
            }

            If !Char_Dead && !Boss_Come
            {
                ToolTip, , , , 17
                If GetKeyState("LButton")
                    Send, {Blind}{LButton Up}

                PixelSearch, Bossa, Bossb, Xj + Round(Wj * 0.442), Yj + Round(Hj * 0.13), Xj + Wj // 2, Yj + Round(Hj * 0.15), 0xFFFFFF, 0, Fast ;#FFFFFF Boss级别怪物
                If !ErrorLevel
                {
                    If !枪口上
                    {
                        mouseXY(0, -50) ;枪口略微朝上
                        枪口上 := True
                    }
                    press_key("e", 10, 10) ;佣兵觉醒
                    Send, {Blind}{s Down}
                    后退 := True
                }
                Else
                {
                    If 枪口上
                    {
                        mouseXY(0, 50) ;枪口略微回调
                        枪口上 := False
                    }
                    If 后退
                        Send, {Blind}{s Up}
                }

                If !枪口上
                {
                    Random, RanTurn, -3, 3
                    mouseXY(RanTurn * 50, 0)
                }

                Loop, 15
                {
                    Random, RanClick, 8, 12
                    press_key("RButton", RanClick, 60 - RanClick)
                    ToolTip, 爆裂轰炸, , Yj, 19
                }
            }
            Else If !Char_Dead && Boss_Come
            {
                If !GetKeyState("LButton")
                    Send, {Blind}{LButton Down}
                press_key("e", 10, 10) ;佣兵觉醒
                LRMoveX := 0, LRMoveY := 0

                If Boss_Come := 1
                    ImageSearch, Boss_x1, Boss_y1, Xj, Yj, Xj + Wj, Yj + Hj, *4 HBITMAP:*%Load_FFFF14% ;#FFFF14
                Else If Boss_Come := 2
                    ImageSearch, Boss_x1, Boss_y1, Xj, Yj, Xj + Wj, Yj + Hj, *4 HBITMAP:*%Load_FAFA00% ;#FAFA00
                If !ErrorLevel
                {
                    Lose_Boss := 0
                    Found_Boss := True
                    LRMoveX := (Boss_x1 - (Xj + Wj // 2)) // 4
                    LRMoveY := (Boss_y1 - (Yj + Hj / 1.5)) // 7 ;枪口上抬
                    ToolTip, 锁定Boss 鼠标移动%LRMoveX%|%LRMoveY%, Xj, , 17
                }
                Else If ErrorLevel && Found_Boss
                {
                    ToolTip, 丢失Boss, Xj, , 17
                    Lose_Boss += 1
                }
                Else If !Found_Boss ;未确认boss位置时转身寻找
                {
                    mouseXY(500, 0)
                    ToolTip, 搜寻Boss, Xj, , 17
                }

                If Lose_Boss > 21
                    Found_Boss := False

                mouseXY(LRMoveX, LRMoveY)

                Loop, 9
                {
                    If !GetKeyState("LButton")
                        Send, {Blind}{LButton Down}
                    HyperSleep(100)
                }
                ToolTip, 立地成佛, , Yj, 19
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

            PixelSearch, 升级x, 升级y, Xj + Wj // 2 - Wj // 20, Yj + Round(Hj * 0.54), Xj + Wj // 2 + Wj // 20, Yj + Round(Hj * 0.62), 0x00D4FF, 0, Fast ;#FFD400 #00D4FF 挑战升级
            If !ErrorLevel
            {
                Loop
                {
                    ClickWait(0.44, 0.765)
                    PixelSearch, 升级x, 升级y, Xj + Wj // 2 - Wj // 20, Yj + Round(Hj * 0.54), Xj + Wj // 2 + Wj // 20, Yj + Round(Hj * 0.62), 0x00D4FF, 0, Fast ;#FFD400 #00D4FF 挑战升级
                } Until, CF_Now.GetStatus() = 0 || JumpLoop() || ErrorLevel
            }

            PixelSearch, 确认成绩x, 确认成绩y, Xj + Round(Wj * 0.7), Yj + Round(Hj * 0.85), Xj + Round(Wj * 0.85), Yj + Round(Hj * 0.95), 0x4E332E, 0, Fast ;#2E334E #4E332E 确认按钮

            PixelSearch, 确认成绩a, 确认成绩b, Xj + Round(Wj * 0.7), Yj + Round(Hj * 0.85), Xj + Round(Wj * 0.85), Yj + Round(Hj * 0.95), 0xFFFFFF, 0, Fast ;#FFFFFF 确认字样
        } Until, (确认成绩x > 0 && 确认成绩y > 0 && 确认成绩a > 0 && 确认成绩b > 0) || JumpLoop() || CF_Now.GetStatus() = 0 || Time_Minute > 18 ;游戏内部总倒计时25分,因为cf无尽内置倒计时精度太差以及死亡次数过多会减少时间而降低实际时间
        ToolTip, 本局完毕, , , 19
        ToolTip, , , , 18
        ToolTip, , , , 17
        Send, {Blind}{LButton Up}

        If Time_Minute > 18 && !(确认成绩x > 0 && 确认成绩y > 0 && 确认成绩a > 0 && 确认成绩b > 0) && !JumpLoop() && CF_Now.GetStatus() != 0 ;超时无法通关则降低等级
        {
            global XGui10, YGui10
            Loop
            {
                press_key("Esc", 100, 100)
                PixelSearch, ESCx, ESCy, Xj + Wj // 2 - Wj // 32, Yj + Hj // 3, Xj + Wj // 2 + Wj // 32, Yj + Hj // 2.25, 0xFAFEFF, 0, Fast ;#FFFEFA #FAFEFF Esc目录
            } Until !ErrorLevel
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
    地图选择x := 0, 地图选择y := 0
    If CF_Now.GetStatus() = 2
    {
        准备 := True
        Return
    }
    Else If CF_Now.GetStatus() = 0
    {
        ToolTip, 选择模式, , , 19
        Loop ;确认是否进入模式/地图选择界面
        {
            ClickWait(0.2, 0.03) ;进行游戏
            ClickWait(0.09, 0.117) ;新版大厅
            ClickWait(0.8125, 0.805) ;选择模式
            ClickWait(0.4125, 0.141) ;挑战模式
            ClickWait(0.1, 0.25) ;无尽挑战
            PixelSearch, 地图选择x, 地图选择y, Xj + Wj // 2 - Wj // 16, Yj, Xj + Wj // 2 + Wj // 16, Yj + Hj // 9, 0x4CCDFF, 0, Fast ;#FFCD4C #4CCDFF
        } Until, (地图选择x > 0 && 地图选择y > 0) || JumpLoop()

        Loop
        {
            ClickWait(0.844, 0.95) ;点击确认
        } Until, CF_Now.GetStatus() = 0 || JumpLoop()

        准备 := True
        ToolTip, 准备完毕, , , 19
    }
}
;==================================================================================
;更新等级
等级调整()
{
    If CF_Now.GetStatus() = 2
        Return
    Else If CF_Now.GetStatus() = 0 && 准备
    {
        ToolTip, 选择等级, , , 19
        ClickWait(0.8, 0.85) ;打开级别选择
        ClickWait(0.8, 0.62 - 35 / 900 * (Sel_Level - 6)) ;默认六级
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
        PixelSearch, 称号升级X, 称号升级Y, Xj + Wj // 2 - Wj // 8, Yj + Hj // 2 - Hj // 20, Xj + Wj // 2 + Wj // 8, Yj + Hj // 2 + Hj // 20, 0xFF972F, 0, Fast ;#2F97FF #FF972F
        If ErrorLevel
            称号升级 := False
    } Until, JumpLoop() || !称号升级

    ToolTip, 点击确认军衔, , , 19
    军衔提升 := True
    Loop
    {
        ClickWait(0.51, 0.63) ;确认军衔
        PixelSearch, 军衔提升X, 军衔提升Y, Xj + Wj // 2.1, Yj + Hj // 2.7, Xj + Wj // 1.5, Yj + Hj // 2.4, 0x91FFFF, 0, Fast ;#FFFF91 #91FFFF
        If ErrorLevel
            军衔提升 := False
    } Until, JumpLoop() || !军衔提升

    ToolTip, 点击确认成绩, , , 19
    Loop
    {
        ClickWait(0.775, 0.9) ;点击确认键
    } Until, CF_Now.GetStatus() = 0 || JumpLoop()
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
;##################################################################################
;# This #Include file was generated by Image2Include.ahk, you must not change it! #
;##################################################################################
Create_ffff14_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
    hBitmap := 0
If (hBitmap)
    Return hBitmap
VarSetCapacity(B64, 1232 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAIAAABvrngfAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAEUlEQVR42mP4/18EDTHQVggAurZKiRLIUFoAAAAASUVORK5CYII="
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
;##################################################################################
;# This #Include file was generated by Image2Include.ahk, you must not change it! #
;##################################################################################
Create_fafa00_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
    hBitmap := 0
If (hBitmap)
    Return hBitmap
VarSetCapacity(B64, 1232 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAIAAABvrngfAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAEUlEQVR42mP49YsBDTHQVggAzEtGUdGPnoQAAAAASUVORK5CYII="
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