    ;スコア関係のサブルーチン群

    ;-------------------
    ;score_reset
    ;r0,r1を使用
score_reset:
    lodi,r1 LastScoreValue-ScoreData
    eorz r0 
_sr:
    stra,r0 ScoreData,r1-
    brnr,r1 _sr
    retc,un

    ;-------------------
    ;update_timer_text
    ;タイマーを更新
    ;r0,r1を使用
update_timer_text:
    ;1/10s
    loda,r1 Timer100msBCD
    lodz r1 
    andi,r0 0fh
    addi,r0 10h
    stra,r0 PAGE1+SCRLODATA+(SCORE_TEXT_Y+1)*10h+SCORE_TEXT_X+4

    ;'.'
    lodi,r0 34h
    stra,r0 PAGE1+SCRLODATA+(SCORE_TEXT_Y+1)*10h+SCORE_TEXT_X+3

    ;1s
    rrr,r1
    rrr,r1
    rrr,r1
    rrr,r1
    andi,r1 0fh
    addi,r1 10h
    stra,r1 PAGE1+SCRLODATA+(SCORE_TEXT_Y+1)*10h+SCORE_TEXT_X+2

    ;10s/100s
    loda,r1 Timer10sBCD
    retc,eq ;上２桁が０. 描画しない

    lodz r1
    andi,r0 0f0h
    bctr,eq _utt_skip100s
    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    addi,r0 10h
    stra,r0 PAGE1+SCRLODATA+(SCORE_TEXT_Y+1)*10h+SCORE_TEXT_X+0

_utt_skip100s:
    andi,r1 0fh
    addi,r1 10h
    stra,r1 PAGE1+SCRLODATA+(SCORE_TEXT_Y+1)*10h+SCORE_TEXT_X+1
    retc,un

    ;-------------------
    ;update_score_text
    ;スコア表記を更新
    ;r0,r1,r2,r3を使用
update_score_text:
    loda,r0 UpdateScoreText
    retc,eq ;更新がないので終了

update_score_text_force:

    eorz r0 
    stra,r0 UpdateScoreText ;フラグ落す

    ;スコア
    loda,r0 PAGE1+GameMode
    bctr,eq _ust_skip_score ;スプリントならスコアは描画しない
    lodi,r1 (SCORE_TEXT_Y+1)*10h+SCORE_TEXT_X-1 ;エッジと被る,がまあ・・６桁は無理ってことでスルー
    lodi,r2 3
    lodi,r3 ScoreCountBCD0-ScoreData
    bsta,un draw_bcd
_ust_skip_score:

    ;ライン
    lodi,r1 (LINE_TEXT_Y+1)*10h+LINE_TEXT_X+1
    lodi,r2 2
    lodi,r3 LineCountBCD0-ScoreData
    bsta,un draw_bcd

    ;テトリス
    lodi,r1 (TETRIS_TEXT_Y+1)*10h+TETRIS_TEXT_X+1
    lodi,r2 2
    lodi,r3 TetrisCountBCD0-ScoreData
    bsta,un draw_bcd

    ;レベル
    lodi,r1 (LV_TEXT_Y+1)*10h+LV_TEXT_X
    lodi,r2 2
    lodi,r3 LvBCD0-ScoreData
    bsta,un draw_bcd

    ;t-spin
    lodi,r1 (TSPIN_TEXT_Y+1)*10h+TSPIN_TEXT_X+1
    lodi,r2 2
    lodi,r3 TspinCountBCD0-ScoreData
    bcta,un draw_bcd    ;直return

    ;-------------------
    ;draw_bcd
    ;[ScoreData+r3]~[ScoreData+r3+r2-1]のBCDを[SCRLODATA+r1+0]~[SCRLODATA+r1+r2*2-1]へ書き込む
    ;r0,r1,r2,r3を使用
draw_bcd:

    subi,r1 1   ;straのインクリメントで処理するために１個前にずらす

    ;上から見て0の桁をスキップするループ
_db_first_zero:

    ;上桁
    loda,r0 ScoreData,r3
    andi,r0 0f0h
    bcfr,eq _db_draw0
    addi,r1 1

    ;下桁
    loda,r0 ScoreData,r3
    andi,r0 0fh
    bcfr,eq _db_draw1

    addi,r1 1
    addi,r3 1
    bdrr,r2 _db_first_zero

    ;最後まで0だけだった,0書いて終了
    lodi,r0 CHAR_0
    stra,r0 PAGE1+SCRLODATA,r1
    retc,un

    ;順次桁を描画するループ
_db_draw:

    ;上桁
    loda,r0 ScoreData,r3+
    andi,r0 0f0h
