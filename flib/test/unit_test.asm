    name unit_test           ; module name

    include "inc\arcadia.h"      ; v1.01

    org         0000H        ; Start of Arcadia ROM

programentry:
    eorz  r0                 ; Zero-out register 0
    bctr,un     programstart ; Branch to start of program
    retc,un                  ; Called on VSYNC or VBLANK?
                             ; As suggested by Paul Robson

programstart:
    ppsu        00100000b    ; Set Interrupt Inhibit bit
                             ; The Tech doc that Paul
                             ; wrote infers that Inter-
                             ; rupts aren't used
    
    ppsl 00000010b           ; COM=1
    
    lodi,r0 00000000b       ;ノーマルモード&通常解像度
    stra,r0 RESOLUTION
    lodi,r0 00000000b       ;通常解像度&背景白
    stra,r0 BGCOLOUR
    
    ;スクロール位置を画面上端へ
    lodi,r0 0F0h
    stra,r0 CRTCVPR
    
    ;RAM1           equ 18D0h   ;$18D0..$18EF are user RAM1 - 32 Byte 
    Sign            equ 18D0h 
    DataOffset0     equ 18D1h 
    DataOffset1     equ 18D2h 

    ;RAM2            equ 18F8h   ;$18F8..$18FB are user RAM2 -  4 Byte
    Temporary0      equ 18F8h
    Temporary1      equ 18F9h
    Temporary0P1    equ 18F8h + 8*1024
    Temporary1P1    equ 18F9h + 8*1024

    FStack equ 1AD0h + PAGE1        ;$1AD0..$1AFF are user RAM3 - 48 Byte

    ;-------
    ;fcom0のテスト

    ; +0.0
    lodi,r0 00h
    stra,r0 FStack+0-PAGE1
    lodi,r0 00h
    stra,r0 FStack+1-PAGE1
    lodi,r1 0
    bsta,un fcom0
    bsfa,eq failed_unit_test

    ; -0.0
    lodi,r0 80h
    stra,r0 FStack+2-PAGE1
    lodi,r0 00h
    stra,r0 FStack+3-PAGE1
    lodi,r1 2
    bsta,un fcom0
    bsfa,eq failed_unit_test

    ; 1.0
    lodi,r0 00h + EXPONENT_OFFSET
    stra,r0 FStack+4-PAGE1
    lodi,r0 00h
    stra,r0 FStack+5-PAGE1
    lodi,r1 4
    bsta,un fcom0
    bsfa,gt failed_unit_test

    ; -1.0
    lodi,r0 80h + EXPONENT_OFFSET
    stra,r0 FStack+6-PAGE1
    lodi,r0 00h
    stra,r0 FStack+7-PAGE1
    lodi,r1 6
    bsta,un fcom0
    bsfa,lt failed_unit_test

    ; 1.5
    lodi,r0 00h + EXPONENT_OFFSET
    stra,r0 FStack+8-PAGE1
    lodi,r0 80h
    stra,r0 FStack+9-PAGE1
    lodi,r1 8
    bsta,un fcom0
    bsfa,gt failed_unit_test

    ; -1.5
    lodi,r0 80h + EXPONENT_OFFSET
    stra,r0 FStack+10-PAGE1
    lodi,r0 80h
    stra,r0 FStack+11-PAGE1
    lodi,r1 10
    bsta,un fcom0
    bsfa,lt failed_unit_test
    
    ; 3.0
    lodi,r0 00h + EXPONENT_OFFSET + 1
    stra,r0 FStack+8-PAGE1
    lodi,r0 80h
    stra,r0 FStack+9-PAGE1
    lodi,r1 8
    bsta,un fcom0
    bsfa,gt failed_unit_test

    ; -3.0
    lodi,r0 80h + EXPONENT_OFFSET + 1
    stra,r0 FStack+10-PAGE1
    lodi,r0 80h
    stra,r0 FStack+11-PAGE1
    lodi,r1 10
    bsta,un fcom0
    bsfa,lt failed_unit_test
    
    ; 0.75
    lodi,r0 00h + EXPONENT_OFFSET - 1
    stra,r0 FStack+12-PAGE1
    lodi,r0 80h
    stra,r0 FStack+13-PAGE1
    lodi,r1 12
    bsta,un fcom0
    bsfa,gt failed_unit_test

    ; -0.75
    lodi,r0 80h + EXPONENT_OFFSET - 1
    stra,r0 FStack+14-PAGE1
    lodi,r0 80h
    stra,r0 FStack+15-PAGE1
    lodi,r1 14
    bsta,un fcom0
    bsfa,lt failed_unit_test

    ; 0.375
    lodi,r0 00h + EXPONENT_OFFSET - 2
    stra,r0 FStack+16-PAGE1
    lodi,r0 80h
    stra,r0 FStack+17-PAGE1
    lodi,r1 16
    bsta,un fcom0
    bsfa,gt failed_unit_test

    ; -0.375
    lodi,r0 80h + EXPONENT_OFFSET - 2
    stra,r0 FStack+18-PAGE1
    lodi,r0 80h
    stra,r0 FStack+19-PAGE1
    lodi,r1 18
    bsta,un fcom0
    bsfa,lt failed_unit_test

    ;-------
    ;fcomのテスト

    ;0.0 == 0.0
    lodi,r1 0
    lodi,r2 0
    bsta,un fcom
    bsfa,eq failed_unit_test

    ;-0.0 == -0.0
    lodi,r1 2
    lodi,r2 2
    bsta,un fcom
    bsfa,eq failed_unit_test

    ;1.0 == 1.0
    lodi,r1 4
    lodi,r2 4
    bsta,un fcom
    bsfa,eq failed_unit_test

    ;-1.0 == -1.0
    lodi,r1 6
    lodi,r2 6
    bsta,un fcom
    bsfa,eq failed_unit_test

    ;0.0 < 1.0
    lodi,r1 0
    lodi,r2 4
    bsta,un fcom
    bsfa,lt failed_unit_test

    ;1.0 > 0.0
    lodi,r1 4
    lodi,r2 0
    bsta,un fcom
    bsfa,gt failed_unit_test

    ;0.0 > -1.0
    lodi,r1 0
    lodi,r2 6
    bsta,un fcom
    bsfa,gt failed_unit_test

    ;-1.0 < 0.0
    lodi,r1 6
    lodi,r2 0
    bsta,un fcom
    bsfa,lt failed_unit_test

    ;1.0 < 1.5
    lodi,r1 4
    lodi,r2 8
    bsta,un fcom
    bsfa,lt failed_unit_test

    ;1.5 > 1.0
    lodi,r1 8
    lodi,r2 4
    bsta,un fcom
    bsfa,gt failed_unit_test

    ;-1.0 > -1.5
    lodi,r1 6
    lodi,r2 10
    bsta,un fcom
    bsfa,gt failed_unit_test

    ;-1.5 < -1.0
    lodi,r1 10
    lodi,r2 6
    bsta,un fcom
    bsfa,lt failed_unit_test
    
    ;-1.0 < 1.5
    lodi,r1 6
    lodi,r2 8
    bsta,un fcom
    bsfa,lt failed_unit_test

    ;1.0 > -1.5
    lodi,r1 4
    lodi,r2 10
    bsta,un fcom
    bsfa,gt failed_unit_test

    ;0.75 > 0.375
    lodi,r1 12
    lodi,r2 16
    bsta,un fcom
    bsfa,gt failed_unit_test

    ;0.375 < 0.75
    lodi,r1 16
    lodi,r2 12
    bsta,un fcom
    bsfa,lt failed_unit_test

    ;0.375 == 0.375
    lodi,r1 16
    lodi,r2 16
    bsta,un fcom
    bsfa,eq failed_unit_test

    ;-0.75 < -0.375
    lodi,r1 14
    lodi,r2 18
    bsta,un fcom
    bsfa,lt failed_unit_test

    ;-0.375 > -0.75
    lodi,r1 18
    lodi,r2 14
    bsta,un fcom
    bsfa,gt failed_unit_test
    
    ;-0.75 == -0.75
    lodi,r1 14
    lodi,r2 14
    bsta,un fcom
    bsfa,eq failed_unit_test

    ;-------
    ;fsqrtのテスト
    bcta,un fsqrt_test

