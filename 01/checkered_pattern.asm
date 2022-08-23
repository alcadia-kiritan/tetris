      name CheckeredPattern          ; module name

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


    ;スクロール位置を画面上端へ
    lodi,r0 0F0h
    stra,r0 CRTCVPR

    ;高解像度モードへ切り替え
    lodi,r0 01000000b       ;ノーマルモード&高解像度
    stra,r0 RESOLUTION
    lodi,r0 10000011b       ;高解像度&背景緑
    stra,r0 BGCOLOUR
    
    ;-------------------
    ;ブロックのデータをスプライト領域(UDC0DATA)へ転送
    lodi,r1 32                ;転送サイズ

load_blocks:
    loda,r0 block00,r1-
    stra,r0 SPRITE0DATA,r1
    stra,r0 UDC0DATA,r1
    brnr,r1 load_blocks       ;r1が0でなければload_blocksへ分岐

    ;-------------------
    ;市松模様を上画面に書き込み
    lodi,r1 0D0h

set_upper_screen:

    lodi,r2 0FDh    ;r2 = 0xFD, UDC0DATAの２個目(0x3D) + 0xC0(色)
    lodz r1         ;r0=r1
    subi,r0 1       ;--r0
    andi,r0 10h     ;r0&0x10
    bctr,eq skipped_block10     ;5bit目が0なら分岐
    lodi,r2 0FEh       ;r2=0xFE, UDC0DATAの３個目(0x3E) + 0xC0(色)
skipped_block10:
    lodz r2         ;r0=r2
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    brnr,r1 set_upper_screen    ; if(r1 != 0) goto set_upper_screen
    
    ;-------------------
    ;市松模様を下画面に書き込み
    lodi,r0 0A0h
    lodi,r1 0D0h

set_lower_screen:
    lodi,r2 0FEh
    lodz r1
    subi,r0 1
    andi,r0 10h
    bctr,eq skipped_block01
    lodi,r2 0FDh
skipped_block01:
    lodz r2
    stra,r0 SCRLODATA,r1-
    brnr,r1 set_lower_screen

loopforever:
    bctr,un     loopforever  ; Loop forever

block00:
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b

block01:
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b

block10:
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b

block11:
    db          11111111b
    db          11111111b
    db          11111111b
    db          11111111b
    db          11111111b
    db          11111111b
    db          11111111b
    db          11111111b


end ; End of assembly
