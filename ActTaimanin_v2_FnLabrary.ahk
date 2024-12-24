#Requires AutoHotkey v2.0

#HotIf WinActive("ahk_exe ActionTaimanin.exe")


Return

#HotIf WinActive("ahk_exe ActionTaimanin.exe")
;====================== - Sub Functions - ======================;
searchAndWait(searchDuration, searchInterval, filename, X1 := 0, Y1 := 0, X2 := 2573, Y2 := 1498, writeLog := 1, Coord := false)
{
    if (Coord)
    {
        CT := CoordTransfer(X1, Y1)
        X1 := CT.X
        Y1 := CT.Y
        CT := CoordTransfer(X2, Y2)
        X2 := CT.X
        Y2 := CT.Y
    }
    If (searchInterval == 0 Or searchDuration == 0)
        S_Loop := 1
    Else
        S_Loop := Ceil(searchDuration / searchInterval)

    Loop S_Loop
    {
        try
        {
            if ImageSearch(&foundX, &foundY, X1, Y1, X2, Y2, "*32 *TransBlack " A_WorkingDir "\ImageSearch\" filename)
                return 0
            else
                Sleep searchInterval
        }
        catch Error as err {
            Log_Text := "Image_Search_and_Wait Crashed: " . filename
            Log_Text := Log_Text . ". " . err
            fnWriteLog("Error", Log_Text)
            Return 2    ; Search Failed.
        }
    }
    If (writeLog)
    {
        Log_Text := "Image_Search_and_Wait Time out: " . filename
        Log_Text := Log_Text . "."
        fnWriteLog("Warning", Log_Text)
    }
    Return 1    ; Search Timeout.
}


checkLobbyEvent()
{
    searchResult := searchAndWait(2000, 500, "Lobby_Event.png", 1400, 128, 2200, 384, 0, true)
    If (searchResult == 0)
    {
        SoundAlarm(2, 1)
        fnWriteLog("Event", "Surprise Campaign detected.")
    }
    Return
}

; Old: BackToMain
returnToHomePage(Error_Global := 0)
{
    WinActivate("ActionTaimanin")
    ClickRTB()
    Sleep 500
    Loop 7
    {
        ActTaimanin_Click(1280, 128, 0)
        E_Level := searchAndWait(1000, 250, "Menu_Main_0.png", 0, 0, 512, 128, 0, true)
        ; Old coor: 2240, 560, 2504, 880)
        If (E_Level == 0)
        {
            Sleep 2000
            ; To-do: add a new searchAndWait() here.
            ; E_Level_2 := searchAndWait(2000, 400, "Menu_Main_Ready.png", coor_x4)
            Return 0
        }
        Else If (E_Level == 1)
        {
            Send "{Esc}"
            Sleep 200
            Sleep 1000
            Error_Local := 2
        }
        Else ; If (E_Level == 2)
        {
            Error_Local := 4
            fnWriteLog("Error", "Main_Menu Searching Crashed!")
        }
    }
    ActTaimanin_Click(1120, 1088, 0)
    Sleep 300
    ClickVoid()                 ; 100 ms
    Sleep 1000
    If (Error_Local <= 4)
    {
        Error_Local := 2 ; Title_Check(0)   ; To be done!!
    }
    fnWriteLog("Warning", "Too many failed attempts returning to Main_Menu!")
    SoundAlarm(4)
    Return Error_Local
}


Check_Main_Menu(Error_Global := 0)
{   ; Return: Error_Global in Total
    Error_Local := 0
    searchResult := searchAndWait(1, 0, "Menu_Main_0.png", 0, 0, 512, 128, , true)
    ;ImageSearch(&_, &_, 0, 0, 512, 128, "*32 *TransBlack " A_WorkingDir "\ImageSearch\Menu_Main_0.png")
    If (searchResult == 0)
        Return 0
    If (searchResult == 1) {
        Error_Global += 1
        If (Error_Global >= 5) {
            fnWriteLog("Error", "Unable to locate Main_Menu!")
            Return Error_Global
        }

        Error_Global += returnToHomePage()
        Error_Local := Check_Main_Menu(Error_Global)
        If (Error_Local == 0)
            Return 0
        Else
        {
            Error_Global += Error_Local
            Return Error_Global
        }
    }
    Else ; If (ErrorLevel == 2)
        Return 100
}


