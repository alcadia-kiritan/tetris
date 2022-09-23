;タイトル画面
    
    ;-------------------
    ;fill_screen
    ;r0の値で画面を埋める
    ;r0,r1,r2,r3を使用
fill_screen:
    lodi,r1 HALF_SCREEN_CHARA_HEIGHT*SCREEN_CHARA_WIDTH
_fsloop:
    stra,r0 SCRLODATA,r1-
    stra,r0 SCRUPDATA,r1
    brnr,r1 _fsloop
    retc,un

arrow_sprite:
    db 11000000b
    db 11110000b
    db 11111100b
    db 11111111b
    db 11111111b
    db 11111100b
    db 11110000b
    db 11000000b

    ;-------------------
    ;game_title_start
    ;タイトルシーンの開始時に呼ばれる
    ;r0,r1,r2,r3を使用
game_title_start:

    ;スクロール位置を最下段にリセット
    eorz r0
    stra,r0 CRTCVPR

    ;スプライトをみえなくしておく（念のため
    lodi,r1 8
_gts_reset_spritepos:
    stra,r0 SPRITE0Y,r1-
    brnr,r1 _gts_reset_spritepos

    ;垂直同期待ち
    bsta,un wait_vsync

    ;画面を0クリア
    eorz r0
    bstr,un fill_screen

    ;変数初期化
    stra,r0 GameTitleFrameCount

    lodi,r0 0ffh
    stra,r0 GameMode

    ;--
    ;ゲームモード選択用の矢印スプライトを書き込み
    lodi,r1 8
_gts_set_arrow_sprite:
    loda,r0 arrow_sprite,r1-
    stra,r0 SPRITE0DATA,r1
    brnr,r1 _gts_set_arrow_sprite

    ;-----
    ;タイトルロゴの書き込み

    ;□□
    lodi,r0 00h
    lodi,r1 8
_gts_set_sprite0:
    stra,r0 UDC0DATA,r1-
    brnr,r1 _gts_set_sprite0

    ;□■
    lodi,r0 0Fh
    lodi,r1 8
_gts_set_sprite1:
    stra,r0 UDC1DATA,r1-
    brnr,r1 _gts_set_sprite1

    ;■□
    lodi,r0 0F0h
    lodi,r1 8
_gts_set_sprite2:
    stra,r0 UDC2DATA,r1-
    brnr,r1 _gts_set_sprite2

    ;■■
    lodi,r0 0FFh
    lodi,r1 8
_gts_set_sprite3:
    stra,r0 UDC3DATA,r1-
    brnr,r1 _gts_set_sprite3

    LOGO_Y          equ 3
    LOGO_COLOR      equ 000h
    SCRUP           equ SCRUPDATA+LOGO_Y*10h

    lodi,r3 -1
    lodi,r1 -1
_gts_write_logo2:
    loda,r0 tetris_logo,r1+
    strz r2
_gts_write_logo:
    rrl,r2
    rrl,r2
    lodz r2
    andi,r0 3
    addi,r0 LOGO_COLOR+BLOCK_SPRITE_INDEX
    stra,r0 SCRUP,r3+
    tmi,r3 3
    bcfr,eq _gts_write_logo

    comi,r1 20-1
    bcfr,eq _gts_write_logo2

    retc,un
    
tetris_logo:
    dd 01111101111011111011110010011110b
    dd 00010001000000100010001000100000b
    dd 00010001110000100011110010011100b
    dd 00010001000000100010001010000010b
    dd 00010001111000100010001010111100b

push_button_text:
    db ASCII_OFFSET+'P'
    db ASCII_OFFSET+'U'
    db ASCII_OFFSET+'S'
    db ASCII_OFFSET+'H'
    db 0
    db DIGIT_OFFSET+'8'
    db 0
    db ASCII_OFFSET+'B'
    db ASCII_OFFSET+'U'
    db ASCII_OFFSET+'T'
    db ASCII_OFFSET+'T'
    db ASCII_OFFSET+'O'
    db ASCII_OFFSET+'N'

