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

    ;0.5 + -1.0 = -0.5
    ;0.5 - -1.0 = 1.5
    ;0.5 * -1.0 = -0.5
    ;0.500000 / -1.000000 = -0.500000
    ;-1.000000 / 0.500000 = -2.000000
    db EXPONENT_OFFSET-1
    db 00h
    db EXPONENT_OFFSET+80h
    db 00h
    db EXPONENT_OFFSET-1+80h
    db 00h
    db EXPONENT_OFFSET
    db 80h
    db EXPONENT_OFFSET-1+80h
    db 00h
    db EXPONENT_OFFSET + -1+80h
    db 000h
    db EXPONENT_OFFSET + 1+80h
    db 000h

    ;1.0 + -0.5 = 0.5
    ;1.0 - -0.5 = 1.5
    ;1.0 * -0.5 = -0.5
    ;1.000000 / -0.500000 = -2.000000
    ;-0.500000 / 1.000000 = -0.500000
    db EXPONENT_OFFSET
    db 00h
    db EXPONENT_OFFSET-1+80h
    db 00h
    db EXPONENT_OFFSET-1
    db 00h
    db EXPONENT_OFFSET
    db 80h
    db EXPONENT_OFFSET-1+80h
    db 00h
    db EXPONENT_OFFSET + 1+80h
    db 000h
    db EXPONENT_OFFSET + -1+80h
    db 000h

    ;77.000000 + 25.312500 = 102.312500
    ;77.000000 - 25.312500 = 51.687500
    ;77.000000 * 25.312500 = 1949.062500(1948.000000)
    ;77.000000 / 25.312500 = 3.041975
    ;25.312500 / 77.000000 = 0.328734
    db EXPONENT_OFFSET + 6
    db 034h
    db EXPONENT_OFFSET + 4
    db 095h
    db EXPONENT_OFFSET + 6
    db 099h
    db EXPONENT_OFFSET + 5
    db 09Eh
    db EXPONENT_OFFSET + 10
    db 0E7h
    db EXPONENT_OFFSET + 1
    db 085h
    db EXPONENT_OFFSET + -2
    db 050h
    ;256.000000 + 256.000000 = 512.000000
    ;256.000000 - 256.000000 = 0.000000
    ;256.000000 * 256.000000 = 65536.000000(65536.000000)
    ;256.000000 / 256.000000 = 1.000000
    ;256.000000 / 256.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 9
    db 000h
    db 0
    db 000h
    db EXPONENT_OFFSET + 16
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;256.000000 + 257.000000 = 513.000000
    ;256.000000 - 257.000000 = -1.000000
    ;256.000000 * 257.000000 = 65792.000000(65792.000000)
    ;256.000000 / 257.000000 = 0.996109
    ;257.000000 / 256.000000 = 1.003906
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 9
    db 000h
    db 80h + EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 16
    db 001h
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + 0
    db 001h
    ;256.000000 + 258.000000 = 514.000000
    ;256.000000 - 258.000000 = -2.000000
    ;256.000000 * 258.000000 = 66048.000000(66048.000000)
    ;256.000000 / 258.000000 = 0.992248
    ;258.000000 / 256.000000 = 1.007812
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 9
    db 001h
    db 80h + EXPONENT_OFFSET + 1
    db 000h
    db EXPONENT_OFFSET + 16
    db 002h
    db EXPONENT_OFFSET + -1
    db 0FCh
    db EXPONENT_OFFSET + 0
    db 002h
    ;256.000000 + 320.000000 = 576.000000
    ;256.000000 - 320.000000 = -64.000000
    ;256.000000 * 320.000000 = 81920.000000(81920.000000)
    ;256.000000 / 320.000000 = 0.800000
    ;320.000000 / 256.000000 = 1.250000
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 9
    db 020h
    db 80h + EXPONENT_OFFSET + 6
    db 000h
    db EXPONENT_OFFSET + 16
    db 040h
    db EXPONENT_OFFSET + -1
    db 099h
    db EXPONENT_OFFSET + 0
    db 040h
    ;256.000000 + 384.000000 = 640.000000
    ;256.000000 - 384.000000 = -128.000000
    ;256.000000 * 384.000000 = 98304.000000(98304.000000)
    ;256.000000 / 384.000000 = 0.666667
    ;384.000000 / 256.000000 = 1.500000
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 9
    db 040h
    db 80h + EXPONENT_OFFSET + 7
    db 000h
    db EXPONENT_OFFSET + 16
    db 080h
    db EXPONENT_OFFSET + -1
    db 055h
    db EXPONENT_OFFSET + 0
    db 080h
    ;256.000000 + 511.000000 = 767.000000
    ;256.000000 - 511.000000 = -255.000000
    ;256.000000 * 511.000000 = 130816.000000(130816.000000)
    ;256.000000 / 511.000000 = 0.500978
    ;511.000000 / 256.000000 = 1.996094
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 07Fh
    db 80h + EXPONENT_OFFSET + 7
    db 0FEh
    db EXPONENT_OFFSET + 16
    db 0FFh
    db EXPONENT_OFFSET + -1
    db 000h
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;256.000000 + 510.000000 = 766.000000
    ;256.000000 - 510.000000 = -254.000000
    ;256.000000 * 510.000000 = 130560.000000(130560.000000)
    ;256.000000 / 510.000000 = 0.501961
    ;510.000000 / 256.000000 = 1.992188
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 07Fh
    db 80h + EXPONENT_OFFSET + 7
    db 0FCh
    db EXPONENT_OFFSET + 16
    db 0FEh
    db EXPONENT_OFFSET + -1
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FEh
    ;256.000000 + 509.000000 = 765.000000
    ;256.000000 - 509.000000 = -253.000000
    ;256.000000 * 509.000000 = 130304.000000(130304.000000)
    ;256.000000 / 509.000000 = 0.502947
    ;509.000000 / 256.000000 = 1.988281
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 07Eh
    db 80h + EXPONENT_OFFSET + 7
    db 0FAh
    db EXPONENT_OFFSET + 16
    db 0FDh
    db EXPONENT_OFFSET + -1
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FDh
    ;256.000000 + 494.000000 = 750.000000
    ;256.000000 - 494.000000 = -238.000000
    ;256.000000 * 494.000000 = 126464.000000(126464.000000)
    ;256.000000 / 494.000000 = 0.518219
    ;494.000000 / 256.000000 = 1.929688
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 077h
    db 80h + EXPONENT_OFFSET + 7
    db 0DCh
    db EXPONENT_OFFSET + 16
    db 0EEh
    db EXPONENT_OFFSET + -1
    db 009h
    db EXPONENT_OFFSET + 0
    db 0EEh
    ;256.000000 + 476.000000 = 732.000000
    ;256.000000 - 476.000000 = -220.000000
    ;256.000000 * 476.000000 = 121856.000000(121856.000000)
    ;256.000000 / 476.000000 = 0.537815
    ;476.000000 / 256.000000 = 1.859375
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 9
    db 06Eh
    db 80h + EXPONENT_OFFSET + 7
    db 0B8h
    db EXPONENT_OFFSET + 16
    db 0DCh
    db EXPONENT_OFFSET + -1
    db 013h
    db EXPONENT_OFFSET + 0
    db 0DCh
    ;256.000000 + 463.000000 = 719.000000
    ;256.000000 - 463.000000 = -207.000000
    ;256.000000 * 463.000000 = 118528.000000(118528.000000)
    ;256.000000 / 463.000000 = 0.552916
    ;463.000000 / 256.000000 = 1.808594
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 9
    db 067h
    db 80h + EXPONENT_OFFSET + 7
    db 09Eh
    db EXPONENT_OFFSET + 16
    db 0CFh
    db EXPONENT_OFFSET + -1
    db 01Bh
    db EXPONENT_OFFSET + 0
    db 0CFh
    ;256.000000 + 437.000000 = 693.000000
    ;256.000000 - 437.000000 = -181.000000
    ;256.000000 * 437.000000 = 111872.000000(111872.000000)
    ;256.000000 / 437.000000 = 0.585812
    ;437.000000 / 256.000000 = 1.707031
    db EXPONENT_OFFSET + 8
    db 000h
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 9
    db 05Ah
    db 80h + EXPONENT_OFFSET + 7
    db 06Ah
    db EXPONENT_OFFSET + 16
    db 0B5h
    db EXPONENT_OFFSET + -1
    db 02Bh
    db EXPONENT_OFFSET + 0
    db 0B5h
    ;257.000000 + 257.000000 = 514.000000
    ;257.000000 - 257.000000 = 0.000000
    ;257.000000 * 257.000000 = 66049.000000(66048.000000)
    ;257.000000 / 257.000000 = 1.000000
    ;257.000000 / 257.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 9
    db 001h
    db 0
    db 000h
    db EXPONENT_OFFSET + 16
    db 002h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;257.000000 + 258.000000 = 515.000000
    ;257.000000 - 258.000000 = -1.000000
    ;257.000000 * 258.000000 = 66306.000000(66304.000000)
    ;257.000000 / 258.000000 = 0.996124
    ;258.000000 / 257.000000 = 1.003891
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 9
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 16
    db 003h
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + 0
    db 000h
    ;257.000000 + 320.000000 = 577.000000
    ;257.000000 - 320.000000 = -63.000000
    ;257.000000 * 320.000000 = 82240.000000(82432.000000)
    ;257.000000 / 320.000000 = 0.803125
    ;320.000000 / 257.000000 = 1.245136
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 9
    db 020h
    db 80h + EXPONENT_OFFSET + 5
    db 0F8h
    db EXPONENT_OFFSET + 16
    db 042h
    db EXPONENT_OFFSET + -1
    db 09Bh
    db EXPONENT_OFFSET + 0
    db 03Eh
    ;257.000000 + 384.000000 = 641.000000
    ;257.000000 - 384.000000 = -127.000000
    ;257.000000 * 384.000000 = 98688.000000(98816.000000)
    ;257.000000 / 384.000000 = 0.669271
    ;384.000000 / 257.000000 = 1.494163
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 9
    db 040h
    db 80h + EXPONENT_OFFSET + 6
    db 0FCh
    db EXPONENT_OFFSET + 16
    db 082h
    db EXPONENT_OFFSET + -1
    db 056h
    db EXPONENT_OFFSET + 0
    db 07Eh
    ;257.000000 + 511.000000 = 768.000000
    ;257.000000 - 511.000000 = -254.000000
    ;257.000000 * 511.000000 = 131327.000000(131072.000000)
    ;257.000000 / 511.000000 = 0.502935
    ;511.000000 / 257.000000 = 1.988327
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 080h
    db 80h + EXPONENT_OFFSET + 7
    db 0FCh
    db EXPONENT_OFFSET + 17
    db 000h
    db EXPONENT_OFFSET + -1
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FDh
    ;257.000000 + 510.000000 = 767.000000
    ;257.000000 - 510.000000 = -253.000000
    ;257.000000 * 510.000000 = 131070.000000(131072.000000)
    ;257.000000 / 510.000000 = 0.503922
    ;510.000000 / 257.000000 = 1.984436
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 07Fh
    db 80h + EXPONENT_OFFSET + 7
    db 0FAh
    db EXPONENT_OFFSET + 17
    db 000h
    db EXPONENT_OFFSET + -1
    db 002h
    db EXPONENT_OFFSET + 0
    db 0FCh
    ;257.000000 + 509.000000 = 766.000000
    ;257.000000 - 509.000000 = -252.000000
    ;257.000000 * 509.000000 = 130813.000000(130816.000000)
    ;257.000000 / 509.000000 = 0.504912
    ;509.000000 / 257.000000 = 1.980545
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 07Fh
    db 80h + EXPONENT_OFFSET + 7
    db 0F8h
    db EXPONENT_OFFSET + 16
    db 0FFh
    db EXPONENT_OFFSET + -1
    db 002h
    db EXPONENT_OFFSET + 0
    db 0FBh
    ;257.000000 + 494.000000 = 751.000000
    ;257.000000 - 494.000000 = -237.000000
    ;257.000000 * 494.000000 = 126958.000000(126976.000000)
    ;257.000000 / 494.000000 = 0.520243
    ;494.000000 / 257.000000 = 1.922179
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 077h
    db 80h + EXPONENT_OFFSET + 7
    db 0DAh
    db EXPONENT_OFFSET + 16
    db 0F0h
    db EXPONENT_OFFSET + -1
    db 00Ah
    db EXPONENT_OFFSET + 0
    db 0ECh
    ;257.000000 + 476.000000 = 733.000000
    ;257.000000 - 476.000000 = -219.000000
    ;257.000000 * 476.000000 = 122332.000000(122368.000000)
    ;257.000000 / 476.000000 = 0.539916
    ;476.000000 / 257.000000 = 1.852140
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 9
    db 06Eh
    db 80h + EXPONENT_OFFSET + 7
    db 0B6h
    db EXPONENT_OFFSET + 16
    db 0DEh
    db EXPONENT_OFFSET + -1
    db 014h
    db EXPONENT_OFFSET + 0
    db 0DAh
    ;257.000000 + 463.000000 = 720.000000
    ;257.000000 - 463.000000 = -206.000000
    ;257.000000 * 463.000000 = 118991.000000(119040.000000)
    ;257.000000 / 463.000000 = 0.555076
    ;463.000000 / 257.000000 = 1.801556
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 9
    db 068h
    db 80h + EXPONENT_OFFSET + 7
    db 09Ch
    db EXPONENT_OFFSET + 16
    db 0D1h
    db EXPONENT_OFFSET + -1
    db 01Ch
    db EXPONENT_OFFSET + 0
    db 0CDh
    ;257.000000 + 437.000000 = 694.000000
    ;257.000000 - 437.000000 = -180.000000
    ;257.000000 * 437.000000 = 112309.000000(112384.000000)
    ;257.000000 / 437.000000 = 0.588101
    ;437.000000 / 257.000000 = 1.700389
    db EXPONENT_OFFSET + 8
    db 001h
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 9
    db 05Bh
    db 80h + EXPONENT_OFFSET + 7
    db 068h
    db EXPONENT_OFFSET + 16
    db 0B7h
    db EXPONENT_OFFSET + -1
    db 02Dh
    db EXPONENT_OFFSET + 0
    db 0B3h
    ;258.000000 + 258.000000 = 516.000000
    ;258.000000 - 258.000000 = 0.000000
    ;258.000000 * 258.000000 = 66564.000000(66560.000000)
    ;258.000000 / 258.000000 = 1.000000
    ;258.000000 / 258.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 9
    db 002h
    db 0
    db 000h
    db EXPONENT_OFFSET + 16
    db 004h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;258.000000 + 320.000000 = 578.000000
    ;258.000000 - 320.000000 = -62.000000
    ;258.000000 * 320.000000 = 82560.000000(82688.000000)
    ;258.000000 / 320.000000 = 0.806250
    ;320.000000 / 258.000000 = 1.240310
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 9
    db 021h
    db 80h + EXPONENT_OFFSET + 5
    db 0F0h
    db EXPONENT_OFFSET + 16
    db 043h
    db EXPONENT_OFFSET + -1
    db 09Ch
    db EXPONENT_OFFSET + 0
    db 03Dh
    ;258.000000 + 384.000000 = 642.000000
    ;258.000000 - 384.000000 = -126.000000
    ;258.000000 * 384.000000 = 99072.000000(99072.000000)
    ;258.000000 / 384.000000 = 0.671875
    ;384.000000 / 258.000000 = 1.488372
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 9
    db 041h
    db 80h + EXPONENT_OFFSET + 6
    db 0F8h
    db EXPONENT_OFFSET + 16
    db 083h
    db EXPONENT_OFFSET + -1
    db 058h
    db EXPONENT_OFFSET + 0
    db 07Dh
    ;258.000000 + 511.000000 = 769.000000
    ;258.000000 - 511.000000 = -253.000000
    ;258.000000 * 511.000000 = 131838.000000(131584.000000)
    ;258.000000 / 511.000000 = 0.504892
    ;511.000000 / 258.000000 = 1.980620
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 080h
    db 80h + EXPONENT_OFFSET + 7
    db 0FAh
    db EXPONENT_OFFSET + 17
    db 001h
    db EXPONENT_OFFSET + -1
    db 002h
    db EXPONENT_OFFSET + 0
    db 0FBh
    ;258.000000 + 510.000000 = 768.000000
    ;258.000000 - 510.000000 = -252.000000
    ;258.000000 * 510.000000 = 131580.000000(131584.000000)
    ;258.000000 / 510.000000 = 0.505882
    ;510.000000 / 258.000000 = 1.976744
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 080h
    db 80h + EXPONENT_OFFSET + 7
    db 0F8h
    db EXPONENT_OFFSET + 17
    db 001h
    db EXPONENT_OFFSET + -1
    db 003h
    db EXPONENT_OFFSET + 0
    db 0FAh
    ;258.000000 + 509.000000 = 767.000000
    ;258.000000 - 509.000000 = -251.000000
    ;258.000000 * 509.000000 = 131322.000000(131072.000000)
    ;258.000000 / 509.000000 = 0.506876
    ;509.000000 / 258.000000 = 1.972868
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 07Fh
    db 80h + EXPONENT_OFFSET + 7
    db 0F6h
    db EXPONENT_OFFSET + 17
    db 000h
    db EXPONENT_OFFSET + -1
    db 003h
    db EXPONENT_OFFSET + 0
    db 0F9h
    ;258.000000 + 494.000000 = 752.000000
    ;258.000000 - 494.000000 = -236.000000
    ;258.000000 * 494.000000 = 127452.000000(127488.000000)
    ;258.000000 / 494.000000 = 0.522267
    ;494.000000 / 258.000000 = 1.914729
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 078h
    db 80h + EXPONENT_OFFSET + 7
    db 0D8h
    db EXPONENT_OFFSET + 16
    db 0F2h
    db EXPONENT_OFFSET + -1
    db 00Bh
    db EXPONENT_OFFSET + 0
    db 0EAh
    ;258.000000 + 476.000000 = 734.000000
    ;258.000000 - 476.000000 = -218.000000
    ;258.000000 * 476.000000 = 122808.000000(122880.000000)
    ;258.000000 / 476.000000 = 0.542017
    ;476.000000 / 258.000000 = 1.844961
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 9
    db 06Fh
    db 80h + EXPONENT_OFFSET + 7
    db 0B4h
    db EXPONENT_OFFSET + 16
    db 0E0h
    db EXPONENT_OFFSET + -1
    db 015h
    db EXPONENT_OFFSET + 0
    db 0D8h
    ;258.000000 + 463.000000 = 721.000000
    ;258.000000 - 463.000000 = -205.000000
    ;258.000000 * 463.000000 = 119454.000000(119296.000000)
    ;258.000000 / 463.000000 = 0.557235
    ;463.000000 / 258.000000 = 1.794574
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 9
    db 068h
    db 80h + EXPONENT_OFFSET + 7
    db 09Ah
    db EXPONENT_OFFSET + 16
    db 0D2h
    db EXPONENT_OFFSET + -1
    db 01Dh
    db EXPONENT_OFFSET + 0
    db 0CBh
    ;258.000000 + 437.000000 = 695.000000
    ;258.000000 - 437.000000 = -179.000000
    ;258.000000 * 437.000000 = 112746.000000(112640.000000)
    ;258.000000 / 437.000000 = 0.590389
    ;437.000000 / 258.000000 = 1.693798
    db EXPONENT_OFFSET + 8
    db 002h
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 9
    db 05Bh
    db 80h + EXPONENT_OFFSET + 7
    db 066h
    db EXPONENT_OFFSET + 16
    db 0B8h
    db EXPONENT_OFFSET + -1
    db 02Eh
    db EXPONENT_OFFSET + 0
    db 0B1h
    ;320.000000 + 320.000000 = 640.000000
    ;320.000000 - 320.000000 = 0.000000
    ;320.000000 * 320.000000 = 102400.000000(102400.000000)
    ;320.000000 / 320.000000 = 1.000000
    ;320.000000 / 320.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 9
    db 040h
    db 0
    db 000h
    db EXPONENT_OFFSET + 16
    db 090h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;320.000000 + 384.000000 = 704.000000
    ;320.000000 - 384.000000 = -64.000000
    ;320.000000 * 384.000000 = 122880.000000(122880.000000)
    ;320.000000 / 384.000000 = 0.833333
    ;384.000000 / 320.000000 = 1.200000
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 9
    db 060h
    db 80h + EXPONENT_OFFSET + 6
    db 000h
    db EXPONENT_OFFSET + 16
    db 0E0h
    db EXPONENT_OFFSET + -1
    db 0AAh
    db EXPONENT_OFFSET + 0
    db 033h
    ;320.000000 + 511.000000 = 831.000000
    ;320.000000 - 511.000000 = -191.000000
    ;320.000000 * 511.000000 = 163520.000000(163328.000000)
    ;320.000000 / 511.000000 = 0.626223
    ;511.000000 / 320.000000 = 1.596875
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 09Fh
    db 80h + EXPONENT_OFFSET + 7
    db 07Eh
    db EXPONENT_OFFSET + 17
    db 03Fh
    db EXPONENT_OFFSET + -1
    db 040h
    db EXPONENT_OFFSET + 0
    db 098h
    ;320.000000 + 510.000000 = 830.000000
    ;320.000000 - 510.000000 = -190.000000
    ;320.000000 * 510.000000 = 163200.000000(162816.000000)
    ;320.000000 / 510.000000 = 0.627451
    ;510.000000 / 320.000000 = 1.593750
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 09Fh
    db 80h + EXPONENT_OFFSET + 7
    db 07Ch
    db EXPONENT_OFFSET + 17
    db 03Eh
    db EXPONENT_OFFSET + -1
    db 041h
    db EXPONENT_OFFSET + 0
    db 098h
    ;320.000000 + 509.000000 = 829.000000
    ;320.000000 - 509.000000 = -189.000000
    ;320.000000 * 509.000000 = 162880.000000(162816.000000)
    ;320.000000 / 509.000000 = 0.628684
    ;509.000000 / 320.000000 = 1.590625
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 09Eh
    db 80h + EXPONENT_OFFSET + 7
    db 07Ah
    db EXPONENT_OFFSET + 17
    db 03Eh
    db EXPONENT_OFFSET + -1
    db 041h
    db EXPONENT_OFFSET + 0
    db 097h
    ;320.000000 + 494.000000 = 814.000000
    ;320.000000 - 494.000000 = -174.000000
    ;320.000000 * 494.000000 = 158080.000000(158208.000000)
    ;320.000000 / 494.000000 = 0.647773
    ;494.000000 / 320.000000 = 1.543750
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 097h
    db 80h + EXPONENT_OFFSET + 7
    db 05Ch
    db EXPONENT_OFFSET + 17
    db 035h
    db EXPONENT_OFFSET + -1
    db 04Bh
    db EXPONENT_OFFSET + 0
    db 08Bh
    ;320.000000 + 476.000000 = 796.000000
    ;320.000000 - 476.000000 = -156.000000
    ;320.000000 * 476.000000 = 152320.000000(152064.000000)
    ;320.000000 / 476.000000 = 0.672269
    ;476.000000 / 320.000000 = 1.487500
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 9
    db 08Eh
    db 80h + EXPONENT_OFFSET + 7
    db 038h
    db EXPONENT_OFFSET + 17
    db 029h
    db EXPONENT_OFFSET + -1
    db 058h
    db EXPONENT_OFFSET + 0
    db 07Ch
    ;320.000000 + 463.000000 = 783.000000
    ;320.000000 - 463.000000 = -143.000000
    ;320.000000 * 463.000000 = 148160.000000(147968.000000)
    ;320.000000 / 463.000000 = 0.691145
    ;463.000000 / 320.000000 = 1.446875
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 9
    db 087h
    db 80h + EXPONENT_OFFSET + 7
    db 01Eh
    db EXPONENT_OFFSET + 17
    db 021h
    db EXPONENT_OFFSET + -1
    db 061h
    db EXPONENT_OFFSET + 0
    db 072h
    ;320.000000 + 437.000000 = 757.000000
    ;320.000000 - 437.000000 = -117.000000
    ;320.000000 * 437.000000 = 139840.000000(139776.000000)
    ;320.000000 / 437.000000 = 0.732265
    ;437.000000 / 320.000000 = 1.365625
    db EXPONENT_OFFSET + 8
    db 040h
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 9
    db 07Ah
    db 80h + EXPONENT_OFFSET + 6
    db 0D4h
    db EXPONENT_OFFSET + 17
    db 011h
    db EXPONENT_OFFSET + -1
    db 076h
    db EXPONENT_OFFSET + 0
    db 05Dh
    ;384.000000 + 384.000000 = 768.000000
    ;384.000000 - 384.000000 = 0.000000
    ;384.000000 * 384.000000 = 147456.000000(147456.000000)
    ;384.000000 / 384.000000 = 1.000000
    ;384.000000 / 384.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 9
    db 080h
    db 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 020h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;384.000000 + 511.000000 = 895.000000
    ;384.000000 - 511.000000 = -127.000000
    ;384.000000 * 511.000000 = 196224.000000(196096.000000)
    ;384.000000 / 511.000000 = 0.751468
    ;511.000000 / 384.000000 = 1.330729
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 0BFh
    db 80h + EXPONENT_OFFSET + 6
    db 0FCh
    db EXPONENT_OFFSET + 17
    db 07Fh
    db EXPONENT_OFFSET + -1
    db 080h
    db EXPONENT_OFFSET + 0
    db 054h
    ;384.000000 + 510.000000 = 894.000000
    ;384.000000 - 510.000000 = -126.000000
    ;384.000000 * 510.000000 = 195840.000000(195584.000000)
    ;384.000000 / 510.000000 = 0.752941
    ;510.000000 / 384.000000 = 1.328125
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 0BFh
    db 80h + EXPONENT_OFFSET + 6
    db 0F8h
    db EXPONENT_OFFSET + 17
    db 07Eh
    db EXPONENT_OFFSET + -1
    db 081h
    db EXPONENT_OFFSET + 0
    db 054h
    ;384.000000 + 509.000000 = 893.000000
    ;384.000000 - 509.000000 = -125.000000
    ;384.000000 * 509.000000 = 195456.000000(195072.000000)
    ;384.000000 / 509.000000 = 0.754420
    ;509.000000 / 384.000000 = 1.325521
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 0BEh
    db 80h + EXPONENT_OFFSET + 6
    db 0F4h
    db EXPONENT_OFFSET + 17
    db 07Dh
    db EXPONENT_OFFSET + -1
    db 082h
    db EXPONENT_OFFSET + 0
    db 053h
    ;384.000000 + 494.000000 = 878.000000
    ;384.000000 - 494.000000 = -110.000000
    ;384.000000 * 494.000000 = 189696.000000(189440.000000)
    ;384.000000 / 494.000000 = 0.777328
    ;494.000000 / 384.000000 = 1.286458
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 0B7h
    db 80h + EXPONENT_OFFSET + 6
    db 0B8h
    db EXPONENT_OFFSET + 17
    db 072h
    db EXPONENT_OFFSET + -1
    db 08Dh
    db EXPONENT_OFFSET + 0
    db 049h
    ;384.000000 + 476.000000 = 860.000000
    ;384.000000 - 476.000000 = -92.000000
    ;384.000000 * 476.000000 = 182784.000000(182784.000000)
    ;384.000000 / 476.000000 = 0.806723
    ;476.000000 / 384.000000 = 1.239583
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 9
    db 0AEh
    db 80h + EXPONENT_OFFSET + 6
    db 070h
    db EXPONENT_OFFSET + 17
    db 065h
    db EXPONENT_OFFSET + -1
    db 09Dh
    db EXPONENT_OFFSET + 0
    db 03Dh
    ;384.000000 + 463.000000 = 847.000000
    ;384.000000 - 463.000000 = -79.000000
    ;384.000000 * 463.000000 = 177792.000000(177664.000000)
    ;384.000000 / 463.000000 = 0.829374
    ;463.000000 / 384.000000 = 1.205729
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 9
    db 0A7h
    db 80h + EXPONENT_OFFSET + 6
    db 03Ch
    db EXPONENT_OFFSET + 17
    db 05Bh
    db EXPONENT_OFFSET + -1
    db 0A8h
    db EXPONENT_OFFSET + 0
    db 034h
    ;384.000000 + 437.000000 = 821.000000
    ;384.000000 - 437.000000 = -53.000000
    ;384.000000 * 437.000000 = 167808.000000(167936.000000)
    ;384.000000 / 437.000000 = 0.878719
    ;437.000000 / 384.000000 = 1.138021
    db EXPONENT_OFFSET + 8
    db 080h
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 9
    db 09Ah
    db 80h + EXPONENT_OFFSET + 5
    db 0A8h
    db EXPONENT_OFFSET + 17
    db 048h
    db EXPONENT_OFFSET + -1
    db 0C1h
    db EXPONENT_OFFSET + 0
    db 023h
    ;511.000000 + 511.000000 = 1022.000000
    ;511.000000 - 511.000000 = 0.000000
    ;511.000000 * 511.000000 = 261121.000000(261120.000000)
    ;511.000000 / 511.000000 = 1.000000
    ;511.000000 / 511.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 0FFh
    db 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 0FEh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;510.000000 + 511.000000 = 1021.000000
    ;510.000000 - 511.000000 = -1.000000
    ;510.000000 * 511.000000 = 260610.000000(260608.000000)
    ;510.000000 / 511.000000 = 0.998043
    ;511.000000 / 510.000000 = 1.001961
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 0FEh
    db 80h + EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 0FDh
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + 0
    db 000h
    ;510.000000 + 510.000000 = 1020.000000
    ;510.000000 - 510.000000 = 0.000000
    ;510.000000 * 510.000000 = 260100.000000(260096.000000)
    ;510.000000 / 510.000000 = 1.000000
    ;510.000000 / 510.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 0FEh
    db 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 0FCh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;509.000000 + 511.000000 = 1020.000000
    ;509.000000 - 511.000000 = -2.000000
    ;509.000000 * 511.000000 = 260099.000000(260096.000000)
    ;509.000000 / 511.000000 = 0.996086
    ;511.000000 / 509.000000 = 1.003929
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 0FEh
    db 80h + EXPONENT_OFFSET + 1
    db 000h
    db EXPONENT_OFFSET + 17
    db 0FCh
    db EXPONENT_OFFSET + -1
    db 0FDh
    db EXPONENT_OFFSET + 0
    db 001h
    ;509.000000 + 510.000000 = 1019.000000
    ;509.000000 - 510.000000 = -1.000000
    ;509.000000 * 510.000000 = 259590.000000(259584.000000)
    ;509.000000 / 510.000000 = 0.998039
    ;510.000000 / 509.000000 = 1.001965
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 0FDh
    db 80h + EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 0FBh
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + 0
    db 000h
    ;509.000000 + 509.000000 = 1018.000000
    ;509.000000 - 509.000000 = 0.000000
    ;509.000000 * 509.000000 = 259081.000000(259072.000000)
    ;509.000000 / 509.000000 = 1.000000
    ;509.000000 / 509.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 0FDh
    db 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 0FAh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;494.000000 + 511.000000 = 1005.000000
    ;494.000000 - 511.000000 = -17.000000
    ;494.000000 * 511.000000 = 252434.000000(252416.000000)
    ;494.000000 / 511.000000 = 0.966732
    ;511.000000 / 494.000000 = 1.034413
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 0F6h
    db 80h + EXPONENT_OFFSET + 4
    db 010h
    db EXPONENT_OFFSET + 17
    db 0EDh
    db EXPONENT_OFFSET + -1
    db 0EEh
    db EXPONENT_OFFSET + 0
    db 008h
    ;494.000000 + 510.000000 = 1004.000000
    ;494.000000 - 510.000000 = -16.000000
    ;494.000000 * 510.000000 = 251940.000000(251904.000000)
    ;494.000000 / 510.000000 = 0.968627
    ;510.000000 / 494.000000 = 1.032389
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 0F6h
    db 80h + EXPONENT_OFFSET + 4
    db 000h
    db EXPONENT_OFFSET + 17
    db 0ECh
    db EXPONENT_OFFSET + -1
    db 0EFh
    db EXPONENT_OFFSET + 0
    db 008h
    ;494.000000 + 509.000000 = 1003.000000
    ;494.000000 - 509.000000 = -15.000000
    ;494.000000 * 509.000000 = 251446.000000(251392.000000)
    ;494.000000 / 509.000000 = 0.970530
    ;509.000000 / 494.000000 = 1.030364
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 0F5h
    db 80h + EXPONENT_OFFSET + 3
    db 0E0h
    db EXPONENT_OFFSET + 17
    db 0EBh
    db EXPONENT_OFFSET + -1
    db 0F0h
    db EXPONENT_OFFSET + 0
    db 007h
    ;494.000000 + 494.000000 = 988.000000
    ;494.000000 - 494.000000 = 0.000000
    ;494.000000 * 494.000000 = 244036.000000(243712.000000)
    ;494.000000 / 494.000000 = 1.000000
    ;494.000000 / 494.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 0EEh
    db 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 0DCh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;476.000000 + 511.000000 = 987.000000
    ;476.000000 - 511.000000 = -35.000000
    ;476.000000 * 511.000000 = 243236.000000(243200.000000)
    ;476.000000 / 511.000000 = 0.931507
    ;511.000000 / 476.000000 = 1.073529
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 0EDh
    db 80h + EXPONENT_OFFSET + 5
    db 018h
    db EXPONENT_OFFSET + 17
    db 0DBh
    db EXPONENT_OFFSET + -1
    db 0DCh
    db EXPONENT_OFFSET + 0
    db 012h
    ;476.000000 + 510.000000 = 986.000000
    ;476.000000 - 510.000000 = -34.000000
    ;476.000000 * 510.000000 = 242760.000000(242688.000000)
    ;476.000000 / 510.000000 = 0.933333
    ;510.000000 / 476.000000 = 1.071429
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 0EDh
    db 80h + EXPONENT_OFFSET + 5
    db 010h
    db EXPONENT_OFFSET + 17
    db 0DAh
    db EXPONENT_OFFSET + -1
    db 0DDh
    db EXPONENT_OFFSET + 0
    db 012h
    ;476.000000 + 509.000000 = 985.000000
    ;476.000000 - 509.000000 = -33.000000
    ;476.000000 * 509.000000 = 242284.000000(242176.000000)
    ;476.000000 / 509.000000 = 0.935167
    ;509.000000 / 476.000000 = 1.069328
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 0ECh
    db 80h + EXPONENT_OFFSET + 5
    db 008h
    db EXPONENT_OFFSET + 17
    db 0D9h
    db EXPONENT_OFFSET + -1
    db 0DEh
    db EXPONENT_OFFSET + 0
    db 011h
    ;476.000000 + 494.000000 = 970.000000
    ;476.000000 - 494.000000 = -18.000000
    ;476.000000 * 494.000000 = 235144.000000(235008.000000)
    ;476.000000 / 494.000000 = 0.963563
    ;494.000000 / 476.000000 = 1.037815
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 0E5h
    db 80h + EXPONENT_OFFSET + 4
    db 020h
    db EXPONENT_OFFSET + 17
    db 0CBh
    db EXPONENT_OFFSET + -1
    db 0EDh
    db EXPONENT_OFFSET + 0
    db 009h
    ;476.000000 + 476.000000 = 952.000000
    ;476.000000 - 476.000000 = 0.000000
    ;476.000000 * 476.000000 = 226576.000000(226304.000000)
    ;476.000000 / 476.000000 = 1.000000
    ;476.000000 / 476.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 9
    db 0DCh
    db 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 0BAh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;463.000000 + 511.000000 = 974.000000
    ;463.000000 - 511.000000 = -48.000000
    ;463.000000 * 511.000000 = 236593.000000(236544.000000)
    ;463.000000 / 511.000000 = 0.906067
    ;511.000000 / 463.000000 = 1.103672
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 0E7h
    db 80h + EXPONENT_OFFSET + 5
    db 080h
    db EXPONENT_OFFSET + 17
    db 0CEh
    db EXPONENT_OFFSET + -1
    db 0CFh
    db EXPONENT_OFFSET + 0
    db 01Ah
    ;463.000000 + 510.000000 = 973.000000
    ;463.000000 - 510.000000 = -47.000000
    ;463.000000 * 510.000000 = 236130.000000(236032.000000)
    ;463.000000 / 510.000000 = 0.907843
    ;510.000000 / 463.000000 = 1.101512
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 0E6h
    db 80h + EXPONENT_OFFSET + 5
    db 078h
    db EXPONENT_OFFSET + 17
    db 0CDh
    db EXPONENT_OFFSET + -1
    db 0D0h
    db EXPONENT_OFFSET + 0
    db 019h
    ;463.000000 + 509.000000 = 972.000000
    ;463.000000 - 509.000000 = -46.000000
    ;463.000000 * 509.000000 = 235667.000000(235520.000000)
    ;463.000000 / 509.000000 = 0.909627
    ;509.000000 / 463.000000 = 1.099352
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 0E6h
    db 80h + EXPONENT_OFFSET + 5
    db 070h
    db EXPONENT_OFFSET + 17
    db 0CCh
    db EXPONENT_OFFSET + -1
    db 0D1h
    db EXPONENT_OFFSET + 0
    db 019h
    ;463.000000 + 494.000000 = 957.000000
    ;463.000000 - 494.000000 = -31.000000
    ;463.000000 * 494.000000 = 228722.000000(228864.000000)
    ;463.000000 / 494.000000 = 0.937247
    ;494.000000 / 463.000000 = 1.066955
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 0DEh
    db 80h + EXPONENT_OFFSET + 4
    db 0F0h
    db EXPONENT_OFFSET + 17
    db 0BFh
    db EXPONENT_OFFSET + -1
    db 0DFh
    db EXPONENT_OFFSET + 0
    db 011h
    ;463.000000 + 476.000000 = 939.000000
    ;463.000000 - 476.000000 = -13.000000
    ;463.000000 * 476.000000 = 220388.000000(220160.000000)
    ;463.000000 / 476.000000 = 0.972689
    ;476.000000 / 463.000000 = 1.028078
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 9
    db 0D5h
    db 80h + EXPONENT_OFFSET + 3
    db 0A0h
    db EXPONENT_OFFSET + 17
    db 0AEh
    db EXPONENT_OFFSET + -1
    db 0F2h
    db EXPONENT_OFFSET + 0
    db 007h
    ;463.000000 + 463.000000 = 926.000000
    ;463.000000 - 463.000000 = 0.000000
    ;463.000000 * 463.000000 = 214369.000000(214016.000000)
    ;463.000000 / 463.000000 = 1.000000
    ;463.000000 / 463.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 9
    db 0CFh
    db 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 0A2h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;437.000000 + 511.000000 = 948.000000
    ;437.000000 - 511.000000 = -74.000000
    ;437.000000 * 511.000000 = 223307.000000(223232.000000)
    ;437.000000 / 511.000000 = 0.855186
    ;511.000000 / 437.000000 = 1.169336
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 8
    db 0FFh
    db EXPONENT_OFFSET + 9
    db 0DAh
    db 80h + EXPONENT_OFFSET + 6
    db 028h
    db EXPONENT_OFFSET + 17
    db 0B4h
    db EXPONENT_OFFSET + -1
    db 0B5h
    db EXPONENT_OFFSET + 0
    db 02Bh
    ;437.000000 + 510.000000 = 947.000000
    ;437.000000 - 510.000000 = -73.000000
    ;437.000000 * 510.000000 = 222870.000000(222720.000000)
    ;437.000000 / 510.000000 = 0.856863
    ;510.000000 / 437.000000 = 1.167048
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 8
    db 0FEh
    db EXPONENT_OFFSET + 9
    db 0D9h
    db 80h + EXPONENT_OFFSET + 6
    db 024h
    db EXPONENT_OFFSET + 17
    db 0B3h
    db EXPONENT_OFFSET + -1
    db 0B6h
    db EXPONENT_OFFSET + 0
    db 02Ah
    ;437.000000 + 509.000000 = 946.000000
    ;437.000000 - 509.000000 = -72.000000
    ;437.000000 * 509.000000 = 222433.000000(222208.000000)
    ;437.000000 / 509.000000 = 0.858546
    ;509.000000 / 437.000000 = 1.164760
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 8
    db 0FDh
    db EXPONENT_OFFSET + 9
    db 0D9h
    db 80h + EXPONENT_OFFSET + 6
    db 020h
    db EXPONENT_OFFSET + 17
    db 0B2h
    db EXPONENT_OFFSET + -1
    db 0B7h
    db EXPONENT_OFFSET + 0
    db 02Ah
    ;437.000000 + 494.000000 = 931.000000
    ;437.000000 - 494.000000 = -57.000000
    ;437.000000 * 494.000000 = 215878.000000(215552.000000)
    ;437.000000 / 494.000000 = 0.884615
    ;494.000000 / 437.000000 = 1.130435
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 8
    db 0EEh
    db EXPONENT_OFFSET + 9
    db 0D1h
    db 80h + EXPONENT_OFFSET + 5
    db 0C8h
    db EXPONENT_OFFSET + 17
    db 0A5h
    db EXPONENT_OFFSET + -1
    db 0C4h
    db EXPONENT_OFFSET + 0
    db 021h
    ;437.000000 + 476.000000 = 913.000000
    ;437.000000 - 476.000000 = -39.000000
    ;437.000000 * 476.000000 = 208012.000000(207872.000000)
    ;437.000000 / 476.000000 = 0.918067
    ;476.000000 / 437.000000 = 1.089245
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 8
    db 0DCh
    db EXPONENT_OFFSET + 9
    db 0C8h
    db 80h + EXPONENT_OFFSET + 5
    db 038h
    db EXPONENT_OFFSET + 17
    db 096h
    db EXPONENT_OFFSET + -1
    db 0D6h
    db EXPONENT_OFFSET + 0
    db 016h
    ;437.000000 + 463.000000 = 900.000000
    ;437.000000 - 463.000000 = -26.000000
    ;437.000000 * 463.000000 = 202331.000000(202240.000000)
    ;437.000000 / 463.000000 = 0.943844
    ;463.000000 / 437.000000 = 1.059497
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 8
    db 0CFh
    db EXPONENT_OFFSET + 9
    db 0C2h
    db 80h + EXPONENT_OFFSET + 4
    db 0A0h
    db EXPONENT_OFFSET + 17
    db 08Bh
    db EXPONENT_OFFSET + -1
    db 0E3h
    db EXPONENT_OFFSET + 0
    db 00Fh
    ;437.000000 + 437.000000 = 874.000000
    ;437.000000 - 437.000000 = 0.000000
    ;437.000000 * 437.000000 = 190969.000000(190464.000000)
    ;437.000000 / 437.000000 = 1.000000
    ;437.000000 / 437.000000 = 1.000000
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 8
    db 0B5h
    db EXPONENT_OFFSET + 9
    db 0B5h
    db 0
    db 000h
    db EXPONENT_OFFSET + 17
    db 074h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h

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

    loda,r0 FStack+2-PAGE1
    stra,r0 FStack+0-PAGE1
    loda,r0 FStack+3-PAGE1
    stra,r0 FStack+1-PAGE1

    lodi,r1 0
    lodi,r2 4
    bsta,un fadd

    comi,r1 0
    bcfa,eq failed_unit_test
    comi,r2 4
    bcfa,eq failed_unit_test

    lodi,r0 041h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 4
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fadd_zero_test3
    comi,r0 80h
    bctr,eq _fadd_zero_test3

    eora,r0 Sign
    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 042h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 5
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fadd_next_test3