fnWriteLog(Log_Kata := "Log", Log_Lines*)
{
    if (A_ScriptName == "ActTaimanin_Autohk_Model_4.ahk")
        File_Log := FileOpen("ActTaimanin_Log.txt", "a -wd")
    else If (A_ScriptName == "ActTaimanin_Autohk_Test.ahk")
        File_Log := FileOpen("ActTaimanin_Log_TestMode.txt", "a -wd")
    if (!File_Log)
    {
        MsgBox "Fail to Open Log File!"
        Return
    }

    ; FormatTime, Text, , [yyyy.MM.dd - HH: mm: ss]
    Text := FormatTime(A_Now, "[yyyy.MM.dd - HH:mm:ss] ")  ; 获取格式化的当前时间
    Log_Kata := Log_Kata . ": "
    StrLine := Text . Log_Kata

    for index, Log_L in Log_Lines {
        StrLine := StrLine . Log_L
    }

    File_Log.WriteLine(StrLine)
    File_Log.Close()

    return
}


LoadConfig()
{
    global
    ; IniRead, Taimanin_F1, ActTaimanin_Config.ini, Factory, Taimanin_F1, %Taimanin_F1%
    Taimanin_F1 := IniRead("ActTaimanin_Config.ini", "Factory", "Taimanin_F1", Taimanin_F1)

    Taimanin_F2 := IniRead("ActTaimanin_Config.ini", "Factory", "Taimanin_F2", -1)  ; %Taimanin_F2%
    Weapon_1Y := IniRead("ActTaimanin_Config.ini", "Factory", "Weapon_1Y", Weapon_1Y)
    Weapon_1X := IniRead("ActTaimanin_Config.ini", "Factory", "Weapon_1X", Weapon_1X)
    Weapon_2Y := IniRead("ActTaimanin_Config.ini", "Factory", "Weapon_2Y", Weapon_2Y)
    Weapon_2X := IniRead("ActTaimanin_Config.ini", "Factory", "Weapon_2X", Weapon_2X)
    Weapon_3Y := IniRead("ActTaimanin_Config.ini", "Factory", "Weapon_3Y", Weapon_3Y)
    Weapon_3X := IniRead("ActTaimanin_Config.ini", "Factory", "Weapon_3X", Weapon_3X)
    ;
    AP_DlM := IniRead("ActTaimanin_Config.ini", "Quests", "AP_DlM", AP_DlM)
    AP_Event := IniRead("ActTaimanin_Config.ini", "Quests", "AP_Event", AP_Event)
    AP_Exp := IniRead("ActTaimanin_Config.ini", "Quests", "AP_Exp", AP_Exp)
    BP_SpR := IniRead("ActTaimanin_Config.ini", "Quests", "BP_SpR", BP_SpR)
    BP_Ldr := IniRead("ActTaimanin_Config.ini", "Quests", "BP_Ldr", BP_Ldr)
    ;
    AP_Time := IniRead("ActTaimanin_Config.ini", "Timer", "AP_Time", AP_Time)
    BA_Time := IniRead("ActTaimanin_Config.ini", "Timer", "BA_Time", BA_Time)
    ;
    Loop_Total := IniRead("ActTaimanin_Config.ini", "Process", "Loop_Total", Loop_Total)
    Time_Last := IniRead("ActTaimanin_Config.ini", "Process", "Time_Last", Time_Last)
    TimeZone := IniRead("ActTaimanin_Config.ini", "Process", "TimeZone", 2)
    UseWemod := IniRead("ActTaimanin_Config.ini", "Process", "Wemod", 0)
    Return
}


LoadIniConfig(Ini_Key, Ini_Section := "Actives", Ini_File := "ActTaimanin_Config.ini", Ini_Default := 0)
{
    Ini_Config := IniRead(Ini_File, Ini_Section, Ini_Key, Ini_Default)
    ; MsgBox, %Ini_Key%: %Ini_Config%
    Return Ini_Config
}

SaveIniConfig(Ini_Value, Ini_Key, Ini_Section := "Actives", Ini_File := "ActTaimanin_Config.ini")
{
    IniWrite(Ini_Value, Ini_File, Ini_Section, Ini_Key)
}


Act_CD_Check(Last_Run := 0, Time_CD := 10800)
{   ; Time_CD: Seconds
    ; Time_Now := DateDiff(A_Now, Last_Run, "Seconds")
    Time_Now -= Last_Run, "Seconds"
    ; MsgBox, Time_Now
    if (Time_Now >= Time_CD)
    {
        ; MsgBox, CD_Check:1
        return 1
    }
    else
    {
        ; MsgBox, CD_Check:0
        return 0
    }
}


