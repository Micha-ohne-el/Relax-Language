﻿class Config {
	static DEBUG := True
}

#Include %A_ScriptDir%
#Include Interface.ahk

; TODO: Pick a name
; TODO: CodeGen linking rewrite
; TODO: (Related to above) Shorter Jmp encodings
; TODO: Write more tests
; TODO: Eventually find a smarted way to handle variables
; TODO: Fix floating point comparison operators

Code = 
( % 
DllImport Int64 MessageBoxA(Int64*, Int8*, Int8*, Int32) {User32.dll, MessageBoxA}

define Double T2() {
	return 1.2
}

)

;define Int64 T1() {
;	MessageBoxA(0, "Scumbug", "What the fuck did you just fucking say about me?", 0)
;}

;Todo: Implement dllcalls as using a table pointed to by R14 (It can probably live on stack), so we can easily compile a function to an AHK version without having to re-link every single byte
;Todo: Maybe(???????) include modules in the table
;
;To call:
;mov rax, [r14 + indexReg * 8]
;call rax


; (BodyText + i) *= *(BodyText + i)

;	for (Int64 i := 0, i <= P1, i++) {
;		(BodyText + i) *= *(BodyText + i)
;		Test2(0, TitleText, BodyText)
;	}


;define void* T1() {
;	Int8* StringBuffer := Memory:Alloc(40) as Int8*
;	
;	StringBuffer *= 'h'
;	StringBuffer + 1 *= 'i'
;	
;	return &T1
;}

;global Int64 TestGlobal
;
;define Int64 T1(Int64 Value) {
;	TestGlobal := Value
;	Int8* A := Memory:HeapAlloc(8)
;	return 0
;}
;define Int64 T2() {
;	return TestGlobal
;}


;define Int64 Test3(Int64 B) {if (B >= 2) {return 20} return 90}
;
;DllImport Int64 MessageBoxA(Int64*, Int8*, Int8*, Int32) {User32.dll, MessageBoxA}
;define Int64 Test2(Int64 P1, Int8* BT, Int8* TT) {return MessageBoxA(P1, TT, BT, 0)}

;define Int8 Test(Int64 P1) {
;	Int8* TitleText := "this is the title" 
;	Int8* BodyText := "this is the body text"
;	Int16 A := 999
;	/*Int8* B := &A*/
;	/*B *= 999*/
;
;	for (Int64 i := 0, i <= P1, i++) {
;		(BodyText + i) *= *(BodyText + 12 + i + -4)
;		Test2(0, TitleText, BodyText)
;	}
;
;	return 0
;}

;MsgBox, % LanguageName.FormatCode(Code)
MsgBox, % LanguageName.CompileToAHKFunctions(Code)

R := LanguageName.CompileCode(Code, {"Features": LanguageNameFlags.ToAHK})

MsgBox, % R.Node.Stringify()
MsgBox, % (Clipboard := R.CodeGen.Stringify())
MsgBox, % R.ToAHK()
MsgBox, % "Result: " R.CallFunction("T2", 6, 1, 4, 3, 4, 2) "`n" A_LastError "`n" ;R.GetFunctionPointer("T1")
;MsgBox, % "Stored: " R.CallFunction("T2")

; Int64* A := &B
; A := 99