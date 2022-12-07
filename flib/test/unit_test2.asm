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
    Temporary2      equ 18FAh
    Temporary3      equ 18FBh
    Temporary0P1    equ 18F8h + 8*1024
    Temporary1P1    equ 18F9h + 8*1024
    Temporary2P1    equ 18FAh + 8*1024
    Temporary3P1    equ 18FBh + 8*1024

    FStack equ 1AD0h + PAGE1        ;$1AD0..$1AFF are user RAM3 - 48 Byte


    ;-------
    ;vadd3のテスト
    bcta,un _vadd3_test
_vadd3_data:
    ;(1,2,3)
    db EXPONENT_OFFSET+0
    db 000h
    db EXPONENT_OFFSET+1
    db 000h
    db EXPONENT_OFFSET+1
    db 080h
    ;(4,5,6)
    db EXPONENT_OFFSET+2
    db 000h
    db EXPONENT_OFFSET+2
    db 040h
    db EXPONENT_OFFSET+2
    db 080h
    ;(5,7,9)
    db EXPONENT_OFFSET+2
    db 040h
    db EXPONENT_OFFSET+2
    db 0C0h
    db EXPONENT_OFFSET+3
    db 020h

_vadd3_test:

    lodi,r0 0D0h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 12
_vadd3_test_:
    loda,r0 _vadd3_data,r1-
    stra,r0 FStack+8-PAGE1,r1
    brnr,r1 _vadd3_test_

    lodi,r0 2
    lodi,r1 8
    lodi,r2 14
    bsta,un vadd3

    comi,r1 8+4
    bcfa,eq failed_unit_test
    comi,r2 14+4
    bcfa,eq failed_unit_test

    lodi,r0 0D1h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 6
_vadd3_test2_:
    loda,r0 _vadd3_data+12,r1-
    coma,r0 FStack+2-PAGE1,r1
    bsfa,eq failed_unit_test
    brnr,r1 _vadd3_test2_


    ;-------
    ;vsub3のテスト
    bctr,un _vsub3_test
_vsub3_data:
    ;(1,2,3)
    db EXPONENT_OFFSET+0
    db 000h
    db EXPONENT_OFFSET+1
    db 000h
    db EXPONENT_OFFSET+1
    db 080h
    ;(4,6,8)
    db EXPONENT_OFFSET+2
    db 000h
    db EXPONENT_OFFSET+2
    db 080h
    db EXPONENT_OFFSET+3
    db 000h
    ;(-3,-4,-5)
    db EXPONENT_OFFSET+1 + 80h
    db 080h
    db EXPONENT_OFFSET+2 + 80h
    db 000h
    db EXPONENT_OFFSET+2 + 80h
    db 040h
_vsub3_test:

    lodi,r0 0D2h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 12
_vsub3_test_:
    loda,r0 _vsub3_data,r1-
    stra,r0 FStack+8-PAGE1,r1
    brnr,r1 _vsub3_test_

    lodi,r0 2
    lodi,r1 8
    lodi,r2 14
    bsta,un vsub3
    
    comi,r1 8+4
    bcfa,eq failed_unit_test
    comi,r2 14+4
    bcfa,eq failed_unit_test

    lodi,r0 0D3h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 6
_vsub3_test2_:
    loda,r0 _vsub3_data+12,r1-
    coma,r0 FStack+2-PAGE1,r1
    bsfa,eq failed_unit_test
    brnr,r1 _vsub3_test2_


    ;-------
    ;vsum3のテスト
    bcta,un _vsum3_test
_vsum3_data:
    ;(1+eps,1+eps,2+2eps)
    db EXPONENT_OFFSET+0
    db 001h
    db EXPONENT_OFFSET+1
    db 001h
    db EXPONENT_OFFSET+0
    db 001h
    ;4+4eps
    db EXPONENT_OFFSET+2
    db 001h

_vsum3_test:

    lodi,r0 0D4h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 6
_vsum3_test_:
    loda,r0 _vsum3_data,r1-
    stra,r0 FStack+2-PAGE1,r1
    brnr,r1 _vsum3_test_

    lodi,r1 2
    bsta,un vsum3

    lodi,r0 0D5h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 2