_fadd_zero_test3:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fadd_next_test3:

    loda,r0 FStack+4-PAGE1
    stra,r0 FStack+0-PAGE1
    loda,r0 FStack+5-PAGE1
    stra,r0 FStack+1-PAGE1

    lodi,r1 2
    lodi,r2 0
    bsta,un fadd

    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 0
    bcfa,eq failed_unit_test

    lodi,r0 041h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 4
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fadd_zero_test4
    comi,r0 80h
    bctr,eq _fadd_zero_test4

    eora,r0 Sign
    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 042h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 5
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fadd_next_test4

_fadd_zero_test4:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fadd_next_test4:

    lodi,r1 2
    lodi,r2 4

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

    lodi,r0 0D7h            ;マーカー
    stra,r0 SCRUPDATA

    loda,r0 FStack+4-PAGE1
    stra,r0 FStack+0-PAGE1
    loda,r0 FStack+5-PAGE1
    stra,r0 FStack+1-PAGE1

    lodi,r1 0
    lodi,r2 2

    bsta,un fsub
    comi,r1 0
    bcfa,eq failed_unit_test
    comi,r2 2
    bcfa,eq failed_unit_test

    lodi,r3 6
    loda,r0 *DataOffset0,r3
    
    comi,r0 00h
    bctr,eq _fsub_zero_test3
    comi,r0 80h
    bctr,eq _fsub_zero_test3

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

    bctr,un _fsub_next_test3

