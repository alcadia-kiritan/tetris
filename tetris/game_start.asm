;ゲームスタート

    DEBUG_MODE  equ 1
    
    ;-------------------
    ;game_start_start
    ;ゲーム開始の開始時に呼ばれる
    ;現画面を下にスクロールして、フィールドを描画して上に戻す.
    ;r0,r1,r2,r3を使用
game_start_start:

IF DEBUG_MODE = 0

    ;0.33s待機
    lodi,r3 20
_gss_wait:
    bsta,un wait_vsync
    bsta,un sound_process
    bdrr,r3 _gss_wait

ENDIF

    loda,r2 SPRITE0Y
    lodi,r3 SCROLL_Y
    
    ;現画面を下にスクロール
_gss:

IF DEBUG_MODE = 0
    GAME_START_SCROLL equ 3
ELSE
    GAME_START_SCROLL equ 10
ENDIF

    subi,r2 GAME_START_SCROLL
    subi,r3 GAME_START_SCROLL

    bsta,un wait_vsync
    
    comi,r3 GAME_START_SCROLL
    bctr,lt _gss_start          ;下までスクロールした

    stra,r2 SPRITE0Y
    stra,r3 CRTCVPR

    bsta,un sound_process
    bctr,un _gss

    ;---------
    ;諸々の初期化処理を開始
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
    loda,r0 BLOCK10a,r1-
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
    lodi,r0 1
    stra,r0 EnabledHoldTetromino

    lodi,r0 EMPTY_HOLD_TETROMINO_TYPE
    stra,r0 HoldTetrominoType

    lodi,r0 30
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
    bsta,un score_reset
    bsta,un update_score_text_force

    ;次フレームテトロミノ生成から開始
    lodi,r0 SCENE_GAME_NEW_TETROMINO
    stra,r0 NextSceneIndex

    ;r0に0入れてついでに０デフォの変数をリセット
    eorz r0 
    stra,r0 LastOperationIsRotated

    lodi,r1 SCROLL_Y

_gss_scroll_up:
    addi,r0 GAME_START_SCROLL
    bsta,un wait_vsync
    stra,r0 CRTCVPR
    comz r1
    bctr,lt _gss_scroll_up

_gss_scroll_end:
    stra,r1 CRTCVPR
    retc,un

    ;-------------------
    ;game_start
    ;ゲーム開始シーン
    ;r0を使用