ActiveRecord()
{
    Return
}
; FIXME:
; {
;     Active_Last := LoadIniConfig("Active_Last", "Process", , Ini_Default := Time_Last)
;     Time_Now := A_Now
;     Active_Last -= Time_Now, "Seconds"
;     If (Active_Last < 0)
;         SaveIniConfig(Time_Now, "Active_Last", "Process")
;     Return
; }

WakeUpSequence()
{
    WinActivate("ActionTaimanin")
    ClickRTB()
    Maintenance_From := LoadIniConfig("Maintenance_From", "Process")
    Maintenance_Until := LoadIniConfig("Maintenance_Until", "Process")
    TimeZone := LoadIniConfig("TimeZone", "Process", , Ini_Default := 2)
    Maintenance_From += TimeZone, "Hours"
    Maintenance_Until += TimeZone, "Hours"
    While (Maintenance_Until > A_Now AND Maintenance_From < A_Now)
    {
        fnWriteLog("System", "Wake Up during Server Maintenance.")
        Sleep 3600000  ; 3600s, not 3600 ms !
    }
    Error_Total += returnToHomePage(0)
    CLE_Until := LoadIniConfig("No_CLE_Until")
    CD_Check := Act_CD_Check(CLE_Until, 0)
    If (CD_Check)
        CheckLobbyEvent()
    Return
}

WakeUpSequence_0()   ;   ---------- BLOCK_TIME = 22s ----------    ;
{
    WinActivate("ActionTaimanin")
    Sleep 500
    ; FIXME: Gosub ClickVoid
    Maintenance_From := IniRead("ActTaimanin_Config.ini", "Process", "Maintenance_From")
    Maintenance_Until := IniRead("ActTaimanin_Config.ini", "Process", "Maintenance_Until")
    TimeZone := IniRead("ActTaimanin_Config.ini", "Process", "TimeZone", 2)
    Maintenance_From += TimeZone, "Hours"
    Maintenance_Until += TimeZone, "Hours"
    If (Maintenance_Until > A_Now AND Maintenance_From < A_Now)
    {
        fnWriteLog("System", "Wake Up during Server Maintenance.")
        Sleep 18000
        SoundAlarm(-1)
    }
    Else
    {
        Error_Total += returnToHomePage(0)
        Send_Last := 0
        Send_Last := IniRead("ActTaimanin_Config.ini", "Process", "Send_Last", 0)
        If (Send_Last)
        {
            Time_Now := A_Now
            Send_Last += 12, "Hours"
            Send_Last -= Time_Now, "Seconds"   ; 现在到本次Send的理论时间点的剩余时间
            If (Send_Last > 0 AND Send_Last > 600)
            {   ;   距离下次送FP时间超过10分钟，则执行特殊任务
                SpecialMode()
            }
        }
        Send("{F3}")
        Error_Total += returnToHomePage(0)        ; 1s+
        CheckLobbyEvent()
        RunEntsendung(0)
        Run_Sakusen_Kaigi()
        fnWriteLog("System", "Waked Up.`n")
    }
    Return
}

RunningCheck()           ;   -------- BLOCK_TIME = 4s --------   ;
{
    WeMod_Check()
    Return
}

WeMod_Check()
{
    WinActivate("WeMod")
    Send "{F3}"
    Sleep 1000
    ActTaimanin_Click(1000, 100, 0)
    ; Check F3
    E_Level := searchAndWait(2000, 400, "WeMod_Switch_2.png", 136, 376, 1632, 768)
    ;ImageSearch, FindX, FindY, 136, 376, 1632, 768, *32 %A_WorkingDir%\ImageSearch\WeMod_Switch_2.png
    If (E_Level == 1)
    {
        FindX := 260
        FindY := 570
    }
    If (E_Level == 2)
    {
        fnWriteLog("Error", "WeMod: ImageSearch Crashed!")
    }
    Sleep 500
    _ := 0
    searchResult1 := PixelSearch(&_, &_, FindX, FindY, FindX + 700, FindY + 150, 0x0298c1, 32)
    If (searchResult1) {      ; If (WeMod_Cheat_3 == On)
        Send "{F3}"
        Sleep 2000
    }
    Else
    {
        Send "{F3}"
        Sleep 1000
        searchResult2 := PixelSearch(&_, &_, FindX, FindY, (FindX + 700), (FindY + 150), 0x0298c1, 32)
        If (searchResult2) {      ; If (WeMod_Cheat_3 == On)
            Send "{F3}"
            Sleep 1000
        }
        Else
        {   ; Detected Taimanin is not Running!
            ; Record Time
            AA_Error_Time := A_Now
            SoundAlarm(-1)
        }
    }   ; EndIf(WeMod_Cheat_1)    Post: WeMod_Cheat_1 := Off
    ; Check F7
    searchResult1 := PixelSearch(&_, &_, FindX, (FindY + 150), (FindX + 700), (FindY + 180), 0x0298c1, 32)
    If (searchResult1) {      ; If (WeMod_Cheat_4 == On)
        Send "{F7}"
    }   ; EndIf(WeMod_Cheat_4)    Post: WeMod_Cheat_4 := Off
    WinActivate("ActionTaimanin")
    Sleep 2000
    Return
}


