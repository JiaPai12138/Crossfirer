#Include Crossfirer_Functions.ahk
Preset()
;==================================================================================
global CTL_Service_On := False
CheckPermission()
;==================================================================================
Need_Help := False
global Title_Blank := 0
CF_Title :=

If WinExist("ahk_class CrossFire")
{
    Gui, Helper: New, +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize -DPIScale, CTL ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Helper: Margin, 0, 0
    Gui, Helper: Color, 333333 ;#333333
    Gui, Helper: Font, s8 c00FF00, Microsoft YaHei ;#00FF00
    Gui, Helper: add, Text, hwndGui_8, ╔====使用==说明===╗`n     按~     =开关自火==`n     按2   ==手枪模式==`n     按3/4  =暂停模式==`n     按J    ==瞬狙模式==`n     按L   ==连发速点==`n     按Tab键 通用模式==`n================`n     鼠标中间键 右键连点`n     鼠标前进键 炼狱连刺`n     鼠标后退键 左键连点`n     按W和F ==基础鬼跳`n     按W和Alt =空中跳蹲`n     按W放LCtrl bug小道`n     按S和F  ==跳蹲上墙`n     按W和C==前跳跳蹲`n     按S和C ==后跳跳蹲`n     按Z和C ==六级跳箱`n================`n     小键盘123 更换射速`n     小键盘0     关闭压枪`n     小键盘+ 更换压枪度`n================`n     按H  =运行一键限速`n     按-   =重新加载脚本`n     按=      开关E键快反`n     大写锁定 最小化窗口`n     回车键 开关所有按键`n     右Alt   恢复所有按键`n╚====使用==说明===╝
    GuiControlGet, P8, Pos, %Gui_8%
    global P8H ;*= (A_ScreenDPI / 96)
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端

    Gui, Hint: New, +LastFound +AlwaysOnTop -Caption +ToolWindow +MinSize -DPIScale, CTL ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
    Gui, Hint: Margin, 0, 0
    Gui, Hint: Color, 333333 ;#333333
    Gui, Hint: Font, s8 c00FF00, Microsoft YaHei ;#00FF00
    Gui, Hint: add, Text, hwndGui_9, 按`n右`n c`n t`n r`n l`n键`n开`n关`n帮`n助
    GuiControlGet, P9, Pos, %Gui_9%
    global P9H ;*= (A_ScreenDPI / 96)
    WinSet, TransColor, 333333 255 ;#333333
    WinSet, ExStyle, +0x20 +0x8; 鼠标穿透以及最顶端

    SetGuiPosition(XGui9, YGui9, "V", 0, -P8H // 2)
    SetGuiPosition(XGui10, YGui10, "V", 0, -P9H // 2)
    Gui, Hint: Show, x%XGui10% y%YGui10% NA
    Gui, Helper: Show, Hide

    WinGetTitle, CF_Title, ahk_class CrossFire
    WinMinimize, ahk_class ConsoleWindowClass
    SetTimer, UpdateGui, 200
    DPI_Initial := A_ScreenDPI
    CTL_Service_On := True
} 
;==================================================================================
~*-::
    WinClose, ahk_class ConsoleWindowClass
    Try
        Run, .\请低调使用.bat
    Catch
        Run, .\双击我启动助手!!!.exe
ExitApp

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
    If CTL_Service_On
    {
        SetGuiPosition(XGui9, YGui9, "V", 0, -P8H // 2)
        SetGuiPosition(XGui10, YGui10, "V", 0, -P9H // 2)
        ShowHelp(Need_Help, XGui9, YGui9, "Helper", XGui10, YGui10, "Hint", 0)
    }
Return

~*RCtrl::
    If CTL_Service_On
        ShowHelp(Need_Help, XGui9, YGui9, "Helper", XGui10, YGui10, "Hint", 1)
Return

~*CapsLock Up:: ;minimize window and replace origin use
    If CTL_Service_On
    {
        If WinActive("ahk_class CrossFire")
        {
            WinMinimize, ahk_class CrossFire
            HyperSleep(100)
            CoordMode, Mouse, Screen
            MouseMove, A_ScreenWidth // 2, A_ScreenHeight // 2 ;The middle of screen
        }
        Else
            WinActivate, ahk_class CrossFire ;激活该窗口
    }
Return
;==================================================================================
UpdateGui() ;精度0.2s
{
    global DPI_Initial, CF_Title
    If !InStr(A_ScreenDPI, DPI_Initial)
        MsgBox, 262144, 提示/Hint, 请按"-"键重新加载脚本`nPlease restart by pressing "-" key
    If !WinExist("ahk_class CrossFire")
    {
        WinClose, ahk_class ConsoleWindowClass
        Loop ;, 10
        {
            PostMessage("Listening", 125638)
            WinGetTitle, Gui_Title, ahk_class AutoHotkeyGUI
            ;MsgBox, , , %Gui_Title%
            If StrLen(Gui_Title) < 4
                Title_Blank += 1
            HyperSleep(100) ;just for stability
        } Until Title_Blank > 4
        
        If ProcessExist("GameLoader.exe")
        {
            If A_IsCompiled && A_IsAdmin
            {
                Runwait, %comspec% /c taskkill /IM GameLoader.exe /F, ,Hide
                Runwait, %comspec% /c taskkill /IM TQMCenter.exe /F, ,Hide
                Runwait, %comspec% /c taskkill /IM TenioDL.exe /F, ,Hide
                Runwait, %comspec% /c taskkill /IM feedback.exe /F, ,Hide
                Runwait, %comspec% /c taskkill /IM CrossProxy.exe /F, ,Hide
            }
            Else
                Run, *RunAs .\关闭TX残留进程.bat, , Hide
        }
        ExitApp
    }
    Else If !Not_In_Game(CF_Title)
        Send, {Blind}{vk87 Up} ;F24 key
    Else If Not_In_Game(CF_Title)
        Send, {Blind}{vk87 Down} ;F24 key
}
;==================================================================================
;通过按下快捷键显示/隐藏提示
ShowHelp(ByRef Need_Help, XGui1, YGui1, Gui_Number1, XGui2, YGui2, Gui_Number2, Changer)
{
    If Changer = 1
        Need_Help := !Need_Help
    If Need_Help
    {
        Gui, %Gui_Number1%: Show, x%XGui1% y%YGui1% NA
        Gui, %Gui_Number2%: Show, Hide
    }
    Else
    {
        Gui, %Gui_Number1%: Show, Hide
        Gui, %Gui_Number2%: Show, x%XGui2% y%YGui2% NA
    }
}
;==================================================================================