_vsum3_test2_:
    loda,r0 _vsum3_data+6,r1-
    coma,r0 FStack+0-PAGE1,r1
    bsfa,eq failed_unit_test
    brnr,r1 _vsum3_test2_

    
    ;-------
    ;vmul3のテスト
    bcta,un _vmul3_test
_vmul3_data:
    ;(1,2,3,4)
    db EXPONENT_OFFSET+0
    db 000h
    db EXPONENT_OFFSET+1
    db 000h
    db EXPONENT_OFFSET+1
    db 080h
    db EXPONENT_OFFSET+2
    db 000h
    ;(4,8,12)
    db EXPONENT_OFFSET+2
    db 000h
    db EXPONENT_OFFSET+3
    db 000h
    db EXPONENT_OFFSET+3
    db 080h

_vmul3_test:

    lodi,r0 0D4h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 8
_vmul3_test_:
    loda,r0 _vmul3_data,r1-
    stra,r0 FStack+2-PAGE1,r1
    brnr,r1 _vmul3_test_

    lodi,r0 10
    lodi,r1 8
    lodi,r2 2
    bsta,un vmul3

    lodi,r0 0D5h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 6
_vmul3_test2_:
    loda,r0 _vmul3_data+8,r1-
    coma,r0 FStack+10-PAGE1,r1
    bsfa,eq failed_unit_test
    brnr,r1 _vmul3_test2_

    ;-------
    ;fsqのテスト
    bcta,un _fsq_data_end