Set_Maintenance()
{
    Maintenance_From := IniRead("ActTaimanin_Config.ini", "Process", "Maintenance_From")
    While (Maintenance_From < A_Now)
    {
        Maintenance_From += 7, "Days"
    }
    Maintenance_Until := Maintenance_From
    Maintenance_Until += 4, "Hours"
    Maintenance_Until += 30, "Minutes"
    IniWrite(Maintenance_From, "ActTaimanin_Config.ini", "Process", "Maintenance_From")
    IniWrite(Maintenance_Until, "ActTaimanin_Config.ini", "Process", "Maintenance_Until")
    Return
}


SoundAlarm_0()
{
    SoundBeep 783, 400
    SoundBeep 783, 400
    SoundBeep 783, 400
    Sleep 700
    SoundBeep 1568
    SoundBeep 1568
    SoundBeep 1568
    Sleep 7500
    Return
}

SoundAlarm_1()
{
    Loop 8
    {   ; EventAtLobby
        SoundBeep 783, 250
        Sleep 250
    }
    Sleep 2000
    Return
}

SoundAlarm(Times := 1, AlarmCat := 0)
{
    If (Times == -1)
        While (1)
        {
            SelectAlarm(AlarmCat)
        }
        Else
            Loop Times
            {
                SelectAlarm(AlarmCat)
            }
    Return
}

SelectAlarm(AlarmCat := 0)
{
    If (AlarmCat == 1)
        SoundAlarm_1()
    Else ; Cat_0    ; Default
        SoundAlarm_0()
    Return
}


Entsenden(FindX, FindY, Times)
{
    Sleep 3000
    Loop Times
    {
        ActTaimanin_Click(FindX, FindY)
        ; Click, %FindX%, %FindY% 0
        ; Sleep 100
        ; Click
        Sleep 1000
    }
    fnWriteLog("Process", "Gruppe entsendet.")
    Return
}


Entsendung_Search()
{
    try
    {
        searchResult := ImageSearch(&FindX, &FindY, 1920, 256, 2328, 1440, "*32 " A_WorkingDir "\ImageSearch\Entsendung_Fin.png")
        if (searchResult) {
            Entsenden(FindX, FindY, 4)
            return 0
        }
        else
        {
            searchResult := ImageSearch(&FindX, &FindY, 1920, 256, 2328, 1440, "*32 " A_WorkingDir "\ImageSearch\Entsendung_Einstellen.png")
            if (searchResult) {
                Entsenden(FindX, FindY, 2)
                return 0
            }
            else
            {
                return 1
            }
        }
    }
    catch Error as err
    {
        fnWriteLog("Error", "Entsenden: ImageSearch Crashed! " err)
        Return 4
    }
    Sleep 500
}

RunEntsendung(Error_Local)
{
    ;========================= - Factory - =========================;
    ;  Before: Main_Menu
    ;  After: Main_Menu, Factory_Issue_Done
    ;           ----------- BLOCK_TIME = 132s -----------           ;
    Error_Local := 0
    ;------------------ = Training Facility = ------------------;
    ;        ---------- BLOCK_TIME = 59500 ms ----------        ;
    If (Check_Main_Menu(0) > 0)
    {
        ; FIXME: Gosub SoundAlarm
        Error_Local += 1
    }

    ; Factory_Menu  2500
    ; FIXME: Gosub, Factory_Menu

    ; Factory_Entsendung
    Click 200, 800 0
    Sleep 100
    Click
    Sleep 300
    Click 200, 800 0
    Sleep 100
    Click

    Sleep 2000

    Loop 3     ; 3
    {
        Entsendung_Found := Entsendung_Search()
        If (Entsendung_Found == 4)
            Return 4
    }

    Click 1200, 800 0
    Sleep 100
    Loop 15    ; 10
    {
        ; FIXME: Click WheelDown
        Sleep 100
    }
    Sleep 500

    Loop 2
    {
        Entsendung_Found := Entsendung_Search()
        If (Entsendung_Found == 4)
            Return 4

    }

    returnToHomePage(0)
    Return Error_Local
}


