      name ScreenExample          ; module name

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
    
    ;-------------------------------------------------------------------------
    ;RAM1 $18D0..$18EF
    Player1Pad equ 18EDh        ;パッド１の値を0,1,2に変換した数値

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

    ;画面の上下に枠をつける
    lodi,r1 16
    lodi,r0 0c3h
draw_up_down_edge:
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRUPDATA+0c0h,r1
    brnr,r1 draw_up_down_edge

    ;画面の左右に枠をつける
    lodi,r1 11
    lodi,r2 10h
    lodi,r0 0c3h
draw_left_right_edge:
    stra,r0 SCRUPDATA+00h,r2
    stra,r0 SCRUPDATA+0fh,r2
    addi,r2 10h
    bdrr,r1 draw_left_right_edge

    ;ユーザー定義スプライトの０番を■にする
    lodi,r0 0ffh
    stra,r0 SPRITE0DATA+0
    stra,r0 SPRITE0DATA+1
    stra,r0 SPRITE0DATA+2
    stra,r0 SPRITE0DATA+3
    stra,r0 SPRITE0DATA+4
    stra,r0 SPRITE0DATA+5
    stra,r0 SPRITE0DATA+6
    stra,r0 SPRITE0DATA+7

    ;０番スプライトを赤色,通常高さに設定
    lodi,r0 00101000b
    stra,r0 SPRITES01CTRL

    ;---------------------

    ;操作可能なフレームのカウンタ, 0のときだけ操作を受け付ける
    lodi,r3 3

    ;現在のスクロール値を画面に描画
    
    lodi,r0 0ech            ;S
    stra,r0 SCRUPDATA+11h

    loda,r0 CRTCVPR
    lodi,r1 12h
    bsta,un draw_hex
    
    lodi,r0 0f1h            ;X
    stra,r0 SCRUPDATA+21h
    
    lodi,r0 0f2h            ;Y
    stra,r0 SCRUPDATA+31h
    

loopforever:

    bsta,un wait_vsync              ;垂直帰線期間を待つ
    bsta,un get_padd_status_player1       ;ボタンの状態を取得

    addi,r3 -1
    bcfa,eq loopforever   ;数フレームに１回以外は、キー操作を無効化
    lodi,r3 3

    ;キー操作でスクロール値を上下させる
    ;前のフレームのパッド値をビットを反転＆現在値とAND=前回０で今回１のビットを抽出
    loda,r0 Player1Pad
    ;eori,r3 255
    ;andz r3

    tmi,r0 1
    bctr,eq push_up_key
    tmi,r0 2
    bctr,eq push_down_key
    bctr,un skip

push_up_key:
    lodi,r1 1
    bctr,un scroll
push_down_key:
    lodi,r1 -1    

scroll:
    loda,r0 CRTCVPR
    addz r1
    stra,r0 CRTCVPR
    lodi,r1 12h
    bsta,un draw_hex

skip:

    ;2(w),4(a),6(d),5(s)で０番スプライトを移動させる

    ;4(a) 左
    loda,r0 P1LEFTKEYS
    tmi,r0 2
    bcfr,eq skip_4_key
    loda,r0 SPRITE0X
    addi,r0 -1
    stra,r0 SPRITE0X
skip_4_key:

    ;2(w) 上
    loda,r0 P1MIDDLEKEYS
    tmi,r0 4
    bcfr,eq skip_2_key
    loda,r1 SPRITE0Y
    addi,r1 1
    stra,r1 SPRITE0Y
skip_2_key:

    ;5(s) 下
    tmi,r0 2
    bcfr,eq skip_5_key
    loda,r1 SPRITE0Y
    addi,r1 -1
    stra,r1 SPRITE0Y
skip_5_key:

    ;6(d) 右
    loda,r0 P1RIGHTKEYS
    tmi,r0 2
    bcfr,eq skip_6_key
    loda,r0 SPRITE0X
    addi,r0 1
    stra,r0 SPRITE0X
skip_6_key:

    ;2,4,6,8でスプライト座標を移動させる

    ;スプライト座標値を描画
    loda,r0 SPRITE0X
    lodi,r1 22h
    bsta,un draw_hex

    loda,r0 SPRITE0Y
    lodi,r1 32h
    bsta,un draw_hex

    bcta,un     loopforever  ; Loop forever

    ;-------------------
    ;draw_hex
    ;r0の数値を(SCRUPDATA+r1+1)と(SCRUPDATA+r1+2)に書き込む
    ;r0,r1,r2を使用, r1は+2される
draw_hex:
    strz r2

    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    andi,r0 0fh
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+

    lodz r2
    andi,r0 0fh
    addi,r0 0d0h
    stra,r0 SCRUPDATA,r1+
    
    retc,un

    ;-------------------
    ;get_padd_status_player1
    ;プレイヤー１のパッド状態を取得し、1(上),0,2(下)のいずれかをPlayer1Padに書き込む
    ;r0,r1,r2を使用
get_padd_status_player1:
    loda,r0 P1PADDLE     
    lodi,r2 0                       ;何も押されてないときのパッドの値
    comi,r0 040h
    bctr,gt _get_button_status_1
    lodi,r2 1                       ;上押してるときのパッドの値
    bctr,un _get_button_status_end
_get_button_status_1:
    comi,r0 0A0h
    bctr,lt _get_button_status_end
    lodi,r2 2                      ;下押してるときのパッドの値
_get_button_status_end:
    stra,r2 Player1Pad
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