fsqrt_test_data:
    ;sqrt(0.112305) = 0.335119
    db EXPONENT_OFFSET + -4
    db 0CCh
    db EXPONENT_OFFSET + -2
    db 057h
    
    ;sqrt(6899514629131599872.000000) = 2626692716.922099
    db EXPONENT_OFFSET + 62
    db 07Fh
    db EXPONENT_OFFSET + 31
    db 039h

    ;sqrt(13799029258263199744.000000) = 3714704464.457866
    db EXPONENT_OFFSET + 63
    db 07Fh
    db EXPONENT_OFFSET + 31
    db 0BAh

    ;sqrt(0.000000) = 0.000000
    db EXPONENT_OFFSET + -63
    db 07Fh
    db EXPONENT_OFFSET + -32
    db 0BAh

    ;sqrt(0.000000) = 0.000000
    db EXPONENT_OFFSET + -62
    db 07Fh
    db EXPONENT_OFFSET + -31
    db 039h

    ;sqrt(0.000000) = 0.000000
    db EXPONENT_OFFSET + -62
    db 0FFh
    db EXPONENT_OFFSET + -31
    db 069h

    ;sqrt(0.000000) = 0.000000
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -32
    db 0FFh

    ;sqrt(1023.000000) = 31.984371
    db EXPONENT_OFFSET + 9
    db 0FFh
    db EXPONENT_OFFSET + 4
    db 0FFh

    ;sqrt(4.046875) = 2.011685
    db EXPONENT_OFFSET + 2
    db 003h
    db EXPONENT_OFFSET + 1
    db 001h

    ;sqrt(2.023438) = 1.422476
    db EXPONENT_OFFSET + 1
    db 003h
    db EXPONENT_OFFSET + 0
    db 06Ch

    ;sqrt(1.011719) = 1.005842
    db EXPONENT_OFFSET + 0
    db 003h
    db EXPONENT_OFFSET + 0
    db 001h

    ;sqrt(1.003906) = 1.001951
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h

    ;sqrt(1.996094) = 1.412832
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 069h
    
    ;sqrt(0.996094) = 0.998045
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + -1
    db 0FEh

    ;sqrt(511.000000) = 22.605309
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 4
    db 069h

    ;sqrt(1.996094) = 1.412832
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 069h

    ;sqrt(0.003906) = 0.062500
    db EXPONENT_OFFSET + -8
    db 000h
    db EXPONENT_OFFSET + -4
    db 000h

    ;sqrt(10.00000) = 3.16228
    db EXPONENT_OFFSET + 3
    db 40h
    db EXPONENT_OFFSET + 1
    db 94h

    ;sqrt(9.000000) = 3.000000
    db EXPONENT_OFFSET+3
    db 20h
    db EXPONENT_OFFSET+1
    db 080h

    ; sqrt(3.00) = 1.732051
    db EXPONENT_OFFSET+1
    db 80h
    db EXPONENT_OFFSET
    db 0BBh

    ; sqrt(1.50) = 1.224745
    db EXPONENT_OFFSET
    db 80h
    db EXPONENT_OFFSET
    db 039h

    ; sqrt(0.75) = 0.86602540378
    db EXPONENT_OFFSET-1
    db 80h
    db EXPONENT_OFFSET-1
    db 0BBh

    ; sqrt(0.25) = 0.5
    db EXPONENT_OFFSET-2
    db 0
    db EXPONENT_OFFSET-1
    db 0h

    ; sqrt(0.5) = 0.70710678118
    db EXPONENT_OFFSET-1
    db 0
    db EXPONENT_OFFSET-1
    db 06Ah

    ; sqrt(1.0) = 1.0
    db EXPONENT_OFFSET
    db 0
    db EXPONENT_OFFSET
    db 0

    ; sqrt(2.0) = 1.41421356237
    db EXPONENT_OFFSET+1
    db 0
    db EXPONENT_OFFSET
    db 06Ah

    ; sqrt(0.0) = 1.0
    db 0
    db 0
    db 0
    db 0
    