Run_Sakusen_Kaigi()
{
    ; FIXME: IniRead Kaigi_Last, ActTaimanin_Config.ini, Process, Kaigi_Last, 0
    Time_Now := A_Now
    ; FIXME: Time_Now -= Kaigi_Last, Hours
    If (Time_Now >= 24)
    {
        E_Level := Sakusen_Kaigi(0)
        If (E_Level == 0)
        {
            fnWriteLog("Process", "New Sakusen_Kaigi started.")
            Time_Now := A_Now
            SaveIniConfig(Time_Now, "Kaigi_Last", "Process")
        }
    }
    Return
}

Sakusen_Kaigi(Error_Loacl)
{
    ; FIXME: Gosub, Factory_Menu
    Sleep 2300
    ActTaimanin_Click(152, 720)
    Sleep 300
    ActTaimanin_Click(152, 720)
    Sleep 500
    E_Level := searchAndWait(5000, 500, "Conference_Menu.png", 1440, 800, 1650, 1100)
    If (E_Level == 0)
    {
        Sleep 1000
        ; FIXME: ImageSearch, , , 2128, 1128, 2560, 1400, *32 %A_WorkingDir%\ImageSearch\Conference_Stop.png
        If 1 ; FIXME: (ErrorLevel == 0)
        {
            Flag := 1
        }
        Else If 1 ; FIXME: (ErrorLevel == 1)
        {
            ActTaimanin_Click(2312, 1240)
            Sleep 1400
            ActTaimanin_Click(2312, 1240)
            Sleep 400
            ActTaimanin_Click(2312, 1240)
            Sleep 1400
            ActTaimanin_Click(2312, 1240)
            Sleep 1400
            ActTaimanin_Click(2332, 200)
            Sleep 400
            ActTaimanin_Click(2332, 200)
            Sleep 400
            ActTaimanin_Click(2128, 1408)
            Sleep 400
            ActTaimanin_Click(2128, 1408)
            Sleep 2000
            ; FIXME: ImageSearch, , , 2128, 1128, 2560, 1400, *32 %A_WorkingDir%\ImageSearch\Conference_Stop.png
            If 0 ; FIXME: (ErrorLevel == 0)
                Flag := 0
            Else
                Flag := 1
        }
        Else ;If (ErrorLevel == 2)
            Flag := 2

    }
    Else
        Flag := 2

    returnToHomePage(0)
    Return Flag
}


Game_Refresh_Title()
{
    Error_Local := 0
    fnWriteLog("System", "Game Status Refreshing by Returning to Title...")
    If (Check_Main_Menu(0) > 0)
    {
        SoundAlarm(-1)
        Return 100
    }
    ActTaimanin_Click(2448, 150)
    Sleep 1000
    E_Level := searchAndWait(2000, 500, "F10_Locating.png", 1500, 450, 2000, 1000)
    ; FIXME: ImageSearch, FindX, FindY, 1500, 450, 2000, 1000, *32 %A_WorkingDir%\ImageSearch\F10_Locating.png
    If 1 ; FIXME: (ErrorLevel == 0)
        click , , 0 ; TODO: remove this line, it's temp...
    ; FIXME: ActTaimanin_Click(FindX, FindY, 0)
    Else
        ActTaimanin_Click(2448, 150, 0)
    ActTaimanin_WheelDown()
    Sleep 1000
    E_Level := searchAndWait(2000, 500, "F10_Return_to_Title.png", 1500, 1100, 2000, 1400)
    ; FIXME: ImageSearch, FindX, FindY, 1500, 1100, 2000, 1400, *32 %A_WorkingDir%\ImageSearch\F10_Return_to_Title.png
    If 1 ; FIXME: (ErrorLevel == 0)
        ActTaimanin_Click(0, 0)  ; FIXME: (FindX, FindY)
    Else
        ActTaimanin_Click(1800, 1260)

    E_Level := searchAndWait(2000, 500, "YesButton.png", 1100, 900, 1900, 1200)
    ActTaimanin_Click(1600, 1040)
    Sleep 25000
    ; Returning to Title
    ActTaimanin_Click(1600, 1040)
    Sleep 20000

    If (Check_Main_Menu(0) > 0)
    {
        SoundAlarm()
        Return 100
    }
    fnWriteLog("System", "Game Status Refreshed.")
    Return 0
}