_db_draw0:

    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    addi,r0 CHAR_0
    stra,r0 PAGE1+SCRLODATA,r1+
    
    ;下桁
    loda,r0 ScoreData,r3
    andi,r0 0fh
_db_draw1:
    addi,r0 CHAR_0
    stra,r0 PAGE1+SCRLODATA,r1+

    bdrr,r2 _db_draw
    
    retc,un

    ;-------------------
    ;add_line1_score
    ;１行消したときのスコアカウント
    ;r0,r1,r2,r3,Temporary0を使用
add_line1_score:
    ;スコア+
    lodi,r0 1h+66h
    bsta,un bcd_add_with_score
    
    ;ライン+
    lodi,r0 1h+66h
    bcta,un bcd_add_with_line

    ;-------------------
    ;add_line2_score
    ;2行消したときのスコアカウント
    ;r0,r1,r2,r3,Temporary0を使用
add_line2_score:
    ;スコア+
    lodi,r0 5h+66h
    bsta,un bcd_add_with_score
    
    ;ライン+
    lodi,r0 2+66h
    bcta,un bcd_add_with_line

    ;-------------------
    ;add_line3_score
    ;3行消したときのスコアカウント
    ;r0,r1,r2,r3,Temporary0を使用
add_line3_score:
    ;スコア+
    lodi,r0 10h+66h
    bsta,un bcd_add_with_score
    
    ;ライン+
    lodi,r0 3+66h
    bcta,un bcd_add_with_line

    ;-------------------
    ;add_line4_score
    ;4行消したときのスコアカウント
    ;r0,r1,r2,r3,Temporary0を使用
add_line4_score:
    ;スコア+
    lodi,r0 20h+66h
    bsta,un bcd_add_with_score

    ;テトリス+
    lodi,r0 1+66h
    lodi,r1 TetrisCountBCD1-ScoreData
    lodi,r2 2
    bsta,un bcd_add
    
    ;ライン+
    lodi,r0 4+66h
    bcta,un bcd_add_with_line

    ;-------------------
    ;bcd_add_with_line
    ;LineCountBCD0/1にr0(0~99)-66hを足す. ついでにレベルアップもする
    ;r0,r1,r2,r3,Temporary0を使用
bcd_add_with_line:
    loda,r3 LineCountBCD1
    lodi,r1 LineCountBCD1-ScoreData
    lodi,r2 2
    stra,r2 UpdateScoreText         ;更新フラグ立てる
    bstr,un bcd_add

    ;ラインの10の桁が変わったかチェック, 代わってたらレベルアップ
    eora,r3 LineCountBCD1
    andi,r3 0f0h
    retc,eq             ;１０の桁に変化なし.終了
    
    ;レベルアップ処理して直return
    bcta,un level_up

    ;-------------------
    ;add_tspin_score
    ;t-spinのスコアカウント
    ;r0,r1,r2,Temporary0を使用
add_tspin_score:
    ;スコア+
    lodi,r0 8h+66h
    bsta,un bcd_add_with_score
    
    ;t-spin+
    lodi,r0 1+66h
    stra,r0 UpdateScoreText
    lodi,r1 TspinCountBCD1-ScoreData
    lodi,r2 2
    bctr,un bcd_add

    ;-------------------
    ;bcd_add_with_score
    ;ScoreCountBCD0-2にr0(0~99)-66hを足す.
    ;r0,r1,r2,Temporary0を使用
bcd_add_with_score:
    loda,r1 PAGE1+GameMode
    retc,eq                 ;スプリントならスコアは足さない.

    lodi,r1 ScoreCountBCD2-ScoreData
    lodi,r2 3
    bctr,un bcd_add ;直return

    ;-------------------
    ;bcd_add
    ;BCDの[ScoreData+r1]にr0(0~99)-66hを足す.[ScoreData+r1-(r2-1)]まで順次桁上がりする
    ;r0,r1,r2,Temporary0を使用
bcd_add:
    stra,r2 PAGE1+Temporary0
    ;addi,r0 66h    ;引数側で対応
    
    adda,r0 ScoreData,r1
    dar,r0
    stra,r0 ScoreData,r1

    tpsl 1b
    bcfr,eq _ba_end ;桁上がりが出なかったので終了
    
_ba_carray_up:
    subi,r2 1
    bctr,eq _ba_overflow
    lodi,r0 67h
    adda,r0 ScoreData,r1-
    dar,r0
    stra,r0 ScoreData,r1
    bctr,eq _ba_carray_up       ;+1して0になった.桁上がりをもう一回.

_ba_end:
    retc,un

_ba_overflow:
    ;全部99にする
    loda,r2 PAGE1+Temporary0
    subi,r1 1
    lodi,r0 99h
