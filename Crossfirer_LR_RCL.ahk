;对压枪时水平方向控制的尝试
;==================================================================================
#Include Crossfirer_Functions.ahk
Preset(0)
;==================================================================================
global LRC_Service_On := False
CheckPermission()
;==================================================================================
LR_Points := ""
A_Gun_Chosen := False
LRColor := []
If (WinExist("ahk_class CrossFire"))
{
    CheckPosition(X8, Y8, W8, H8, "CrossFire")
    OnMessage(0x1001, "ReceiveMessage")
    LRC_Service_On := True
    Return
}
;==================================================================================
~*-::ExitApp
~*Right::Suspend, Toggle ;输入聊天时不受影响

~*$LButton:: ;压枪 正在开发
    If LRC_Service_On
    {
        If (!Not_In_Game() && A_Gun_Chosen)
        {
            Loop, 5 ;取5个点
            {
                PixelGetColor, Color_Var, X8 + W8 // 2, Y8 + Round(H8 / 3.6) + (A_Index - 1) * Round(H8 / 60)
                LRColor.Push(Color_Var)
            }
            SetTimer, LRController, 120
        }
    }
Return

~*Lbutton Up:: ;保障新一轮压枪
    If LRC_Service_On
    {
        LRColor := []
        LR_Points := ""
        SetTimer, LRController, Off
    }
Return

~*NumpadIns::
~*Numpad0::
    A_Gun_Chosen := False
Return

~*NumpadEnd::
~*Numpad1::
~*NumpadDown::
~*Numpad2::
~*NumpadPgDn::
~*Numpad3::
~*NumpadLeft::
~*Numpad4::
~*NumpadClear::
~*Numpad5::
~*NumpadRight::
~*Numpad6::
~*NumpadHome::
~*Numpad7::
~*NumpadUp::
~*Numpad8::
~*NumpadPgUp::
~*Numpad9::
    A_Gun_Chosen := True
Return

LRController()
{
    global LR_Points, LRColor, X8, Y8, W8, H8, 
    If !WinActive("ahk_class CrossFire")
        SetTimer, LRController, Off
    CheckPosition(X8, Y8, W8, H8, "CrossFire")
    Loop, 5 ;从中线开始向左右搜索7个点
    {
        Current_Color := LRColor[A_Index]
        PixelSearch, LRTempPos%A_Index%A, , X8 + W8 // 2 + Round(W8 / 32), Y8, X8 + W8 // 2 - Round(W8 / 32), Y8 + H8 // 2, %Current_Color%, 0, Fast
        PixelSearch, LRTempPos%A_Index%B, , X8 + W8 // 2 - Round(W8 / 32), Y8, X8 + W8 // 2 + Round(W8 / 32), Y8 + H8 // 2, %Current_Color%, 0, Fast
        LRColorPos%A_Index% := Ceil((LRTempPos%A_Index%A + LRTempPos%A_Index%B) / 2)
    }
    Loop, 5 ;处理7个数据
    {
        If LRColorPos%A_Index% ;如果结果不为空
            LR_Points .= LRColorPos%A_Index%
        A_Next := A_Index + 1
        If LRColorPos%A_Next%
            LR_Points .= ","
    }
    
    LRMoveX := (Median(LR_Points) - (X8 + W8 // 2)) ** 1/3
    mouseXY(LRMoveX, 0)
    LR_Points := "" ;重置
}