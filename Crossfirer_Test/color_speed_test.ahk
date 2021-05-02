#NoEnv                           ;不检查空变量是否为环境变量
#Warn                            ;启用可能产生错误的特定状况时的警告
#Persistent                      ;让脚本持久运行
#MenuMaskKey, vkFF               ;改变用来掩饰(屏蔽)Win或Alt松开事件的按键
#MaxHotkeysPerInterval, 1000     ;与下行代码一起指定热键激活的速率(次数)
#HotkeyInterval, 1000            ;与上一行代码一起指定热键激活的速率(时间)
#SingleInstance, Force           ;跳过对话框并自动替换旧实例
#KeyHistory, 0                   ;禁用按键历史
#Include, Gdip_All.ahk           ;使脚本表现得好像指定文件的内容出现在这个位置一样
ListLines, Off                   ;不显示最近执行的脚本行
SendMode, Input                  ;使用更速度和可靠方式发送键鼠点击
SetWorkingDir, %A_ScriptDir%     ;保证一致的脚本起始工作目录
Process, Priority, , H           ;进程高优先级
SetBatchLines, -1                ;全速运行,且因为全速运行,部分代码不得不调整
SetKeyDelay, -1, -1              ;设置每次Send和ControlSend发送键击后无延时
SetMouseDelay, -1                ;设置每次鼠标移动或点击后无延时
SetDefaultMouseSpeed, 0          ;设置移动鼠标速度时默认使用最快速度
SetWinDelay, -1                  ;全速执行窗口命令
SetControlDelay, -1              ;控件修改命令全速执行

global PosColor_red := "0x353796|0x353797|0x353798|0x353799|0x343799|0x34379A|0x34389A|0x34389B|0x34389C|0x33389C|0x33389D|0x33389E|0x33389F|0x32389F|0x32399F|0x3239A0|0x3239A1|0x3239A2|0x3139A2|0x3139A3|0x3139A4|0x313AA4|0x313AA5|0x303AA5|0x303AA6|0x303AA7|0x303AA8|0x2F3AA8|0x2F3AA9|0x2F3BA9|0x2F3BAA|0x2F3BAB|0x2E3BAB|0x2E3BAC|0x2E3BAD|0x2E3BAE|0x2E3CAE|0x2D3CAE|0x2D3CAF|0x2D3CB0|0x2D3CB1|0x2C3CB1|0x2C3CB2|0x2C3CB3|0x2C3DB3|0x2C3DB4|0x2B3DB4|0x2B3DB5|0x2B3DB6|0x2B3DB7|0x2A3DB7|0x2A3EB7|0x2A3EB8|0x2A3EB9|0x2A3EBA|0x293EBA|0x293EBB|0x293EBC|0x293FBC|0x293FBC|0x293FBD|0x283FBD|0x283FBE|0x283FBF|0x283FC0|0x273FC0|0x273FC1|0x2740C1|0x2740C2|0x2740C3|0x2640C4|0x2640C5|0x2640C6|0x2641C6|0x2641C7|0x2541C7|0x2541C8|0x2541C9|0x2541CA|0x2441CA|0x2441CB|0x2442CB|0x2442CC|0x2442CD|0x2342CD|0x2342CE|0x2342CF|0x2342D0|0x2343D0|0x2243D0|0x2243D1|0x2243D2|0x2243D3|0x2143D3|0x2143D4|0x2144D4|0x2144D5|0x2144D6|0x2044D6|0x2044D7|0x2044D8|0x2044D9|0x1F44D9|0x1F45D9|0x1F45DA|0x1F45DB|0x1F45DC|0x1E45DC|0x1E45DD|0x1E45DE|0x1E46DE|0x1E46DF|0x1D46DF|0x1D46E0|0x1D46E1|0x1D46E2|0x1C46E2|0x1C46E3|0x1C47E3|0x1C47E4|0x1C47E5|0x1B47E5|0x1B47E6|0x1B47E7|0x1B47E8|0x1B48E8|0x1A48E8|0x1A48E9|0x1A48EA|0x1A48EB|0x1948EB|0x1948EC|0x1948ED|0x1949ED|0x1949EE|0x1849EE|0x1849EF|0x1849F0|0x1849F1|0x174AF2"

pc_red := StrSplit(PosColor_red, "|")
loop, 140
	FileAppend, % DecToHex(FlipBandR(pc_red[A_Index])) . "|", Testcolor.txt

