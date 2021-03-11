#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#MenuMaskKey vkFF  ; vkFF is no mapping
#IfWinExist, ahk_class CrossFire	; Only active while crossfire is running
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
;Translated from 按键精灵.Q version downloaded from Bilibili
;Now only works for Crossfire West using 神圣爆裂者

~*F7::Reload
~*F8::
	WinActivate, ahk_class CrossFire
    While, Not (GetKeyState("F9", "P"))
    {
        MyVar := 1 ; Assign stage value MyVar
    
        ; Stage 1
        While, (( MyVar = 1 ) && !(GetKeyState("F9", "P")))
        {
            WinGetPos, X, Y, , , ahk_class CrossFire
            Sleep, 500
            ; Get the color of certain position
            PixelGetColor, color1, (X + 546), (Y + 178)
            Sleep, 500
            IfEqual, color1, 0x1C1C1C
            {
                Sleep, 200
                ; Select map and level
                MouseClick, left, (X + 403), (Y + 463)
                Sleep, 200
                MouseMove, (X + 310), (Y + 477)
                Sleep, 200
                Loop, 20 ; for level 21
                {
                    MouseClick, WheelDown
                    Sleep, 50
                } 
                Sleep, 200  
                MouseClick, left, (X + 310), (Y + 477)
                Sleep, 200
                MouseClick, left, (X + 702), (Y + 702) ; click to start
                Sleep, 20000
                MyVar := 2 ; set to next stage
            }   
        }

        ; Stage 2
        While, ((MyVar = 2) && !(GetKeyState("F9", "P")))
        {
            WinGetPos, X, Y, , , ahk_class CrossFire
            Sleep, 500
            PixelGetColor, color2, (X + 332), (Y + 758)
            Sleep, 500

            IfEqual, color2, 0xFFF9D8
            {
                Sleep, 500
                MyVar := 3 ; set to next stage
            }
            Else
                Sleep, 500
        }

        ; Stage 3
        While, ((MyVar = 3) && !(GetKeyState("F9", "P")))
        {
            WinGetPos, X, Y, , , ahk_class CrossFire
            PixelGetColor, color2, (X + 332), (Y + 758)
            IfEqual, color2, 0xFFF9D8
            {
                MouseMove, (X + 515), (Y + 401)
                Loop, 100
                {
                    MouseMove, (X + 515), (Y + 451)
                    SendInput, {Click, Down, Right}
                    Sleep, 10
                    SendInput, {Click, Up, Right}
                    Sleep, 50
                }
            }
            Else
            {
                MouseClick, left, (X + 514), (Y + 674)
                Sleep, 500

                MouseClick, left, (X + 970), (Y + 723)
                Sleep, 500

                MouseClick, left, (X + 750), (Y + 589)
                Sleep, 500

                PixelGetColor, color1, (X + 546), (Y + 178)
                IfEqual, color1, 0x1C1C1C
                {
                    Sleep, 500
                    MyVar := 0
                }
            }
        }
    }
Return