fsqrt_test_data_end:

fsqrt_test:

    ;テストデータのアドレスをDataOffset0/DataOffset1へセット
    lodi,r0 fsqrt_test_data>>8
    stra,r0 DataOffset0
    lodi,r0 fsqrt_test_data&0ffh
    stra,r0 DataOffset1


fsqrt_test_loop:

    ;テストデータをFStack+2へロード
    lodi,r3 0
    loda,r0 *DataOffset0,r3
    stra,r0 FStack+2-PAGE1
    lodi,r3 1
    loda,r0 *DataOffset0,r3
    stra,r0 FStack+3-PAGE1
    
    lodi,r0 0DEh            ;マーカー
    stra,r0 SCRUPDATA

    ;fsqrtを呼び出し
    lodi,r1 2
    lodi,r2 0
    bsta,un fsqrt

    ;r1,r2に変化がないことをチェック
    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 0
    bcfa,eq failed_unit_test

    lodi,r0 0DFh            ;マーカー
    stra,r0 SCRUPDATA

    ;テストデータの結果と比較
    lodi,r3 2
    loda,r0 *DataOffset0,r3
    loda,r3 FStack+0-PAGE1
    comz r3    
    bcfa,eq failed_unit_test
    
    lodi,r3 3
    loda,r0 *DataOffset0,r3
    loda,r3 FStack+1-PAGE1
    comz r3    
    bcfa,eq failed_unit_test

    ;テストデータのアドレスをインクリメント
    loda,r0 DataOffset1
    addi,r0 4
    stra,r0 DataOffset1
    tpsl 1
    bcfr,eq _fsqrt_test_not_carry
    loda,r0 DataOffset0
    addi,r0 1
    stra,r0 DataOffset0
_fsqrt_test_not_carry:

    ;テストデータ末尾チェックして到達してないならループ
    loda,r0 DataOffset1
    comi,r0 fsqrt_test_data_end & 0ffh
    bcfa,eq fsqrt_test_loop
    loda,r0 DataOffset0
    comi,r0 fsqrt_test_data_end >> 8
    bcfa,eq fsqrt_test_loop


    ;-------
    ;faddのテスト
    bcta,un fadd_test

