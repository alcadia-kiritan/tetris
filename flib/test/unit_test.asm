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
    ;faddのテスト
    bcta,un fadd_test

fadd_test_data:

    ;511 + 511 = 1022
    ;511 - 511 = 0
    ;511 * 511 = 261,121
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

    ;0.99609375 + -1.00390625 = 0.0078125
    ;0.99609375 - -1.00390625 = 2.0
    ;0.99609375 * -1.00390625 = -0.99998474121 = -1
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

    ;2.0 + -0.00390625 = 2.0
    ;2.0 - -0.00390625 = 2.0
    ;2.0 * -0.00390625 = -0.0078125
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

    ;1.0 + -0.00390625 = 0.99609375
    ;1.0 - -0.00390625 = 1.00390625
    ;1.0 * -0.00390625 = -0.00390625
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

    ;0.99609375 + -0.00390625 = 0.9921875
    ;0.99609375 - -0.00390625 = 1.0
    ;0.99609375 * -0.00390625 = -0.00389099121
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
    
    ;1.5 + -0.25 = 1.25
    ;1.5 - -0.25 = 1.75
    ;1.5 * -0.25 = -0.375
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

    ;1.5 + -0.5 = 1.0
    ;1.5 - -0.5 = 2.0
    ;1.5 * -0.5 = -0.75
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

    ;1.5 + -1.0 = 0.5
    ;1.5 - -1.0 = 2.5
    ;1.5 * -1.0 = -1.5
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

    ;1.0 + -1.0 = 0.0
    ;1.0 - -1.0 = 2.0
    ;1.0 * -1.0 = -1.0
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

    ;1.99609375 + -0.0 = 1.99609375
    ;1.99609375 - -0.0 = 1.99609375
    ;1.99609375 * -0.0 = 0
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

    ;1.99609375 + 0.0 = 1.99609375
    ;1.99609375 - 0.0 = 1.99609375
    ;1.99609375 * 0.0 = 0
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

    ;0.0 + -0.0 = -0.0
    ;0.0 - -0.0 = -0.0
    ;0.0 * -0.0 = -0.0
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

    ;0.0 + 0.0 = 0.0
    ;0.0 + 0.0 = 0.0
    ;0.0 * 0.0 = 0.0
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

    ;1.00390625 + 1.00390625 = 2.0078125
    ;1.00390625 - 1.00390625 = 0.0
    ;1.00390625 * 1.00390625 = 1.00782775879
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

    ;0.5 + 1.00390625 = 1.50390625
    ;0.5 - 1.00390625 = -0.50390625
    ;0.5 * 1.00390625 = 0.501953125
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

    ;1.0 + 1.00390625 = 2.0
    ;1.0 - 1.00390625 = -0.00390625
    ;1.0 * 1.00390625 = 1.00390625
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

    ;2.0 + 0.00390625 = 2.0
    ;2.0 - 0.00390625 = 2.0
    ;2.0 * 0.00390625 = 0.0078125
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

    ;1.0 + 0.00390625 = 1.00390625
    ;1.0 - 0.00390625 = 0.99609375
    ;1.0 * 0.00390625 = 0.00390625
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

    ;511 + 257 = 768
    ;511 - 257 = 254
    ;511 * 257 = 131,327
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

    ;1.75 + 1.5 = 3.25
    ;1.75 - 1.5 = 0.25
    ;1.75 * 1.5 = 2.625
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

    ;1.0 + 1.0 = 2.0
    ;1.0 - 1.0 = 0.0
    ;1.0 * 1.0 = 1.0
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
    
    ;1.0 + 0.5 = 1.5
    ;1.0 - 0.5 = 0.5
    ;1.0 * 0.5 = 0.5
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
    
    ;1.0 + 0.25 = 1.25
    ;1.0 - 0.25 = 0.75
    ;1.0 * 0.25 = 0.25
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

    ;1.5 + 1.5 = 3.0
    ;1.5 - 1.5 = 0.0
    ;1.5 * 1.5 = 2.25
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

    ;1.5 + 1.5+eps = 3.0
    ;1.5 - 1.5-eps = -eps
    ;1.5 * 1.5+eps = 2.25 + 1.5*eps
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

    comi,r1 2
    bcfa,eq failed_unit_test
    comi,r2 4
    bcfa,eq failed_unit_test

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

    comi,r1 4
    bcfa,eq failed_unit_test
    comi,r2 2
    bcfa,eq failed_unit_test

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


    ;Signを切り替えてもう一回
    loda,r0 Sign
    eori,r0 80h
    stra,r0 Sign
    bcta,eq _fadd_test_change_sign

    ;データオフセット進める
    loda,r0 DataOffset1
    addi,r0 10
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


end ; End of assembly
