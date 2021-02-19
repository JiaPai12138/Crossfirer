#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#MenuMaskKey, vkFF  ; vkFF is no mapping
#MaxHotkeysPerInterval, 99000000  
#HotkeyInterval, 99000000  
#SingleInstance, Force  
#IfWinActive, ahk_class CrossFire  
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
DetectHiddenWindows, On  
SetTitleMatchMode, Regex  

Game_Obj := CriticalObject()  ;Create new critical object