#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

KeyDown = false

^!s::Suspend ; alt+ctrl+s to suspend script execution

XButton1::
  KeyDown := !KeyDown
  If KeyDown
    {
      SendInput {Click down right}
    }
  Else
    {
      SendInput {Click up right}
    }
  Return
