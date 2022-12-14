;ゲームオーバーシーン

    GAME_OVER_FILL_FRAMES     equ 1
    GAME_OVER_SCROLL_SPEED    equ 1
    
    ;-------------------
    ;game_over_start
    ;ゲームオーバーシーンの開始時に呼ばれる
    ;r0を使用
game_over_start:
    eorz r0
    stra,r0 GameOverFrameCount+PAGE1
    stra,r0 EnabledTimer

    lodi,r0 FIELD_START_Y-1
    stra,r0 GameOverFillLineIndex+PAGE1
    
    ;音鳴らして直return
    bcta,un play_se12
    
    ;-------------------
    ;game_over_after_vsync
    ;ゲームオーバーシーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_over_after_vsync:

    ;カウンタを減らして０以外なら終了
    loda,r0 GameOverFrameCount+PAGE1
    bctr,eq _goav_fill_line
    subi,r0 1
    stra,r0 GameOverFrameCount+PAGE1
    retc,un

_goav_fill_line:

    lodi,r0 GAME_OVER_FILL_FRAMES
    stra,r0 GameOverFrameCount+PAGE1

    loda,r1 GameOverFillLineIndex+PAGE1
    addi,r1 1
    comi,r1 FIELD_START_Y+FIELD_HEIGHT
    bctr,eq _goav_fill_end

    ;現在行を保存して塗りつぶして終了
    stra,r1 GameOverFillLineIndex+PAGE1
    bcta,un fill_red_line

_goav_fill_end:

    ;GAME OVERを描画
    lodi,r1 7
_goav_draw_text:
    loda,r0 game_text,r1-
    stra,r0 PAGE1+SCRUPDATA+10h*9+FIELD_START_X/2-1,r1
    loda,r0 over_text,r1
    stra,r0 PAGE1+SCRUPDATA+10h*11+FIELD_START_X/2-1,r1
    eorz r0 
    stra,r0 PAGE1+SCRUPDATA+10h*08+FIELD_START_X/2-1,r1
    stra,r0 PAGE1+SCRUPDATA+10h*10+FIELD_START_X/2-1,r1
    stra,r0 PAGE1+SCRUPDATA+10h*12+FIELD_START_X/2-1,r1
    brnr,r1 _goav_draw_text

    ;適当に待機
    lodi,r2 120
    bsta,un wait_for_frame

    ;スプリントならタイトルへ, スプリント以外ならクリア(リザルト)画面へ
    loda,r0 PAGE1+GameMode
    bctr,eq _goav_sprint

    ;スプリント以外,クリアへ移動
    lodi,r1 SCENE_GAME_CLEAR
    stra,r1 NextSceneIndex+PAGE1
    retc,un

_goav_sprint:
    ;スプリントでゲームオーバー, スクロールしてタイトルへ移動
    lodi,r1 SCENE_GAME_TIELE
    stra,r1 NextSceneIndex+PAGE1
    
    lodi,r2 4
    bcta,un scroll_to_bottom

game_text:
    db 0
    db ('G'+CHAR_A_OFFSET)
    db ('A'+CHAR_A_OFFSET)
    db ('M'+CHAR_A_OFFSET)
    db ('E'+CHAR_A_OFFSET)
    db 0
    db 0


over_text:
    db 0
    db 0
    db ('O'+CHAR_A_OFFSET)
    db ('V'+CHAR_A_OFFSET)
    db ('E'+CHAR_A_OFFSET)
    db ('R'+CHAR_A_OFFSET)
    db 0

    ;-------------------
    ;fill_red_line
    ;Y=r1の行を赤色で塗りつぶす
    ;r0,r1を使用
fill_red_line:

    lodi,r0 HOLD_DISABLE_COLOR+EMPTY_2BLOCK+3

    comi,r1 HALF_SCREEN_CHARA_HEIGHT
    bctr,lt _frl_lower_screen

    ;上画面
    ;Y = (SCREEN_CHARA_HEIGHT-1) - r1 = 25-r1 = 26+(r1^255)
    ;VRAMオフセット = Y*10h
    eori,r1 255
    addi,r1 26
    rrl,r1
    rrl,r1
    rrl,r1
    rrl,r1

    stra,r0 PAGE1+SCRUPDATA+FIELD_START_X/2+0,r1
    stra,r0 PAGE1+SCRUPDATA+FIELD_START_X/2+1,r1
    stra,r0 PAGE1+SCRUPDATA+FIELD_START_X/2+2,r1
    stra,r0 PAGE1+SCRUPDATA+FIELD_START_X/2+3,r1
    stra,r0 PAGE1+SCRUPDATA+FIELD_START_X/2+4,r1   
    retc,un 

_frl_lower_screen:
    ;下画面
    ;Y = (HALF_SCREEN_CHARA_HEIGHT-1) - r1 = 12-r1 = 13+(r1^255)
    ;VRAMオフセット = Y*10h
    eori,r1 255
    addi,r1 13
    rrl,r1
    rrl,r1
    rrl,r1
    rrl,r1

    stra,r0 PAGE1+SCRLODATA+FIELD_START_X/2+0,r1
    stra,r0 PAGE1+SCRLODATA+FIELD_START_X/2+1,r1
    stra,r0 PAGE1+SCRLODATA+FIELD_START_X/2+2,r1
    stra,r0 PAGE1+SCRLODATA+FIELD_START_X/2+3,r1
    stra,r0 PAGE1+SCRLODATA+FIELD_START_X/2+4,r1   
    retc,un 

    ;-------------------
    ;is_game_over
    ;ゲームオーバー判定. ゲームオーバならgtをそうでないならeqをCCに入れて返す
    ;r0を使用
is_game_over:
    ;フィールドの１番上の１つ上にブロックがあればゲームオーバー
    IGO_CHECK_ADR equ PAGE1+SCRUPDATA+(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN-1)*10h+FIELD_START_X/2
    loda,r0 IGO_CHECK_ADR+0
    iora,r0 IGO_CHECK_ADR+1
    iora,r0 IGO_CHECK_ADR+2
    iora,r0 IGO_CHECK_ADR+3
    iora,r0 IGO_CHECK_ADR+4
    andi,r0 3
    retc,un


end ; End of assembly