fadd_test_data:

    ;1.5 + -0.25 = 1.25
    ;1.5 - -0.25 = 1.75
    ;1.5 * -0.25 = -0.375
    ;1.500000 / -0.250000 = -6.000000
    ;-0.250000 / 1.500000 = -0.166667
    db EXPONENT_OFFSET
    db 80h
    db 80h + EXPONENT_OFFSET - 2
    db 0h
    db EXPONENT_OFFSET
    db 40h
    db EXPONENT_OFFSET
    db 0C0h
    db 80h + EXPONENT_OFFSET - 2
    db 080h
    db 80h + EXPONENT_OFFSET + 2
    db 080h
    db 80h + EXPONENT_OFFSET + -3
    db 055h

    ;0.99609375 + -1.00390625 = 0.0078125
    ;0.99609375 - -1.00390625 = 2.0
    ;0.99609375 * -1.00390625 = -0.99998474121 = -1
    ;0.996094 / -1.003906 = -0.992218
    ;-1.003906 / 0.996094 = -1.007843
    db EXPONENT_OFFSET-1
    db 0feh
    db 80h + EXPONENT_OFFSET
    db 01h
    db 80h + EXPONENT_OFFSET-7
    db 0h
    db EXPONENT_OFFSET+1
    db 0h
    db 80h + EXPONENT_OFFSET
    db 00h
    db 80h + EXPONENT_OFFSET + -1
    db 0FCh
    db 80h + EXPONENT_OFFSET + 0
    db 002h

    ;511 + 511 = 1022
    ;511 - 511 = 0
    ;511 * 511 = 261,121
    ;511 / 511 = 1
    ;511 / 511 = 1
    db EXPONENT_OFFSET+8
    db 0FFh
    db EXPONENT_OFFSET+8
    db 0FFh
    db EXPONENT_OFFSET+9
    db 0FFh
    db 0
    db 0h
    db EXPONENT_OFFSET+17
    db 0FEh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h

    ;2.0 + -0.00390625 = 2.0
    ;2.0 - -0.00390625 = 2.0
    ;2.0 * -0.00390625 = -0.0078125
    ;2.000000 / -0.003906 = -512.000000
    ;-0.003906 / 2.000000 = -0.001953
    db EXPONENT_OFFSET+1
    db 00h
    db 80h+EXPONENT_OFFSET-8
    db 00h
    db EXPONENT_OFFSET+1
    db 00h
    db EXPONENT_OFFSET+1
    db 00h
    db 80h+EXPONENT_OFFSET-7
    db 00h
    db 80h + EXPONENT_OFFSET + 9
    db 000h
    db 80h + EXPONENT_OFFSET + -9
    db 000h

    ;1.0 + -0.00390625 = 0.99609375
    ;1.0 - -0.00390625 = 1.00390625
    ;1.0 * -0.00390625 = -0.00390625
    ;1.000000 / -0.003906 = -256.000000
    ;-0.003906 / 1.000000 = -0.003906
    db EXPONENT_OFFSET
    db 00h
    db 80h+EXPONENT_OFFSET-8
    db 00h
    db EXPONENT_OFFSET-1
    db 0feh
    db EXPONENT_OFFSET
    db 01h
    db 80h+EXPONENT_OFFSET-8
    db 00h    
    db 80h + EXPONENT_OFFSET + 8
    db 000h
    db 80h + EXPONENT_OFFSET + -8
    db 000h

    ;0.99609375 + -0.00390625 = 0.9921875
    ;0.99609375 - -0.00390625 = 1.0
    ;0.99609375 * -0.00390625 = -0.00389099121
    ;0.996094 / -0.003906 = -255.000000
    ;-0.003906 / 0.996094 = -0.003922
    db EXPONENT_OFFSET-1
    db 0feh
    db 80h + EXPONENT_OFFSET-8
    db 0h
    db EXPONENT_OFFSET-1
    db 0fch
    db EXPONENT_OFFSET
    db 0h
    db 80h + EXPONENT_OFFSET-9
    db 0feh
    db 80h + EXPONENT_OFFSET + 7
    db 0FEh
    db 80h + EXPONENT_OFFSET + -8
    db 001h

    ;1.5 + -0.5 = 1.0
    ;1.5 - -0.5 = 2.0
    ;1.5 * -0.5 = -0.75
    ;1.500000 / -0.500000 = -3.000000
    ;-0.500000 / 1.500000 = -0.333333
    db EXPONENT_OFFSET
    db 80h
    db 80h + EXPONENT_OFFSET - 1
    db 0h
    db EXPONENT_OFFSET
    db 0h
    db EXPONENT_OFFSET+1
    db 0h
    db 80h + EXPONENT_OFFSET-1
    db 80h
    db 80h + EXPONENT_OFFSET + 1
    db 080h
    db 80h + EXPONENT_OFFSET + -2
    db 055h

    ;1.5 + -1.0 = 0.5
    ;1.5 - -1.0 = 2.5
    ;1.5 * -1.0 = -1.5
    ;1.500000 / -1.000000 = -1.500000
    ;-1.000000 / 1.500000 = -0.666667
    db EXPONENT_OFFSET
    db 80h
    db 80h + EXPONENT_OFFSET
    db 0h
    db EXPONENT_OFFSET-1
    db 0h
    db EXPONENT_OFFSET+1
    db 040h
    db 80h + EXPONENT_OFFSET
    db 080h
    db 80h + EXPONENT_OFFSET + 0
    db 080h
    db 80h + EXPONENT_OFFSET + -1
    db 055h

    ;1.0 + -1.0 = 0.0
    ;1.0 - -1.0 = 2.0
    ;1.0 * -1.0 = -1.0
    ;1.000000 / -1.000000 = -1.000000
    ;-1.000000 / 1.000000 = -1.000000
    db EXPONENT_OFFSET
    db 0h
    db 80h + EXPONENT_OFFSET
    db 0h
    db 0
    db 0h
    db EXPONENT_OFFSET+1
    db 0h
    db 80h + EXPONENT_OFFSET
    db 0h
    db 80h + EXPONENT_OFFSET + 0
    db 000h
    db 80h + EXPONENT_OFFSET + 0
    db 000h

    ;1.99609375 + -0.0 = 1.99609375
    ;1.99609375 - -0.0 = 1.99609375
    ;1.99609375 * -0.0 = 0
    ;1.996094 / -0.000000 = inf
    ;-0.000000 / 1.996094 = 0.000000
    db EXPONENT_OFFSET
    db 0ffh
    db 80h
    db 0h
    db EXPONENT_OFFSET
    db 0ffh
    db EXPONENT_OFFSET
    db 0ffh
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0

    ;1.99609375 + 0.0 = 1.99609375
    ;1.99609375 - 0.0 = 1.99609375
    ;1.99609375 * 0.0 = 0
    ;1.996094 / 0.000000 = inf
    ;0.000000 / 1.996094 = 0.000000
    db EXPONENT_OFFSET
    db 0ffh
    db 0h
    db 0h
    db EXPONENT_OFFSET
    db 0ffh
    db EXPONENT_OFFSET
    db 0ffh
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0

    ;0.0 + -0.0 = -0.0
    ;0.0 - -0.0 = -0.0
    ;0.0 * -0.0 = -0.0
    ;0.000000 / -0.000000 = inf
    ;-0.000000 / 0.000000 = inf
    db 00h
    db 0h
    db 80h
    db 0h
    db 80h
    db 0h
    db 80h
    db 0h
    db 80h
    db 0
    db 0
    db 0
    db 0
    db 0

    ;0.0 + 0.0 = 0.0
    ;0.0 + 0.0 = 0.0
    ;0.0 * 0.0 = 0.0
    ;0.000000 / -0.000000 = inf
    ;-0.000000 / 0.000000 = inf
    db 0
    db 0h
    db 0
    db 0h
    db 0
    db 0h
    db 0
    db 0h
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0

    ;1.00390625 + 1.00390625 = 2.0078125
    ;1.00390625 - 1.00390625 = 0.0
    ;1.00390625 * 1.00390625 = 1.00782775879
    ;1.003906 / 1.003906 = 1.000000
    ;1.003906 / 1.003906 = 1.000000
    db EXPONENT_OFFSET
    db 01h
    db EXPONENT_OFFSET
    db 01h
    db EXPONENT_OFFSET+1
    db 01h
    db 0h
    db 0h
    db EXPONENT_OFFSET
    db 02h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h

    ;0.5 + 1.00390625 = 1.50390625
    ;0.5 - 1.00390625 = -0.50390625
    ;0.5 * 1.00390625 = 0.501953125
    ;0.500000 / 1.003906 = 0.498054
    ;1.003906 / 0.500000 = 2.007812
    db EXPONENT_OFFSET-1
    db 00h
    db EXPONENT_OFFSET
    db 01h
    db EXPONENT_OFFSET
    db 081h
    db 80h+EXPONENT_OFFSET-1
    db 02h
    db EXPONENT_OFFSET-1
    db 01h
    db EXPONENT_OFFSET + -2
    db 0FEh
    db EXPONENT_OFFSET + 1
    db 001h

    ;1.0 + 1.00390625 = 2.0
    ;1.0 - 1.00390625 = -0.00390625
    ;1.0 * 1.00390625 = 1.00390625
    ;1.000000 / 1.003906 = 0.996109
    ;1.003906 / 1.000000 = 1.003906
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET
    db 01h
    db EXPONENT_OFFSET+1
    db 00h
    db 80h + EXPONENT_OFFSET - 8
    db 00h
    db EXPONENT_OFFSET
    db 01h
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + 0
    db 001h

    ;2.0 + 0.00390625 = 2.0
    ;2.0 - 0.00390625 = 2.0
    ;2.0 * 0.00390625 = 0.0078125
    ;2.000000 / 0.003906 = 512.000000
    ;0.003906 / 2.000000 = 0.001953
    db EXPONENT_OFFSET+1
    db 00h
    db EXPONENT_OFFSET-8
    db 00h
    db EXPONENT_OFFSET+1
    db 00h
    db EXPONENT_OFFSET+1
    db 00h
    db EXPONENT_OFFSET-7
    db 00h
    db EXPONENT_OFFSET + 9
    db 000h
    db EXPONENT_OFFSET + -9
    db 000h

    ;1.0 + 0.00390625 = 1.00390625
    ;1.0 - 0.00390625 = 0.99609375
    ;1.0 * 0.00390625 = 0.00390625
    ;1.000000 / 0.003906 = 256.000000
    ;0.003906 / 1.000000 = 0.003906
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET-8
    db 00h
    db EXPONENT_OFFSET
    db 01h
    db EXPONENT_OFFSET-1
    db 0feh
    db EXPONENT_OFFSET-8
    db 00h
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + -8
    db 000h

    ;511 + 257 = 768
    ;511 - 257 = 254
    ;511 * 257 = 131,327
    ;511.000000 / 257.000000 = 1.988327
    ;257.000000 / 511.000000 = 0.502935
    db EXPONENT_OFFSET+8
    db 0FFh
    db EXPONENT_OFFSET+8
    db 01h
    db EXPONENT_OFFSET+9
    db 080h
    db EXPONENT_OFFSET+7
    db 0fch
    db EXPONENT_OFFSET+17
    db 00h
    db EXPONENT_OFFSET + 0
    db 0FDh
    db EXPONENT_OFFSET + -1
    db 001h

    ;1.75 + 1.5 = 3.25
    ;1.75 - 1.5 = 0.25
    ;1.75 * 1.5 = 2.625
    ;1.750000 / 1.500000 = 1.166667
    ;1.500000 / 1.750000 = 0.857143
    db EXPONENT_OFFSET
    db 0C0h
    db EXPONENT_OFFSET
    db 080h
    db EXPONENT_OFFSET+1
    db 0A0h
    db EXPONENT_OFFSET-2
    db 00h
    db EXPONENT_OFFSET+1
    db 50h
    db EXPONENT_OFFSET + 0
    db 02Ah
    db EXPONENT_OFFSET + -1
    db 0B6h

    ;1.0 + 1.0 = 2.0
    ;1.0 - 1.0 = 0.0
    ;1.0 * 1.0 = 1.0
    ;1.0 / 1.0 = 1.0
    ;1.0 / 1.0 = 1.0
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET+1
    db 00h
    db 0
    db 00h
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET
    db 00h
    
    ;1.0 + 0.5 = 1.5
    ;1.0 - 0.5 = 0.5
    ;1.0 * 0.5 = 0.5
    ;1.000000 / 0.500000 = 2.000000
    ;0.500000 / 1.000000 = 0.500000
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET-1
    db 00h
    db EXPONENT_OFFSET
    db 80h
    db EXPONENT_OFFSET-1
    db 00h
    db EXPONENT_OFFSET-1
    db 00h
    db EXPONENT_OFFSET + 1
    db 000h
    db EXPONENT_OFFSET + -1
    db 000h
    
    ;1.0 + 0.25 = 1.25
    ;1.0 - 0.25 = 0.75
    ;1.0 * 0.25 = 0.25
    ;1.000000 / 0.250000 = 4.000000
    ;0.250000 / 1.000000 = 0.250000
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET-2
    db 00h
    db EXPONENT_OFFSET
    db 40h
    db EXPONENT_OFFSET-1
    db 80h
    db EXPONENT_OFFSET-2
    db 00h    
    db EXPONENT_OFFSET + 2
    db 000h
    db EXPONENT_OFFSET + -2
    db 000h

    ;1.5 + 1.5 = 3.0
    ;1.5 - 1.5 = 0.0
    ;1.5 * 1.5 = 2.25
    ;1.5 / 1.5 = 1.0
    ;1.5 / 1.5 = 1.0
    db EXPONENT_OFFSET
    db 80h
    db EXPONENT_OFFSET
    db 80h
    db EXPONENT_OFFSET+1
    db 80h
    db 0
    db 0h
    db EXPONENT_OFFSET+1
    db 20h
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET
    db 00h

    ;1.5 + 1.5+eps = 3.0
    ;1.5 - 1.5-eps = -eps
    ;1.5 * 1.5+eps = 2.25 + 1.5*eps
    ;1.500000 / 1.503906 = 0.997403
    ;1.503906 / 1.500000 = 1.002604
    db EXPONENT_OFFSET
    db 80h
    db EXPONENT_OFFSET
    db 81h
    db EXPONENT_OFFSET+1
    db 80h
    db 80h + EXPONENT_OFFSET-8
    db 0h
    db EXPONENT_OFFSET+1
    db 20h
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + 0
    db 000h

    
