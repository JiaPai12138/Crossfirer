;CrossHirer_Founctions
;==================================================================================
;预设参数
Preset()
{
    #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
    #Warn  ; Enable warnings to assist with detecting common errors.
    #MenuMaskKey, vkFF  ; vkFF is no mapping
    #MaxHotkeysPerInterval, 99000000
    #HotkeyInterval, 99000000
    #SingleInstance, Force
    #IfWinActive, ahk_class CrossFire  ; Chrome_WidgetWin_1 CrossFire
    #KeyHistory, 0
    ListLines, Off
    SendMode, Input  ; Recommended for new scripts due to its superior speed and reliability.
    SetWorkingDir, %A_ScriptDir%  ; Ensures a consistent starting directory.
    Process, Priority, , H  ;进程高优先级
    SetBatchLines, -1  ;全速运行,且因为全速运行,部分代码不得不调整
    SetKeyDelay, -1, -1
    SetMouseDelay, -1
    SetDefaultMouseSpeed, 0
    SetWinDelay, -1
    SetControlDelay, -1
}
;==================================================================================
;检查脚本执行权限,只有以管理员权限或以UI Access运行才能正常工作
CheckPermission()
{
    If A_OSVersion in WIN_NT4, WIN_95, WIN_98, WIN_ME, WIN_2000, WIN_2003, WIN_XP, WIN_VISTA ;检测操作系统
    {
        MsgBox, 262160, 错误/Error, 此辅助需要Win 7及以上操作系统!!!`nThis program requires Windows 7 or later!!!
        ExitApp
    }

    SysGet, Mouse_Buttons, 43 ;检测鼠标按键数量
    If Mouse_Buttons < 5
    {
        MsgBox, 262144, 鼠标按键数量不足/Not enough buttons on mouse, 请考虑更换鼠标,不然无法使用本连点辅助/Please consider getting a new mouse, or you will not able to use this auto clicker
    }

    If Not A_IsAdmin ;必须管理员运行,因为无法使用UIA
    {
        Try
        {
            Run, *RunAs "%A_ScriptFullPath%" ;管理员权限运行
        }
        Catch
        {
            MsgBox, 262160, 错误/Error, 未正确运行!辅助将退出!!`nUnable to start correctly!The program will exit!!
            ExitApp
        }
    }
    Else
    {
        Loop
        {
            HyperSleep(1000)
        } Until WinExist("ahk_class CrossFire")
        HyperSleep(5000) ;等待客户端完整出现
    }
}
;==================================================================================
;检查游戏界面真正位置,不包括标题栏和边缘等等
CheckPosition(ByRef Xcp, ByRef Ycp, ByRef Wcp, ByRef Hcp, class_name)
{
    WinGet, CFID, ID, ahk_class %class_name%

    VarSetCapacity(rect, 16)
    DllCall("GetClientRect", "ptr", CFID, "ptr", &rect) ;内在宽高
    Wcp := NumGet(rect, 8, "int")
    Hcp := NumGet(rect, 12, "int")

    VarSetCapacity(WINDOWINFO, 60, 0)
    DllCall("GetWindowInfo", "ptr", CFID, "ptr", &WINDOWINFO) ;内在XY
    Xcp := NumGet(WINDOWINFO, 20, "Int")
    Ycp := NumGet(WINDOWINFO, 24, "Int")

    If InStr(class_name, "CrossFire")
    {
        VarSetCapacity(Screen_Info, 156)
        DllCall("EnumDisplaySettingsA", Ptr, 0, UInt, -1, UInt, &Screen_Info) ;真实分辨率
        Mon_Width := NumGet(Screen_Info, 108, "int")
        Mon_Hight := NumGet(Screen_Info, 112, "int")
        If (Wcp >= Mon_Width) || (Hcp >= Mon_Hight) ;全屏检测,未知是否适应UHD不放大
            CoordMode, Pixel, Client
        Else
            CoordMode, Pixel, Screen
    }
}
;==================================================================================
;检查进程是否存在
ProcessExist(Process_Name)
{
    Process, Exist, %Process_Name%
    Return ErrorLevel
}
;==================================================================================
;检测是否不再游戏中,目标为界面左上角火焰状字样黄色部分以及附近的黑色阴影
Not_In_Game()
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x72FFFF, 0, Fast ;show color in editor: #FFFF72 #72FFFF
    If !ErrorLevel
    {
        PixElsearch, OutputVarX, OutputVarY, X1, Y1, X1 + Round(W1 / 4), Y1 + Round(H1 / 9), 0x000000, 0, Fast ;show color in editor: #000000
        Return !ErrorLevel
    }
    Else
        Return False
}
;==================================================================================
;检测是否退出模式,由按键触发
ExitMode()
{
    Return (Not_In_Game() || GetKeyState("1", "P") || GetKeyState("Tab", "P") || GetKeyState("2", "P") || GetKeyState("3", "P") || GetKeyState("4", "P") || GetKeyState("J", "P") || GetKeyState("L", "P") || GetKeyState("`", "P") || GetKeyState("~", "P") || GetKeyState("RAlt", "P")) 
}
;==================================================================================
;检测点位颜色状态(颜色是否在颜色库中)
GetColorStatus(X, Y, CX1, CX2, color_lib)
{
    PixelGetColor, color_got, (X + CX1), (Y + CX2)
    Return InStr(color_lib, color_got)
}
;==================================================================================
;控制鼠标移动,上下左右
mouseXY(x1,y1)
{
    DllCall("mouse_event", uint, 1, int, x1, int, y1, uint, 0, int, 0)
}
;==================================================================================
;按键脚本,鉴于Input模式下单纯的send太快而开发
press_key(key_name, press_time, sleep_time)
{
    Send, {Blind}{%key_name% DownTemp}
    HyperSleep(press_time)
    Send, {Blind}{%key_name% Up}
    HyperSleep(sleep_time)
}
;==================================================================================
;设置图形界面位置
SetGuiPosition(ByRef XGui, ByRef YGui, GuiPosition, OffsetX, OffsetY)
{
    CheckPosition(X1, Y1, W1, H1, "CrossFire")
    If InStr("H", GuiPosition) ;顶部一栏横向
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + OffsetY
    }
    Else If InStr("V", GuiPosition) ;左侧一栏纵向
    {
        XGui := X1 + OffsetX
        YGui := Y1 + H1 // 2 + OffsetY
    }
    Else If InStr("M", GuiPosition) ;居中显示
    {
        XGui := X1 + W1 // 2 + OffsetX
        YGui := Y1 + H1 // 2 + OffsetY
    }
    Else ;从左上角为基准显示
    {
        XGui := X1 + OffsetX
        YGui := Y1 + OffsetY
    }
}
;==================================================================================
;学习自AHK自带的Windows Spy脚本,更新文字状态而减少引起闪烁
UpdateText(Gui_Number, ControlID, NewText, X, Y)
{
    static OldText := {}
    If (OldText[ControlID] != NewText)
    {
        GuiControl, %Gui_Number%: Text, %ControlID%, %NewText%
        OldText[ControlID] := NewText
        Gui, %Gui_Number%: Show, x%X% y%Y% NA
    }
}
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度时钟
SystemTime()
{
    freq := 0, tick := 0
    If (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", tick)
    Return tick / freq * 1000
} 
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度睡眠
HyperSleep(value)
{
    t_accuracy := 0.991 ;本机精度测试结果,通过JacobHu0723的CPS测试项目得出
    value *= t_accuracy
    s_begin_time := SystemTime()
    freq := 0, t_current := 0
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    s_end_time := (s_begin_time + value) * freq / 1000 
    While, (t_current < s_end_time)
    {
        If (s_end_time - t_current) > 20000 ;大于二毫秒时不暴力轮询,以减少CPU占用
        {
            DllCall("Winmm.dll\timeBeginPeriod", UInt, 1)
            DllCall("Sleep", "UInt", 1)
            DllCall("Winmm.dll\timeEndPeriod", UInt, 1)
            ;以上三行代码为相对ahk自带sleep函数稍高精度的睡眠
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
        }
        Else ;小于三毫秒时开始暴力轮询,为更高精度睡眠
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
    }
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,接受信息
ReceiveMessage(Message) 
{
    If Message = 125638
        ExitApp ;退出当前脚本,未来可加其他动作
}
;==================================================================================
;学习自AHK论坛中的多脚本间通过端口简单通信函数,发送信息
PostMessage(Receiver, Message) ;接受方为GUI标题
{
    SetTitleMatchMode, 3
    DetectHiddenWindows, On
    PostMessage, 0x1001, %Message%, , , %Receiver% ahk_class AutoHotkeyGUI
}
;==================================================================================
;释放所有按键,来自于https://www.autohotkey.com/boards/viewtopic.php?t=60762
Release_All_Keys()
{
    Loop, 0xFF
    {
        Key := Format("VK{:02X}", A_Index)
        If GetKeyState(Key)
            Send, {Blind}{%Key% Up}
    }
}
;==================================================================================
;计算一组数的中位数,必须以逗号隔开
Median(values)
{
    Sort, values, N D, ;以逗号为分界符
    VarArray := StrSplit(values, ",")
    Mid := Ceil(VarArray.Length() / 2)
    If Mod(VarArray.Length(), 2) ;奇数
        VarMedian := VarArray[Mid]
    Else ;偶数
        VarMedian := (VarArray[Mid] + VarArray[Mid + 1]) / 2
    Return VarMedian
}
;==================================================================================
;启用规则蓝
;##################################################################################
;# This #Include file was generated by Image2Include.ahk, you must not change it! #
;##################################################################################
Create_Limit_net_1_bmp(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 6088 << !!A_IsUnicode)
    B64 := "Qk3WEQAAAAAAADYAAAAoAAAAPgAAABgAAAABABgAAAAAAKARAAB0EgAAdBIAAAAAAAAAAAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////7uD6+s+V////9v//56iW/+KU////////////////////////57W7/+KU////7uX/7a9R///h////////////9///66+j//7A////573P5ZsD7KkX//vN////8P//7Kht///Z////////5bW77KgD///Z////////58Ha5ZsE5ZsD8LQD///+9v//5aiW/89q////////////////6tD//89r////5bW75ZsD5ZsD9sE5////////AAD////u6P/pnk7/8rD2///lqJbmohfmpCjmpCjmpCjmpCjmpCjmpCjnnh3/4pT////2///mqJb903b////////////2///qqJb//rn////////2///nqJb/4pT////////nwdr/z2v////////////q0P/nmwX/4pT////ntbv/4pT2///qqJb//rn////2///lqJb2wTn////////w///wtG3///7////////////w///sqG3//9n///8AAP///////+e+0/S+Lfb//ueolv/ilP///////////////////////+e1u//ilP///////+nM8PC0EP//+f////////b//+qolv/+uf////////b//+eolv/ilP////////D//+qbbf/+uf////////////D//+qbbf/+uee1u//ilP///+e1u//ilP////////b//+Wolv/Pavb//+qolv/+uf////////////////D//+yobf//2f///wAA////////7ej/7KVI9v/S56iW/+KU////////////////////////57W7/+KU////////7/P/66Bb//7F////////9v//6qiW//65////////9v//56iW/+KU////////////58Ha/89r////7OL/9sFs////7OL/8LQ757W6/+KU////////////////////////7OL/8LQ757W6/+KU////////6tD/9sE6////8P//7Kht///Z////AAD////////z///opIf266Lmr6PmpCjmpCjmpCjmpCjmpCjmpCjmpCjopCj/5KH////////1///pp5L/8q3////////2///qqJb//rn////////2///nqJb/4pT////////////s4v/wtDvw//7qm23//rn////2///qqJbntGv/4pTnwdr/z2v////////nwdr/z2v2///qqJb//rn2///qqJb//rnq0P/2wTr////w///sqG3//9n///8AAP///////////+a1u//Vev////////////////////////////////////////////////n//+WtpOWbA+WbA+WbA+WbA+WbA+WbA+WbA+WbA+WbA+ebA//ilP////////////D//+yobefBuf/Pa+rQ//bBOv///+e1u//ilP///+fB2v/Pa////////+fB2v/Pa////+e1u//ilPb//+qolv/+uerQ//bBOv////D//+yobf//2f///wAA////////////573P5qEP5qQo5qQo5qQo5qQo5qQo5qQo5qQo5qQo66MP///O////////////57W7/+KU////////9v//6qiW//65////////9v//56iW/+KU////////////9v//6qiW//65////6tD/9sE6////58Ha/89r////58Ha/89r////////58Ha/89r////57W7/+KU9v//6qiW//656tD/9sE6////8P//7Kht///Z////AAD////////////nwdr/z2v////////////////////////////w///sqG3//9n////////////ntbv/2oX////////2///qqJb//rn////////2///nqJb/4pT////w///lm23lmwPlmwPlmwPlmwPqtGr2wTr////nwdr/z2v////nwdr/z2v////////nwdr/z2v////ntbv/4pT2///qqJb//rnq0P/2wTr////w///sqG3//9n///8AAP///////////+fB2v/Pa/////////////////////////////D//+yobf//2f///////////+W1u+WbA+WbA+WbA+WbA+WbA+WbA+WbA+WbA+WbA+ebA//ilP///////////////+e1u//ilP///+rQ//bBOv///+fB2v/Pa////+fB2v/Pa////////+fB2v/Pa////+e1u//ilPb//+qolv/+uerQ//bBOv////D//+yobf//2f///wAA////////////58Ha5qEQ5qQo5qQo5qQo5qQo5qQo5qQo5qQo5qQo7awo///V////////////5bW7/89q////////9v//6qiW//65////////9v//56iW/+KU////////////////57W7/+KU////6tD/9sE6////58Ha/89r////58Ha/89r////////58Ha/89r////57W7/+KU9v//6qiW//656tD/9sE6////8P//7Kht///Z////AAD////////////nwdr/z2v////////////////////////////////////////////////////ltbv/z2r////////2///qqJb//rn////////2///nqJb/4pT////////ltbvlmwPlmwPlmwPqmwPq0Ln2wTr////nwdr/z2v////nwdr/z2v////////nwdr/z2v////ntbv/4pT2///qqJb//rnq0P/2wTr////w///sqG3//9n///8AAP///////////+fB2uahEOakKOakKOmqKOq2c+y6c+/NqfbZvPvt5f//+v///////////////+W1u//Pav////////b//+qolv/+uf////////b//+eolv/ilP///////////////+e1u//ilP///+rQ//bBOv///////////////+fB2v/Pa////////+fB2v/Pa/////////////b//+qolv/+uerQ//bBOv////D//+yobf//2f///wAA////////////+/T6///2/////f//+Ort9url79HN7Mi06bZ/5qZO7q4k///Z////////////5bW75ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD55sD/+KU////////////////57W7/+KU////6tD/5ZsF5ZsD5ZsD5ZsD5ZsD5ZsD/89q////////58Ha5ZsE5ZsD5ZsD5ZsD5ZsD6psD//65////////////8P//7Kht///Z////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA"
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
;启用规则灰
;##################################################################################
;# This #Include file was generated by Image2Include.ahk, you must not change it! #
;##################################################################################
Create_Limit_net_2_bmp(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 6088 << !!A_IsUnicode)
    B64 := "Qk3WEQAAAAAAADYAAAAoAAAAPgAAABgAAAABABgAAAAAAKARAAB0EgAAdBIAAAAAAAAAAAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////yeX889TD////6P//oKDD/+fC////////////////////////oLLV/+fC////yer/yaqo///s////////////6v//uarJ///Y////mr3gkI6Ov6GU//zf////1f//wqCy///n////////j7LVwqCO///n////////oMPojo6Ojo6O1LGO////6P//jqDD/9Sx////////////////stX//9Sy////j7LVjo6Ojo6O58Kg////////AAD////J7f+tkqf/9c/o//+QoMOamJSampqampqampqampqampqampqgkpb/58L////o//+UoMP82bb////////////o//+xoMP//9T////////o//+goMP/58L///////+gw+j/1LH///////////+y1f+gjo//58L///+gstX/58Lo//+xoMP//9T////o//+OoMPnwqD////////V///UsrL////////////////V///CoLL//+f///8AAP///////5y/4+K+m+j//6Cgw//nwv///////////////////////6Cy1f/nwv///////67Q9tSxkv///P///////+j//7Ggw///1P///////+j//6Cgw//nwv///////9X//7GPsv//1P///////////9X//7GPsv//1KCy1f/nwv///6Cy1f/nwv///////+j//46gw//Usej//7Ggw///1P///////////////9X//8Kgsv//5////wAA////////x+3/vpyl6P/ioKDD/+fC////////////////////////oLLV/+fC////////z/b/t5Ws///a////////6P//saDD///U////////6P//oKDD/+fC////////////oMPo/9Sx////w+j/58Ky////w+j/1LGgoLLU/+fC////////////////////////w+j/1LGgoLLU/+fC////////stX/58Kg////1f//wqCy///n////AAD////////g//+mmr3q78maqsmampqampqampqampqampqampqampqpmpr/6cj////////l//+rn8H/9c7////////o//+xoMP//9T////////o//+goMP/58L////////////D6P/UsaDV//+xj7L//9T////o//+xoMOgsrL/58Kgw+j/1LH///////+gw+j/1LHo//+xoMP//9To//+xoMP//9Sy1f/nwqD////V///CoLL//+f///8AAP///////////5Wy1f/at/////////////////////////////////////////////////D//46nyY6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6OjqCOjv/nwv///////////9X//8KgsqDD1P/UsbLV/+fCoP///6Cy1f/nwv///6DD6P/Usf///////6DD6P/Usf///6Cy1f/nwuj//7Ggw///1LLV/+fCoP///9X//8Kgsv//5////wAA////////////mr3gmpaSmpqampqampqampqampqampqampqalpqavJqS///g////////////oLLV/+fC////////6P//saDD///U////////6P//oKDD/+fC////////////6P//saDD///U////stX/58Kg////oMPo/9Sx////oMPo/9Sx////////oMPo/9Sx////oLLV/+fC6P//saDD///UstX/58Kg////1f//wqCy///n////AAD///////////+gw+j/1LH////////////////////////////V///CoLL//+f///////////+astX/4Lz////////o//+xoMP//9T////////o//+goMP/58L////V//+Oj7KOjo6Ojo6Ojo6Ojo6ysrHnwqD///+gw+j/1LH///+gw+j/1LH///////+gw+j/1LH///+gstX/58Lo//+xoMP//9Sy1f/nwqD////V///CoLL//+f///8AAP///////////6DD6P/Usf///////////////////////////9X//8Kgsv//5////////////4+y1Y6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6OjqCOjv/nwv///////////////6Cy1f/nwv///7LV/+fCoP///6DD6P/Usf///6DD6P/Usf///////6DD6P/Usf///6Cy1f/nwuj//7Ggw///1LLV/+fCoP///9X//8Kgsv//5////wAA////////////oMPompaSmpqampqampqampqampqampqampqampqaxKWa///k////////////j7LV/9Sx////////6P//saDD///U////////6P//oKDD/+fC////////////////oLLV/+fC////stX/58Kg////oMPo/9Sx////oMPo/9Sx////////oMPo/9Sx////oLLV/+fC6P//saDD///UstX/58Kg////1f//wqCy///n////AAD///////////+gw+j/1LH///////////////////////////////////////////////////+PstX/1LH////////o//+xoMP//9T////////o//+goMP/58L///////+PstWOjo6Ojo6Ojo6xjo6y1NTnwqD///+gw+j/1LH///+gw+j/1LH///////+gw+j/1LH///+gstX/58Lo//+xoMP//9Sy1f/nwqD////V///CoLL//+f///8AAP///////////6DD6JqWkpqampqamqyjmrS0tMO5tNHRzOnf1vfx7////P///////////////4+y1f/Usf///////+j//7Ggw///1P///////+j//6Cgw//nwv///////////////6Cy1f/nwv///7LV/+fCoP///////////////6DD6P/Usf///////6DD6P/Usf///////////+j//7Ggw///1LLV/+fCoP///9X//8Kgsv//5////wAA////////////9/f8///5////+v//7+/06e/v0dbfw8zRsLS5lJ2ny6iY///n////////////j7LVjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6OoI6O/+fC////////////////oLLV/+fC////stX/jo6Pjo6Ojo6Ojo6Ojo6Ojo6O/9Sx////////oMPojo6Ojo6Ojo6Ojo6Ojo6OsY6O///U////////////1f//wqCy///n////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////8AAP///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wAA"
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
;禁用规则蓝
; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_Restore_net_1_bmp(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 6216 << !!A_IsUnicode)
    B64 := "Qk02EgAAAAAAADYAAAAoAAAAPwAAABgAAAABABgAAAAAAAASAAB0EgAAdBIAAAAAAAAAAAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////+Pv/7sW//u3I////7eP95ZxB554G+tJ5////////////9vf/78S3//fW+v//6LrD+9WB////////////////69Tu98Zr////7+v/5Z9e554G+Mxq///9////6MLd+tBt////////7eT/5ps++tBt////////8fD/5aJv5ZsD55sD/+OX////6tHs7agh///b////////////9v//7bSZ///b7eT/5Zs+5ZsD6qID/++7////////AAAA/////////v//7NXp6KJH+teL///9////6s/q8bY5///t////8Or75qZz77g+/vPX////6tHs7awq//3d////////////6tHs9sJU////////////6tHs8LU6///r////8fD/7a5v///b////////9v//5amZ8LUg///r7eT/8LVV///r6tHs9sJU////////6tHs6qIh/++7////////6sLd/+OX////////////////6MLd+tBt////////AAAA////////////////8O396KZx+dSH///66tHs8LU6///r7+P16KZn+teL///9////////9Pn/6KiO/uKX////////////6tHs9sJU////////////6tHs8LU6///r////////58Ld9sI8////////////////58Ld9sI87eT/8LVV///r7eT/8LVV///r////////6tHs7agh///b6tHs9sJU////////////////////6MLd+tBt////////AAAA////////////////////8eP1++DB///96tHs8LU6///r8+r7/OPH/////////////////f//577S98dO////////////6tHs9sJU////////////6tHs8LU6///r////////8fD/7a5v///b+v//67u9/++7+v//6La97dCX8LVV///r////////////////////+v//6La97dCX8LVV///r////9v//6q+Z/++7////6MLd+tBt////////AAAA////////7eT/5Zs+5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD55sD/+OX////////6s/q9L1I///3////////6tHs9sJU////////////6tHs8LU6///r////////+v//6La9/+OX58Ld9sI8////////6tHs6rRU8LVV8fDr7a5v///b////8fD/7a5v///b6tHs9sJU////6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////////////////////////////////////////////////////////////////////69fy5Zss5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD8LUg///r////////////6MLd7sht7a5v9v/b6q+Z/++77eT/8LVV///r8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////////////58Ld5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD8LUg///r////////////7eT/8LVV///r////////6tHs9sJU////////////6tHs8LU6///r////////////6tHs9sJU////9v//6q+Z/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA/////P//6sXU9syB///16sfg+tOA////7tbs+tmm///96sfg+tOA/v//8OHx9cye///1////7eT/77BN///l////////6tHs9sJU////////////6tHs8LU6///r////58Ld5ZsD5ZsD5ZsD5ZsD6qgD6q9r/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////+fv/6cHJ8r5X6MHM9c9t677A+OGr6b/F9cdo6cLV+NV96cbU7rdV/enK///9////7eT/5Zs+5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD8LUg///r////////////7eT/8LVV///r9v//6q+Z/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA/////////////v//7NLo56RS6rFC+tma///9/v//68/k6Kpf67ZX+teV///9////////////7eT/7ag+///b////////6tHs9sJU////////////6tHs8LU6///r////////////7eT/8LVV///r9v//6q+Z/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////6tHs5Zsh5ZsD5ZsD5ZsD5ZsD7Ls85aJv5ZsD5ZsD5ZsD5ZsD5psD+tBt////////7eT/7ag+///b////////6tHs9sJU////////////6tHs8LU6///r////7eT/5Zs+5ZsD5ZsD5ZsD8MI86q+Z/++78fD/7a5v///b8fD/7a5v///b////8fD/7a5v///b7eT/8LVV///r6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA////////////////////6MLd+tBt////////////////6MLd+tBt////////////////////7eT/7ag+///b////////6tHs9sJU////////////6tHs8LU6///r////////////7eT/8LVV///r9v//6q+Z/++7////////////8fD/7a5v///b////8fD/7a5v///b////////////6tHs9sJU9v//6q+Z/++7////6MLd+tBt////////AAAA/////////////////v//6MHZ+cxh/////////////f//6L7S+cxh////////////////////7eT/5Zs+5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD5ZsD8LUg///r////////////7eT/8LVV///r9v//5amZ5ZsD5ZsD5ZsD5ZsD5ZsD7agD///b////8fD/5aJv5ZsD5ZsD5ZsD5ZsD5ZsD9sI8////////////////6MLd+tBt////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA"
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
;禁用规则灰
; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_Restore_net_2_bmp(NewHandle := False)
{
    Static hBitmap := 0
    If (NewHandle)
        hBitmap := 0
    If (hBitmap)
        Return hBitmap
    VarSetCapacity(B64, 6216 << !!A_IsUnicode)
    B64 := "Qk02EgAAAAAAADYAAAAoAAAAPwAAABgAAAABABgAAAAAAAASAAB0EgAAdBIAAAAAAAAAAAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////7vz/ysfX/PHc////xOj+jo+inZKP8te3////////////6Pn/0MfT//nl9P//qbna9du6////////////////utr06smx////z+//jpStm5KP7dCx///+////qcTp8tWy////////xOn/l46h8tWy////////1vP/jpezjo6OoY6O/+nE////s9bzxKGX///p////////////6f//xLLE///pxOn/jo6hjo6OspeO//LV////////AAAA/////////P//v9vxo5il89y+///+////sdTy17Sg///0////1O78lpy1z7eh/vbm////s9bzyKaa//7q////////////s9bz6cSp////////////s9bz1bKg///y////1vP/xKmz///p////////6f//jqHE1bKX///yxOn/1bKp///ys9bz6cSp////////s9bzspeX//LV////////ssTp/+nE////////////////qcTp8tWy////////AAAA////////////////1fD+o5208dq9///8s9bz1bKg///yzuj5o52w89y+///+////////4/r/oqHA/ufE////////////s9bz6cSp////////////s9bz1bKg///y////////ocTp6cSh////////////////ocTp6cShxOn/1bKp///yxOn/1bKp///y////////s9bzxKGX///ps9bz6cSp////////////////////qcTp8tWy////////AAAA////////////////////2uj59ubY///+s9bz1bKg///y3u78+ejc////////////////+v//oL7i7Mqn////////////s9bz6cSp////////////s9bz1bKg///y////////1vP/xKmz///p8///urvW//LV8///qbPWxNTE1bKp///y////////////////////8///qbPWxNTE1bKp///y////6f//sqnE//LV////qcTp8tWy////////AAAA////////xOn/jo6hjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6OoY6O/+nE////////sdTy4b2l///6////////s9bz6cSp////////////s9bz1bKg///y////////8///qbPW/+nEocTp6cSh////////s9bzsrKp1bKp1vPyxKmz///p////1vP/xKmz///ps9bz6cSp////s9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////////////////////////////////////////////////////////////////////ud33jo6bjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6O1bKX///y////////////qcTpzMyyxKmz6f/psqnE//LVxOn/1bKp///y1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////////////ocTpjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6O1bKX///y////////////xOn/1bKp///y////////s9bz6cSp////////////s9bz1bKg///y////////////s9bz6cSp////6f//sqnE//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////+f//tcfj6NC6///5ssrr9Nm6////ydzz897K///+ssrr9Nm6/v//0ub25dDH///5////xOn/z6ym///v////////s9bz6cSp////////////s9bz1bKg///y////ocTpjo6Ojo6Ojo6Ojo6OsqGOsqmy//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////8fz/rcPd3L+qqcPf5dSyub7Y7ubNrL/b5cqwrMTk7tu4scnkyrWq+e7d///+////xOn/jo6hjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6O1bKX///y////////////xOn/1bKp///y6f//sqnE//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA/////////////v//vtjwm5uotayj897F///+/P//vNTuoqKtt7Oq89zD///+////////////xOn/xKGh///p////////s9bz6cSp////////////s9bz1bKg///y////////////xOn/1bKp///y6f//sqnE//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////s9bzjo6Xjo6Ojo6Ojo6Ojo6Ow7qhjpezjo6Ojo6Ojo6Ojo6Ol46O8tWy////////xOn/xKGh///p////////s9bz6cSp////////////s9bz1bKg///y////xOn/jo6hjo6Ojo6Ojo6O1MShsqnE//LV1vP/xKmz///p1vP/xKmz///p////1vP/xKmz///pxOn/1bKp///ys9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA////////////////////qcTp8tWy////////////////qcTp8tWy////////////////////xOn/xKGh///p////////s9bz6cSp////////////s9bz1bKg///y////////////xOn/1bKp///y6f//sqnE//LV////////////1vP/xKmz///p////1vP/xKmz///p////////////s9bz6cSp6f//sqnE//LV////qcTp8tWy////////AAAA/////////////////v//psLn8NGu////////////+v//pL7i8NGu////////////////////xOn/jo6hjo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6Ojo6O1bKX///y////////////xOn/1bKp///y6f//jqHEjo6Ojo6Ojo6Ojo6Ojo6OxKGO///p////1vP/jpezjo6Ojo6Ojo6Ojo6Ojo6O6cSh////////////////qcTp8tWy////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AAAA"
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