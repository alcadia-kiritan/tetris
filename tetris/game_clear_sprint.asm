;スプリントをクリアしたときのシーン

    ;-------------------
    ;game_clear_sprint_start
    ;スプリントクリア時に呼ばれる
    ;r0,r1,r2を使用
game_clear_sprint_start:

    eorz r0
    stra,r0 EnabledTimer      ;タイマー止める
    stra,r0 PAGE1+GameClearFrameCount

    ;新タイムが出たら更新する
    bsta,un compare_best_time
    bcfr,gt _gcss_not_best
    loda,r0 Timer10sBCD
    stra,r0 BestTimer10sBCD
    loda,r0 Timer100msBCD
    stra,r0 BestTimer100msBCD
    loda,r0 Timer1msBCD
    stra,r0 BestTimer1msBCD
_gcss_not_best:

    ;効果音鳴らしてreturn
    bcta,un play_se14    

    ;-------------------
    ;game_clear_sprint
    ;スプリントクリアシーン
    ;r0を使用
game_clear_sprint:
    loda,r0 PAGE1+GameClearFrameCount
    addi,r0 1
    stra,r0 PAGE1+GameClearFrameCount
    comi,r0 180
    retc,lt

    ;時間経過したらタイトルへ戻る
    lodi,r0 SCENE_GAME_TIELE
    stra,r0 PAGE1+NextSceneIndex
    retc,un

    ;-------------------
    ;game_clear_sprint_after_vsync
    ;スプリントクリアシーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_clear_sprint_after_vsync:

    lodi,r0 SCENE_GAME_TIELE
    coma,r0 PAGE1+NextSceneIndex
    bcfr,eq _gcsav_result

    ;タイトルに戻る前に画面全体を下にスクロール
    lodi,r2 1
    bsta,un compare_best_time
    bctr,eq _gcsav_update_best_time
    lodi,r2 6
_gcsav_update_best_time:

    ;下スクロールして直returnして終了
    bcta,un scroll_to_bottom
    
_gcsav_result:

    ;スプライトを非表示に
    eorz r0
    stra,r0 PAGE1+SPRITE0X
    stra,r0 PAGE1+SPRITE1X
    stra,r0 PAGE1+SPRITE2X
    stra,r0 PAGE1+SPRITE3X

    ;game clear
    lodi,r2 text_game-game_hiscr_texts
    bsta,un draw_text_hiscr
    lodi,r2 text_clear-game_hiscr_texts
    bsta,un draw_text_hiscr

    lodi,r1 (GAME_TEXT_Y-1)*10h+(GAME_TEXT_X-1)
    bsta,un clear5_hi

    lodi,r1 (GAME_TEXT_Y+2)*10h+(GAME_TEXT_X-1)
    bsta,un clear5_hi

    lodi,r2 text_time-game_hiscr_texts
    bsta,un draw_text_hiscr

    lodi,r2 (GAME_TEXT_Y+4)*10h+(GAME_TEXT_X-1)
    lodi,r3 Timer10sBCD-ScoreData
    bsta,un draw_time

    lodi,r1 (GAME_TEXT_Y+5)*10h+(GAME_TEXT_X-1)
    bsta,un clear5_hi
    
    bsta,un compare_best_time
    bcfr,eq _gcav_skip_new
    lodi,r2 text_new-game_hiscr_texts
    bsta,un draw_text_hiscr
_gcav_skip_new:

    lodi,r2 text_best-game_hiscr_texts
    bsta,un draw_text_hiscr

    lodi,r2 (GAME_TEXT_Y+7)*10h+(GAME_TEXT_X-1)
    lodi,r3 BestTimer10sBCD-ScoreData
    bsta,un draw_time
    
    lodi,r1 7
    eorz r0 
_gcsav_lo:
    stra,r0 PAGE1+SCRLODATA+FIELD_START_X/2-1,r1-
    brnr,r1 _gcsav_lo

    retc,un

    ;-------------------
    ;clear5_hi
    ;[SCRUPDATA+r1+0~6]を0で塗りつぶす
    ;r0,r1を使用
clear5_hi:
    eorz r0
    stra,r0 PAGE1+SCRUPDATA,r1
    stra,r0 PAGE1+SCRUPDATA,r1+
    stra,r0 PAGE1+SCRUPDATA,r1+
    stra,r0 PAGE1+SCRUPDATA,r1+
    stra,r0 PAGE1+SCRUPDATA,r1+
    stra,r0 PAGE1+SCRUPDATA,r1+
    stra,r0 PAGE1+SCRUPDATA,r1+
    retc,un

    

    ;-------------------
    ;draw_time
    ;[ScoreData+r3+0]~[ScoreData+r3+2]のBCDを[SCRUPDATA+r2+0]~[SCRUPDATA+r2+6]へ書き込む
    ;r0,r1,r2,r3を使用
draw_time:
    ;最上位桁２を空白で埋めておく
    eorz r0
    stra,r0 PAGE1+SCRUPDATA+0,r2
    stra,r0 PAGE1+SCRUPDATA+1,r2

    loda,r0 ScoreData,r3    ;100s/10s
    bctr,eq _dt_skip10s

    strz r1
    andi,r0 0f0h
    bctr,eq _dt_skip100s
    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    addi,r0 10h
    stra,r0 PAGE1+SCRUPDATA+0,r2

_dt_skip100s:
    lodz r1
    andi,r0 0fh
    addi,r0 10h
    stra,r0 PAGE1+SCRUPDATA+1,r2
    
_dt_skip10s:
    
    loda,r0 ScoreData+1,r3  ;1s/100ms

    strz r1
    andi,r0 0f0h
    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    addi,r0 10h
    stra,r0 PAGE1+SCRUPDATA+2,r2

    lodz r1
    andi,r0 0fh
    addi,r0 10h
    stra,r0 PAGE1+SCRUPDATA+4,r2

    lodi,r0 34h
    stra,r0 PAGE1+SCRUPDATA+3,r2

    loda,r0 ScoreData+2,r3  ;10ms/1ms

    strz r1
    andi,r0 0f0h
    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    addi,r0 10h
    stra,r0 PAGE1+SCRUPDATA+5,r2

    lodz r1
    andi,r0 0fh
    addi,r0 10h
    stra,r0 PAGE1+SCRUPDATA+6,r2
    
    retc,un

    ;-------------------
    ;今回のタイムとベストタイムを比較
    ;ベストタイム ope 今回タイム
    ;r0を使用
compare_best_time:
    loda,r0 BestTimer10sBCD
    coma,r0 Timer10sBCD
    retc,gt
    retc,lt    

    loda,r0 BestTimer100msBCD
    coma,r0 Timer100msBCD
    retc,gt
    retc,lt

    loda,r0 BestTimer1msBCD
    coma,r0 Timer1msBCD
    retc,un

end ; End of assembly