Factory_Menu()
{
    If (Check_Main_Menu(0) > 0)
    {
        SoundAlarm()
        Error_Loacl := Error_Loacl + 1
    }
    ; 2500ms
    ActTaimanin_Click(140, 1400, 1, 200)
    Sleep 2300
    Return
}

ActTaimanin_Click(posX, posY, Times := 1, Sleep_Time := 100)
{
    Coord := CoordTransfer(posX, posY)

    Click Coord.X, Coord.Y 0

    Loop Times
    {
        Sleep Sleep_Time
        Click
    }
}

ActTaimanin_WheelDown(Times := 10, Sleep_Time := 100)
{
    Loop Times
    {
        Click "WheelDown"
        Sleep Sleep_Time
    }
    Return
}

ClickVoid()      ;   ---------- BLOCK_TIME = 100 ms ----------   ;
{
    ActTaimanin_Click(2544, 288)
    Return
}

ClickRTB()
{
    ActTaimanin_Click(410, 110)
    Return
}

ClickEnter()
{
    ActTaimanin_Click(2250, 1380)
    ; ActTaimanin_Click(2128, 1408)
    ; Click, 2048, 1408 0
    Return
}

ClickRedoMission()
{
    ActTaimanin_Click(2000, 1408)
    Return
}

CoordTransfer(posX, posY, resX := 1600, resY := 900, fromX := 2560, fromY := 1440)
{
    ; 2560 x 1440:
    Coord := Object()
    Coord.X := posX * resX / fromX
    Coord.Y := posY * resY / fromY
    return Coord
}
;===================== - HotKeys Setting - =====================;
;            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⡀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀
;            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⣼⣿⣿⣦⡀⠀⠀⠀⠀⠀
;            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⢸⣿⣿⡟⢰⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀
;            ⠀ ⠀⠀⠀ ⠀⠀⢰⣿⠿⢿⣦⣀⠀⠘⠛⠛⠃⠸⠿⠟⣫⣴⣶⣾⡆⠀⠀⠀
;            ⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⡀⠀⠉⢿⣦⡀⠀⠀⠀⠀⠀⠀⠛⠿⠿⣿⠃⠀⠀⠀
;            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣦⠀⠀⠹⣿⣶⡾⠛⠛⢷⣦⣄⠀⠀⠀⠀⠀⠀⠀
;            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣧⠀⠀⠈⠉⣀⡀⠀⠀⠙⢿⡇⠀⠀⠀⠀⠀⠀
;            ⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡿⠟⠋⠀⠀⢠⣾⠟⠃⠀⠀⠀⢸⣿⡆⠀⠀⠀⠀⠀
;            ⠀⠀⠀⠀⢀⣠⣶⡿⠛⠉⠀⠀⠀⠀⠀⣾⡇⠀⠀⠀⠀⠀⢸⣿⠇⠀⠀⠀⠀⠀
;            ⠀⢀⣠⣾⠿⠛⠁⠀⠀⠀⠀⠀⠀⠀⢀⣼⣧⣀⠀⠀⠀⢀⣼⠇⠀⠀⠀⠀⠀⠀
;            ⠀⠈⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡿⠋⠙⠛⠛⠛⠛⠛⠁⠀⠀⠀⠀⠀⠀⠀
;            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣾⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
;            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢾⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
;---------------------- = Other Hotkeys = ----------------------;
Joy7::
~p::
{
    ; Click_Skip()
    ClickRedoMission()
}

Click_Skip()
{
    ActTaimanin_Click(2448, 150)
    Return
}
~\::
~'::
XButton2::
{
    ClickRedoMission()
    return
}

~q::
{
    ClickRTB()
    return
}

EnterButton()
{
    Maus_X := 0
    Maus_Y := 0
    MouseGetPos &Maus_X, &Maus_Y
    ClickEnter()
    Click Maus_X, Maus_Y, 0
    ActiveRecord()
    Return
}

~Up::
{
    Wheel_Up(15)
    Return
}

~Down::
{
    ActTaimanin_WheelDown(Times := 15, Sleep_Time := 50)
    Return
}


Wheel_Up(Times := 5)
{
    Loop Times
    {
        ; FIXME: Click WheelUp 2
        Sleep 50
    }
    Return
}
Wheel_Down(Times := 5)
{
    Loop Times
    {
        ; FIXME: Click, WheelDown
        Sleep 50
    }
    Return
}

