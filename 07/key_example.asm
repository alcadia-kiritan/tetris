      name KeyExample          ; module name

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
    
    ;-------------------------------------------------------------------------
    ;RAM1 $18D0..$18EF
    Player1Pad equ 18EDh        ;パッド１の値
    Player2Pad equ 18EFh        ;パッド２の値

    ;RAM2 $18F8..$18FB
    Temporary0 equ 18F8h       ;汎用領域
    Temporary1 equ 18F9h       ;汎用領域
    Temporary2 equ 18FAh       ;汎用領域
    Temporary3 equ 18FBh       ;汎用領域

    ;RAM3 $1AD0..$1AFF
    ;-------------------------------------------------------------------------

    ;スクロール位置を画面上端へ
    lodi,r0 199;0FFh
    stra,r0 CRTCVPR

    ;通常解像度モードへ切り替え
    lodi,r0 00000000b       ;ノーマルモード&通常解像度
    stra,r0 RESOLUTION
    lodi,r0 00000000b       ;通常解像度&背景白
    stra,r0 BGCOLOUR

    lodi,r0 0e9h            ;P
    stra,r0 SCRUPDATA+20h
    stra,r0 SCRUPDATA+80h
    lodi,r0 0d1h            ;1
    stra,r0 SCRUPDATA+21h
    stra,r0 SCRUPDATA+81h
    lodi,r0 0c7h            ;|
    stra,r0 SCRUPDATA+22h
    stra,r0 SCRUPDATA+82h

    lodi,r0 0e9h            ;P
    stra,r0 SCRUPDATA+30h
    stra,r0 SCRUPDATA+90h
    lodi,r0 0d2h            ;2
    stra,r0 SCRUPDATA+31h
    stra,r0 SCRUPDATA+91h
    lodi,r0 0c7h            ;|
    stra,r0 SCRUPDATA+32h
    stra,r0 SCRUPDATA+92h
    
    lodi,r0 0c9h            ;[
    stra,r0 SCRUPDATA+12h
    stra,r0 SCRUPDATA+72h
    lodi,r0 0c4h            ;-
    stra,r0 SCRUPDATA+13h
    stra,r0 SCRUPDATA+14h
    stra,r0 SCRUPDATA+15h
    stra,r0 SCRUPDATA+16h
    stra,r0 SCRUPDATA+17h
    stra,r0 SCRUPDATA+18h
    stra,r0 SCRUPDATA+19h

    stra,r0 SCRUPDATA+1ch
    stra,r0 SCRUPDATA+1dh
    stra,r0 SCRUPDATA+1eh
    
    stra,r0 SCRUPDATA+73h
    stra,r0 SCRUPDATA+74h
    stra,r0 SCRUPDATA+75h
    stra,r0 SCRUPDATA+76h
    stra,r0 SCRUPDATA+77h
    stra,r0 SCRUPDATA+78h
    stra,r0 SCRUPDATA+79h
    stra,r0 SCRUPDATA+7ah
    stra,r0 SCRUPDATA+7bh
    stra,r0 SCRUPDATA+7ch
    stra,r0 SCRUPDATA+7dh
    stra,r0 SCRUPDATA+7eh
    
    lodi,r0 0ech            ;START
    stra,r0 SCRUPDATA+0ch
    lodi,r0 0e8h            ;OPTION
    stra,r0 SCRUPDATA+0dh
    lodi,r0 0ddh            ;DIFFICULTY
    stra,r0 SCRUPDATA+0eh

    lodi,r0 0e9h            ;P
    stra,r0 SCRUPDATA+2h
    lodi,r0 0dah            ;A
    stra,r0 SCRUPDATA+3h
    lodi,r0 0ddh            ;D
    stra,r0 SCRUPDATA+4h
    lodi,r0 0f0h            ;w
    stra,r0 SCRUPDATA+6h
    lodi,r0 0f1h            ;x
    stra,r0 SCRUPDATA+7h
    lodi,r0 0f2h            ;y
    stra,r0 SCRUPDATA+8h
    lodi,r0 0f3h            ;z
    stra,r0 SCRUPDATA+9h

    lodi,r0 0deh            ;E
    stra,r0 SCRUPDATA+63h
    lodi,r0 0d7h            ;7
    stra,r0 SCRUPDATA+64h
    lodi,r0 0d4h            ;4
    stra,r0 SCRUPDATA+65h
    lodi,r0 0d1h            ;1
    stra,r0 SCRUPDATA+66h
    
    lodi,r0 0d0h            ;0
    stra,r0 SCRUPDATA+67h
    lodi,r0 0d8h            ;8
    stra,r0 SCRUPDATA+68h
    lodi,r0 0d5h            ;5
    stra,r0 SCRUPDATA+69h
    lodi,r0 0d2h            ;2
    stra,r0 SCRUPDATA+6ah
    
    lodi,r0 0dCh            ;C
    stra,r0 SCRUPDATA+6bh
    lodi,r0 0d9h            ;9
    stra,r0 SCRUPDATA+6ch
    lodi,r0 0d6h            ;6
    stra,r0 SCRUPDATA+6dh
    lodi,r0 0d3h            ;3
    stra,r0 SCRUPDATA+6eh

loopforever:

    bsta,un wait_vsync              ;垂直帰線期間を待つ
    bsta,un get_button_status       ;ボタンの状態を取得

    ;Player1Padの上位4bitを画面に書き込む
    loda,r0 Player1Pad
    lodi,r1 22h
    bsta,un draw_padd_status

    ;1,4,7,e
    loda,r0 P1LEFTKEYS
    lodi,r1 82h
    bsta,un draw_button_status
    
    ;2,5,8,0
    loda,r0 P1MIDDLEKEYS
    bsta,un draw_button_status
    
    ;3,6,9,c
    loda,r0 P1RIGHTKEYS
    bsta,un draw_button_status
    
    ;palladium
    loda,r0 P1PALLADIUM
    lodi,r1 25h
    bsta,un draw_button_status
    
    ;Player2Padを画面に書き込む
    loda,r0 Player2Pad
    lodi,r1 32h
    bsta,un draw_padd_status
    
    ;1,4,7,e
    loda,r0 P2LEFTKEYS
    lodi,r1 92h
    bsta,un draw_button_status
    
    ;2,5,8,0
    loda,r0 P2MIDDLEKEYS
    bsta,un draw_button_status
    
    ;3,6,9,c
    loda,r0 P2RIGHTKEYS
    bsta,un draw_button_status
    
    ;palladium
    loda,r0 P2PALLADIUM
    lodi,r1 35h
    bsta,un draw_button_status
    
    ;console
    loda,r0 CONSOLE
    lodi,r1 2bh
    bsta,un draw_button_status3

    bcta,un     loopforever  ; Loop forever

    
    ;-------------------
    ;draw_padd_status
    ;r0をSCRUPDATA+r1に１６進数として書き込む
    ;r0,r1,r2を使用
draw_padd_status:
    strz r2

    ;上位4bitを画面に描画
    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    andi,r0 15
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    ;下位4bitを画面に描画
    lodz r2
    andi,r0 15
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    retc,un


    ;-------------------
    ;draw_button_status
    ;r0の下位4bitを２進数４桁として、SCRUPDATA+r1+0~3に0|1で書き込む. r1は+4される
    ;r0,r1,r2を使用
draw_button_status:
    strz r2 
    andi,r0 1
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    rrr,r2 
    lodz r2 
    andi,r0 1
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    rrr,r2 
    lodz r2 
    andi,r0 1
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+
    
    rrr,r2 
    lodz r2 
    andi,r0 1
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    retc,un

draw_button_status3:
    strz r2 
    andi,r0 1
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    rrr,r2 
    lodz r2 
    andi,r0 1
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    rrr,r2 
    lodz r2 
    andi,r0 1
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    retc,un

    ;-------------------
    ;get_button_status
    ;ボタン状態を取得する
get_button_status:

    loda,r0 P1PADDLE 
    stra,r0 Player1Pad
    loda,r0 P2PADDLE 
    stra,r0 Player2Pad

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

end ; End of assembly
