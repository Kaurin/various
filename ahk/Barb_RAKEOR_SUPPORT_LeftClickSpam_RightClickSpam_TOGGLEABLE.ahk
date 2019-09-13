#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

lClickToggle := false
rClickToggle := false
lCurrentlyClicking := false
rCurrentlyClicking := false


^!s::Suspend ; alt+ctrl+s to suspend script execution


XButton2::
  rClickToggle := false
  SetTimer, rightclick, Off
  lClickToggle := !lClickToggle
  if (lClickToggle)
      SetTimer, leftclick, 50 ; Call the sub every 25ms
  else
      SetTimer, leftclick, Off
return

XButton1::
  lClickToggle := false
  SetTimer, leftclick, Off
  rClickToggle := !rClickToggle
  if (rClickToggle)
      SetTimer, rightclick, 50 ; Call the sub every 25ms
  else
      SetTimer, rightclick, Off
return


leftclick:
  If (!lClickToggle or lCurrentlyClicking)
    return
  lCurrentlyClicking := true
  Click
  Random, SleepTime, 100, 200 ; Add the default 25msec for timer invocation, and we get a range of 26-55 msec
  Sleep %SleepTime%
  lCurrentlyClicking := false
return

rightclick:
  If (!rClickToggle or rCurrentlyClicking)
    return
  rCurrentlyClicking := true
  Click, right
  Random, SleepTime, 30, 60 ; Add the default 25msec for timer invocation, and we get a range of 26-55 msec
  Sleep %SleepTime%
  rCurrentlyClicking := false
return