_fsub_zero_test3:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test
    
_fsub_next_test3:

    lodi,r0 0D7h            ;マーカー
    stra,r0 SCRUPDATA

    loda,r0 FStack+2-PAGE1
    stra,r0 FStack+0-PAGE1
    loda,r0 FStack+3-PAGE1
    stra,r0 FStack+1-PAGE1

    lodi,r1 4
    lodi,r2 0

    bsta,un fsub
    comi,r1 4
    bcfa,eq failed_unit_test
    comi,r2 0
    bcfa,eq failed_unit_test

    lodi,r3 6
    loda,r0 *DataOffset0,r3
    
    comi,r0 00h
    bctr,eq _fsub_zero_test4
    comi,r0 80h
    bctr,eq _fsub_zero_test4

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

    bctr,un _fsub_next_test4

_fsub_zero_test4:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test
    
_fsub_next_test4:

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

    lodi,r0 0DBh            ;マーカー
    stra,r0 SCRUPDATA

    loda,r0 FStack+4-PAGE1
    stra,r0 FStack+0-PAGE1
    loda,r0 FStack+5-PAGE1
    stra,r0 FStack+1-PAGE1

    lodi,r1 0
    lodi,r2 2
    bsta,un fmul

    lodi,r3 8
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fmul_zero_test3
    comi,r0 80h
    bctr,eq _fmul_zero_test3

    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0DCh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 9
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fmul_next_test3

