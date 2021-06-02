; http://www.autohotkey.com/board/topic/77303-acc-library-ahk-l-updated-09272012/
; https://dl.dropbox.com/u/47573473/Web%20Server/AHK_L/Acc.ahk
;------------------------------------------------------------------------------
; Acc.ahk Standard Library
; by Sean
; Updated by jeThrow:
;     ModIfied ComObjEnwrap params from (9,pacc) --> (9,pacc,1)
;     Changed ComObjUnwrap to ComObjValue in order to avoid AddRef (thanks fincs)
;     Added Acc_GetRoleText & Acc_GetStateText
;     Added additional functions - commented below
;     Removed original Acc_Children function
; last updated 2/25/2010
;------------------------------------------------------------------------------

Acc_Init()
{
    Static h
    h := DllCall("LoadLibrary","Str","oleacc","Ptr")
}

Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild)
{
    Acc_Init()
    If DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd, "UInt", idObject, "UInt", idChild, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
    Return ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "")
{
    Acc_Init()
    If DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
    Return ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromWindow(hWnd, idObject = -4)
{
    Acc_Init()
	pacc := ""
    If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
    Return ComObjEnwrap(9,pacc,1)
}

Acc_WindowFromObject(pacc)
{
    If DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
    Return hWnd
}

Acc_GetRoleText(nRole)
{
    nSize := DllCall("oleacc\GetRoleText", "Uint", nRole, "Ptr", 0, "Uint", 0)
    VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
    DllCall("oleacc\GetRoleText", "Uint", nRole, "str", sRole, "Uint", nSize+1)
    Return sRole
}

Acc_GetStateText(nState)
{
    nSize := DllCall("oleacc\GetStateText", "Uint", nState, "Ptr", 0, "Uint", 0)
    VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
    DllCall("oleacc\GetStateText", "Uint", nState, "str", sState, "Uint", nSize+1)
    Return sState
}

Acc_SetWinEventHook(eventMin, eventMax, pCallback)
{
    Return DllCall("SetWinEventHook", "Uint", eventMin, "Uint", eventMax, "Uint", 0, "Ptr", pCallback, "Uint", 0, "Uint", 0, "Uint", 0)
}

Acc_UnhookWinEvent(hHook)
{
    Return DllCall("UnhookWinEvent", "Ptr", hHook)
}
/*    Win Events:

    pCallback := RegisterCallback("WinEventProc")
    WinEventProc(hHook, event, hWnd, idObject, idChild, eventThread, eventTime)
    {
        Critical
        Acc := Acc_ObjectFromEvent(_idChild_, hWnd, idObject, idChild)
        ; Code Here:

    }
*/

; Written by jeThrow
Acc_Role(Acc, ChildId=0) {
    Try Return ComObjType(Acc,"Name")="IAccessible"?Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
}

Acc_State(Acc, ChildId=0) {
    Try Return ComObjType(Acc,"Name")="IAccessible"?Acc_GetStateText(Acc.accState(ChildId)):"invalid object"
}

Acc_Location(Acc, ChildId=0, byref Position="") { ; adapted from Sean's code
    Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
    Catch
        Return
    Position := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
    Return {x:NumGet(x,0,"int"), y:NumGet(y,0,"int"), w:NumGet(w,0,"int"), h:NumGet(h,0,"int")}
}

Acc_Parent(Acc) {
    Try parent:=Acc.accParent
    Return parent?Acc_Query(parent):
}

Acc_Child(Acc, ChildId=0) {
    Try child:=Acc.accChild(ChildId)
    Return child?Acc_Query(child):
}

Acc_Query(Acc) { ; thanks Lexikos - www.autohotkey.com/forum/viewtopic.php?t=81731&p=509530#509530
    Try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}

Acc_Error(p="") {
    static setting:=0
    Return p=""?setting:setting:=p
}

Acc_Children(Acc) {
    If ComObjType(Acc,"Name") != "IAccessible"
        ErrorLevel := "Invalid IAccessible Object"
    Else {
        Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
        If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
            Loop %cChildren%
                i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
            Return Children.MaxIndex()?Children:
        } Else
            ErrorLevel := "AccessibleChildren DllCall Failed"
    }
    If Acc_Error()
        Throw Exception(ErrorLevel,-1)
}

Acc_ChildrenByRole(Acc, Role) {
    If ComObjType(Acc,"Name")!="IAccessible"
        ErrorLevel := "Invalid IAccessible Object"
    Else {
        Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
        If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
            Loop %cChildren% {
                i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i)
                If NumGet(varChildren,i-8)=9
                    AccChild:=Acc_Query(child), ObjRelease(child), Acc_Role(AccChild)=Role?Children.Insert(AccChild):
                Else
                    Acc_Role(Acc, child)=Role?Children.Insert(child):
            }
            Return Children.MaxIndex()?Children:, ErrorLevel:=0
        } Else
            ErrorLevel := "AccessibleChildren DllCall Failed"
    }
    If Acc_Error()
        Throw Exception(ErrorLevel,-1)
}

Acc_Get(Cmd, ChildPath="", ChildID=0, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="") {
    static properties := {Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut"}
    AccObj :=   IsObject(WinTitle)? WinTitle
            :   Acc_ObjectFromWindow( WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0 )
    If ComObjType(AccObj, "Name") != "IAccessible"
        ErrorLevel := "Could not access an IAccessible Object"
    Else {
        StringReplace, ChildPath, ChildPath, _, %A_Space%, All
        AccError:=Acc_Error(), Acc_Error(true)
        Loop Parse, ChildPath, ., %A_Space%
            Try {
                If A_LoopField is digit
                    Children:=Acc_Children(AccObj), m2:=A_LoopField ; mimic "m2" output in Else-statement
                Else
                    RegExMatch(A_LoopField, "(\D*)(\d*)", m), Children:=Acc_ChildrenByRole(AccObj, m1), m2:=(m2?m2:1)
                If Not Children.HasKey(m2)
                    Throw
                AccObj := Children[m2]
            } Catch {
                ErrorLevel:="Cannot access ChildPath Item #" A_Index " -> " A_LoopField, Acc_Error(AccError)
                If Acc_Error()
                    Throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
                Return
            }
        Acc_Error(AccError)
        StringReplace, Cmd, Cmd, %A_Space%, , All
        properties.HasKey(Cmd)? Cmd:=properties[Cmd]:
        Try {
            If (Cmd = "Location")
                AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId), ret_val := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
            Else If (Cmd = "Object")
                ret_val := AccObj
            Else If Cmd in Role,State
                ret_val := Acc_%Cmd%(AccObj, ChildID+0)
            Else If Cmd in ChildCount,Selection,Focus
                ret_val := AccObj["acc" Cmd]
            Else
                ret_val := AccObj["acc" Cmd](ChildID+0)
        } Catch {
            ErrorLevel := """" Cmd """ Cmd Not Implemented"
            If Acc_Error()
                Throw Exception("Cmd Not Implemented", -1, Cmd)
            Return
        }
        Return ret_val, ErrorLevel:=0
    }
    If Acc_Error()
        Throw Exception(ErrorLevel,-1)
}