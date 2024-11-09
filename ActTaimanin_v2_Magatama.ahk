#Requires AutoHotkey v2.0

~^s::
{
    Sleep 500
    Reload
}

#HotIf WinActive("ahk_exe ActionTaimanin.exe")

Numpad1::
{
    ClickRestart()
}

Numpad7::
{
    aClick(1300, 250)
    Wait()
    ClickRestart()
}

Numpad4::
{
    aClick(1300, 550)
    Wait()
    ClickRestart()
}

aClick(posX, posY, Times := 1, Sleep_Time := 50)
{
    Click posX, posY, 0

    Loop Times
    {
        Sleep Sleep_Time
        Click
    }
}

Wait()
{
    Sleep 650
}

ClickRestart()
{
    aClick(1400, 860, 2)
    Sleep 650
    aClick(1400, 860)
    return
}