_fsq_data:
    ;0^2=0
    db 0
    db 0
    db 0
    db 0
    ;-0^2=0
    db 80h
    db 0
    db 0
    db 0
    ;-3.992188^2 = 15.937561
    db 80h + EXPONENT_OFFSET + 1
    db 0FFh
    db EXPONENT_OFFSET + 3
    db 0FEh
    ;-15.937500^2 = 254.003906
    db 80h + EXPONENT_OFFSET + 3
    db 0FEh
    db EXPONENT_OFFSET + 7
    db 0FCh
    ;-65.000000^2 = 4225.000000
    db 80h + EXPONENT_OFFSET + 6
    db 004h
    db EXPONENT_OFFSET + 12
    db 008h
    ;-16.125000^2 = 260.015625
    db 80h + EXPONENT_OFFSET + 4
    db 002h
    db EXPONENT_OFFSET + 8
    db 004h
    ;-2.007812^2 = 4.031311
    db 80h + EXPONENT_OFFSET + 1
    db 001h
    db EXPONENT_OFFSET + 2
    db 002h
    ;16.000000^2 = 256.000000
    db EXPONENT_OFFSET + 4
    db 000h
    db EXPONENT_OFFSET + 8
    db 000h
    ;64.250000^2 = 4128.062500
    db EXPONENT_OFFSET + 6
    db 001h
    db EXPONENT_OFFSET + 12
    db 002h
    ;64.500000^2 = 4160.250000
    db EXPONENT_OFFSET + 6
    db 002h
    db EXPONENT_OFFSET + 12
    db 004h
    ;4.046875^2 = 16.377197
    db EXPONENT_OFFSET + 2
    db 003h
    db EXPONENT_OFFSET + 4
    db 006h
    ;1.410156^2 = 1.988541
    db EXPONENT_OFFSET + 0
    db 069h
    db EXPONENT_OFFSET + 0
    db 0FDh
    ;2.828125^2 = 7.998291
    db EXPONENT_OFFSET + 1
    db 06Ah
    db EXPONENT_OFFSET + 2
    db 0FFh
    ;2.835938^2 = 8.042542
    db EXPONENT_OFFSET + 1
    db 06Bh
    db EXPONENT_OFFSET + 3
    db 001h
    ;2.843750^2 = 8.086914
    db EXPONENT_OFFSET + 1
    db 06Ch
    db EXPONENT_OFFSET + 3
    db 002h
    ;11.406250^2 = 130.102539
    db EXPONENT_OFFSET + 3
    db 06Dh
    db EXPONENT_OFFSET + 7
    db 004h
    ;3.976562^2 = 15.813049
    db EXPONENT_OFFSET + 1
    db 0FDh
    db EXPONENT_OFFSET + 3
    db 0FAh
    ;15.937500^2 = 254.003906
    db EXPONENT_OFFSET + 3
    db 0FEh
    db EXPONENT_OFFSET + 7
    db 0FCh
    ;15.968750^2 = 255.000977
    db EXPONENT_OFFSET + 3
    db 0FFh
    db EXPONENT_OFFSET + 7
    db 0FEh
    ;-0.998047^2 = 0.996098
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db EXPONENT_OFFSET + -1
    db 0FEh
    ;-0.249023^2 = 0.062013
    db 80h + EXPONENT_OFFSET + -3
    db 0FEh
    db EXPONENT_OFFSET + -5
    db 0FCh
    ;-0.015869^2 = 0.000252
    db 80h + EXPONENT_OFFSET + -6
    db 004h
    db EXPONENT_OFFSET + -12
    db 008h
    ;-0.062988^2 = 0.003968
    db 80h + EXPONENT_OFFSET + -4
    db 002h
    db EXPONENT_OFFSET + -8
    db 004h
    ;-0.501953^2 = 0.251957
    db 80h + EXPONENT_OFFSET + -1
    db 001h
    db EXPONENT_OFFSET + -2
    db 002h
    ;0.062500^2 = 0.003906
    db EXPONENT_OFFSET + -4
    db 000h
    db EXPONENT_OFFSET + -8
    db 000h
    ;0.015686^2 = 0.000246
    db EXPONENT_OFFSET + -6
    db 001h
    db EXPONENT_OFFSET + -12
    db 002h
    ;0.015747^2 = 0.000248
    db EXPONENT_OFFSET + -6
    db 002h
    db EXPONENT_OFFSET + -12
    db 004h
    ;0.252930^2 = 0.063973
    db EXPONENT_OFFSET + -2
    db 003h
    db EXPONENT_OFFSET + -4
    db 006h
    ;1.410156^2 = 1.988541
    db EXPONENT_OFFSET + 0
    db 069h
    db EXPONENT_OFFSET + 0
    db 0FDh
    ;0.707031^2 = 0.499893
    db EXPONENT_OFFSET + -1
    db 06Ah
    db EXPONENT_OFFSET + -2
    db 0FFh
    ;0.708984^2 = 0.502659
    db EXPONENT_OFFSET + -1
    db 06Bh
    db EXPONENT_OFFSET + -1
    db 001h
    ;0.710938^2 = 0.505432
    db EXPONENT_OFFSET + -1
    db 06Ch
    db EXPONENT_OFFSET + -1
    db 002h
    ;0.178223^2 = 0.031763
    db EXPONENT_OFFSET + -3
    db 06Dh
    db EXPONENT_OFFSET + -5
    db 004h
    ;0.994141^2 = 0.988316
    db EXPONENT_OFFSET + -1
    db 0FDh
    db EXPONENT_OFFSET + -1
    db 0FAh
    ;0.249023^2 = 0.062013
    db EXPONENT_OFFSET + -3
    db 0FEh
    db EXPONENT_OFFSET + -5
    db 0FCh
    ;0.249512^2 = 0.062256
    db EXPONENT_OFFSET + -3
    db 0FFh
    db EXPONENT_OFFSET + -5
    db 0FEh
_fsq_data_end:

    lodi,r3 0

_fsq_test:
    lodi,r0 0D6h            ;マーカー
    stra,r0 SCRUPDATA

    loda,r0 _fsq_data+0,r3
    stra,r0 FStack+2-PAGE1
    loda,r0 _fsq_data+1,r3
    stra,r0 FStack+3-PAGE1

    lodi,r1 2
    lodi,r2 4
    bsta,un fsq
    
    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 4
    bcfa,eq failed_unit_test

    lodi,r0 0D7h            ;マーカー
    stra,r0 SCRUPDATA

    loda,r0 _fsq_data+2,r3
    coma,r0 FStack+4-PAGE1
    bcfa,eq failed_unit_test

    lodi,r0 0D8h            ;マーカー
    stra,r0 SCRUPDATA

    loda,r0 _fsq_data+3,r3
    coma,r0 FStack+5-PAGE1
    bcfa,eq failed_unit_test

    addi,r3 4
    comi,r3 _fsq_data_end-_fsq_data
    bcfa,eq _fsq_test


    ;-------
    ;vnorm2のテスト
    bctr,un _vnorm2_test
