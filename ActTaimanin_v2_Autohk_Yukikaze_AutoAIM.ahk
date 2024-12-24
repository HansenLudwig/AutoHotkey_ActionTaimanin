#Requires AutoHotkey v2.0

CoordMode "Mouse", "Window"
SendLevel 0
#InputLevel 1

return

#HotIf WinActive("ahk_exe ActionTaimanin.exe")

SpecialMode()
{
    resolution := "1600x900"
    ; Menu_Quests(0)
    Filename1 := "QuestMenu_SpMode_Ready.png"
    Filename2 := "SpM_Yukikaze.png"
    Filename3 := "SpM_Yukikaze_Change.png"
    foundX := 0
    foundY := 0
    coord1 := CoordTransfer(40, 132, 2560, 1440)
    coord2 := CoordTransfer(360, 750, 2560, 1440)
    coord3 := CoordTransfer(650, 150, 2560, 1440)
    coord4 := CoordTransfer(750, 235, 2560, 1440)
    coord5 := CoordTransfer(1300, 300, 1600, 900)
    coord6 := CoordTransfer(1700, 700, 1600, 900)
    Loop 5
    {
        errorLevel1 := ImageSearch(&foundX, &foundY, coord1.X, coord1.Y, coord2.X, coord2.Y, "*32 *TransBlack " A_WorkingDir "\ImageSearch\" resolution "\" Filename1)
        if (errorLevel1)
        {
            ActTaimanin_Click(320, 800, 0)
            Loop 5
            {
                errorLevel2 := ImageSearch(&foundX, &foundY, coord3.X, coord3.Y, coord4.X, coord4.Y, "*32 *TransBlack " A_WorkingDir "\ImageSearch\" resolution "\" Filename2)
                If (errorLevel2)
                {
                    ActTaimanin_Click(2048, 1408, 0)
                    Sleep 5000
                    YukikazeShooting()
                    Return 0
                }
                Else
                    Sleep 500
            }
            ; If Not found:
            SoundBeep 720, 500
            If (A_Hour < 1 OR A_Hour > 7)
            {   ; 手动取消了SpM切换，因为无切换库存的功能未能实现
                Send "{Esc}"
                Sleep 500
                Send "{Esc}"
                Return 1
            }
            ActTaimanin_Click(890, 1010)
            Sleep 2000
            Loop 5
            {
                errorLevel2 := ImageSearch(&foundX, &foundY, coord5.X, coord5.Y, coord6.X, coord6.Y, "*32 *TransBlack " A_WorkingDir "\ImageSearch\" resolution "\" Filename3)
                if (errorLevel2)
                {
                    ActTaimanin_Click(1500, 700)
                    Sleep 500
                    ActTaimanin_Click(2048, 1408)
                    Sleep 1000
                    ; Log_Write("SpMode", "SpMode switched.")
                    ActTaimanin_Click(1500, 1040)
                    Sleep 1000
                    ActTaimanin_Click(2048, 1408)
                    Sleep 5000
                    YukikazeShooting()
                    Return 0
                }
                else {
                    Sleep 500
                }
            }
            Send "{Esc}"
            Return 1
        }
        else
            Sleep 500
    }
    Return 1
}

~^8::
NumpadMult::
{
    YukikazeShooting()
}
YukikazeShooting()
{
    WinActivate("ActionTaimanin")
    Sleep 500

    ;====================== - Timer Setting - ======================;
    SearchRate := 400
    SearchRate := SearchRate / 2
    ;===============================================================;
    tgtArray := []
    ; ArrayCount := 0

    Loop Read, "ActTaimanin_Autohk_Yukikaze_AutoAIM_Rec.txt"
    {
        tgtArray.Push(A_LoopReadLine)
    }
    ; Log_Write("SpMode", "YukikazeShooting")

    ;Sleep 5000
    coord1 := CoordTransfer(975, 200, 2560, 1440)
    coord2 := CoordTransfer(1015, 722, 2560, 1440)
    coord3 := CoordTransfer(590, 200, 2560, 1440)
    coord4 := CoordTransfer(630, 722, 2560, 1440)
    Miss_Count := 0
    SoundBeep
    For index, element in tgtArray {
        Loop 500 {
            PixLoc_X := 0
            PixLoc_Y := 0
            If (element == 2)
            {
                pxSearchRes := PixelSearch(&PixLoc_X, &PixLoc_Y, coord1.X, coord1.Y, coord2.X, coord2.Y, 0x04fb04, 4)
                ; If (PixLoc_X) {
                If (pxSearchRes) {
                    Send "d"
                    Miss_Count := 0
                    Break
                }
            }
            Else if (element == 1)
            {
                pxSearchRes := PixelSearch(&PixLoc_X, &PixLoc_Y, coord3.X, coord3.Y, coord4.X, coord4.Y, 0x04fb04, 4)
                ; If (PixLoc_X) {
                If (pxSearchRes == 1) {
                    Send "a"
                    Miss_Count := 0
                    Break
                }
            }
            Sleep 20
        }
        Miss_Count += 1
        Sleep SearchRate
        If (Miss_Count > 2)
            Break
    }
    coord1 := CoordTransfer(1600, 1200, 2560, 1440)
    E_Level := SearchAndWait(15500, 500, "SpM_Yukikaze_Fin.png", coord1.X, coord1.Y, , , 0)
    if (E_Level)
        Sleep 500
    else
    {
        Sleep 10500
        ; Log_Write("Warning", "SpM_Yukikaze_Fin.png not found after SpM.")
    }
    ActTaimanin_Click(2240, 1408, 2, 600)
    Return
}


; ====================================================================


; CoordTransfer(posX, posY, resX := 2560, resY := 1440) ; from 2560 * 1440 to resX * resY
; {
;     ; 2560 x 1440:
;     Coord := Object()
;     Coord.X := posX * resX / 2560
;     Coord.Y := posY * resY / 1440
;     return Coord
; }
; ActTaimanin_Click(posX, posY, Times := 1, Sleep_Time := 100)
; {
;     Coord := CoordTransfer(posX, posY, 1600, 900)

;     Click Coord.X, Coord.Y 0

;     Loop Times
;     {
;         Sleep Sleep_Time
;         Click
;     }
; }
; SearchAndWait(S_Time, S_Rate, Filename, X1 := 0, Y1 := 0, X2 := 2573, Y2 := 1498, Log_W := 1)
; {
;     resolution := "1600x900"
;     If (S_Rate == 0 Or S_Time == 0)
;         S_Loop := 1
;     Else
;         S_Loop := S_Time / S_Rate
;     Loop S_Loop
;     {
;         errorLevel0 := ImageSearch(&foundX, &foundY, X1, Y1, X2, Y2, "*32 *TransBlack " A_WorkingDir "\ImageSearch\" resolution "\" Filename)
;         If (errorLevel0)
;             Return 0
;         Else
;             Sleep S_Rate
;     }

;     If (Log_W)
;     {
;         Log_Text := "Image_Search_and_Wait Time out: " . Filename
;         Log_Text := Log_Text . "."
;         ; Log_Write("Warning", Log_Text)
;     }
;     Return 1    ; Search Timeout.
; }


; ====================================================================


; Left
;Click 469, 176
;Click 671, 722
; Right
;Click 963, 156
;Click 1165, 732
; a
;Click 155, 776
;Click 155, 776
; d
;Click 1447, 786
;Click 1447, 786

; ~^d::
SPModeYukikaze_Alt_2()
{
    ; Combo 1-
    WinActivate("ActionTaimanin")
    Send "d"   ; 0
    Sleep 800  ; 880
    Send "a"   ; 880
    Sleep 800
    Send "a"   ; 1680
    Sleep 760
    Send "a"   ; 2440
    Sleep 760
    Send "a"   ; 3200
    Sleep 760
    Send "d"   ; 3960
    Sleep 760
    Send "a"   ; 4720
    Sleep 760
    Send "d"   ; 5480
    Sleep 800
    Send "d"   ; 6280
    Sleep 760
    Send "a"   ; 7040
    ; Combo 11-
    Sleep 800
    Send "a"   ; 7840
    Sleep 800
    Send "d"   ; 8640
    Sleep 480
    Send "a"   ; 9120
    Sleep 480
    Send "d"   ; 9600
    Sleep 760
    Send "a"   ; 10360
    Sleep 280
    Send "d"   ; 10640
    Sleep 520
    Send "a"   ; 11160
    Sleep 480
    Send "d"   ; 11640
    Sleep 440
    Send "d"   ; 12080
    Sleep 520
    Send "a"   ; 12600
    ; Combo 21-
    Sleep 480
    Send "a"   ; 13080
    Sleep 480
    Send "d"   ; 13560
    Sleep 520
    Send "d"   ; 14080
    Sleep 440
    Send "a"   ; 14520
    Sleep 800
    Send "a"   ; 15320
    Sleep 240
    Send "d"   ; 15560
    Sleep 580
    Send "a"   ; 16140
    Sleep 460
    Send "d"   ; 16600
    Sleep 480
    Send "d"   ; 17080
    Sleep 440
    Send "d"   ; 17520
    ; Combo 31-
    Sleep 520
    Send "d"   ; 18040
    Sleep 480
    Send "d"   ; 18520
    Sleep 480
    Send "d"   ; 19000
    Sleep 480
    Send "a"   ; 19480
    Sleep 520
    Send "d"   ; 20000
    Sleep 480
    Send "a"   ; 20480
    Sleep 520
    Send "a"   ; 21000
    Sleep 440
    Send "d"   ; 21440
    Sleep 440
    Send "d"   ; 21880
    Sleep 560  ; 600
    Send "a"   ; 22480
    ; Combo 41-
    Sleep 420
    Send "a"   ; 22900
    Sleep 560
    Send "d"   ; 23460
    Sleep 420
    Send "d"   ; 23880
    Sleep 540
    Send "a"   ; 24420
    Sleep 460
    Send "d"   ; 24880
    Sleep 560
    Send "a"   ; 25440
    Sleep 480
    Send "d"   ; 25920
    Sleep 520
    Send "a"   ; 26440
    Sleep 440
    Send "d"   ; 26880
    Sleep 490
    Send "a"   ; 27370
    ; Combo 51-
    Sleep 510
    Send "a"   ; 27880
    Sleep 480
    Send "d"   ; 28360
    Sleep 520
    Send "d"   ; 28880
    Sleep 450
    Send "a"   ; 29330
    Sleep 510
    Send "d"   ; 29840
    Sleep 480
    Send "a"   ; 30320
    Sleep 520
    Send "a"   ; 30840
    Sleep 470
    Send "a"   ; 31310
    Sleep 500  ; 510
    Send "a"   ; 31820
    Sleep 460
    Send "d"   ; 32280
    ; Combo 61-
    Sleep 520
    Send "d"   ; 32800
    Sleep 480
    Send "a"   ; 33280
    Sleep 520
    Send "a"   ; 33800
    Sleep 480
    Send "a"   ; 34280
    Sleep 500
    Send "a"   ; 34780
    Sleep 500
    Send "d"   ; 35280
    Sleep 490
    Send "a"   ; 35770
    Sleep 510
    Send "d"   ; 36280
    Sleep 480
    Send "d"   ; 36760
    Sleep 480
    Send "a"   ; 37240
    ; Combo 71-
    Sleep 520
    Send "a"   ; 37760
    Sleep 480
    Send "d"   ; 38240
    Sleep 520
    Send "a"   ; 38760
    Sleep 480
    Send "d"   ; 39240
    Sleep 480
    Send "a"   ; 39720
    Sleep 520
    Send "d"   ; 40240
    Sleep 2420
    Send "a"   ; 42660
    ; 42870
    Sleep 12000
    ActTaimanin_Click(1400, 880, 0)

    Return
}