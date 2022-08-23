      name TestVramBlock          ; module name

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
    FILED_HEIGHT                equ 20

    ;フィールドの描画の開始位置（キャラ単位）
    FIELD_START_CHARA_X         equ 6
    FIELD_START_CHARA_Y         equ 0

    ;上画面、下画面でのフィールドの高さ
    FIELD_HEIGHT_HI             equ (HALF_SCREEN_CHARA_HEIGHT - FIELD_START_CHARA_Y)
    FIELD_HEIGHT_LO             equ (FILED_HEIGHT - FIELD_HEIGHT_HI)
    

    storeValue equ 18D0h       ;書き込む値を保存する変数（のアドレス）
    
    lodi,r0 1
    stra,r0 storeValue         ;*storeValue = 1

    ;フィールドの左上壁を描画する
    lodi,r0 0C3h
    lodi,r1 FIELD_HEIGHT_HI
    lodi,r2 0
set_hi_left_wall:
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X-1),r2
    addi,r2 10h
    bdrr,r1 set_hi_left_wall

    ;フィールドの左下壁を描画する
    lodi,r1 FIELD_HEIGHT_LO
    lodi,r2 0
set_lo_left_wall:
    stra,r0 SCRLODATA+(FIELD_START_CHARA_X-1),r2
    addi,r2 10h
    bdrr,r1 set_lo_left_wall

    ;フィールドの右上壁を描画する
    lodi,r0 0C3h
    lodi,r1 FIELD_HEIGHT_HI
    lodi,r2 0
set_hi_right_wall:
    stra,r0 SCRUPDATA+(FIELD_START_CHARA_Y*10h+FIELD_START_CHARA_X+FILED_WIDTH/2),r2
    addi,r2 10h
    bdrr,r1 set_hi_right_wall

    ;フィールドの右下壁を描画する
    lodi,r1 FIELD_HEIGHT_LO
    lodi,r2 0
set_lo_right_wall:
    stra,r0 SCRLODATA+(FIELD_START_CHARA_X+FILED_WIDTH/2),r2
    addi,r2 10h
    bdrr,r1 set_lo_right_wall
    
    ;フィールドの上下下壁を描画する
    lodi,r0 0C3h
    lodi,r1 FILED_WIDTH/2+2
set_bottom_wall:
    stra,r0 SCRLODATA+(FIELD_HEIGHT_LO*10h+FIELD_START_CHARA_X-1),r1-
    stra,r0 SCRLODATA+((FIELD_HEIGHT_LO+1)*10h+FIELD_START_CHARA_X-1),r1
    IF FIELD_START_CHARA_Y >= 2
        stra,r0 SCRUPDATA+((FIELD_START_CHARA_Y-2)*10h+FIELD_START_CHARA_X-1),r1
    ENDIF
    IF FIELD_START_CHARA_Y >= 1
        stra,r0 SCRUPDATA+((FIELD_START_CHARA_Y-1)*10h+FIELD_START_CHARA_X-1),r1
    ENDIF
    brnr,r1 set_bottom_wall
    

loopforever:

    bsta,un wait_vsync              ;垂直帰線期間を待つ

    ;下画面にあるブロックを１段下にずらす
    lodi,r2 FIELD_HEIGHT_LO-1
    lodi,r3 (FIELD_HEIGHT_LO-1)*10h + FIELD_START_CHARA_X + FILED_WIDTH/2

down_line_lower:

    loda,r0 SCRLODATA-10h,r3-
    stra,r0 SCRLODATA,r3
    loda,r0 SCRLODATA-10h,r3-
    stra,r0 SCRLODATA,r3
    loda,r0 SCRLODATA-10h,r3-
    stra,r0 SCRLODATA,r3
    loda,r0 SCRLODATA-10h,r3-
    stra,r0 SCRLODATA,r3
    loda,r0 SCRLODATA-10h,r3-
    stra,r0 SCRLODATA,r3
    subi,r3 010h - FILED_WIDTH/2

    bdrr,r2 down_line_lower     ; if( --r2 != 0 ) goto 

    loda,r0 SCRUPDATA+0C0h,r3-
    stra,r0 SCRLODATA,r3
    loda,r0 SCRUPDATA+0C0h,r3-
    stra,r0 SCRLODATA,r3
    loda,r0 SCRUPDATA+0C0h,r3-
    stra,r0 SCRLODATA,r3
    loda,r0 SCRUPDATA+0C0h,r3-
    stra,r0 SCRLODATA,r3
    loda,r0 SCRUPDATA+0C0h,r3-
    stra,r0 SCRLODATA,r3

    ;上画面にあるブロックを１段下にずらす
    lodi,r2 FIELD_HEIGHT_HI-1
    lodi,r3 (HALF_SCREEN_CHARA_HEIGHT-1)*10h + FIELD_START_CHARA_X + FILED_WIDTH/2

down_line_upper:

    loda,r0 SCRUPDATA-10h,r3-
    stra,r0 SCRUPDATA,r3
    loda,r0 SCRUPDATA-10h,r3-
    stra,r0 SCRUPDATA,r3
    loda,r0 SCRUPDATA-10h,r3-
    stra,r0 SCRUPDATA,r3
    loda,r0 SCRUPDATA-10h,r3-
    stra,r0 SCRUPDATA,r3
    loda,r0 SCRUPDATA-10h,r3-
    stra,r0 SCRUPDATA,r3
    subi,r3 010h - FILED_WIDTH/2

    bdrr,r2 down_line_upper     ; if( --r2 != 0 ) goto 


    ;storeValueを読み込んで１進めた値を書いておく
    loda,r0 storeValue  
    addi,r0 1
    strz r1
    subi,r1 0C0h
    bcfr,eq skip_c0
    addi,r0 1
skip_c0:
    stra,r0 storeValue

    ;最上段の行にstoreValueを書く
    lodi,r3 FIELD_START_CHARA_Y*010h + FIELD_START_CHARA_X + FILED_WIDTH/2
    stra,r0 SCRUPDATA,r3-
    stra,r0 SCRUPDATA,r3-
    stra,r0 SCRUPDATA,r3-
    stra,r0 SCRUPDATA,r3-
    stra,r0 SCRUPDATA,r3-

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


end ; End of assembly
