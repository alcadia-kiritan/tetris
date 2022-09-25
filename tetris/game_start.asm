;ゲームスタート

    DEBUG_MODE  equ 1
    
    ;-------------------
    ;game_start_start
    ;ゲーム開始の開始時に呼ばれる
    ;現画面を下にスクロールして、フィールドを描画して上に戻す.
    ;r0,r1,r2,r3を使用
game_start_start:

IF DEBUG_MODE = 0

    ;0.5s待機
    lodi,r2 30
    bsta,un wait_for_frame

ENDIF
    
IF DEBUG_MODE = 0
    GAME_START_SCROLL equ 3
ELSE
    GAME_START_SCROLL equ 10
ENDIF
    ;現画面を下にスクロール
    lodi,r2 GAME_START_SCROLL
    bsta,un scroll_to_bottom

    ;-------
    ;諸々の初期化処理を開始
    ;画面が下がり切ってるのでVRAMもタイミングを考えずアクセスする
_gss_start:

    eorz r0
    stra,r0 CRTCVPR

    ;スプライトを非表示
    stra,r0 SPRITE0X
    stra,r0 SPRITE1X
    stra,r0 SPRITE2X
    stra,r0 SPRITE3X
    
    ;----
    ;１ブロックだけ描く用のデータを、ユーザー定義のスプライト領域(SPRITE[0-4]DATA)へ転送
    lodi,r1 8                ;転送サイズ
_gss_set_user_sprites:
    loda,r0 GHOST_BLOCK,r1-
    stra,r0 SPRITE0DATA,r1
    stra,r0 SPRITE1DATA,r1
    stra,r0 SPRITE2DATA,r1
    stra,r0 SPRITE3DATA,r1
    brnr,r1 _gss_set_user_sprites       ;r1が0でなければset_user_spritesへ分岐

    ;----
    ;ブロックのデータをユーザー定義のキャラ領域(UDC[0-4]DATA)へ転送
    lodi,r1 32                ;転送サイズ
_gss_set_user_characters:
    loda,r0 BLOCK00a,r1-
    stra,r0 UDC0DATA,r1
    brnr,r1 _gss_set_user_characters       ;r1が0でなければset_user_charactersへ分岐

    ;----
    ;ゲーム関係の変数群を初期化
    bsta,un score_reset

    lodi,r0 1
    stra,r0 EnabledHoldTetromino
    stra,r0 LvBCD1-PAGE1

    lodi,r0 EMPTY_HOLD_TETROMINO_TYPE
    stra,r0 HoldTetrominoType

    lodi,r0 30  ;0.5[s]
    stra,r0 LockDownFrames

    lodi,r0 40
    stra,r0 FallFrame
    lodi,r0 1
    stra,r0 FallDistance
    
    ;ランダムなテトロミノを３つセット
    bsta,un get_random_tetromino_index
    stra,r0 NextOperationTetrominoType0
    bsta,un get_random_tetromino_index
    stra,r0 NextOperationTetrominoType1
    bsta,un get_random_tetromino_index
    stra,r0 NextOperationTetrominoType2

    ;フィールドリセット
    bsta,un reset_tetromino_field

    ;次のテトロミノを描画
    bsta,un draw_next_tetromino

    ;スコア描画
    bsta,un update_score_text_force

    ;次フレームテトロミノ生成から開始
    lodi,r0 SCENE_GAME_NEW_TETROMINO
    stra,r0 NextSceneIndex

    ;r0に0入れてついでに０デフォの変数をリセット
    eorz r0 
    stra,r0 LastOperationIsRotated

    lodi,r1 SCROLL_Y

    ;上画面にスクロール
_gss_scroll_up:
    addi,r0 GAME_START_SCROLL
    bsta,un wait_vsync
    stra,r0 CRTCVPR
    comz r1
    bctr,lt _gss_scroll_up

_gss_scroll_end:
    stra,r1 CRTCVPR

    loda,r0 GameMode
    retc,gt             ;スプリント以外なら終了

    IF GAME_MODE_SPRINT <> 0
        warning GAME_MODE_SPRINTが0以外になってる. eqで判定ができない
    ENDIF

    ;タイマー描画
    bsta,un update_timer_text

    ;0.5s待機
    lodi,r2 30
    bsta,un wait_for_frame

    ;スプリントならカウントダウン開始
    lodi,r3 3
_gss_sprint_countdown:
    bsta,un play_se15
    lodi,r0 10h
    addz r3 
    stra,r0 SCRUPDATA+12*10h+7
    lodi,r2 59
    bsta,un wait_for_frame
    bdrr,r3 _gss_sprint_countdown
    
    ;開始音鳴らして、書き換えてたブロックを元に戻してタイマー起動
    bsta,un play_se16
    lodi,r0 EMPTY_2BLOCK
    stra,r0 SCRUPDATA+12*10h+7
    stra,r0 EnabledTimer-PAGE1

    retc,un
    
    ;-------------------
    ;reset_tetromino_field
    ;テトリスのフィールドをリセットする
    ;r0,r1,r2使用
