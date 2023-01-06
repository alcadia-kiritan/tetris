    name Mul8Test          ; module name

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

    LOOP0 equ 18D0h
    LOOP1 equ 18D1h
    RES0  equ 18D2h
    RES1  equ 18D3h

    ANS0  equ 18D4h
    ANS1  equ 18D5h
    
    Temporary0  equ 18D6h
    Temporary1  equ 18D7h
    ;Temporary2  equ 18D8h
    ;Temporary3  equ 18D9h

    ASCII_OFFSET equ (1Ah-'A')

    ;スクロール位置を画面上端へ
    lodi,r0 0F0h
    stra,r0 CRTCVPR

    ;高解像度モードへ切り替え
    lodi,r0 01000000b       ;ノーマルモード&高解像度
    stra,r0 RESOLUTION
    lodi,r0 10000011b       ;高解像度&背景緑
    stra,r0 BGCOLOUR

    eorz r0
    stra,r0 LOOP0
    stra,r0 LOOP1
    stra,r0 ANS0
    stra,r0 ANS1

    bctr,un test_loop

    ;mul8以外の部分のクロック数を測るためのダミーモード
    DUMMY_MODE equ 0

    ;答えがr0:r1なら1, r1:r0なら0になる定数
    R0_R1_MODE equ 0

test_loop:
    
    loda,r0 LOOP0
    loda,r1 LOOP1
    lodi,r2 0
    bsta,un draw_hex16_lo

    loda,r0 LOOP0
    loda,r1 LOOP1

    IF DUMMY_MODE = 0
        bsta,un mul8
    ELSE
        bstr,un dummy_mul8
    ENDIF

    IF DUMMY_MODE = 0
        IF R0_R1_MODE = 1
            coma,r0 ANS1
        ELSE
            coma,r1 ANS1
        ENDIF
        bcfa,eq failed
    ELSE
        comr,r0 LOOP0
        bcfr,eq failed
    ENDIF

    IF DUMMY_MODE = 0
        IF R0_R1_MODE = 1
            coma,r1 ANS0
        ELSE
            coma,r0 ANS0
        ENDIF
        bcfa,eq failed
    ELSE
        comr,r1 LOOP1
        bcfr,eq failed
    ENDIF

    ;---
    ;ANS1:ANS0 へLOOP1を足す
    loda,r0 ANS0
    adda,r0 LOOP1
    stra,r0 ANS0

    tpsl 1
    bcfr,eq _ans_not_carry_up

    loda,r1 ANS1
    addi,r1 1
    stra,r1 ANS1

_ans_not_carry_up:

    ;---
    ;LOOP1:LOOP0 += 1
    loda,r0 LOOP0
    addi,r0 1
    stra,r0 LOOP0

    tpsl 1
    bcfr,eq _loop_not_carry_up

    loda,r0 LOOP1
    addi,r0 1
    stra,r0 LOOP1

    ;---
    ;LOOP1が０に戻った。終了。
    tpsl 1
    bctr,eq success

    ;ANSを0にリセット
    eorz r0
    stra,r0 ANS0
    stra,r0 ANS1

_loop_not_carry_up:

    bcta,un test_loop


success:   

    lodi,r0 'S'+ASCII_OFFSET
    stra,r0 SCRLODATA+0
    lodi,r0 'U'+ASCII_OFFSET
    stra,r0 SCRLODATA+1
    lodi,r0 'C'+ASCII_OFFSET
    stra,r0 SCRLODATA+2
    lodi,r0 'C'+ASCII_OFFSET
    stra,r0 SCRLODATA+3
    lodi,r0 'E'+ASCII_OFFSET
    stra,r0 SCRLODATA+4
    lodi,r0 'S'+ASCII_OFFSET
    stra,r0 SCRLODATA+5
    lodi,r0 'S'+ASCII_OFFSET
    stra,r0 SCRLODATA+6

    eorz r0
    halt