fadd_test_data_end:

fadd_test:
    lodi,r0 fadd_test_data>>8
    stra,r0 DataOffset0
    lodi,r0 fadd_test_data&0FFh
    stra,r0 DataOffset1

    lodi,r0 080h
    stra,r0 Sign

_fadd_test_change_sign:

    lodi,r0 0D0h
    stra,r0 SCRUPDATA

    ;入力２つをFStackに積む
    lodi,r3 0
    loda,r0 *DataOffset0,r3
    eora,r0 Sign
    stra,r0 FStack+2-PAGE1
    lodi,r3 1
    loda,r0 *DataOffset0,r3
    stra,r0 FStack+3-PAGE1
    lodi,r3 2
    loda,r0 *DataOffset0,r3
    eora,r0 Sign
    stra,r0 FStack+4-PAGE1
    lodi,r3 3
    loda,r0 *DataOffset0,r3
    stra,r0 FStack+5-PAGE1

    lodi,r1 2
    lodi,r2 4
    bsta,un fadd

    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 4
    bcfa,eq failed_unit_test

    lodi,r0 0D1h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 4
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fadd_zero_test
    comi,r0 80h
    bctr,eq _fadd_zero_test

    eora,r0 Sign
    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0D2h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 5
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fadd_next_test   

_fadd_zero_test:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fadd_next_test:

    lodi,r0 0D3h            ;マーカー
    stra,r0 SCRUPDATA

    bsta,un fsub

    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 4
    bcfa,eq failed_unit_test

    lodi,r3 6
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fsub_zero_test
    comi,r0 80h
    bctr,eq _fsub_zero_test

    eora,r0 Sign
    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0D4h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 7
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fsub_next_test   

