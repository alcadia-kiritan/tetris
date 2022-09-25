;クリアしたときのシーン

    ;-------------------
    ;game_clear_start
    ;クリア時に呼ばれる
    ;r0,r1,r2を使用
game_clear_start:

    eorz r0
    stra,r0 EnabledTimer                ;タイマー止める
    stra,r0 PAGE1+GameClearFrameCount
    stra,r0 PAGE1+GameClearHighScoreUpdated

    loda,r0 PAGE1+GameMode
    bctr,eq _gcs_clear_sprint

    ;normalかtgm20g
    bsta,un compare_score
    bcfr,lt _gcss_not_updated
    bctr,un _gcss_updated

_gcs_clear_sprint:
    ;スプリント
    ;新タイムが出たら更新する
    bsta,un compare_score
    bcfr,gt _gcss_not_updated

_gcss_updated:
    ;ハイスコアかベストタイムを更新した
    loda,r0 Timer10sBCD
    stra,r0 HighScoreData+0,r1
    loda,r0 Timer100msBCD
    stra,r0 HighScoreData+1,r1
    loda,r0 Timer1msBCD
    stra,r0 HighScoreData+2,r1
    lodi,r0 1
    stra,r0 PAGE1+GameClearHighScoreUpdated

_gcss_not_updated:

    bsta,un is_game_over
    retc,gt ;ゲームオーバーなら効果音鳴らさず終了

    ;効果音鳴らしてreturn
    bcta,un play_se14    

    ;-------------------
    ;game_clear
    ;クリアシーン
    ;r0を使用
game_clear:
    loda,r0 PAGE1+GameClearFrameCount
    addi,r0 1
    stra,r0 PAGE1+GameClearFrameCount
    comi,r0 240
    retc,lt

    ;時間経過したらタイトルへ戻る
    lodi,r0 SCENE_GAME_TIELE
    stra,r0 PAGE1+NextSceneIndex
    retc,un

    ;-------------------
    ;game_clear_after_vsync
    ;クリアシーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_clear_after_vsync:

    lodi,r0 SCENE_GAME_TIELE
    coma,r0 PAGE1+NextSceneIndex
    bcfr,eq _gcsav_result       ;時間経過でタイトル遷移モードになった？

    ;----
    ;タイトルに戻る前に画面全体を下にスクロール
    lodi,r2 5
    
    ;スコア更新してたらゆっくりにする
    loda,r0 PAGE1+GameClearHighScoreUpdated
    bctr,eq _gcsav_not_best_time
    lodi,r2 1
_gcsav_not_best_time:

    ;下スクロールして直returnして終了
    bcta,un scroll_to_bottom
    
    ;----
_gcsav_result:

    ;game clear or over
    lodi,r2 text_game-game_hiscr_texts
    bsta,un draw_text_hiscr

    lodi,r2 text_over-game_hiscr_texts  ;over
    bsta,un is_game_over
    bctr,gt _gcsav_gameover
    lodi,r2 text_clear-game_hiscr_texts ;clear
_gcsav_gameover:
    bsta,un draw_text_hiscr

    lodi,r1 (GAME_TEXT_Y-1)*10h+(GAME_TEXT_X-1)
    bsta,un clear5_hi

    lodi,r1 (GAME_TEXT_Y+2)*10h+(GAME_TEXT_X-1)
    bsta,un clear5_hi

    ;bestを表示
    lodi,r2 text_best-game_hiscr_texts
    bsta,un draw_text_hiscr

    loda,r0 PAGE1+GameMode
    bctr,eq _gcav_sprint

    ;normal or tgm20gモード

    ;scoreを表示
    lodi,r2 text_score-game_hiscr_texts
    bsta,un draw_text_hiscr

    ;スコア
    lodi,r1 (GAME_TEXT_Y+4)*10h+(GAME_TEXT_X-1)
    lodi,r3 ScoreCountBCD0-ScoreData
    bsta,un draw_score

    ;ハイスコア
    lodi,r3 HighNormalScoreBCD0-ScoreData
    loda,r0 PAGE1+GameMode
    comi,r0 GAME_MODE_NORMAL
    bctr,eq _gcav_score_is_normal
    lodi,r3 HighTGM20GScoreBCD0-ScoreData
_gcav_score_is_normal:
    lodi,r1 (GAME_TEXT_Y+7)*10h+(GAME_TEXT_X-1)
    bsta,un draw_score

    bctr,un _gcav_end_draw_scores