failed:

    ;mul8が出した答え
    lodi,r2 16*1+5
    bsta,un draw_hex16_lo

    ;LOOP0,LOOP1
    lodi,r2 16*2+5
    loda,r0 LOOP0
    loda,r1 LOOP1
    bsta,un draw_hex16_lo

    ;答え
    lodi,r2 16*3+5
    loda,r0 ANS0
    loda,r1 ANS1
    bsta,un draw_hex16_lo

    lodi,r0 'F'+ASCII_OFFSET
    stra,r0 SCRLODATA+0
    lodi,r0 'A'+ASCII_OFFSET
    stra,r0 SCRLODATA+1
    lodi,r0 'I'+ASCII_OFFSET
    stra,r0 SCRLODATA+2
    lodi,r0 'L'+ASCII_OFFSET
    stra,r0 SCRLODATA+3
    lodi,r0 'E'+ASCII_OFFSET
    stra,r0 SCRLODATA+4
    lodi,r0 'D'+ASCII_OFFSET
    stra,r0 SCRLODATA+5

    
    lodi,r0 'A'+ASCII_OFFSET
    stra,r0 SCRLODATA+0+16*3
    lodi,r0 'N'+ASCII_OFFSET
    stra,r0 SCRLODATA+1+16*3
    lodi,r0 'S'+ASCII_OFFSET
    stra,r0 SCRLODATA+2+16*3

    
    lodi,r0 'L'+ASCII_OFFSET
    stra,r0 SCRLODATA+0+16*2
    lodi,r0 'O'+ASCII_OFFSET
    stra,r0 SCRLODATA+1+16*2
    lodi,r0 'O'+ASCII_OFFSET
    stra,r0 SCRLODATA+2+16*2
    lodi,r0 'P'+ASCII_OFFSET
    stra,r0 SCRLODATA+2+16*2

    lodi,r0 'M'+ASCII_OFFSET
    stra,r0 SCRLODATA+0+16*1
    lodi,r0 'U'+ASCII_OFFSET
    stra,r0 SCRLODATA+1+16*1
    lodi,r0 'L'+ASCII_OFFSET
    stra,r0 SCRLODATA+2+16*1
    lodi,r0 8+10h
    stra,r0 SCRLODATA+3+16*1

    halt

    ;-------------------
    ;draw_hex16_lo
    ;r1:r0をSCRLODATA+r2+0～3に書き込む
    ;r0,r1,r2,r3を使用
draw_hex16_lo:
    strz r3
    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    andi,r0 0fh
    addi,r0 10h
    stra,r0 SCRLODATA+2,r2

    lodz r3 
    andi,r0 0fh
    addi,r0 10h
    stra,r0 SCRLODATA+3,r2

    lodz r1
    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    andi,r0 0fh
    addi,r0 10h
    stra,r0 SCRLODATA+0,r2

    lodz r1
    andi,r0 0fh
    addi,r0 10h
    stra,r0 SCRLODATA+1,r2

    retc,un

    ;-------------------
    ;wait_vsync
    ;垂直帰線期間に入るまで待機
wait_vsync:
    tpsu 080h
    bctr,eq wait_vsync    ;非垂直帰線期間に入るのを待つ 7bit目が0になるのを待つ（垂直帰線期間で呼ばれてたらそれが終わるまで待つ
_wait_vsync:
    tpsu 080h
    bcfr,eq _wait_vsync    ;垂直帰線期間に入るのを待つ 7bit目が1になるのを待つ
    retc,un ; return

    IF DUMMY_MODE = 0

        ;mul8を定義しているファイルを切り替えることでテスト対象を切り替える

        ;include "mul/mul.asm"
        ;include "mul/mul_table.asm"
        ;include "mul/mul_net.asm"
        ;include "mul/mul_simple.asm"
        ;include "mul/mul2.asm"
        include "mul/mul3.asm"

    ELSE

        dummy_mul8:
            retc,un

    ENDIF

end ; End of assembly