_vnorm2_data:
    ;(2,3,4)
    db EXPONENT_OFFSET+1
    db 000h
    db EXPONENT_OFFSET+1
    db 080h
    db EXPONENT_OFFSET+2
    db 000h
    ;2^2+3^2+4^2=29 
    db EXPONENT_OFFSET+4
    db 0D0h
_vnorm2_test:

    lodi,r0 0D9h            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 6
_vnorm2_test_:
    loda,r0 _vnorm2_data,r1-
    stra,r0 FStack+8-PAGE1,r1
    brnr,r1 _vnorm2_test_

    lodi,r1 8
    bsta,un vnorm2

    lodi,r0 0DAh            ;マーカー
    stra,r0 SCRUPDATA
    
    loda,r0 _vnorm2_data+6
    coma,r0 FStack+0-PAGE1
    bsfa,eq failed_unit_test

    loda,r0 _vnorm2_data+7
    coma,r0 FStack+1-PAGE1
    bsfa,eq failed_unit_test

    ;-------
    ;vdotのテスト
    bctr,un _vdot_test
_vdot_data:
    ;(2,3,4)
    db EXPONENT_OFFSET+1
    db 000h
    db EXPONENT_OFFSET+1
    db 080h
    db EXPONENT_OFFSET+2
    db 000h
    ;(5,6,7)
    db EXPONENT_OFFSET+2
    db 040h
    db EXPONENT_OFFSET+2
    db 080h
    db EXPONENT_OFFSET+2
    db 0C0h
    ;2*5+3*6+4*7=56
    db EXPONENT_OFFSET+5
    db 0C0h
_vdot_test:

    lodi,r0 0DBh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 12
_vdot_test_:
    loda,r0 _vdot_data,r1-
    stra,r0 FStack+8-PAGE1,r1
    brnr,r1 _vdot_test_

    lodi,r1 8
    lodi,r2 14
    bsta,un vdot3

    lodi,r0 0DCh            ;マーカー
    stra,r0 SCRUPDATA
    
    loda,r0 _vdot_data+12
    coma,r0 FStack+0-PAGE1
    bsfa,eq failed_unit_test

    loda,r0 _vdot_data+13
    coma,r0 FStack+1-PAGE1
    bsfa,eq failed_unit_test

    ;-------
    ;fminmaxのテスト
    bcta,un _fminmax_test