_gcav_sprint:
    ;スプリントモード

    ;クリアタイム
    lodi,r2 (GAME_TEXT_Y+4)*10h+(GAME_TEXT_X-1)
    lodi,r3 Timer10sBCD-ScoreData
    bsta,un draw_time

    ;ベストタイム
    lodi,r2 (GAME_TEXT_Y+7)*10h+(GAME_TEXT_X-1)
    lodi,r3 BestTimer10sBCD-ScoreData
    bsta,un draw_time

    ;timeを表示
    lodi,r2 text_time-game_hiscr_texts
    bsta,un draw_text_hiscr
    
_gcav_end_draw_scores:

    lodi,r1 (GAME_TEXT_Y+5)*10h+(GAME_TEXT_X-1)
    bsta,un clear5_hi
    
    loda,r0 PAGE1+GameClearHighScoreUpdated
    bctr,eq _gcav_skip_new

    ;newを表示
    lodi,r2 text_new-game_hiscr_texts
    bsta,un draw_text_hiscr
_gcav_skip_new:

    ;下画面の一行目を空行にする
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
    ;draw_score
    ;[ScoreData+r3+0]~[ScoreData+r3+2]のBCDを[SCRUPDATA+r1+0]~[SCRUPDATA+r1+5]へ書き込む
    ;r0,r1,r2,r3を使用
draw_score:
    lodi,r2 3
    subi,r1 1   ;straのインクリメントで処理するために１個前にずらす
    eorz r0
    stra,r0 PAGE1+SCRUPDATA+7,r1

    ;上から見て0の桁をスキップするループ
_ds_first_zero:

    ;上桁
    loda,r0 ScoreData,r3
    andi,r0 0f0h
    bcfr,eq _ds_draw0
    stra,r0 PAGE1+SCRUPDATA,r1+

    ;下桁
    loda,r0 ScoreData,r3
    andi,r0 0fh
    bcfr,eq _ds_draw1

    stra,r0 PAGE1+SCRUPDATA,r1+
    addi,r3 1
    bdrr,r2 _ds_first_zero

    ;最後まで0だけだった,0書いて終了
    lodi,r0 CHAR_0
    stra,r0 PAGE1+SCRUPDATA,r1
    retc,un

    ;順次桁を描画するループ
_ds_draw:

    ;上桁
    loda,r0 ScoreData,r3+
    andi,r0 0f0h
_ds_draw0:

    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    addi,r0 CHAR_0
    stra,r0 PAGE1+SCRUPDATA,r1+
    
    ;下桁
    loda,r0 ScoreData,r3
    andi,r0 0fh
_ds_draw1:
    addi,r0 CHAR_0
    stra,r0 PAGE1+SCRUPDATA,r1+

    bdrr,r2 _ds_draw
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
    ;今回のスコア/タイムとハイスコア/ベストタイムを比較
    ;ベストタイム ope 今回タイム
    ;ハイスコア ope 今回スコア
    ;
    ;r0,r1を使用. r1にはHighScoreDataから当該データへのオフセットが入る
compare_score:
    ;ゲームモードを読み込んで３倍(ハイスコアデータのオフセットに変換)
    loda,r0 PAGE1+GameMode
    strz r1 
    rrl,r1
    addz r1
    strz r1
    
    loda,r0 HighScoreData+0,r1
    coma,r0 Timer10sBCD
    retc,gt
    retc,lt    

    loda,r0 HighScoreData+1,r1
    coma,r0 Timer100msBCD
    retc,gt
    retc,lt

    loda,r0 HighScoreData+2,r1
    coma,r0 Timer1msBCD
    retc,un

    IF BestTimer10sBCD-HighScoreData <> GAME_MODE_SPRINT*3
        warning ゲームモードのオフセットとハイスコアデータのオフセットがズレてる
    ENDIF

    IF HighNormalScoreBCD0-HighScoreData <> GAME_MODE_NORMAL*3
        warning ゲームモードのオフセットとハイスコアデータのオフセットがズレてる
    ENDIF

    IF HighTGM20GScoreBCD0-HighScoreData <> GAME_MODE_TGM20G*3
        warning ゲームモードのオフセットとハイスコアデータのオフセットがズレてる
    ENDIF

    IF ScoreCountBCD0 <> Timer10sBCD
        warning ScoreCountBCD0とTimer10sBCDが同じ位置にない
    ENDIF


end ; End of assembly