~Enter::
~NumpadEnter::
{
    EnterButton()
    Return
}

UntilNextLoop(Time_Last)
{
    Loop_CD := LoadIniConfig("Next_Loop", "Process")
    Time_Now := A_Now
    ; FIXME: Time_Last += Loop_CD, Seconds
    ; FIXME: EnvSub, Time_Last, %Time_Now%, Seconds
    Return Time_Last
}

UntilNextAP()
{
    Loop_CD := LoadIniConfig("AP_Last")
    Time_Now := A_Now
    ; FIXME: Time_Now -= Loop_CD, Seconds
    AP_CD := LoadIniConfig("AP_CD", "Timer")
    AP_CD -= Time_Now
    Return AP_CD
}


~^v::
{
    StatusReport()
}

StatusReport()
{
    In_Loop := 0 ; FIXME: remove it. it's temp
    If (In_Loop)
    {
        SoundBeep
        Ctrl_V := 1
        Return
    }
    Else
    {
        Time_Next := UntilNextLoop(Time_Last)
        AP_Next := UntilNextAP()
        AP_Next_Min := Floor(AP_Next / 60)
        AP_Next := Floor(AP_Next_Min / 3)
        ; FIXME: AP_Until_Next := Floor(Loop_Num_no_AP - Loop_Fin) * 60
        If (AP_Until_Next < 0)
            AP_Until_Next := 0
        AP_Until_Next += AP_Next
        If (Time_Next > 10)
            MsgBox_TimeOut := 10
        Else If (3 < Time_Next And Time_Next <= 10)
            MsgBox_TimeOut := Time_Next - 2
        Else
            MsgBox_TimeOut := 1
        ; FIXME: MsgBox "Next_Loop: " + Time_Next + " s.`nNext_AP  : " + AP_Next_Min + " Min / " + AP_Next + " AP / " + AP_Until_Next + " APs.`nAP_Loop  : " + Loop_Fin + " / " + Loop_Num_no_AP + " / " + Loop_Total, "Status:", %MsgBox_TimeOut%
        /*  ||Status:|                                                [X]
            |   Next_Loop: [Secs] s.
            |   Next_AP  : [Next_Loop] Min / [Next] AP / [Until_Next] APs.
            |   AP_Loop  : x/x/54                   ---------------------
            |                                                   [确定]
        */
        Return
    }
}

