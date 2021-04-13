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
        ClickWait(0.94, 0.823) ;点击开始游戏
        游戏即将开始 := False, 进入游戏x := 0, 进入游戏y := 0, Char_Dead := False
        Load_FFFF1B := Create_ffff1b_png() ;Boss胸口黄灯

        Loop
        {
            ToolTip, 等待进入游戏, , , 19
            HyperSleep(1000)
            PixelSearch, 进入游戏x, 进入游戏y, Xj + Round(Wj / 8), Yj, Xj + Round(Wj / 4), Yj + Round(Hj / 9), 0x836F54, 0, Fast ;#546F83 #836F54
            If !ErrorLevel
                游戏即将开始 := True
        } Until, (!GetKeyState("vk87") && 游戏即将开始) || JumpLoop() ;等待进入游戏
        ToolTip, 进入房间界面, , , 19
        
        Loop
        {
            HyperSleep(1000) ;等待真正进入游戏
        } Until, Challenging() || JumpLoop()

        Game_Start_Min := A_Min, Game_Start_Sec := A_Sec
        
        确认成绩x := 0, 确认成绩y := 0, 确认成绩a := 0, 确认成绩b := 0, 升级x := 0, 升级y := 0
        Boss_x := 0, Boss_y := 0, Boss_x1 := 0, Boss_y1 := 0, Found_Boss := False, 枪口上 := False, 后退 := False
        Loop
        {
            确认死亡x := 0, 确认死亡y := 0, Boss_Come := False
            CheckPosition(Xj, Yj, Wj, Hj, "CrossFire")
            PixelSearch, 确认死亡x, 确认死亡y, Xj + Wj // 2 - Round(Wj * 0.05), Yj + Round(Hj * 0.39), Xj + Wj // 2 + Round(Wj * 0.05), Yj + Round(Hj * 0.425), 0x00FFFF, 0, Fast ;#FFFF00 #00FFFF 确认死亡
            If !ErrorLevel
            {
                Char_Dead := True
                ToolTip, 玩家死亡, , , 19
                枪口上 := False
                HyperSleep(500)
            }
            Else
                Char_Dead := False

            PixelSearch, Boss_x, Boss_y, Xj + Round(Wj * 0.4), Yj + Round(Hj * 0.14), Xj + Round(Wj * 0.44), Yj + Round(Hj * 0.2), 0x2E619A, 0, Fast ;#9A612E #2E619A 确认Boss 
            If !ErrorLevel
                Boss_Come := True

            PixelSearch, Boss_x, Boss_y, Xj + Round(Wj * 0.4), Yj + Round(Hj * 0.14), Xj + Round(Wj * 0.44), Yj + Round(Hj * 0.2), 0x2E619A, 0, Fast ;#C44709 #0947C4 确认黄金Boss 
            If !ErrorLevel
                Boss_Come := True
            
            Send, {Blind}{LAlt Up} ;偶发按键影响

            PixelSearch, 佣兵管理x, 佣兵管理y, Xj + Wj // 2 - Round(Wj // 32), Yj + Round(Hj * 0.2), Xj + Wj // 2 + Round(Wj // 32), Yj + Round(Hj * 0.25), 0xFFF9D8, 0, Fast ;#D8F9FF #FFF9D8 佣兵管理
            If !ErrorLevel
                press_key("~", 30, 30) ;退出佣兵管理界面

            If !Mod(A_Sec, 12) && !Char_Dead ;增强佣兵
            {
                press_key("~", 30, 30)
                If Mod(A_Min, 2)
                    press_key("1", 30, 30)
                Else
                    press_key("3", 30, 30)
                press_key("Space", 30, 30)
                press_key("~", 30, 30)
            }

            If !Char_Dead && !Boss_Come
            {
                If GetKeyState("LButton")
                    Send, {Blind}{LButton Up}

                PixelSearch, Bossa, Bossb, Xj + Round(Wj * 0.442), Yj + Round(Hj * 0.13), Xj + Wj // 2, Yj + Round(Hj * 0.15), 0xFFFFFF, 0, Fast ;#FFFFFF Boss级别怪物
                If !ErrorLevel
                {
                    If !枪口上
                    {
                        mouseXY(0, -20) ;枪口略微朝上
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
                        mouseXY(0, 20) ;枪口略微回调
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
                    ToolTip, 爆裂轰炸, , , 19
                }
            }
            Else If !Char_Dead && Boss_Come
            {
                Send, {Blind}{LButton Up}
                Send, {Blind}{LButton Down}
                press_key("e", 10, 10) ;佣兵觉醒
                LRMoveX := 0, LRMoveY := 0

                ImageSearch, Boss_x1, Boss_y1, Xj + Round(Wj / 6.4), Yj + Hj, Xj + Wj - Round(Wj / 6.4), Yj, *27 HBITMAP:*%Load_FFFF1B% ;FFFF23
                ;PixelSearch, Boss_x1, Boss_y1, Xj + Round(Wj / 6.4), Yj + Hj, Xj + Wj - Round(Wj / 6.4), Yj, 0x18FFFF, 7, Fast ;锁定Boss #FFFF18 #18FFFF
                If !ErrorLevel
                {
                    Found_Boss := True
                    LRMoveX := ((Xj + Wj // 2) - Boss_x1) // 10
                    LRMoveY := ((Yj + Round(Hj * 0.65)) - Boss_y1) // 10 ;枪口上抬
                    ToolTip, 锁定Boss 鼠标移动%LRMoveX%|%LRMoveY%, Xj, , 17
                }
                Else If ErrorLevel
                {
                    ToolTip, 丢失Boss, Xj, , 17
                }
                Else If !Found_Boss ;未确认boss位置时转身寻找
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
        } Until, (确认成绩x > 0 && 确认成绩y > 0 && 确认成绩a > 0 && 确认成绩b > 0) || JumpLoop() || GetKeyState("vk87") || Time_Minute > 18 ;游戏内部总倒计时25分,因为cf无尽内置倒计时精度太差而减少实际时间
        ToolTip, 本局完毕, , , 19
        ToolTip, , , , 18
        ToolTip, , , , 17
        Send, {Blind}{LButton Up}
        
        If Time_Minute > 17 && !(确认成绩x > 0 && 确认成绩y > 0 && 确认成绩a > 0 && 确认成绩b > 0) && !JumpLoop() && !GetKeyState("vk87") ;超时无法通关则降低等级
        {
            global XGui10, YGui10
            Loop
            {
                press_key("Esc", 100, 100)
                PixelSearch, ESCx, ESCy, Xj + Wj // 2 - Round(Wj / 32), Yj + Round(Hj / 3), Xj + Wj // 2 + Round(Wj / 32), Yj + Round(Hj / 2.25), 0xFAFEFF, 0, Fast ;#FFFEFA #FAFEFF Esc目录
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
    If Challenging()
        Return
    Else If GetKeyState("vk87")
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
    If GetKeyState("vk87") && 准备
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
;检测是否在挑战中
Challenging()
{
    PixelSearch, clgx, clgy, Xj + Wj // 2 - Round(Wj / 8), Yj, Xj + Wj // 2 + Round(Wj / 8), Yj + Round(Hj / 18), 0xEBE6CA, 0, Fast ;#CAE6EB #EBE6CA
    If !ErrorLevel
        Return True
    Return False
}
;==================================================================================
; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_ffff1b_png(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
    hBitmap := 0
If (hBitmap)
    Return hBitmap
VarSetCapacity(B64, 1232 << !!A_IsUnicode)
B64 := "iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGCAMAAADXEh96AAADAFBMVEX//xtmAGYAZgBiADEALgBuAHAAZwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAChjSCFqHcAd6EAAAAAAAAAAQDBAAB33oMZ+DAAAAAwAAAAAAAAAAAAAAAYAAB33oQAAAAAAAAAAAAAAAAAAACGTAAAd6EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC0AAB343dHzMAAAA0AAOYAAAAAAAAAAAAAAAAAAAAAAAAAAABkAAAAAAAAAADsIADuCMQAAAEAAAAGHAAQAe4NR1BHzMDsEA0ACMQA5gAAAAD4bAC2ABl33zrgrFkAAHcAAAAAAAAAAAAAAAAAAAAAAAA1Q7H3jJcQd5QAGfmU960At3cAAAAAAAAAAAD3y8Bgd5QAAAAAAAAABQCAAAAAAAAQAIAAAMBwAAAAAAwAAAAAAwA2AAAAOABHzMAAAA3AAAANR8wAAAA8AAAQdAUAGfkAAAAAGAAAAAAAAAAZ+LAAQAAAAAAAAAAZ+QAAAAAAAAAAAAAAAAAAAABAAAAVe2HmAAAADAACAAAAAAAGAQHYJNtErL8AGfmU9H4AAHcCAAAAAAAZ+SgAAAAYAAAAAAAAAIAAAAAAAAAAAAAAAAAAAADYAACyUa3BAAAAAWJLR0SL8m9H4AAAAAlwSFlzAAAOxAAADsQBlSsOGwAAADVJREFUeNoBKgDV/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAqAAHsFU4fAAAAAElFTkSuQmCC"
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