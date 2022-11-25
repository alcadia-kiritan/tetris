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
    bcfr,eq _fsq_test




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


end ; End of assembly