reset_tetromino_field:

    ;上下画面を空ブロックで埋める
    lodi,r0 EMPTY_2BLOCK
    lodi,r1 SCREEN_CHARA_WIDTH * HALF_SCREEN_CHARA_HEIGHT

_reset_tetromino_field_fill:
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRLODATA,r1
    brnr,r1 _reset_tetromino_field_fill

    ;HOLD
    lodi,r2 text_hold-game_hiscr_texts
    bsta,un draw_text_hiscr

    ;NEXT
    lodi,r2 text_next-game_hiscr_texts
    bsta,un draw_text_hiscr

    ;下画面の左側の線
    lodi,r0 EDGE_COLOR + 03h   ;塗りつぶしマス
    lodi,r1 FIELD_HEIGHT_ON_LOWER_SCREEN
    lodi,r2 0
_reset_tetromino_field_lo_left:
    stra,r0 SCRLODATA+FIELD_START_X/2-1,r2
    addi,r2 10h
    bdrr,r1 _reset_tetromino_field_lo_left

    ;上画面の左側の線
    lodi,r1 FIELD_HEIGHT_ON_UPPER_SCREEN
    lodi,r2 0    
_reset_tetromino_field_up_left:
    stra,r0 SCRUPDATA+FIELD_START_X/2+(HALF_SCREEN_CHARA_HEIGHT - FIELD_HEIGHT_ON_UPPER_SCREEN)*10h-1,r2
    addi,r2 10h
    bdrr,r1 _reset_tetromino_field_up_left

    ;下画面の右側の線
    lodi,r0 EDGE_COLOR + 03h   ;塗りつぶしマス
    lodi,r1 FIELD_HEIGHT_ON_LOWER_SCREEN
    lodi,r2 0
_reset_tetromino_field_lo_right:
    stra,r0 SCRLODATA+FIELD_START_X/2 + FIELD_WIDTH/2, r2
    addi,r2 10h
    bdrr,r1 _reset_tetromino_field_lo_right

    ;上画面の右側の線
    lodi,r1 FIELD_HEIGHT_ON_UPPER_SCREEN
    lodi,r2 0    
_reset_tetromino_field_hi_right:
    stra,r0 SCRUPDATA+FIELD_START_X/2+(HALF_SCREEN_CHARA_HEIGHT - FIELD_HEIGHT_ON_UPPER_SCREEN)*10h + FIELD_WIDTH/2,r2
    addi,r2 10h
    bdrr,r1 _reset_tetromino_field_hi_right

    ;下画面の左下隅
    lodi,r0 EDGE_COLOR + 03h
    IF FIELD_START_Y > 0
        stra,r0 SCRLODATA + FIELD_HEIGHT_ON_LOWER_SCREEN*10h + FIELD_START_X/2 - 1
    ENDIF
    IF FIELD_START_Y > 1
        stra,r0 SCRLODATA + FIELD_HEIGHT_ON_LOWER_SCREEN*10h + FIELD_START_X/2 + 10h - 1
    ENDIF

    ;下画面の右下隅
    lodi,r0 EDGE_COLOR + 03h
    IF FIELD_START_Y > 0
        stra,r0 SCRLODATA + FIELD_HEIGHT_ON_LOWER_SCREEN*10h + FIELD_START_X/2 + FIELD_WIDTH/2
    ENDIF
    IF FIELD_START_Y > 1
        stra,r0 SCRLODATA + FIELD_HEIGHT_ON_LOWER_SCREEN*10h + FIELD_START_X/2 + FIELD_WIDTH/2 + 10h
    ENDIF

    ;下側の線
    lodi,r0 EDGE_COLOR + 03h   ;塗りつぶしマス
    lodi,r1 FIELD_WIDTH/2
_reset_tetromino_field_down:
    IF FIELD_START_Y > 0
        stra,r0 SCRLODATA+FIELD_START_X/2 + FIELD_HEIGHT_ON_LOWER_SCREEN*10h,r1-
    ENDIF
    IF FIELD_START_Y > 1
        stra,r0 SCRLODATA+FIELD_START_X/2 + FIELD_HEIGHT_ON_LOWER_SCREEN*10h + 10h,r1
    ENDIF
    brnr,r1 _reset_tetromino_field_down

    ;---
    ;SCORE or TIMER, LINE, TSPIN, TETRIS, LVの描画

    ;SCORE or TIMER(SPRINT)
    lodi,r2 game_start_time_text-game_start_texts
    lodi,r0 GAME_MODE_SPRINT
    coma,r0 GameMode
    bctr,eq _rtf_sprint
    lodi,r2 game_start_score_text-game_start_texts