_fmul_zero_test3:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fmul_next_test3:

    lodi,r0 0DBh            ;マーカー
    stra,r0 SCRUPDATA

    loda,r0 FStack+2-PAGE1
    stra,r0 FStack+0-PAGE1
    loda,r0 FStack+3-PAGE1
    stra,r0 FStack+1-PAGE1

    lodi,r1 4
    lodi,r2 0
    bsta,un fmul

    lodi,r3 8
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fmul_zero_test4
    comi,r0 80h
    bctr,eq _fmul_zero_test4

    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0DCh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r3 9
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fmul_next_test4

_fmul_zero_test4:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fmul_next_test4:

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

    lodi,r0 0DFh            ;マーカーF
    stra,r0 SCRUPDATA

    lodi,r1 2
    bsta,un fcom0
    bcta,eq _fdiv_next_test3     ;除数が０ならテストしない

    loda,r0 FStack+4-PAGE1
    stra,r0 FStack+0-PAGE1
    loda,r0 FStack+5-PAGE1
    stra,r0 FStack+1-PAGE1

    lodi,r1 0
    lodi,r2 2
    bsta,un fdiv

    lodi,r3 12
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fdiv_zero_test3
    comi,r0 80h
    bctr,eq _fdiv_zero_test3

    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0E0h            ;マーカーG
    stra,r0 SCRUPDATA

    lodi,r3 13
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fdiv_next_test3

_fdiv_zero_test3:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fdiv_next_test3:

    lodi,r0 0DFh            ;マーカーF
    stra,r0 SCRUPDATA

    lodi,r1 2
    bsta,un fcom0
    bcta,eq _fdiv_next_test4     ;除数が０ならテストしない

    loda,r0 FStack+2-PAGE1
    stra,r0 FStack+0-PAGE1
    loda,r0 FStack+3-PAGE1
    stra,r0 FStack+1-PAGE1

    lodi,r1 4
    lodi,r2 0
    bsta,un fdiv

    lodi,r3 12
    loda,r0 *DataOffset0,r3

    comi,r0 00h
    bctr,eq _fdiv_zero_test4
    comi,r0 80h
    bctr,eq _fdiv_zero_test4

    coma,r0 FStack+0-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0E0h            ;マーカーG
    stra,r0 SCRUPDATA

    lodi,r3 13
    loda,r0 *DataOffset0,r3
    coma,r0 FStack+1-PAGE1
    bcfa,eq failed_unit_test
 
    bctr,un _fdiv_next_test4

_fdiv_zero_test4:
    loda,r0 FStack+0-PAGE1
    andi,r0 7fh
    bcfa,eq failed_unit_test

_fdiv_next_test4:

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