_fminmax_data:
    ;-18410715276690587648.000000 -18410715276690587648.000000
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    ;-18410715276690587648.000000 -9259400833873739776.000000
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    ;-1.996094 -18410715276690587648.000000
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    ;-1.003906 -18410715276690587648.000000
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    ;-18410715276690587648.000000 -0.000000
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    ;-0.000000 -18410715276690587648.000000
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 -18410715276690587648.000000
    db EXPONENT_OFFSET + -63
    db 000h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 000h
    ;0.000000 -18410715276690587648.000000
    db EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 -18410715276690587648.000000
    db EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;1.000000 -18410715276690587648.000000
    db EXPONENT_OFFSET + 0
    db 000h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 000h
    ;-18410715276690587648.000000 1.003906
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    ;-18410715276690587648.000000 1.996094
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;-18410715276690587648.000000 9223372036854775808.000000
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 000h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 000h
    ;-18410715276690587648.000000 9259400833873739776.000000
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 001h
    ;-18410715276690587648.000000 18410715276690587648.000000
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;-9259400833873739776.000000 -9259400833873739776.000000
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    ;-9259400833873739776.000000 -1.996094
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    ;-1.003906 -9259400833873739776.000000
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    ;-9259400833873739776.000000 -0.000000
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    ;-0.000000 -9259400833873739776.000000
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    ;-9259400833873739776.000000 0.000000
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + -63
    db 000h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + -63
    db 000h
    ;0.000000 -9259400833873739776.000000
    db EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 -9259400833873739776.000000
    db EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;-9259400833873739776.000000 1.000000
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h
    ;1.003906 -9259400833873739776.000000
    db EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    ;1.996094 -9259400833873739776.000000
    db EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;-9259400833873739776.000000 9223372036854775808.000000
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 000h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 000h
    ;9259400833873739776.000000 -9259400833873739776.000000
    db EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    ;18410715276690587648.000000 -9259400833873739776.000000
    db EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;-1.996094 -1.996094
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    ;-1.996094 -1.003906
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    ;-0.000000 -1.996094
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    ;-1.996094 -0.000000
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 -1.996094
    db EXPONENT_OFFSET + -63
    db 000h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 000h
    ;-1.996094 0.000000
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 -1.996094
    db EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;-1.996094 1.000000
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 000h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 000h
    ;-1.996094 1.003906
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    ;-1.996094 1.996094
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;9223372036854775808.000000 -1.996094
    db EXPONENT_OFFSET + 63
    db 000h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 000h
    ;-1.996094 9259400833873739776.000000
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 001h
    ;-1.996094 18410715276690587648.000000
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;-1.003906 -1.003906
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    ;-1.003906 -0.000000
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    ;-1.003906 -0.000000
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 -1.003906
    db EXPONENT_OFFSET + -63
    db 000h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + -63
    db 000h
    ;-1.003906 0.000000
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    ;-1.003906 0.000000
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;-1.003906 1.000000
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h
    ;1.003906 -1.003906
    db EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    ;-1.003906 1.996094
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;9223372036854775808.000000 -1.003906
    db EXPONENT_OFFSET + 63
    db 000h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 63
    db 000h
    ;9259400833873739776.000000 -1.003906
    db EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    ;-1.003906 18410715276690587648.000000
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;-0.000000 -0.000000
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    ;-0.000000 -0.000000
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    ;-0.000000 0.000000
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 000h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 000h
    ;-0.000000 0.000000
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 001h
    ;-0.000000 0.000000
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;1.000000 -0.000000
    db EXPONENT_OFFSET + 0
    db 000h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 000h
    ;1.003906 -0.000000
    db EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    ;-0.000000 1.996094
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;9223372036854775808.000000 -0.000000
    db EXPONENT_OFFSET + 63
    db 000h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 000h
    ;9259400833873739776.000000 -0.000000
    db EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 001h
    ;18410715276690587648.000000 -0.000000
    db EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;-0.000000 -0.000000
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 -0.000000
    db EXPONENT_OFFSET + -63
    db 000h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 000h
    ;0.000000 -0.000000
    db EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 -0.000000
    db EXPONENT_OFFSET + -63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;1.000000 -0.000000
    db EXPONENT_OFFSET + 0
    db 000h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h
    ;1.003906 -0.000000
    db EXPONENT_OFFSET + 0
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    ;-0.000000 1.996094
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;9223372036854775808.000000 -0.000000
    db EXPONENT_OFFSET + 63
    db 000h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 63
    db 000h
    ;-0.000000 9259400833873739776.000000
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    ;18410715276690587648.000000 -0.000000
    db EXPONENT_OFFSET + 63
    db 0FFh
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db 80h + EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;0.000000 0.000000
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    ;0.000000 0.000000
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 0.000000
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;0.000000 1.000000
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;1.003906 0.000000
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 0
    db 001h
    ;0.000000 1.996094
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;0.000000 9223372036854775808.000000
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 63
    db 000h
    ;9259400833873739776.000000 0.000000
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 63
    db 001h
    ;18410715276690587648.000000 0.000000
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + -63
    db 000h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;0.000000 0.000000
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    ;0.000000 0.000000
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;1.000000 0.000000
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h
    ;1.003906 0.000000
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    ;0.000000 1.996094
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;9223372036854775808.000000 0.000000
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 63
    db 000h
    ;9259400833873739776.000000 0.000000
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    ;0.000000 18410715276690587648.000000
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;0.000000 0.000000
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    ;0.000000 1.000000
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 000h
    ;0.000000 1.003906
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    ;1.996094 0.000000
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;9223372036854775808.000000 0.000000
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 000h
    ;9259400833873739776.000000 0.000000
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 001h
    ;0.000000 18410715276690587648.000000
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + -63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;1.000000 1.000000
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    ;1.000000 1.003906
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 001h
    ;1.000000 1.996094
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;1.000000 9223372036854775808.000000
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 63
    db 000h
    ;9259400833873739776.000000 1.000000
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 63
    db 001h
    ;18410715276690587648.000000 1.000000
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;1.003906 1.003906
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    ;1.003906 1.996094
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;9223372036854775808.000000 1.003906
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 63
    db 000h
    ;1.003906 9259400833873739776.000000
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    ;18410715276690587648.000000 1.003906
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 0
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;1.996094 1.996094
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    ;1.996094 9223372036854775808.000000
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 000h
    ;9259400833873739776.000000 1.996094
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 001h
    ;18410715276690587648.000000 1.996094
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 0
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;9223372036854775808.000000 9223372036854775808.000000
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 63
    db 000h
    ;9223372036854775808.000000 9259400833873739776.000000
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 63
    db 001h
    ;9223372036854775808.000000 18410715276690587648.000000
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 000h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;9259400833873739776.000000 9259400833873739776.000000
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 001h
    ;9259400833873739776.000000 18410715276690587648.000000
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 001h
    db EXPONENT_OFFSET + 63
    db 0FFh
    ;18410715276690587648.000000 18410715276690587648.000000
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
    db EXPONENT_OFFSET + 63
    db 0FFh
