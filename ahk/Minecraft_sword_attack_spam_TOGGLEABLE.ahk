#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

lClickToggle := false
lCurrentlyClicking := false
rCurrentlyClicking := false


^!s::Suspend ; alt+ctrl+s to suspend script execution


XButton1::
  lClickToggle := !lClickToggle
  if (lClickToggle)
      SetTimer, leftclick, 600
  else
      SetTimer, leftclick, Off
return

leftclick:
  If (!lClickToggle or lCurrentlyClicking)
    return
  lCurrentlyClicking := true
  Click
  Random, SleepTime, 20, 30
  Sleep %SleepTime%
  lCurrentlyClicking := false
return
