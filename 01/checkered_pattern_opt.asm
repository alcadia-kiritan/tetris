      name CheckeredPattern          ; module name

      include "arcadia.h"      ; v1.01

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
    ;市松模様を画面に書き込み

SCRLODATA_10      equ 19F0h

    lodi,r1 06h
    lodi,r3 0D0h

set_block_outer:

    lodi,r2 10h
    lodi,r0 0FDh
set_block01_inner:
    stra,r0 SCRUPDATA,r3-
    stra,r0 SCRLODATA_10,r3
    bdrr,r2 set_block01_inner
    
    lodi,r0 0FEh
    lodi,r2 10h

set_block10_inner:
    stra,r0 SCRUPDATA,r3-
    stra,r0 SCRLODATA_10,r3
    bdrr,r2 set_block10_inner
    
    bdrr,r1 set_block_outer

SCRLODATA_C0      equ 1AC0h

    lodi,r2 10h
set_block10_inner2:
    stra,r0 SCRLODATA_C0,r3-
    bdrr,r2 set_block10_inner2

SCRUPDATA_F0      equ 1710h

    lodi,r2 10h
    lodi,r0 0FDh
set_block01_inner2:
    stra,r0 SCRUPDATA_F0,r3-
    bdrr,r2 set_block01_inner2

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