~^`::
{
    ; FIXME: UserConsole(A_ScriptName, Loop_Fin, Loop_Num_no_AP)
    click ; TODO: to be removed, temp
}

UserConsole(User, Loop_Fin, &Loop_Num_no_AP)
{   ; ByRef is replaced by & @v2
    ; global Loop_Num_no_AP
    If (User != "ActTaimanin_Autohk_Model_4.ahk")
        Return
    Txt_In_Box := "
    (
    Loop+/NoWakeUp; APE(AP_Event);
    Log/Clean; Config/Script/dir;
    TestMode/ImageSearchTest/Exit; Set_Mt
    )"
    ; FIXME: InputBox, UI_Console, Console, %Txt_In_Box%
    UI_Console := "" ; TODO: Remove it. Temp!
    If 1 ; FIXME: (ErrorLevel > 0)
        Return
    Else If (UI_Console = "Loop+" Or UI_Console = "L+")
    {
        fnWriteLog("User", "++ Loop without AP ++")
        If (Loop_Fin > Loop_Num_no_AP)
            Loop_Num_no_AP := Loop_Fin + 1
        Else
            Loop_Num_no_AP += 1
    }
    Else If (UI_Console = "NoWakeUp")
    {
        Time_Now := A_Now
        ; FIXME: IniRead Active_Last, ActTaimanin_Config.ini, Process, Time_Last, %Time_Now%
        ; FIXME: Active_Last += 7200, Seconds
        ; FIXME: IniWrite, %Active_Last%, ActTaimanin_Config.ini, Process, Active_Last
    }
    ; Else If (UI_Console = "Log")
    ; FIXME: run ActTaimanin_Log.txt
    Else If (UI_Console = "Clean")
    {
        SoundAlarm()
        File_Log := FileOpen("ActTaimanin_Log.txt", "w")
        File_Log.Close()
        SoundAlarm()
    }
    Else If (UI_Console = "Config")
        ; FIXME: run, ActTaimanin_Config.ini
        ; Else If (UI_Console = "Script")
        Edit
    Else If (UI_Console = "dir")
    {
        ; FIXME: run, "C:\Source_Code\AHK\ActTaimanin"
    }
    Else If (UI_Console = "Set_Mt" Or UI_Console = "SMt")
    {
        Set_Maintenance()
    }
    Else If (UI_Console = "TestMode")
    {
        ; FIXME: run, ActTaimanin_Autohk_Test.ahk
        ; FIXME: MsgBox, 0x121, TestMode, Initializing Test_Mode.Shut down Main_Mode ?
        ; FIXME: IfMsgBox Yes
        ExitApp
        ; FIXME: Else
        ; FIXME: Suspend On
    }
    Else If (UI_Console = "ImageSearchTest")
    {
        ; FIXME: run, ActTaimanin_Autohk_ImageSearch_Test.ahk
    }
    Else If (UI_Console = "Ini")
    {
        click  ; FIXME: TEMP, remove
        ; FIXME: InputBox, Ini_Console, Save_Ini, Fac_TW` / Send` / AP` / BP` / SP` / Kaigi` / Entsendung
        ; FIXME: Ini_Config(Ini_Console)
    }
    Else If (UI_Console = "AP_Event" Or UI_Console = "APE")
    {
        AP_Config()
    }
    Else If (UI_Console = "Exit")
        ExitApp
    Return
}


AP_Config()
{
    Txt_In_Box := "AP_Event: 0(Daily), 1, 2"
    ; FIXME: InputBox, AP_Console, Console: AP, %Txt_In_Box%
    If 1 ; FIXME: (AP_Console == 0)
    {
        SaveIniConfig(0, "AP_Event", "Quests")
        SaveIniConfig(1, "AP_DlM", "Quests")
    }
    Else If 0 ; FIXME: (AP_Console == 1 Or AP_Console == 2)
    {
        ; FIXME: SaveIniConfig(AP_Console, "AP_Event", "Quests")
        SaveIniConfig(0, "AP_DlM", "Quests")
    }

}


Ini_Config(Ini_Console)
{
    Time_Now := A_Now
    If (Ini_Console = "Fac_T_LR" Or Ini_Console = "Fac_T")
        SaveIniConfig(Time_Now, "Fac_T_LR")
    Else If (Ini_Console = "Fac_W_LR" Or Ini_Console = "Fac_W")
        SaveIniConfig(Time_Now, "Fac_W_LR")
    Else If (Ini_Console = "Send" Or Ini_Console = "Send_Last")
        SaveIniConfig(Time_Now, "Send_Last", "Process")
    Else If (Ini_Console = "AP" Or Ini_Console = "AP_Last")
        SaveIniConfig(Time_Now, "AP_Last")
    Else If (Ini_Console = "BP" Or Ini_Console = "BP_Last")
        SaveIniConfig(Time_Now, "BP_Last")
    Else If (Ini_Console = "BP+")
    {
        New_BP_Last := LoadIniConfig("BP_Last", Ini_Default := A_Now)
        While (New_BP_Last < A_Now)
        {
            ; FIXME: New_BP_Last += 1, Hours
            click ; TODO: TEMP, remove!
        }
        New_BP_Last -= 010000 ; 1, Hours    ; EnvSub/-= ,hours 只能用来做时间之间的差值，以hours为结果，不能做减去时间长度
        ; EnvSub, New_BP_Last, 1, Hours
        ; New_BP_Last -= 1, Hours
        SaveIniConfig(New_BP_Last, "BP_Last")
    }
    Else If (Ini_Console = "SP" Or Ini_Console = "SP_Last")
        SaveIniConfig(Time_Now, "SP_Last")
    Else If (Ini_Console = "Entsenden" Or Ini_Console = "Entsendung")
        SaveIniConfig(Time_Now, "Entsendung_Last")
    Else If (Ini_Console = "Kaigi" Or Ini_Console = "Kaigi_Last")
        SaveIniConfig(Time_Now, "Kaigi_Last", "Process")
    Return
}


XButton1::
{
    Send "{Esc}"
    ActiveRecord()
    Return
}

~F5::
{
    ; Suspend Off
    If 0 ; FIXME: (Is_Running AND A_ScriptName == "ActTaimanin_Autohk_Model_4.ahk")
    {
        fnWriteLog("User", "KeyboardInterrupt"
            , "`n--------------------------------------------------")
    }
    ; FIXME:
    ; If (File_Log)
    ;     File_Log.Close()
    SoundBeep 789
    Sleep 200
    SoundBeep 523
    Reload
    Sleep 500
    SoundAlarm()
    Return
}