_ba_overflow_:
    stra,r0 ScoreData,r1+
    bdrr,r2 _ba_overflow_
    retc,un
    
    ;-------------------
    ;add_timer_1frame
    ;Timer1msBCD/Timer100msBCD/Timer10sBCDに1/60s(1フレーム)を足す
    ;r0,r1,r2,Temporary0を使用
add_timer_1frame:

    ;0-5カウンタが奇数か０のときは17を足す,それ以外は16を足す. 60フレームで合計1000になる.
    lodi,r0 17h + 66h
    loda,r1 FrameCount6+PAGE1
    bctr,eq _at1f_skip16
    andi,r1 1
    bcfr,eq _at1f_skip16
    lodi,r0 16h + 66h
_at1f_skip16:
    lodi,r1 Timer1msBCD-ScoreData
    lodi,r2 3

    ;16か17足して直return
    bcta,un bcd_add

    ;-------------------
    ;level_up
    ;レベルアップ処理
    ;r0,r1,r2を使用
level_up:
    bsta,un play_se8

    loda,r0 PAGE1+GameMode
    bcfr,eq _lu_not_sprint

    ;スプリント
    loda,r0 FallFrame+PAGE1
    comi,r0 5
    bctr,lt _lv_sprint_gup

    ;落下までのフレーム数を下げる
    subi,r0 3
    stra,r0 FallFrame+PAGE1
    bctr,un _lu_lv_inc

_lv_sprint_gup:
    ;フレームはもう十分小さいので重力上げる
    loda,r0 FallDistance+PAGE1
    addi,r0 2
    stra,r0 FallDistance+PAGE1
    bctr,un _lu_lv_inc

_lu_not_sprint:
    ;スプリント以外
    loda,r0 FallFrame+PAGE1
    comi,r0 5
    bctr,lt _lv_not_sprint_gup
    
    ;落下までのフレーム数を下げる
    subi,r0 2
    stra,r0 FallFrame+PAGE1
    bctr,un _lu_lv_inc

_lv_not_sprint_gup:
    ;フレームはもう十分小さいので重力上げる
    loda,r0 FallDistance+PAGE1
    comi,r0 20
    bctr,eq _lv_not_sprint_lock_up
    addi,r0 1
    stra,r0 FallDistance+PAGE1
    bctr,un _lu_lv_inc

_lv_not_sprint_lock_up:
    ;重力も十分大きいので、ロックダウンまでのフレーム数を下げる
    loda,r0 LockDownFrames+PAGE1
    comi,r0 3
    bctr,lt _lu_lv_inc
    subi,r0 1
    stra,r0 LockDownFrames+PAGE1

_lu_lv_inc:
    ;表示用のBCDをインクリメント
    lodi,r0 1+66h
    lodi,r1 LvBCD1-ScoreData
    lodi,r2 2
    bcta,un bcd_add ;直return
    

    ;テストコード
IF 0

    lodi,r0 0cch
    stra,r0 ScoreCountBCD2+1-PAGE1
    
    lodi,r0 1
    lodi,r1 ScoreCountBCD2-ScoreData
    lodi,r2 3
    bsta,un bcd_add

    lodi,r0 90h
    lodi,r1 ScoreCountBCD2-ScoreData
    lodi,r2 3
    bsta,un bcd_add
    halt
    lodi,r0 90h
    lodi,r1 ScoreCountBCD2-ScoreData
    lodi,r2 3
    bsta,un bcd_add
    
    lodi,r0 98h
    lodi,r1 ScoreCountBCD1-ScoreData
    lodi,r2 3
    bsta,un bcd_add

    lodi,r0 18h
    lodi,r1 ScoreCountBCD2-ScoreData
    lodi,r2 3
    bsta,un bcd_add
    
    lodi,r0 2h
    lodi,r1 ScoreCountBCD2-ScoreData
    lodi,r2 3
    bsta,un bcd_add

    lodi,r0 99h
    stra,r0 ScoreCountBCD0-PAGE1
    stra,r0 ScoreCountBCD1-PAGE1
    subi,r0 2
    stra,r0 ScoreCountBCD2-PAGE1

    lodi,r0 3h
    lodi,r1 ScoreCountBCD2-ScoreData
    lodi,r2 3
    bsta,un bcd_add

    halt


    lodi,r0 12h
    stra,r0 ScoreCountBCD0-PAGE1
    lodi,r0 34h
    stra,r0 ScoreCountBCD1-PAGE1
    lodi,r0 56h
    stra,r0 ScoreCountBCD2-PAGE1

    lodi,r1 10h*3+3
    lodi,r2 3
    lodi,r3 ScoreCountBCD0 - ScoreData
    bcta,un draw_bcd
    halt

ENDIF


end ; End of assembly