_fsub_zero_test:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fsub_next_test:

    lodi,r0 0D5h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 4
    lodi,r2 2
    bsta,un fadd

    comi,r1 4
    bcfa,eq failed_unit_test
    comi,r2 2
    bcfa,eq failed_unit_test

    lodi,r3 4
    loda,r0 *DataOffset0,r3
    
    comi,r0 00h
    bctr,eq _fadd_zero_test2
    comi,r0 80h
    bctr,eq _fadd_zero_test2

    eora,r0 Sign
    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0D6h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 5
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test

    bctr,un _fadd_next_test2   

_fadd_zero_test2:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test
    
_fadd_next_test2:

    lodi,r0 0D7h            ;マーカー
    stra,r0 SCRUPDATA

    bsta,un fsub
    comi,r1 4
    bcfa,eq failed_unit_test
    comi,r2 2
    bcfa,eq failed_unit_test

    lodi,r3 6
    loda,r0 *DataOffset0,r3
    
    comi,r0 00h
    bctr,eq _fsub_zero_test2
    comi,r0 80h
    bctr,eq _fsub_zero_test2

    eora,r0 Sign
    eori,r0 80h
    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test
    
    lodi,r0 0D8h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 7
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test

    bctr,un _fsub_next_test2   

_fsub_zero_test2:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test
    