_fminmax_data_end:
_fminmax_test:

    lodi,r0 _fminmax_data >> 8
    stra,r0 DataOffset0
    lodi,r0 _fminmax_data & 255
    stra,r0 DataOffset1

    lodi,r0 0DDh            ;マーカー
    stra,r0 SCRUPDATA

_fminmax_test_:
    

    lodi,r0 0DEh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 8
_fminmax_test_copy:
    loda,r0 *DataOffset0,r1-
    stra,r0 FStack+2-PAGE1,r1
    brnr,r1 _fminmax_test_copy

    lodi,r0 0DFh            ;マーカー
    stra,r0 SCRUPDATA

    ;FStack+10 = min(FStack+2,FStack+4)
    lodi,r1 2
    lodi,r2 4
    lodi,r3 10
    bsta,un fmin        

    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 4
    bcfa,eq failed_unit_test
    comi,r3 10
    bcfa,eq failed_unit_test

    lodi,r1 10      
    lodi,r2 6       ;correct min 
    bsta,un fcom
    bcfa,eq failed_unit_test
    
    comi,r1 10
    bcfa,eq failed_unit_test
    comi,r2 6
    bcfa,eq failed_unit_test
    
    ;FStack+12 = min(FStack+4,FStack+2)
    lodi,r1 4
    lodi,r2 2
    lodi,r3 12
    bsta,un fmin        

    comi,r1 4
    bcfa,eq failed_unit_test
    comi,r2 2
    bcfa,eq failed_unit_test
    comi,r3 12
    bcfa,eq failed_unit_test

    lodi,r1 6       ;correct min 
    lodi,r2 12      
    bsta,un fcom
    bcfa,eq failed_unit_test

    comi,r1 6
    bcfa,eq failed_unit_test
    comi,r2 12
    bcfa,eq failed_unit_test

    ;FStack+14 = max(FStack+2,FStack+4)
    lodi,r1 2
    lodi,r2 4
    lodi,r3 14
    bsta,un fmax

    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 4
    bcfa,eq failed_unit_test
    comi,r3 14
    bcfa,eq failed_unit_test

    lodi,r1 8    ;correct max
    lodi,r2 14       
    bsta,un fcom
    bcfa,eq failed_unit_test
    
    comi,r1 8
    bcfa,eq failed_unit_test
    comi,r2 14
    bcfa,eq failed_unit_test
    
    ;FStack+16 = max(FStack+4,FStack+2)
    lodi,r1 4
    lodi,r2 2
    lodi,r3 16
    bsta,un fmax

    comi,r1 4
    bcfa,eq failed_unit_test
    comi,r2 2
    bcfa,eq failed_unit_test
    comi,r3 16
    bcfa,eq failed_unit_test

    lodi,r1 16      
    lodi,r2 8       ;correct max
    bsta,un fcom
    bcfa,eq failed_unit_test

    comi,r1 16
    bcfa,eq failed_unit_test
    comi,r2 8
    bcfa,eq failed_unit_test


    loda,r0 DataOffset1
    addi,r0 8
    stra,r0 DataOffset1
    tpsl C
    bcfr,eq _fminmax_test_not_ovf
    loda,r0 DataOffset0
    addi,r0 1
    stra,r0 DataOffset0