_rtf_sprint:
    bsta,un draw_text5_lo

    ;TETRIS
    lodi,r2 game_start_tetrs_text-game_start_texts
    bsta,un draw_text5_lo

    ;LINE
    lodi,r2 game_start_line_text-game_start_texts
    bsta,un draw_text5_lo

    ;TSPIN
    lodi,r2 game_start_tspin_text-game_start_texts
    bsta,un draw_text5_lo

    ;LV, 2文字なので直
    lodi,r0 ASCII_OFFSET+'L'
    stra,r0 SCRLODATA+(LV_TEXT_Y)*10h+LV_TEXT_X+0
    lodi,r0 ASCII_OFFSET+'V'
    stra,r0 SCRLODATA+(LV_TEXT_Y)*10h+LV_TEXT_X+1


IF 1
    ;フィールドテスト用コード

    lodi,r1 1
    lodi,r0 EMPTY_2BLOCK+3
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-1)*10h+0
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-1)*10h+1
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-1)*10h+2
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-1)*10h+3
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-2)*10h+0
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-2)*10h+1
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-2)*10h+2
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-2)*10h+3
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-3)*10h+0
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-3)*10h+1
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-3)*10h+2
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-3)*10h+3
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+0
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+1
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+2
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+3
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-5)*10h+0
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-5)*10h+1
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-5)*10h+2
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-5)*10h+3
    lodi,r0 EMPTY_2BLOCK+1
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-1)*10h+4
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-2)*10h+4
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-3)*10h+4
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+4
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-5)*10h+4

    ;stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-5)*10h+0
    ;stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+1
    ;stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+2
    ;stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-2)*10h+3
    ;stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+3

    lodi,r0 EMPTY_2BLOCK+0
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-5)*10h+2
    lodi,r0 EMPTY_2BLOCK+2
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-5)*10h+3
    lodi,r0 EMPTY_2BLOCK+1
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+2
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-6)*10h+2

    ;stra,r0 SCRUPDATA+FIELD_START_X/2+(14-FIELD_HEIGHT_ON_UPPER_SCREEN)*10h+3

    
    ;lodi,r0 5  ;T型
    lodi,r0 0
    stra,r0 NextOperationTetrominoType0
    ;lodi,r0 5  ;T型
    lodi,r0 0
    stra,r0 NextOperationTetrominoType1
    ;lodi,r0 5  ;T型
    lodi,r0 0
    stra,r0 NextOperationTetrominoType2

ENDIF

    retc,un ; return

    ;-------------------
    ;draw_text5_lo
    ;[SCRLODATA+[game_start_texts+r2]]へ[game_start_texts+r2+1~5]から５文字書き込む
    ;r0,r1,r2,r3使用
draw_text5_lo:
    lodi,r3 5
    loda,r0 game_start_texts,r2
    strz r1
_dt5:
    loda,r0 game_start_texts,r2+
    stra,r0 SCRLODATA-1,r1+
    bdrr,r3 _dt5
    retc,un

    ;0byte目は描画位置, 1-5byteは描画する文字列
game_start_texts:
game_start_time_text:
    db SCORE_TEXT_Y*10h+SCORE_TEXT_X
    db ASCII_OFFSET+'T'
    db ASCII_OFFSET+'I'
    db ASCII_OFFSET+'M'
    db ASCII_OFFSET+'E'
    db 0
    
game_start_score_text:
    db SCORE_TEXT_Y*10h+SCORE_TEXT_X
    db ASCII_OFFSET+'S'
    db ASCII_OFFSET+'C'
    db ASCII_OFFSET+'O'
    db ASCII_OFFSET+'R'
    db ASCII_OFFSET+'E'
    
game_start_tspin_text:
    db TSPIN_TEXT_Y*10h+TSPIN_TEXT_X
    db ASCII_OFFSET+'T'
    db ASCII_OFFSET+'S'
    db ASCII_OFFSET+'P'
    db ASCII_OFFSET+'I'
    db ASCII_OFFSET+'N'
    
game_start_line_text:
    db LINE_TEXT_Y*10h+LINE_TEXT_X
    db ASCII_OFFSET+'L'
    db ASCII_OFFSET+'I'
    db ASCII_OFFSET+'N'
    db ASCII_OFFSET+'E'
    db 0
    
game_start_tetrs_text:
    db TETRIS_TEXT_Y*10h+TETRIS_TEXT_X
    db ASCII_OFFSET+'T'
    db ASCII_OFFSET+'E'
    db ASCII_OFFSET+'T'
    db ASCII_OFFSET+'R'
    db ASCII_OFFSET+'S'
    
    IF FIELD_START_X-FIELD_START_X/2*2 > 0
        error FIELD_START_Xが奇数だよ。reset_tetromino_fieldでの書き込みがずれます
    ENDIF

    IF FIELD_WIDTH-FIELD_WIDTH/2*2 > 0
        error FIELD_WIDTHが奇数だよ。reset_tetromino_fieldでの書き込みがずれます
    ENDIF


end ; End of assembly