_fsub_next_test2:

    lodi,r0 0D9h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 2
    lodi,r2 4
    bsta,un fmul

    lodi,r3 8
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fmul_zero_test
    comi,r0 80h
    bctr,eq _fmul_zero_test

    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test


    lodi,r0 0DAh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 9
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fmul_next_test   

_fmul_zero_test:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fmul_next_test:

    lodi,r0 0DBh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 4
    lodi,r2 2
    bsta,un fmul

    lodi,r3 8
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fmul_zero_test2
    comi,r0 80h
    bctr,eq _fmul_zero_test2

    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0DCh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 9
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fmul_next_test2

_fmul_zero_test2:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fmul_next_test2:

    lodi,r0 0DDh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 4
    bsta,un fcom0
    bctr,eq _fdiv_next_test     ;除数が０ならテストしない

    lodi,r1 2
    lodi,r2 4
    bsta,un fdiv

    lodi,r3 10
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fdiv_zero_test
    comi,r0 80h
    bctr,eq _fdiv_zero_test

    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0DEh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 11
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fdiv_next_test   

_fdiv_zero_test:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fdiv_next_test:

    lodi,r0 0DFh            ;マーカーF
    stra,r0 SCRUPDATA

    lodi,r1 2
    bsta,un fcom0
    bctr,eq _fdiv_next_test2     ;除数が０ならテストしない

    lodi,r1 4
    lodi,r2 2
    bsta,un fdiv

    lodi,r3 12
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fdiv_zero_test2
    comi,r0 80h
    bctr,eq _fdiv_zero_test2

    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0E0h            ;マーカーG
    stra,r0 SCRUPDATA

    lodi,r3 13
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fdiv_next_test2