_fminmax_test_not_ovf:

    lodi,r0 _fminmax_data_end & 255
    coma,r0 DataOffset1
    bcfa,eq _fminmax_test_

    lodi,r0 _fminmax_data_end >> 8
    coma,r0 DataOffset0
    bcfa,eq _fminmax_test_

    ;-------
    ;fadd_mantissaのテスト
    bcta,un _fadd_mantissa_test
_fadd_mantissa_test_data:
    ;1.0, +1, 1.0+eps
    db EXPONENT_OFFSET
    db 0
    db 1
    db EXPONENT_OFFSET
    db 1
    ;1.0, +0, 1.0+eps
    db EXPONENT_OFFSET
    db 0
    db 0
    db EXPONENT_OFFSET
    db 0
    ;2.0, +255, 2.99
    db EXPONENT_OFFSET+1
    db 0
    db 255
    db EXPONENT_OFFSET+1
    db 255
    ;1.00390625, +254, 1.996
    db EXPONENT_OFFSET
    db 1
    db 254
    db EXPONENT_OFFSET
    db 255
    ;1.00390625, +255, 2.0
    db EXPONENT_OFFSET
    db 1
    db 255
    db EXPONENT_OFFSET+1
    db 0
    ;1.996, +1, 2.0
    db EXPONENT_OFFSET
    db 255
    db 1
    db EXPONENT_OFFSET+1
    db 0
    ;1.996, +0, 1.996
    db EXPONENT_OFFSET
    db 255
    db 0
    db EXPONENT_OFFSET
    db 255
_fadd_mantissa_test_data_end:

_fadd_mantissa_test:

    lodi,r0 0E0h            ;マーカーG
    stra,r0 SCRUPDATA

    lodi,r0 _fadd_mantissa_test_data>>8
    stra,r0 DataOffset0
    lodi,r0 _fadd_mantissa_test_data&0ffh
    stra,r0 DataOffset1

    eorz r0
    stra,r0 Sign

_fadd_mantissa_test_:
    lodi,r0 0E1h            ;マーカーH
    stra,r0 SCRUPDATA

    lodi,r2 -1
    loda,r0 *DataOffset0,r2+
    eora,r0 Sign
    stra,r0 FStack+2-PAGE1
    loda,r0 *DataOffset0,r2+
    stra,r0 FStack+3-PAGE1
    loda,r0 *DataOffset0,r2+
    strz r1 
    loda,r0 *DataOffset0,r2+
    eora,r0 Sign
    stra,r0 FStack+4-PAGE1
    loda,r0 *DataOffset0,r2+
    stra,r0 FStack+5-PAGE1

    lodi,r3 0cch

    lodz r1
    lodi,r1 2
    bsta,un fadd_mantissa

    lodi,r0 0E2h            ;マーカーI
    stra,r0 SCRUPDATA

    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 4
    bcfa,eq failed_unit_test
    comi,r3 0CCh
    bcfa,eq failed_unit_test

    lodi,r0 0E3h            ;マーカーJ
    stra,r0 SCRUPDATA

    lodi,r1 2
    lodi,r2 4
    bsta,un fcom
    bsfa,eq failed_unit_test


    ;符号反転
    loda,r0 Sign
    eori,r0 80h
    stra,r0 Sign
    bcfa,eq _fadd_mantissa_test_

    loda,r0 DataOffset1
    addi,r0 5
    stra,r0 DataOffset1
    tpsl C
    bcfr,eq _fadd_mantissa_test_not_ovf
    loda,r0 DataOffset0
    addi,r0 1
    stra,r0 DataOffset0
_fadd_mantissa_test_not_ovf:

    loda,r0 DataOffset0
    comi,r0 _fadd_mantissa_test_data_end>>8
    bcfa,eq _fadd_mantissa_test_

    loda,r0 DataOffset1
    comi,r0 _fadd_mantissa_test_data_end&0ffh
    bcfa,eq _fadd_mantissa_test_


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
    include "flib\vec3.asm"
    include "flib\fsq.asm"
    include "flib\fmul.asm"
    include "flib\fminmax.asm"
    include "flib\fcom.asm"
    include "flib\futil.asm"


end ; End of assembly
