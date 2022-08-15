      name TestVramBlock          ; module name

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
    lodi,r0 0FFh
    stra,r0 CRTCVPR

    ;高解像度モードへ切り替え
    lodi,r0 01000000b       ;ノーマルモード&高解像度
    stra,r0 RESOLUTION
    lodi,r0 10000011b       ;高解像度&背景緑
    stra,r0 BGCOLOUR
    
    ;画面に描けるキャラ数
    SCREEN_CHARA_WIDTH          equ 16
    HALF_SCREEN_CHARA_HEIGHT    equ 13

    ;ゲームのフィールドサイズ(１キャラ＝2x1block)
    FILED_WIDTH                 equ 10
    FILED_HEIGHT                equ 22

    ;フィールドの描画の開始位置（キャラ単位）
    FIELD_START_CHARA_X         equ 6
    FIELD_START_CHARA_Y         equ 0

    ;上画面、下画面でのフィールドの高さ
    FIELD_HEIGHT_HI             equ (HALF_SCREEN_CHARA_HEIGHT - FIELD_START_CHARA_Y)
    FIELD_HEIGHT_LO             equ (FILED_HEIGHT - FIELD_HEIGHT_HI)
    
    storeValue      equ 18D0h   ;1byte, 書き込む値を保存する変数（のアドレス）
    field           equ 1AD0h   ;40byte, テトリスのフィールド
    
    ;-------------------
    ;ブロックのデータをスプライト領域(UDC0DATA)へ転送
    lodi,r1 32                ;転送サイズ

load_blocks:
    loda,r0 block00,r1-
    stra,r0 SPRITE0DATA,r1
    stra,r0 UDC0DATA,r1
    brnr,r1 load_blocks       ;r1が0でなければload_blocksへ分岐

    ;-------------------
    ;フィールドの左上壁を描画する
    lodi,r0 0C3h
    lodi,r1 FIELD_HEIGHT_HI
    lodi,r2 0
set_hi_left_wall:
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X-1),r2
    addi,r2 10h
    bdrr,r1 set_hi_left_wall

    ;-------------------
    ;フィールドの左下壁を描画する
    lodi,r1 FIELD_HEIGHT_LO
    lodi,r2 0
set_lo_left_wall:
    stra,r0 SCRLODATA+(FIELD_START_CHARA_X-1),r2
    addi,r2 10h
    bdrr,r1 set_lo_left_wall

    ;-------------------
    ;フィールドの右上壁を描画する
    lodi,r0 0C3h
    lodi,r1 FIELD_HEIGHT_HI
    lodi,r2 0
set_hi_right_wall:
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X+FILED_WIDTH/2),r2
    addi,r2 10h
    bdrr,r1 set_hi_right_wall

    ;-------------------
    ;フィールドの右下壁を描画する
    lodi,r1 FIELD_HEIGHT_LO
    lodi,r2 0
set_lo_right_wall:
    stra,r0 SCRLODATA+(FIELD_START_CHARA_X+FILED_WIDTH/2),r2
    addi,r2 10h
    bdrr,r1 set_lo_right_wall
    
    ;-------------------
    ;フィールドの上下下壁を描画する
    lodi,r0 0C3h
    lodi,r1 FILED_WIDTH/2+2
set_bottom_wall:
    stra,r0 SCRLODATA+(FIELD_HEIGHT_LO*10h+FIELD_START_CHARA_X-1),r1-
    stra,r0 SCRLODATA+((FIELD_HEIGHT_LO+1)*10h+FIELD_START_CHARA_X-1),r1
    IF FIELD_START_CHARA_Y >= 2 ;画面の上端に近ければスキップ
        stra,r0 SCRUPDATA+((FIELD_START_CHARA_Y-2)*10h+FIELD_START_CHARA_X-1),r1
    ENDIF
    IF FIELD_START_CHARA_Y >= 1 ;画面の上端に近ければスキップ
        stra,r0 SCRUPDATA+((FIELD_START_CHARA_Y-1)*10h+FIELD_START_CHARA_X-1),r1
    ENDIF
    brnr,r1 set_bottom_wall
    
    ;-------------------
    ;フィールドをクリア
    lodi,r0 10101010b
    lodi,r1 40
