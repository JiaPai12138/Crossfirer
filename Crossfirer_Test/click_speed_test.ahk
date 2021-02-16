#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey vkFF  ; vkFF is no mapping
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#SingleInstance, force 
#KeyHistory 0
ListLines Off
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;CoordMode, Pixel, Screen ;Client 
;CoordMode, Mouse, Screen
Process, Priority, , H  ;进程高优先级
SetBatchLines -1  ;全速运行,且因为全速运行,部分代码不得不调整
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1

~*XButton2:: ;半自动速点,适合救世主步枪
    While, !(GetKeyState("E", "P") || GetKeyState("RButton", "P") || GetKeyState("`", "P"))
    {
        ;press_key("LButton", 42.8, 42.8) ;FAL CAMO射速700
        press_key("LButton", 50.0, 50.0) ;For click test
        ;press_key("LButton", 43.8, 43.75) ;M4A1射速685
    }
	Send, {Blind}{LButton Up}
Return

;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度时钟
SystemTime()
{
    freq := 0, tick := 0
    if (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", tick)
    Return tick / freq * 1000
} 
;==================================================================================
;学习自Bilibili用户开发的CSGO压枪脚本中的高精度睡眠
HyperSleep(value)
{
	t_accuracy := 0.991
	value *= t_accuracy
	begin_time := SystemTime()
	freq := 0, t_current := 0
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
	t_tmp := (begin_time + value) * freq / 1000 
    While (t_current < t_tmp)
    {
        If (t_tmp - t_current) > 20000 ;减少CPU占用
        {
            DllCall("Winmm.dll\timeBeginPeriod", UInt, 1) ;;相对高精度睡眠
			DllCall("Sleep", "UInt", 1)
			DllCall("Winmm.dll\timeEndPeriod", UInt, 1)
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
        }
        Else
            DllCall("QueryPerformanceCounter", "Int64*", t_current)
    }
}
;==================================================================================
;按键脚本,鉴于Input模式下单纯的send太快而开发
press_key(key, press_time, sleep_time)
{
    Send, {%key% DownTemp}
    HyperSleep(press_time)
    Send, {Blind}{%key% up}
    HyperSleep(sleep_time)
}
;==================================================================================