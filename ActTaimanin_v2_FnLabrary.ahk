#Requires AutoHotkey v2.0

#HotIf WinActive("ahk_exe RelicCoH2.exe")


Return

#HotIf WinActive("ahk_exe ActionTaimanin.exe")
;====================== - Sub Functions - ======================;
searchAndWait(searchDuration, searchInterval, filename, X1 := 0, Y1 := 0, X2 := 2573, Y2 := 1498, writeLog := 1)
{
    If (searchInterval == 0 Or searchDuration == 0)
        S_Loop := 1
    Else
        S_Loop := Ceil(searchDuration / searchInterval)
    Loop S_Loop
    {
        try
        {
            if ImageSearch(&foundX, &foundY, X1, Y1, X2, Y2, "*32 *TransBlack %A_WorkingDir%\ImageSearch\%filename%")
                return 0
            else
                Sleep searchInterval
        }
        catch as err {
            Log_Text := "Image_Search_and_Wait Crashed: " . filename
            Log_Text := Log_Text . "."
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
    searchResult := searchAndWait(2000, 500, "Lobby_Event.png", 1400, 128, 2200, 384, 0)
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
    WinActivate, ActionTaimanin ahk_class UnityWndClass
    Gosub, ClickRTB
    Sleep 500
    Loop 7
    {
        Click, 1280, 128 0
        E_Level := searchAndWait(1000, 250, "Menu_Main_0.png", 0, 0, 512, 128, 0)
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
            Send { Esc }
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
    Click, 1120, 1088 0       ;
    Sleep 100              ;
    Click                   ;
    Sleep 300
    Gosub ClickVoid                 ; 100 ms
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
    ImageSearch, , , 0, 0, 512, 128
        , *32 * TransBlack %A_WorkingDir%\ImageSearch\Menu_Main_0.png
    If (ErrorLevel == 0)
        Return 0
    If (ErrorLevel == 1) {
        Error_Global += 1
        If (Error_Global >= 5) {
            fnWriteLog("Error", "Unable to locate Main_Menu!")
            Return Error_Global
        }

        Error_Global += BackToMain()
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


fnWriteLog(Log_Kata, Log_Lines*)
{
    If (A_ScriptName == "ActTaimanin_Autohk_Model_4.ahk")
        File_Log := FileOpen("ActTaimanin_Log.txt", "a -wd")
    Else If (A_ScriptName == "ActTaimanin_Autohk_Test.ahk")
        File_Log := FileOpen("ActTaimanin_Log_TestMode.txt", "a -wd")
    If (!File_Log)
    {
        MsgBox "Fail to Open Log File!"
        Return
    }

    FormatTime, Text, , [yyyy.MM.dd - HH: mm: ss]
    Log_Kata := Log_Kata . ": "
    StrLine := Text . Log_Kata

    For index, Log_L in Log_Lines {
        StrLine := StrLine . Log_L
    }

    File_Log.WriteLine(StrLine)
    File_Log.Close()

    Return
}


LoadConfig:
    IniRead, Taimanin_F1, ActTaimanin_Config.ini, Factory, Taimanin_F1, %Taimanin_F1%
    IniRead, Taimanin_F2, ActTaimanin_Config.ini, Factory, Taimanin_F2, -1  ; %Taimanin_F2%
    IniRead, Weapon_1Y, ActTaimanin_Config.ini, Factory, Weapon_1Y, %Weapon_1Y%
    IniRead, Weapon_1X, ActTaimanin_Config.ini, Factory, Weapon_1X, %Weapon_1X%
    IniRead, Weapon_2Y, ActTaimanin_Config.ini, Factory, Weapon_2Y, %Weapon_2Y%
    IniRead, Weapon_2X, ActTaimanin_Config.ini, Factory, Weapon_2X, %Weapon_2X%
    IniRead, Weapon_3Y, ActTaimanin_Config.ini, Factory, Weapon_3Y, %Weapon_3Y%
    IniRead, Weapon_3X, ActTaimanin_Config.ini, Factory, Weapon_3X, %Weapon_3X%
    ;
    IniRead, AP_DlM, ActTaimanin_Config.ini, Quests, AP_DlM, %AP_DlM%
    IniRead, AP_Event, ActTaimanin_Config.ini, Quests, AP_Event, %AP_Event%
    IniRead, AP_Exp, ActTaimanin_Config.ini, Quests, AP_Exp, %AP_Exp%
    IniRead, BP_SpR, ActTaimanin_Config.ini, Quests, BP_SpR, %BP_SpR%
    IniRead, BP_Ldr, ActTaimanin_Config.ini, Quests, BP_Ldr, %BP_Ldr%
    ;
    IniRead, AP_Time, ActTaimanin_Config.ini, Timer, AP_Time, %AP_Time%
    IniRead, BA_Time, ActTaimanin_Config.ini, Timer, BA_Time, %BA_Time%
    ;
    IniRead, Loop_Total, ActTaimanin_Config.ini, Process, Loop_Total, %Loop_Total%
    IniRead, Time_Last, ActTaimanin_Config.ini, Process, Time_Last, %Time_Last%
    IniRead, TimeZone, ActTaimanin_Config.ini, Process, TimeZone, 2
    IniRead, UseWemod, ActTaimanin_Config.ini, Process, Wemod, 0
    Return


    LoadIniConfig(Ini_Key, Ini_Section := "Actives", Ini_File := "ActTaimanin_Config.ini", Ini_Default := 0)
    {
        IniRead, Ini_Config, %Ini_File%, %Ini_Section%, %Ini_Key%, %Ini_Default%
        ; MsgBox, %Ini_Key%: %Ini_Config%
        Return Ini_Config
    }

    SaveIniConfig(Ini_Value, Ini_Key, Ini_Section := "Actives", Ini_File := "ActTaimanin_Config.ini")
    {
        IniWrite, %Ini_Value%, %Ini_File%, %Ini_Section%, %Ini_Key%
    }


    Act_CD_Check(Last_Run := 0, Time_CD := 10800)
    {   ; Time_CD: Seconds
        Time_Now := A_Now
        Time_Now -= Last_Run, Seconds
        ; MsgBox, %Time_Now%
        If (Time_Now >= Time_CD)
        {
            ; MsgBox, CD_Check:1
            Return 1
        }
        Else
        {
            ; MsgBox, CD_Check:0
            Return 0
        }
    }


    ActiveRecord()
    {
        Active_Last := LoadIniConfig("Active_Last", "Process", , Ini_Default := Time_Last)
        Time_Now := A_Now
        Active_Last -= Time_Now, Seconds
        If (Active_Last < 0)
            SaveIniConfig(Time_Now, "Active_Last", "Process")
        Return
    }

WakeUpSequence:
    WinActivate, ActionTaimanin ahk_class UnityWndClass
    Gosub ClickRTB
    Maintenance_From := LoadIniConfig("Maintenance_From", "Process")
    Maintenance_Until := LoadIniConfig("Maintenance_Until", "Process")
    TimeZone := LoadIniConfig("TimeZone", "Process", , Ini_Default := 2)
    Maintenance_From += TimeZone, Hours
    Maintenance_Until += TimeZone, Hours
    While (Maintenance_Until > A_Now AND Maintenance_From < A_Now)
    {
        fnWriteLog("System", "Wake Up during Server Maintenance.")
        Sleep 3600000  ; 3600s, not 3600 ms !
    }
    Error_Total += BackToMain(0)
    CLE_Until := LoadIniConfig("No_CLE_Until")
    CD_Check := Act_CD_Check(CLE_Until, 0)
    If (CD_Check)
        CheckLobbyEvent()
    Return

WakeUpSequence_0:   ;   ---------- BLOCK_TIME = 22s ----------    ;
    WinActivate, ActionTaimanin ahk_class UnityWndClass
    Sleep 500
    Gosub ClickVoid
    IniRead, Maintenance_From, ActTaimanin_Config.ini, Process, Maintenance_From
    IniRead, Maintenance_Until, ActTaimanin_Config.ini, Process, Maintenance_Until
    IniRead, TimeZone, ActTaimanin_Config.ini, Process, TimeZone, 2
    Maintenance_From += TimeZone, Hours
    Maintenance_Until += TimeZone, Hours
    If (Maintenance_Until > A_Now AND Maintenance_From < A_Now)
    {
        fnWriteLog("System", "Wake Up during Server Maintenance.")
        Sleep 18000
        SoundAlarm(-1)
    }
    Else
    {
        Error_Total += BackToMain(0)
        Send_Last := 0
        IniRead, Send_Last, ActTaimanin_Config.ini, Process, Send_Last, 0
        If (Send_Last)
        {
            Time_Now := A_Now
            Send_Last += 12, Hours
            Send_Last -= Time_Now, Seconds   ; 现在到本次Send的理论时间点的剩余时间
            If (Send_Last > 0 AND Send_Last > 600)
            {   ;   距离下次送FP时间超过10分钟，则执行特殊任务
                SpecialMode()
            }
        }
        Send { F3 }
        Error_Total += BackToMain(0)        ; 1s+
        CheckLobbyEvent()
        RunEntsendung(0)
        Run_Sakusen_Kaigi()
        fnWriteLog("System", "Waked Up.`n")
    }
    Return


RunningCheck:           ;   -------- BLOCK_TIME = 4s --------   ;
    WeMod_Check()
    Return

    WeMod_Check()
    {
        WinActivate, WeMod ahk_class Chrome_WidgetWin_1
        Send { F3 }
        Sleep 1000
        Click, 1000, 100 0
        ; Check F3
        E_Level := searchAndWait(2000, 400, "WeMod_Switch_2.png", 136, 376, 1632, 768)
        ;ImageSearch, FindX, FindY, 136, 376, 1632, 768, *32 %A_WorkingDir%\ImageSearch\WeMod_Switch_2.png
        If (E_Level == 1)
        {
            FindX = 260
            FindY = 570
        }
        If (E_Level == 2)
        {
            fnWriteLog("Error", "WeMod: ImageSearch Crashed!")
        }
        Sleep 500
        PixelSearch, , , FindX, FindY, (FindX + 700), (FindY + 150), 0x0298c1, 32, Fast RGB
        If (ErrorLevel == 0) {      ; If (WeMod_Cheat_3 == On)
            Send { F3 }
            Sleep 2000
        }
        Else
        {
            Send { F3 }
            Sleep 1000
            PixelSearch, , , FindX, FindY, (FindX + 700), (FindY + 150), 0x0298c1, 32, Fast RGB
            If (ErrorLevel == 0) {      ; If (WeMod_Cheat_3 == On)
                Send { F3 }
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
        PixelSearch, , , FindX, (FindY + 150), (FindX + 700), (FindY + 180), 0x0298c1, 32, Fast RGB
        If (ErrorLevel == 0) {      ; If (WeMod_Cheat_4 == On)
            Send { F7 }
        }   ; EndIf(WeMod_Cheat_4)    Post: WeMod_Cheat_4 := Off
        WinActivate, ActionTaimanin ahk_class UnityWndClass
        Sleep 2000
        Return
    }


    Set_Maintenance()
    {
        IniRead, Maintenance_From, ActTaimanin_Config.ini, Process, Maintenance_From
        While (Maintenance_From < A_Now)
        {
            Maintenance_From += 7, Days
        }
        Maintenance_Until := Maintenance_From
        Maintenance_Until += 4, Hours
        Maintenance_Until += 30, Minutes
        IniWrite, %Maintenance_From%, ActTaimanin_Config.ini, Process, Maintenance_From
        IniWrite, %Maintenance_Until%, ActTaimanin_Config.ini, Process, Maintenance_Until
        Return
    }


SoundAlarm:
    SoundBeep 783, 400
    SoundBeep 783, 400
    SoundBeep 783, 400
    Sleep 700
    SoundBeep 1568
    SoundBeep 1568
    SoundBeep 1568
    Sleep 7500
    Return

SoundAlarm_1:
    Loop 8
    {   ; EventAtLobby
        SoundBeep 783, 250
        Sleep 250
    }
    Sleep 2000
    Return

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
            Gosub SoundAlarm_1
        Else ; Cat_0    ; Default
            Gosub SoundAlarm
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
        ImageSearch, FindX, FindY, 1920, 256, 2328, 1440, *32 %A_WorkingDir%\ImageSearch\Entsendung_Fin.png
        If (ErrorLevel == 0) {
            Entsenden(FindX, FindY, 4)
            Return 0
        }
        Else If (ErrorLevel == 1)
        {
            ImageSearch, FindX, FindY, 1920, 256, 2328, 1440, *32 %A_WorkingDir%\ImageSearch\Entsendung_Einstellen.png
            If (ErrorLevel == 0) {
                Entsenden(FindX, FindY, 2)
                Return 0
            }
        }
        Else ; If (ErrorLevel == 2)
        {
            fnWriteLog("Error", "Entsenden: ImageSearch Crashed!")
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
            Gosub SoundAlarm
            Error_Local ++
        }

        ; Factory_Menu  2500
        Gosub, Factory_Menu

        ; Factory_Entsendung
        Click, 200, 800 0
        Sleep 100
        Click
        Sleep 300
        Click, 200, 800 0
        Sleep 100
        Click

        Sleep 2000

        Loop 3     ; 3
        {
            Entsendung_Found := Entsendung_Search()
            If (Entsendung_Found == 4)
                Return 4
        }

        Click, 1200, 800 0
        Sleep 100
        Loop 15    ; 10
        {
            Click, WheelDown
            Sleep 100
        }
        Sleep 500

        Loop 2
        {
            Entsendung_Found := Entsendung_Search()
            If (Entsendung_Found == 4)
                Return 4

        }

        BackToMain(0)
        Return Error_Local
    }


    Run_Sakusen_Kaigi()
    {
        IniRead, Kaigi_Last, ActTaimanin_Config.ini, Process, Kaigi_Last, 0
        Time_Now := A_Now
        Time_Now -= Kaigi_Last, Hours
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
        Gosub, Factory_Menu
        Sleep 2300
        ActTaimanin_Click(152, 720)
        Sleep 300
        ActTaimanin_Click(152, 720)
        Sleep 500
        E_Level := searchAndWait(5000, 500, "Conference_Menu.png", 1440, 800, 1650, 1100)
        If (E_Level == 0)
        {
            Sleep 1000
            ImageSearch, , , 2128, 1128, 2560, 1400, *32 %A_WorkingDir%\ImageSearch\Conference_Stop.png
            If (ErrorLevel == 0)
            {
                Flag := 1
            }
            Else If (ErrorLevel == 1)
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
                ImageSearch, , , 2128, 1128, 2560, 1400, *32 %A_WorkingDir%\ImageSearch\Conference_Stop.png
                If (ErrorLevel == 0)
                    Flag := 0
                Else
                    Flag := 1
            }
            Else ;If (ErrorLevel == 2)
                Flag := 2

        }
        Else
            Flag := 2

        BackToMain(0)
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
        ImageSearch, FindX, FindY, 1500, 450, 2000, 1000, *32 %A_WorkingDir%\ImageSearch\F10_Locating.png
        If (ErrorLevel == 0)
            ActTaimanin_Click(FindX, FindY, 0)
        Else
            ActTaimanin_Click(2448, 150, 0)
        ActTaimanin_WheelDown()
        Sleep 1000
        E_Level := searchAndWait(2000, 500, "F10_Return_to_Title.png", 1500, 1100, 2000, 1400)
        ImageSearch, FindX, FindY, 1500, 1100, 2000, 1400, *32 %A_WorkingDir%\ImageSearch\F10_Return_to_Title.png
        If (ErrorLevel == 0)
            ActTaimanin_Click(FindX, FindY)
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
            Gosub SoundAlarm
            Return 100
        }
        fnWriteLog("System", "Game Status Refreshed.")
        Return 0
    }


Factory_Menu:
    If (Check_Main_Menu(0) > 0)
    {
        Gosub SoundAlarm
        Error_Loacl ++
    }
    ; 2500ms
    ActTaimanin_Click(140, 1400, 1, 200)
    Sleep 2300
    Return

    ActTaimanin_Click(Coor_X, Coor_Y, Times := 1, Sleep_Time := 100)
    {
        Click, %Coor_X%, %Coor_Y% 0
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
            Click, WheelDown
            Sleep Sleep_Time
        }
        Return
    }

ClickVoid:      ;   ---------- BLOCK_TIME = 100 ms ----------   ;
    ActTaimanin_Click(2544, 288)
    Return

ClickRTB:
    ActTaimanin_Click(410, 110)
    Return

ClickEnter:
    ActTaimanin_Click(2155, 1408)
    ; ActTaimanin_Click(2128, 1408)
    ; Click, 2048, 1408 0
    Return

ClickRedoMission:
    ActTaimanin_Click(2000, 1408)
    Return

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
Click_Skip:
    ActTaimanin_Click(2448, 150)
    Return

    ~\::
    ~'::
    Gosub, ClickRedoMission
    Return

    ~q::
    Gosub, ClickRTB
    Return


    EnterButton()
    {
        MouseGetPos, Maus_X, Maus_Y
        Gosub, ClickEnter
        Click, %Maus_X%, %Maus_Y%, 0
        ActiveRecord()
        Return
    }

    ~Up::
    Wheel_Up(15)
    Return

    ~Down::
    ActTaimanin_WheelDown(Times := 15, Sleep_Time := 50)
    Return


    Wheel_Up(Times := 5)
    {
        Loop Times
        {
            Click, WheelUp 2
            Sleep 50
        }
        Return
    }
    Wheel_Down(Times := 5)
    {
        Loop Times
        {
            Click, WheelDown
            Sleep 50
        }
        Return
    }

    ~Enter::
    ~NumpadEnter::
    EnterButton()
    Return


    UntilNextLoop(Time_Last)
    {
        Loop_CD := LoadIniConfig("Next_Loop", "Process")
        Time_Now := A_Now
        Time_Last += Loop_CD, Seconds
        EnvSub, Time_Last, %Time_Now%, Seconds
        Return Time_Last
    }

    UntilNextAP()
    {
        Loop_CD := LoadIniConfig("AP_Last")
        Time_Now := A_Now
        Time_Now -= Loop_CD, Seconds
        AP_CD := LoadIniConfig("AP_CD", "Timer")
        AP_CD -= Time_Now
        Return AP_CD
    }


    ~^v::
StatusReport:
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
        AP_Until_Next := Floor(Loop_Num_no_AP - Loop_Fin) * 60
        If (AP_Until_Next < 0)
            AP_Until_Next := 0
        AP_Until_Next += AP_Next
        If (Time_Next > 10)
            MsgBox_TimeOut := 10
        Else If (3 < Time_Next And Time_Next <= 10)
            MsgBox_TimeOut := Time_Next - 2
        Else
            MsgBox_TimeOut := 1
        MsgBox, , Status:, Next_Loop: %Time_Next% s.`nNext_AP: %AP_Next_Min% Min` / %AP_Next% AP` / %AP_Until_Next% APs.`nAP_Loop: %Loop_Fin%` / %Loop_Num_no_AP%` / %Loop_Total%, %MsgBox_TimeOut%
        /*  ||Status:|                                                [X]
            |   Next_Loop: [Secs] s.
            |   Next_AP  : [Next_Loop] Min / [Next] AP / [Until_Next] APs.
            |   AP_Loop  : x/x/54                   ---------------------
            |                                                   [确定]
        */
        Return
    }


    ~^`::
    UserConsole(A_ScriptName, Loop_Fin, Loop_Num_no_AP)
    Return

    UserConsole(User, Loop_Fin, ByRef Loop_Num_no_AP)
    {
        ; global Loop_Num_no_AP
        If (User != "ActTaimanin_Autohk_Model_4.ahk")
            Return
        Txt_In_Box := "
    (
    Loop+/NoWakeUp; APE(AP_Event);
    Log/Clean; Config/Script/dir;
    TestMode/ImageSearchTest/Exit; Set_Mt
    )"
        InputBox, UI_Console, Console, %Txt_In_Box%
        If (ErrorLevel > 0)
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
            IniRead, Active_Last, ActTaimanin_Config.ini, Process, Time_Last, %Time_Now%
            Active_Last += 7200, Seconds
            IniWrite, %Active_Last%, ActTaimanin_Config.ini, Process, Active_Last
        }
        Else If (UI_Console = "Log")
            run ActTaimanin_Log.txt
        Else If (UI_Console = "Clean")
        {
            Gosub SoundAlarm
            File_Log := FileOpen("ActTaimanin_Log.txt", "w")
            File_Log.Close()
            Gosub SoundAlarm
        }
        Else If (UI_Console = "Config")
            Run, ActTaimanin_Config.ini
        Else If (UI_Console = "Script")
            Edit
        Else If (UI_Console = "dir")
        {
            Run, "C:\Source_Code\AHK\ActTaimanin"
        }
        Else If (UI_Console = "Set_Mt" Or UI_Console = "SMt")
        {
            Set_Maintenance()
        }
        Else If (UI_Console = "TestMode")
        {
            Run, ActTaimanin_Autohk_Test.ahk
            MsgBox, 0x121, TestMode, Initializing Test_Mode.Shut down Main_Mode ?
                IfMsgBox Yes
                ExitApp
                Else
                    Suspend On
                    }
            Else If (UI_Console = "ImageSearchTest")
            {
                Run, ActTaimanin_Autohk_ImageSearch_Test.ahk
            }
            Else If (UI_Console = "Ini")
            {
                InputBox, Ini_Console, Save_Ini, Fac_TW` / Send` / AP` / BP` / SP` / Kaigi` / Entsendung
                Ini_Config(Ini_Console)
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
            InputBox, AP_Console, Console: AP, %Txt_In_Box%
            If (AP_Console == 0)
            {
                SaveIniConfig(0, "AP_Event", "Quests")
                SaveIniConfig(1, "AP_DlM", "Quests")
            }
            Else If (AP_Console == 1 Or AP_Console == 2)
            {
                SaveIniConfig(AP_Console, "AP_Event", "Quests")
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
                    New_BP_Last += 1, Hours
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
        Send { Esc }
        ActiveRecord()
        Return


        ~F5::
        ; Suspend Off
        If (Is_Running AND A_ScriptName == "ActTaimanin_Autohk_Model_4.ahk")
        {
            fnWriteLog("User", "KeyboardInterrupt"
                , "`n--------------------------------------------------")
        }
        If (File_Log)
            File_Log.Close()
        SoundBeep 789
        Sleep 200
        SoundBeep 523
        Reload
        Sleep 500
        Gosub SoundAlarm
        Return