reset_field:
    stra,r0 field,r1-
    brnr,r1 reset_field

    ;-------------------
    lodi,r0 00000111b
    stra,r0 storeValue         ;*storeValue = 1

    ;////////////////////////////////////////////////////////////
    ;メインループ
loopforever:

    ;------------------------
    ;垂直同期の外(VRAM変更以外の処理をやる)

    ;ブロックを１段下にずらす
    lodi,r1 FILED_HEIGHT*2 - 2
down_line:
    loda,r0 field,r1-
    stra,r0 field+2,r1
    brnr,r1 down_line

    ;一番上のブロックを書き込む
    loda,r0 storeValue
    rrl,r0
    stra,r0 field
    stra,r0 field+1
    stra,r0 storeValue

    ;------------------------

    bsta,un wait_vsync              ;垂直帰線期間を待つ
    bsta,un wait_vsync              ;垂直帰線期間を待つ
    bsta,un wait_vsync              ;垂直帰線期間を待つ

    ;------------------------
    ;ここから垂直同期後

    ;上画面描画
    lodi,r1 0ffh
    lodi,r3 0ffh

    ;上画面の行を描画
draw_line_high_screen:
    
    loda,r0 field,r1+       ;ある行の1byte目の読み込み
    strz r2                 ;r2 = r0    ;r0は演算に使うのでr2へコピっておく

    ;最初の2bitを画面に描画
    andi,r0 3               ;r0 &= 3
    addi,r0 38h             ;r0 += 0x38
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X),r3+  ;最初の２ブロックの書き込み
    
    ;r2の行データを次の2ブロックに切り替えて、描画
    rrr,r2                  ;r2 >>= 1
    rrr,r2                  ;r2 >>= 1
    lodz r2                 ;r0 = r2
    andi,r0 3               ;r0 &= 3
    addi,r0 38h             ;r0 += 0x38
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X),r3+  ;次の２ブロックの書き込み

    ;r2の行データを次の2ブロックに切り替えて、描画
    rrr,r2
    rrr,r2    
    lodz r2
    andi,r0 3
    addi,r0 38h
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X),r3+
    
    ;r2の行データを次の2ブロックに切り替えて、描画
    rrr,r2
    rrr,r2    
    lodz r2
    andi,r0 3
    addi,r0 38h
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X),r3+

    loda,r0 field,r1+       ;ある行の2byte目の読み込み
    andi,r0 3
    addi,r0 38h
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X),r3+

    addi,r3 10h-FILED_WIDTH/2

    lodz r1                 ;r0 <- r1
    subi,r0 FIELD_HEIGHT_HI*2-1
    bcfr,eq draw_line_high_screen
    
    ;下画面描画
    lodi,r3 0ffh

draw_line_low_screen:
    
    loda,r0 field,r1+       ;ある行の1byte目の読み込み
    strz r2                 ;r2 <- r0

    andi,r0 3
    addi,r0 38h
    stra,r0 SCRLODATA+FIELD_START_CHARA_X,r3+   ;最初の２ブロックの書き込み
    
    ;r2の行データを次の2ブロックに切り替えて、描画
    rrr,r2
    rrr,r2    
    lodz r2
    andi,r0 3
    addi,r0 38h
    stra,r0 SCRLODATA+FIELD_START_CHARA_X,r3+   ;次の２ブロックの書き込み

    ;r2の行データを次の2ブロックに切り替えて、描画
    rrr,r2
    rrr,r2    
    lodz r2
    andi,r0 3
    addi,r0 38h
    stra,r0 SCRLODATA+FIELD_START_CHARA_X,r3+
    
    ;r2の行データを次の2ブロックに切り替えて、描画
    rrr,r2
    rrr,r2    
    lodz r2
    andi,r0 3
    addi,r0 38h
    stra,r0 SCRLODATA+FIELD_START_CHARA_X,r3+

    loda,r0 field,r1+       ;ある行の2byte目の読み込み
    andi,r0 3
    addi,r0 38h
    stra,r0 SCRLODATA+FIELD_START_CHARA_X,r3+

    addi,r3 10h-FILED_WIDTH/2

    lodz r1
    subi,r0 FILED_HEIGHT*2-1
    bcfr,eq draw_line_low_screen


    bcta,un     loopforever  ; Loop forever


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



block00:
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b

block10:
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b

block01:
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b

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
