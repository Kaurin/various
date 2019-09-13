#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

clickToggle := false
currentlyClicking := false


^!s::Suspend ; alt+ctrl+s to suspend script execution

; This works as well but is unreadable
; XButton1::Send % "{Click " . ( GetKeyState("RButton") ? "Up, right}" : "Down, right}" )

; This is the "back" button (mouse4). It is a toggle for the right click (hold/unhold)
; It will also stop continuous left-clcking macro as these two hotkeys are mutually exclusive
XButton1::
  clickToggle := false
  SetTimer, leftclick, Off
  if GetKeyState("RButton") {
    Click, up, right
  } else {
    Click, down, right
  }
return

; This is the "forward" or "mouse5". It is a toggle for continuous left-clicking
; This will also "lift up the right click" because this macro is mutually exclusive with the xbutton1
XButton2::
  clickToggle := !clickToggle
  if GetKeyState("RButton") {
    Click, up, right
  }
  if (clickToggle)
      SetTimer, leftclick, 50 ; Call the sub every 25ms
  else
      SetTimer, leftclick, Off
return

leftclick:
  If (!clickToggle or currentlyClicking)
    return
  currentlyClicking := true
  Click
  Random, SleepTime, 30, 60 ; Add the default 25msec for timer invocation, and we get a range of 26-55 msec
  Sleep %SleepTime%
  currentlyClicking := false
return