FileRead, String2, Testcolor.txt
StringUpper, String2, String2
FileAppend, `n%String2%, Testcolor.txt

global PosColor_blue := "0x963735|0x973735|0x983735|0x993735|0x993734|0x9A3734|0x9A3834|0x9B3834|0x9C3834|0x9C3833|0x9D3833|0x9E3833|0x9F3833|0x9F3832|0x9F3932|0xA03932|0xA13932|0xA23932|0xA23931|0xA33931|0xA43931|0xA43A31|0xA53A31|0xA53A30|0xA63A30|0xA73A30|0xA83A30|0xA83A2F|0xA93A2F|0xA93B2F|0xAA3B2F|0xAB3B2F|0xAB3B2E|0xAC3B2E|0xAD3B2E|0xAE3B2E|0xAE3C2E|0xAE3C2D|0xAF3C2D|0xB03C2D|0xB13C2D|0xB13C2C|0xB23C2C|0xB33C2C|0xB33D2C|0xB43D2C|0xB43D2B|0xB53D2B|0xB63D2B|0xB73D2B|0xB73D2A|0xB73E2A|0xB83E2A|0xB93E2A|0xBA3E2A|0xBA3E29|0xBB3E29|0xBC3E29|0xBC3F29|0xBC3F29|0xBD3F29|0xBD3F28|0xBE3F28|0xBF3F28|0xC03F28|0xC03F27|0xC13F27|0xC14027|0xC24027|0xC34027|0xC44026|0xC54026|0xC64026|0xC64126|0xC74126|0xC74125|0xC84125|0xC94125|0xCA4125|0xCA4124|0xCB4124|0xCB4224|0xCC4224|0xCD4224|0xCD4223|0xCE4223|0xCF4223|0xD04223|0xD04323|0xD04322|0xD14322|0xD24322|0xD34322|0xD34321|0xD44321|0xD44421|0xD54421|0xD64421|0xD64420|0xD74420|0xD84420|0xD94420|0xD9441F|0xD9451F|0xDA451F|0xDB451F|0xDC451F|0xDC451E|0xDD451E|0xDE451E|0xDE461E|0xDF461E|0xDF461D|0xE0461D|0xE1461D|0xE2461D|0xE2461C|0xE3461C|0xE3471C|0xE4471C|0xE5471C|0xE5471B|0xE6471B|0xE7471B|0xE8471B|0xE8481B|0xE8481A|0xE9481A|0xEA481A|0xEB481A|0xEB4819|0xEC4819|0xED4819|0xED4919|0xEE4919|0xEE4918|0xEF4918|0xF04918|0xF14918|0xF24A17"
PosColor_red1 := "0x174AF2"

~*L Up::
    CounterBefore := 0, CounterAfter := 0, Frequency := 0
    DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)

    Loop, 1000 
    {
        PixelSearch, Px, Py, 0, 0, 100, 100, %PosColor_red1%, 0, Fast 
    }

    DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
    DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
    MsgBox % "Elapsed QPC time is " . (CounterAfter - CounterBefore)*1000/Frequency . " milliseconds"
Return

~*H Up::
    CounterBefore := 0, CounterAfter := 0, Frequency := 0
    DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
    
    Loop, 1000
        checkcolor(0, 0, 80, 16)

    DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
    DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
    MsgBox % "Elapsed QPC time is " . (CounterAfter - CounterBefore)*1000/Frequency/1000 . " milliseconds"
Return

;============================================================================================
checkcolor(a, b, aw, bh)
{
	found := False
	pBitmap := Gdip_BitmapFromScreen(a . "|" . b . "|" . aw . "|" . bh)
	E1 := Gdip_LockBits(pBitmap, 0, 0, Gdip_GetImageWidth(pBitmap), Gdip_GetImageHeight(pBitmap), Stride, Scan0, BitmapData)
	Loop, %bh%
	{
		new_y := 2 * (A_Index - 1)
		If !Mod(new_x, 4)
			HyperSleep(0.0001)
		If new_y < bh
		{
			Loop, %aw%
			{
				new_x := 2 * A_Index
				If new_x < aw
				{
					color_ARGB := Gdip_GetLockBitPixel(Scan0, new_x, new_y, Stride)
					color_got := ARGBtoRGB(color_ARGB)
					If InStr(PosColor_blue, color_got)
					{
						found := True
						Break
					}
				}
			}
		}
	}
	Gdip_UnlockBits(pBitmap, BitmapData)
    Gdip_DisposeImage(pBitmap)
	Return found
}

SystemTime()
{
    freq := 0, tick := 0
    If (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", tick)
    Return tick / freq * 1000
} 

HyperSleep(value)
{
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
        }
        DllCall("QueryPerformanceCounter", "Int64*", t_current)
    }
}

ARGBtoRGB(ARGB) 
{
    VarSetCapacity(RGB, 6, 0)
    DllCall("msvcrt.dll\sprintf", Str, RGB, Str, "%06X", UInt, ARGB<<8)
    Return "0x" RGB
}

FlipBandR(color) ;takes RGB or BGR and swaps the R and B
{
    Return (color & 255) << 16 | (color & 65280) | (color >> 16)
}

DecToHex(dec)
{
    oldfrmt := A_FormatInteger
    hex := dec
    SetFormat, IntegerFast, hex
    hex += 0
    hex .= ""
    SetFormat, IntegerFast, %oldfrmt%
    return hex
}