normal_text:
    db 0
    db ASCII_OFFSET+'N'
    db ASCII_OFFSET+'O'
    db ASCII_OFFSET+'R'
    db ASCII_OFFSET+'M'
    db ASCII_OFFSET+'A'
    db ASCII_OFFSET+'L'
    db 0

sprint_40_text:
    db ASCII_OFFSET+'S'
    db ASCII_OFFSET+'P'
    db ASCII_OFFSET+'R'
    db ASCII_OFFSET+'I'
    db ASCII_OFFSET+'N'
    db ASCII_OFFSET+'T'
    db DIGIT_OFFSET+'4'
    db DIGIT_OFFSET+'0'

tgm_20g_text:
    db 0
    db ASCII_OFFSET+'T'
    db ASCII_OFFSET+'G'
    db ASCII_OFFSET+'M'
    db DIGIT_OFFSET+'2'
    db DIGIT_OFFSET+'0'
    db ASCII_OFFSET+'G'
    db 0

select_game_mode_text:
    SGMT_COLOR equ 40h
    db ASCII_OFFSET+'S'+SGMT_COLOR
    db ASCII_OFFSET+'E'+SGMT_COLOR
    db ASCII_OFFSET+'L'+SGMT_COLOR
    db ASCII_OFFSET+'E'+SGMT_COLOR
    db ASCII_OFFSET+'C'+SGMT_COLOR
    db ASCII_OFFSET+'T'+SGMT_COLOR
    db 0
    db ASCII_OFFSET+'G'+SGMT_COLOR
    db ASCII_OFFSET+'A'+SGMT_COLOR
    db ASCII_OFFSET+'M'+SGMT_COLOR
    db ASCII_OFFSET+'E'+SGMT_COLOR
    db 0
    db ASCII_OFFSET+'M'+SGMT_COLOR
    db ASCII_OFFSET+'O'+SGMT_COLOR
    db ASCII_OFFSET+'D'+SGMT_COLOR
    db ASCII_OFFSET+'E'+SGMT_COLOR

    ;-------------------
    ;game_title
    ;ゲームタイトルシーン
    ;r0を使用
game_title:
    retc,un

    ;-------------------
    ;game_title_after_vsync
    ;ゲームタイトルシーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_title_after_vsync:

    ;適当に乱数シードを進める
    bsta,un inc_random_seed

    ;スクロールが済んでないならスクロール
    loda,r0 CRTCVPR
    comi,r0 SCROLL_Y
    bcta,lt _gtav_scroll

    loda,r3 GameMode
    comi,r3 0ffh
    bcta,eq _gtav_blink

    ;---
    ;ゲームモード選択中
_gtav_select:

    ;カーソルのスプライト位置を設定
    lodz r3
    eori,r0 255
    addi,r0 4
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    addi,r0 SPRITE_OFFSET_Y+4*10
    
    stra,r0 SPRITE0Y
    lodi,r0 SPRITE_OFFSET_X+8*3
    stra,r0 SPRITE0X

    ;2,w,s,xキーのチェック
    loda,r0 P1MIDDLEKEYS
    lodi,r1 PrevP1MiddleKeys - KeyData
    bsta,un button_process

    tmi,r0 00010b
    bcfr,eq _gtav_skip_s_key

    ;Sキー押された
    addi,r3 1
    lodz r3
    bsta,un mod3
    stra,r0 GameMode

    ;操作音鳴らしてreturn
    bcta,un play_se9

_gtav_skip_s_key:
    tmi,r0 00100b
    bcfr,eq _gtav_skip_w_key
    ;Wキー押された
    addi,r3 3-1
    lodz r3
    bsta,un mod3
    stra,r0 GameMode

    ;操作音鳴らしてreturn
    bcta,un play_se4

