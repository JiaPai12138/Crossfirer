#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#MenuMaskKey vkFF  ; vkFF is no mapping
#SingleInstance, force
#IfWinActive ahk_exe crossfire.exe	; Only active while crossfire is running
CoordMode, Pixel, Screen
Process, Priority, , H

PosColor1 := "0x353796 0x353797 0x353798 0x353799 0x343799 0x34379A 0x34389A 0x34389B 0x34389C 0x33389C 0x33389D 0x33389E 0x33389F 0x32389F 0x32399F 0x3239A0 0x3239A1 0x3239A2 0x3139A2 0x3139A3 0x3139A4 0x313AA4 0x313AA5 0x303AA5 0x303AA6 0x303AA7 0x303AA8 0x2F3AA8 0x2F3AA9 0x2F3BA9 0x2F3BAA 0x2F3BAB 0x2E3BAB 0x2E3BAC 0x2E3BAD 0x2E3BAE 0x2E3CAE 0x2D3CAE 0x2D3CAF 0x2D3CB0 0x2D3CB1 0x2C3CB1 0x2C3CB2 0x2C3CB3 0x2C3DB3 0x2C3DB4 0x2B3DB4 0x2B3DB5 0x2B3DB6 0x2B3DB7 0x2A3DB7 0x2A3EB7 0x2A3EB8 0x2A3EB9 0x2A3EBA 0x293EBA 0x293EBB 0x293EBC 0x293FBC 0x293FBC 0x293FBD 0x283FBD 0x283FBE 0x283FBF 0x283FC0 0x273FC0 0x273FC1 0x2740C1 0x2740C2 0x2740C3 0x2640C4 0x2640C5 0x2640C6 0x2641C6 0x2641C7 0x2541C7 0x2541C8 0x2541C9 0x2541CA 0x2441CA 0x2441CB 0x2442CB 0x2442CC 0x2442CD 0x2342CD 0x2342CE 0x2342CF 0x2342D0 0x2343D0 0x2243D0 0x2243D1 0x2243D2 0x2243D3 0x2143D3 0x2143D4 0x2144D4 0x2144D5 0x2144D6 0x2044D6 0x2044D7 0x2044D8 0x2044D9 0x1F44D9 0x1F45D9 0x1F45DA 0x1F45DB 0x1F45DC 0x1E45DC 0x1E45DD 0x1E45DE 0x1E46DE 0x1D46DF 0x1D46E0 0x1D46E1 0x1D46E2 0x1C46E3 0x1C47E3 0x1C47E4 0x1C47E5 0x1B47E5 0x1B47E6 0x1B47E7 0x1B48E8 0x1A48E8 0x1A48E9 0x1A48EA 0x1A48EB 0x1948EC 0x1948ED 0x1949ED 0x1949EE 0x1849EF 0x1849F0 0x1849F1 0x174AF2" ;all detected values of color hex since it is changing
PosColor2 := "0x000000 0x232323"

AutoMode := 0 ;on/off switch

~*C::
    AutoMode := Mod((AutoMode + 1), 2)
return

~*1::AutoFire(1)

~*2::AutoFire(0)

~*J::AutoFire(8) ;sniper mode

~*6::AutoFire(11) ;machine gun

~*L::AutoFire(111) ;Gatling gun

AutoFire(ya_qiang)
{
    global ;declare global vairable
    WinGetPos, X, Y, , , ahk_exe crossfire.exe ;get top left position of the window
    
    PixelGetColor, color_edge, (X + 1130), (Y + 50)
    While, Not (AutoMode = 0 || InStr(PosColor2, color_edge) || GetKeyState("3", "P"))
    {
        Var := 770
        Loop ;detect color in one line where shows the enemy name
        {
            PixelGetColor, color1, (X + Var), (Y + 538)
            Var ++

            If InStr(PosColor1, color1) ;if detected color is found in string
            {
                Random, rand, 118, 122 ;set random value trying to avoid VAC
                If (ya_qiang = 1)
                {
                    SendInput, {Click, Down, Left}
                    ReduceRecoil(2, 90, 90)
                    SendInput, {Blind}{Click, Up, Left}
                    Sleep, (rand + 120)
                    break 
                }
                Else If (ya_qiang = 0)
                {
                    SendInput, {Click}
                    Sleep, (rand - 80)
                    break 
                }
                Else If (ya_qiang = 8)
                {
                    SendInput, {Click}
                    Sleep, 300
                    break 
                }
                Else If (ya_qiang = 11)
                {
                    SendInput, {Click, Down, Left}
                    ReduceRecoil(25, 40, 25)
                    SendInput, {Blind}{Click, Up, Left}
                    break
                }
                Else ;If (ya_qiang = 111)
                {
                    SendInput, {Click, Down, Left}
                    Sleep, (rand - 60)
                    SendInput, {Blind}{Click, Up, Left}
                    Sleep, (rand - 60)
                    break 
                }
            }
        } until ( Var = 830 )
    }
    return
}

ReduceRecoil(chong_fu, yan_chi, jian_ge) 
{
	cnt := 0
	Sleep, yan_chi
    while, (GetKeyState("LButton") && (cnt < chong_fu) && !GetKeyState("3"))
	{
		mouseXY(0,1) ;move mouse down 1
	    Sleep, jian_ge
		cnt ++
    }
	return
}

mouseXY(x1,y1)
{
    DllCall("mouse_event",uint,1,int,x1,int,y1,uint,0,int,0)
}
