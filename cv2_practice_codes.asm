    BASE $B850 ; 003860 in rom (bank 00)

CheckMenu:
        PHP
        CLV
        LDY $26
        LDX $F5
        CPY #$02 ; Currently paused in select
        BEQ CheckButtonSelect
        CPY #$01 ; Currently paused in start
        BEQ CheckButtonStart
        INC $D4 ; count frames if not paused
        BEQ AddFrameHigh
        BVC ReturnMain

AddFrameHigh:
        INC $D5
        BVC ReturnMain

CheckButtonSelect:
        CPX #$80 ; A is pressed
        BEQ APress
        CPX #$40 ; B is pressed
        BEQ BPress
        CPX #$08 ; Up is pressed
        BEQ UpPress
        CPX #$04 ; Down is pressed
        BEQ DownPress
        CPX #$02 ; Left is pressed
        BEQ LeftPress
        CPX #$01 ; Right is pressed
        BEQ RightPress
        BVC ReturnMain

CheckButtonStart:
        CPX #$80 ; A is pressed
        BEQ APressStartTop
        CPX #$40 ; A is pressed
        BEQ BPressStart
        INC $D4 ; count frames if not paused
        BEQ AddFrameHigh
        BVC ReturnMain

APressStartTop:
        LDY $33
        CPY #$01
        BEQ APressStartBot
        LDA #$1F
        STA $91
        BVC ReturnMain

APressStartBot:
        LDA #$FF
        STA $4A
        BVC ReturnMain

BPressStart:
        LDA $91
        CLC
        ADC #$20
        AND #$7F
        STA $91
        CLV
        BVC ReturnMain

APress:
        LDA #$59
        STA $85
        LDA $82
        CMP #$00
        BEQ ChangeToNight
        LDA $86
        CMP #$18
        BCC ChangeToDay

AddDay:
        INC $83

ChangeToDay:
        LDA #$05
        STA $86
        BVC ReturnMain

ChangeToNight:
        LDA #$17
        STA $86
        BVC ReturnMain

ReturnMain:
        LDA $D3
        BEQ PullAndReturn
        JSR DrawCodes

PullAndReturn:
        PLP
        JMP $D308

BPress:
        LDA $81
        STA $80
        BVC ReturnMain

UpPress:
        LDA #$02
        STA $49
        LDA #$56
        STA $48
        BNE ReturnMain

DownPress:
        JSR CycleVar
        BVC ReturnMain

LeftPress:
        LDA $0434
        CMP #$04
        BEQ ResetWhip
        LDA #$01
        CLC
        ADC $0434
        STA $0434
        CLV
        BVC ReturnMain

RightPress:
        LDA $8B
        CMP #$09
        BEQ ResetLvl
        LDA #$01
        CLC
        ADC $8B
        STA $8B
        CLV
        BVC ReturnMain

ResetLvl:
        LDA #$00
        STA $8B
        BVC ReturnMain
        
ResetWhip:
        LDA #$00
        STA $0434
        BVC ReturnMain

DrawCodes:
        LDY #$00
        CPY $D0
        BNE DrawSubPx
        LDA #$01
        STA $D0
        LDA #$36
        STA $D1
        LDA #$03
        STA $D2

DrawSubPx:
        LDA $D3
        CMP #$04
        BEQ DrawFrameCounter
        LDA ($D1),Y
        JSR HexToDec
        STA $01D4
        TXA
        STA $01D3
        TYA
        STA $01D2
        LDX #$03
        LDA #$10
        LDY #$00
        JSR SetPositions
        JMP DrawHp

DrawFrameCounter:
        LDA $D4 ; lobyte
        STA $01D0
        LDA $D5 ; hibyte
        STA $01D1
        JSR HexToDecTwoByte
        ; Results in $01D2 - D6
        LDX #$05
        LDA #$10
        LDY #$00
        JSR SetPositions
        
DrawHp:
        LDA $80
        JSR HexToDec
        STA $0205
        TXA
        STA $0201
        LDA #$00
        STA $0202
        STA $0206
        LDA #$10
        STA $0204
        LDA #$18
        STA $0207

CheckBossHp:
        LDA $03BA
        CMP #$47
        BEQ DrawBossHp
        CMP #$44
        BEQ DrawBossHp
        CMP #$42
        BEQ DrawBossHp
        RTS

DrawBossHp:
        LDA $04C8
        JSR HexToDec
        STA $0219
        TXA
        STA $021D
        TYA
        STA $0221
        LDA #$CC
        STA $0218
        STA $021C
        STA $0220
        STA $0224
        LDA #$00
        STA $021A
        STA $021E
        STA $0222
        STA $0226
        LDA #$88
        STA $021B
        LDA #$80
        STA $021F
        LDA #$78
        STA $0223
        LDA #$70
        STA $0227
        LDA #$34
        STA $0225 ; HP text
        RTS

CycleVar:
        LDX $D3
        BEQ LoadSubPx
        CPX #$01
        BEQ LoadX
        CPX #$02
        BEQ LoadCamX
        CPX #$03
        BEQ LoadFrame

LoadSubPx:
        LDA #$36
        STA $D1
        LDA #$03
        STA $D2
        BNE ResetCycle

LoadCamX:
        LDA #$53
        STA $D1
        LDA #$00
        STA $D2
        BEQ ResetCycle

LoadFrame:
        LDA #$00
        STA $D4
        STA $D5
        STA $D2
        LDA #$D4
        STA $D1
        BNE ResetCycle

LoadX:
        LDA #$03
        STA $D2
        LDA #$48
        STA $D1

ResetCycle:
        INX
        CPX #$05
        BNE Return
        LDX #$00

Return:
        STX $D3
        RTS

SetPositions:
; A = Y position, X = # of digits
        STA $01D0
        STX $01D1
        LDX #$00

PositionsLoop:
        LDA $01D0
        STA $0208,Y
        LDA #$00
        STA $020A,Y
        TYA
        ASL
        CLC
        ADC #$D0
        STA $020B,Y
        LDA $01D2,X
        STA $0209,Y
        INY
        INY
        INY
        INY
        INX
        CPX $01D1
        BNE PositionsLoop
        RTS

HexToDec:
        LDY #$1E
        LDX #$34
        SEC

HundredsPlace:
        INY
        INY
        SBC #$64
        BCS HundredsPlace

TensPlace:
        DEX
        DEX
        ADC #$0A
        BMI TensPlace
        ASL
        ADC #$20
        RTS

HexToDecTwoByte:
; Store value in 01D1 (highbyte) & 01D0 (lobyte)
        LDA #$20
        LDY #$00

Clear:
        STA $01D2,Y ; $01D2 - D6 = results
        INY
        CPY #$05
        BNE Clear
        LDX #$4F ; End of lookup table

Loop1:
        CLC
        ROL $01D0 ; lobyte
        ROL $01D1 ; highbyte
        BCS Calculate
        TXA
        SEC
        SBC #$05
        TAX
        CPX #$FA
        BNE Loop1

End:
        RTS

Calculate:
        CLC
        LDY #$04

Loop2:
        LDA $BF70,X ; lookup table
        BCS AddDigit
        BEQ Zero

AddDigit:
        ASL
        ADC $01D2,Y
        CMP #$34
        BCC NotTen
        SBC #$14
        STA $01D2,Y
        DEX
        DEY
        BPL AddCarry
        JMP Loop1

AddCarry:
        LDA #$01
        ADC $01D2,Y
        CMP #$34
        STA $01D2,Y
        JMP Loop2

NotTen:
        STA $01D2,Y

Zero:
        DEX
        DEY
        BPL Loop2
        JMP Loop1
