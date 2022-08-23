      name FillScreen          ; module name

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
    ;ブロックのデータをスプライト領域(SPRITE0DATA,UDC0DATA)へ転送
    lodi,r1 32                ;転送サイズ

load_blocks:
    loda,r0 block00,r1-
    stra,r0 SPRITE0DATA,r1
    stra,r0 UDC0DATA,r1
    brnr,r1 load_blocks       ;r1が0でなければload_blocksへ分岐

    ;-------------------
    ;0x00～0xCFを上画面に書き込み
    lodi,r1 0D0h
    lodz r1

set_upper_screen:
    subi,r0 1
    stra,r0 SCRUPDATA,r1-
    brnr,r1 set_upper_screen
    
    ;-------------------
    ;0xD0～0x1BFを下画面に書き込み
    lodi,r0 0A0h
    lodi,r1 0D0h

set_lower_screen:
    subi,r0 1
    stra,r0 SCRLODATA,r1-
    brnr,r1 set_lower_screen

loopforever:
    bctr,un     loopforever  ; Loop forever

block00:
    db          11111111b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b

block01:
    db          00000001b
    db          00000001b
    db          00000001b
    db          00000001b
    db          00000001b
    db          00000001b
    db          00000001b
    db          00000001b

block10:
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          11111111b

block11:
    db          10000000b
    db          10000000b
    db          10000000b
    db          10000000b
    db          10000000b
    db          10000000b
    db          10000000b
    db          10000000b


end ; End of assembly