_fdiv_zero_test2:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fdiv_next_test2:


    ;Signを切り替えてもう一回
    loda,r0 Sign
    eori,r0 80h
    stra,r0 Sign
    bcta,eq _fadd_test_change_sign

    ;データオフセット進める
    loda,r0 DataOffset1
    addi,r0 14
    stra,r0 DataOffset1
    tpsl 1
    bcfr,eq _fadd_test_not_carry
    loda,r0 DataOffset0
    addi,r0 1
    stra,r0 DataOffset0
_fadd_test_not_carry:

    ;データ末尾まで行ったら終了
    loda,r0 DataOffset0
    comi,r0 fadd_test_data_end>>8
    bcfa,eq _fadd_test_change_sign
    loda,r0 DataOffset1
    comi,r0 fadd_test_data_end&0ffh
    bcfa,eq _fadd_test_change_sign

    ;-------
    ;mantissa_rshiftのテスト

    lodi,r0 0ffh
    lodi,r3 1
    bsta,un mantissa_rshift
    comi,r0 0ffh
    bsfa,eq failed_unit_test

    lodi,r0 0ffh
    lodi,r3 2
    bsta,un mantissa_rshift
    comi,r0 07fh
    bsfa,eq failed_unit_test

    lodi,r0 0ffh
    lodi,r3 3
    bsta,un mantissa_rshift
    comi,r0 03fh
    bsfa,eq failed_unit_test

    lodi,r0 0ffh
    lodi,r3 4
    bsta,un mantissa_rshift
    comi,r0 01fh
    bsfa,eq failed_unit_test

    lodi,r0 0ffh
    lodi,r3 5
    bsta,un mantissa_rshift
    comi,r0 00fh
    bsfa,eq failed_unit_test

    lodi,r0 0ffh
    lodi,r3 6
    bsta,un mantissa_rshift
    comi,r0 07h
    bsfa,eq failed_unit_test

    lodi,r0 0ffh
    lodi,r3 7
    bsta,un mantissa_rshift
    comi,r0 03h
    bsfa,eq failed_unit_test

    lodi,r0 0ffh
    lodi,r3 8
    bsta,un mantissa_rshift
    comi,r0 01h
    bsfa,eq failed_unit_test

    eorz r0
    lodi,r3 1
    bsta,un mantissa_rshift
    comi,r0 080h
    bsfa,eq failed_unit_test

    eorz r0
    lodi,r3 2
    bsta,un mantissa_rshift
    comi,r0 040h
    bsfa,eq failed_unit_test

    eorz r0
    lodi,r3 3
    bsta,un mantissa_rshift
    comi,r0 020h
    bsfa,eq failed_unit_test

    eorz r0
    lodi,r3 4
    bsta,un mantissa_rshift
    comi,r0 010h
    bsfa,eq failed_unit_test

    eorz r0
    lodi,r3 5
    bsta,un mantissa_rshift
    comi,r0 08h
    bsfa,eq failed_unit_test

    eorz r0
    lodi,r3 6
    bsta,un mantissa_rshift
    comi,r0 04h
    bsfa,eq failed_unit_test

    eorz r0
    lodi,r3 7
    bsta,un mantissa_rshift
    comi,r0 02h
    bsfa,eq failed_unit_test

    eorz r0
    lodi,r3 8
    bsta,un mantissa_rshift
    comi,r0 01h
    bsfa,eq failed_unit_test

    ;--------
    ;テストOK
    lodi,r0 010000011b  ;背景緑
    stra,r0 BGCOLOUR
    halt

_page0_last_:
    if _page0_last_ > 4*1024
        warning "page0の末尾が4K超えてるよ"
    endif

    PAGE1 equ   8*1024
    org PAGE1

    ;-------
    ;テスト失敗
failed_unit_test:
    ;halt
    lodi,r0 010000101b  ;背景赤
    stra,r0 BGCOLOUR+PAGE1
    halt


    include "flib\floating_point_number.asm"
    include "flib\fadd.asm"
    include "flib\mantissa_rshift.asm"
    include "flib\fmul.asm"
    include "flib\fsqrt.asm"
    include "flib\fcom.asm"
    include "flib\fdiv.asm"


end ; End of assembly