game_start:
    retc,un

    ;-------------------
    ;game_start_after_vsync
    ;ゲーム開始シーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_start_after_vsync:
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
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRLODATA,r1
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRLODATA,r1
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRLODATA,r1
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRLODATA,r1
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRLODATA,r1
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRLODATA,r1
    stra,r0 SCRUPDATA,r1-
    stra,r0 SCRLODATA,r1
    brnr,r1 _reset_tetromino_field_fill

    ;HOLD
    lodi,r0 CHAR_A_OFFSET+'H'
    stra,r0 SCRUPDATA+(SCREEN_CHARA_HEIGHT - HOLD_TETROMINO_Y-3)*10h+HOLD_TETROMINO_X/2-1
    lodi,r0 CHAR_A_OFFSET+'O'
    stra,r0 SCRUPDATA+(SCREEN_CHARA_HEIGHT - HOLD_TETROMINO_Y-3)*10h+HOLD_TETROMINO_X/2+0
    lodi,r0 CHAR_A_OFFSET+'L'
    stra,r0 SCRUPDATA+(SCREEN_CHARA_HEIGHT - HOLD_TETROMINO_Y-3)*10h+HOLD_TETROMINO_X/2+1
    lodi,r0 CHAR_A_OFFSET+'D'
    stra,r0 SCRUPDATA+(SCREEN_CHARA_HEIGHT - HOLD_TETROMINO_Y-3)*10h+HOLD_TETROMINO_X/2+2
    
    ;NEXT
    lodi,r0 CHAR_A_OFFSET+'N'
    stra,r0 SCRUPDATA+(SCREEN_CHARA_HEIGHT - NEXT_TETROMINO_Y-3)*10h+NEXT_TETROMINO_X/2-1
    lodi,r0 CHAR_A_OFFSET+'E'
    stra,r0 SCRUPDATA+(SCREEN_CHARA_HEIGHT - NEXT_TETROMINO_Y-3)*10h+NEXT_TETROMINO_X/2+0
    lodi,r0 CHAR_A_OFFSET+'X'
    stra,r0 SCRUPDATA+(SCREEN_CHARA_HEIGHT - NEXT_TETROMINO_Y-3)*10h+NEXT_TETROMINO_X/2+1
    lodi,r0 CHAR_A_OFFSET+'T'
    stra,r0 SCRUPDATA+(SCREEN_CHARA_HEIGHT - NEXT_TETROMINO_Y-3)*10h+NEXT_TETROMINO_X/2+2

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

    ;SCORE, LINE, TSPIN, TETRISの描画
    lodi,r0 ASCII_OFFSET+'T'
    stra,r0 SCRLODATA+TSPIN_TEXT_Y*10h+TSPIN_TEXT_X+0
    stra,r0 SCRLODATA+TETRIS_TEXT_Y*10h+TETRIS_TEXT_X+0
    stra,r0 SCRLODATA+TETRIS_TEXT_Y*10h+TETRIS_TEXT_X+2
    lodi,r0 ASCII_OFFSET+'S'
    stra,r0 SCRLODATA+TSPIN_TEXT_Y*10h+TSPIN_TEXT_X+1
    stra,r0 SCRLODATA+TETRIS_TEXT_Y*10h+TETRIS_TEXT_X+4
    stra,r0 SCRLODATA+SCORE_TEXT_Y*10h+SCORE_TEXT_X+0
    lodi,r0 ASCII_OFFSET+'P'
    stra,r0 SCRLODATA+TSPIN_TEXT_Y*10h+TSPIN_TEXT_X+2
    lodi,r0 ASCII_OFFSET+'I'
    stra,r0 SCRLODATA+TSPIN_TEXT_Y*10h+TSPIN_TEXT_X+3
    stra,r0 SCRLODATA+LINE_TEXT_Y*10h+LINE_TEXT_X+1
    lodi,r0 ASCII_OFFSET+'N'
    stra,r0 SCRLODATA+TSPIN_TEXT_Y*10h+TSPIN_TEXT_X+4
    stra,r0 SCRLODATA+LINE_TEXT_Y*10h+LINE_TEXT_X+2
    lodi,r0 ASCII_OFFSET+'E'
    stra,r0 SCRLODATA+TETRIS_TEXT_Y*10h+TETRIS_TEXT_X+1
    stra,r0 SCRLODATA+LINE_TEXT_Y*10h+LINE_TEXT_X+3
    stra,r0 SCRLODATA+SCORE_TEXT_Y*10h+SCORE_TEXT_X+4
    lodi,r0 ASCII_OFFSET+'R'
    stra,r0 SCRLODATA+TETRIS_TEXT_Y*10h+TETRIS_TEXT_X+3
    stra,r0 SCRLODATA+SCORE_TEXT_Y*10h+SCORE_TEXT_X+3
    lodi,r0 ASCII_OFFSET+'L'
    stra,r0 SCRLODATA+LINE_TEXT_Y*10h+LINE_TEXT_X+0
    lodi,r0 ASCII_OFFSET+'C'
    stra,r0 SCRLODATA+SCORE_TEXT_Y*10h+SCORE_TEXT_X+1
    lodi,r0 ASCII_OFFSET+'O'
    stra,r0 SCRLODATA+SCORE_TEXT_Y*10h+SCORE_TEXT_X+2


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

    IF FIELD_START_X-FIELD_START_X/2*2 > 0
        error FIELD_START_Xが奇数だよ。reset_tetromino_fieldでの書き込みがずれます
    ENDIF

    IF FIELD_WIDTH-FIELD_WIDTH/2*2 > 0
        error FIELD_WIDTHが奇数だよ。reset_tetromino_fieldでの書き込みがずれます
    ENDIF


end ; End of assembly