_gtav_skip_w_key:

    ;3,e,d,cキー
    loda,r0 P1RIGHTKEYS
    lodi,r1 PrevP1RightKeys - KeyData
    bsta,un button_process  
    
    tmi,r0 00100b
    bcfr,eq _gtav_skip_e_key

    ;ゲーム開始シーンに遷移
    lodi,r0 SCENE_GAME_START
    stra,r0 NextSceneIndex

    ;選択したモード以外のテキストをクリア

    comi,r3 0
    bctr,eq _gtav_skip_clear_mode0
    lodi,r1 8
    eorz r0 
_gtav_clear_mode0:
    stra,r0 SCRLODATA+10h*1+4,r1-
    stra,r0 SCRLODATA+10h*1+4,r1-
    brnr,r1 _gtav_clear_mode0
_gtav_skip_clear_mode0:

    comi,r3 1
    bctr,eq _gtav_skip_clear_mode1
    lodi,r1 8
    eorz r0 
_gtav_clear_mode1:
    stra,r0 SCRLODATA+10h*3+4,r1-
    stra,r0 SCRLODATA+10h*3+4,r1-
    brnr,r1 _gtav_clear_mode1
_gtav_skip_clear_mode1:

    comi,r3 2
    bctr,eq _gtav_skip_clear_mode2
    lodi,r1 8
    eorz r0 
_gtav_clear_mode2:
    stra,r0 SCRLODATA+10h*5+4,r1-
    stra,r0 SCRLODATA+10h*5+4,r1-
    brnr,r1 _gtav_clear_mode2
_gtav_skip_clear_mode2:

    ;決定ボタンが押された, 音鳴らしてreturn
    bcta,un play_se13

_gtav_skip_e_key:
    retc,un


    ;----
    ;規定位置までスクロール完了
    ;push buttonを描画
_gtav_blink:

    ;2,w,s,xキー
    loda,r0 P1MIDDLEKEYS
    lodi,r1 PrevP1MiddleKeys - KeyData
    bsta,un button_process

    tmi,r0 00010b
    bcfr,eq _gtav_blink_    ;Sキー押された？

    ;Sキー押された. mode変更して、push~を削除して、音鳴らす
    eorz r0
    stra,r0 GameMode
    lodi,r1 13
_gtav_blink_clear_text:
    stra,r0 SCRLODATA+10h*2+1,r1-
    brnr,r1 _gtav_blink_clear_text

    ;モードのテキストを描画
    lodi,r1 8
_gtav_blink_draw_mode_text:
    loda,r0 normal_text,r1-
    stra,r0 SCRLODATA+10h*1+4,r1
    loda,r0 sprint_40_text,r1
    stra,r0 SCRLODATA+10h*3+4,r1
    loda,r0 tgm_20g_text,r1
    stra,r0 SCRLODATA+10h*5+4,r1
    brnr,r1 _gtav_blink_draw_mode_text

    lodi,r1 16
_gtav_blink_draw_sgm_text:
    loda,r0 select_game_mode_text,r1-
    stra,r0 SCRUPDATA+10h*11,r1
    brnr,r1 _gtav_blink_draw_sgm_text

    ;音鳴らして直returnして終了
    bcta,un play_se8

_gtav_blink_:
    loda,r0 GameTitleFrameCount
    addi,r0 01h
    stra,r0 GameTitleFrameCount

    ;適当な周期で回る色をr2へ格納
    rrl,r0 
    rrl,r0 
    rrl,r0 
    andi,r0 0c0h
    strz r2

    ;pushbuttonを描画
    lodi,r1 13
_gtav_draw_push_button:
    loda,r0 push_button_text,r1-
    addz r2
    comi,r0 0C0h
    bcfr,eq _gtav_skip_c0
    lodi,r0 0
_gtav_skip_c0:
    stra,r0 SCRLODATA+10h*2+1,r1
    brnr,r1 _gtav_draw_push_button

    retc,un

    ;----
    ;画面最下部から規定位置にスクロール
_gtav_scroll:
    addi,r0 1
    stra,r0 CRTCVPR
    retc,un
    

end ; End of assembly
