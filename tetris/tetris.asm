    name Tetris                 ; module name
    include "inc\arcadia.h"     ; v1.01

    ;----------------

;https://amigan.yatho.com/a-coding.txt
;Standard Bootstrap-----------------------------------------------37665,33
    org     $0                                                      ;0
    eorz    r0           ;r0 = 0;                                   ;1
    bctr,un BOOT                                                    ;2
empty_subroutine:
    retc,un                                                         ;1
BOOT:
    lpsu                                                            ;1
    lpsl                                                            ;1
    ppsu    $20          ;PSU = %00100000; // inhibit interrupts    ;2
    ppsl    $02          ;PSL = %00000010; // set unsigned compare  ;2
    stra,r0 CRTCVPR      ;VSCROLL = r0 [0];                         ;3
BOOT_1:
    tpsu    $80                                                     ;2
    bcfr,eq BOOT_1                                                  ;2
BOOT_2:
    tpsu    $80                                                     ;2
    bctr,eq BOOT_2                                                  ;2
    strz    r1           ;r1 = r0 [0];                              ;1
BOOT_3:
    stra,r0 $17FF,r1                                                ;3
    stra,r0 $18FF,r1                                                ;3
    stra,r0 $19FF,r1                                                ;3
    bdrr,r1 BOOT_3                                                  ;2
;End Standard Bootstrap---------------------------------------------------

    include "tetris\values.h"

    ;-------------------------------------------------------------------------

    ;高解像度モードへ切り替え
    lodi,r0 01000000b       ;ノーマルモード&高解像度
    stra,r0 RESOLUTION
    lodi,r0 11000111b       ;高解像度&背景黒, 取得するパッド軸を横方向
    stra,r0 BGCOLOUR

    ;スプライトの設定を書き込み
    lodi,r0 11110110b           ;スプライトをdoubleheightの青色に設定
    stra,r0 SPRITES01CTRL
    stra,r0 SPRITES23CTRL

    ;乱数初期化
    bsta,un init_random_tetromino
    
    ;音有効, ボリューム=3
    lodi,r0 0001011b
    stra,r0 VOLUMESCROLL

    ;ハイスコアリセット(0じゃない)
    lodi,r0 99h
    stra,r0 BestTimer1msBCD-PAGE1
    stra,r0 BestTimer100msBCD-PAGE1
    stra,r0 BestTimer10sBCD-PAGE1

    lodi,r0 SCENE_GAME_TIELE
    ;lodi,r0 SCENE_GAME_START
    stra,r0 NextSceneIndex

    ;============================================================================
    ;メインループ
loopforever:

    ;シーンのインデックスを読み込み
    loda,r3 NextSceneIndex
    coma,r3 SceneIndex
    bctr,eq _lf_no_change   ;シーンに変更があったか？

    ;シーンに変更があった. シーン開始時の処理を呼び出す
    stra,r3 SceneIndex
    bsxa scene_table+0,r3
    loda,r3 SceneIndex
_lf_no_change:

    ;メイン処理
    bsxa scene_table+3,r3

    ;現フレームのキー情報を退避
    bsta,un post_key_process        

    ;タイマーを進める
    loda,r0 EnabledTimer-PAGE1
    bsta,gt add_timer_1frame

    ;負荷見る用のコード
    ;loda,r0 CHARLINE
    ;stra,r0 Debug0

    ;垂直帰線期間を待つ
    bsta,un wait_vsync

    ;パッドの状態を取得しておく
    bsta,un get_padd_status_player1     

    ;音処理. 垂直同期からここまでタイミングがずれるような重い処理をしないように注意
    bsta,un sound_process

    ;垂直同期後の処理, ここからタイミングが限られてる系の処理（主に描画
    loda,r3 SceneIndex
    bsxa scene_table+6,r3

    ;タイマー更新
    loda,r0 EnabledTimer-PAGE1
    bsta,gt update_timer_text

    ;0-5のカウンタを回す
    loda,r0 FrameCount6
    addi,r0 1
    comi,r0 6
    bctr,lt _lf_skip_counter_reset
    eorz r0 
_lf_skip_counter_reset:
    stra,r0 FrameCount6
    
    bcta,un loopforever  ; Loop forever
    ;============================================================================

    ;============
    ;シーンテーブル
    ;垂直同期前に実行されるサブルーチンと、垂直同期後に実行されるサブルーチンのペア、のbctaが並んでる
    
    SCENE_GAME_MAIN                 equ     0 * 9       ;9=bcta命令3個分  
    SCENE_GAME_NEW_TETROMINO        equ     1 * 9
    SCENE_GAME_LOCK_DOWN            equ     2 * 9
    SCENE_GAME_OVER                 equ     3 * 9
    SCENE_GAME_TIELE                equ     4 * 9
    SCENE_GAME_START                equ     5 * 9
    SCENE_GAME_CLEAR                equ     6 * 9

scene_table:
    ;---    
    bcta,un empty_subroutine
    bcta,un game_main
    bcta,un game_main_after_vsync
    ;---
    bcta,un empty_subroutine
    bcta,un game_new_tetromino
    bcta,un game_new_tetromino_after_vsync
    ;---
    bcta,un empty_subroutine
    bcta,un game_lock_down
    bcta,un game_lock_down_after_vsync
    ;---
    bcta,un game_over_start
    bcta,un empty_subroutine
    bcta,un game_over_after_vsync
    ;---
    bcta,un game_title_start
    bcta,un game_title
    bcta,un game_title_after_vsync
    ;---
    bcta,un game_start_start
    bcta,un empty_subroutine
    bcta,un empty_subroutine
    ;---
    bcta,un game_clear_start
    bcta,un game_clear
    bcta,un game_clear_after_vsync



    ;/////////////////////////

    ;メイン
    include "tetris\game_main.asm"

    ;共通処理
    include "tetris\common.asm"
    
    ;新しいテトリス生成するときの処理
    include "tetris\game_new_tetromino.asm"

    ;タイトル画面
    include "tetris\game_title.asm"

    ;ゲームスタート
    include "tetris\game_start.asm"

    ;テトロミノ
    include "tetris\tetromino.h"

    ;音系
    include "tetris\sound.asm"
    
_PAGE0END_:
    IF _PAGE0END_ >= 1000h
        WARNING "0ページ目の末端が4K超えてる"
    ENDIF
    
    ;-----
    ;ここから下はpage1
    org PAGE1
    
    ;テトリスを固定する処理
    include "tetris\game_lock_down.asm"

    ;ゲームオーバー関連
    include "tetris\game_over.asm"

    ;汎用処理
    include "inc\util.h"
    
    ;mod2-mod7
    include "inc\mod.h"

    ;シャッフル関係
    include "tetris\shuffle.asm"

    ;音系2
    include "tetris\se.asm"

    ;スコア系
    include "tetris\score.asm"

    ;スプリントクリア
    include "tetris\game_clear.asm"

    ;テキスト描画
    include "tetris\draw_text_hiscr.asm"

    ;/////////////////////////

_PAGE1END_:

    IF _PAGE1END_ >= PAGE1 + 1000h
        WARNING "1ページ目の末端が12K超えてる"
    ENDIF

end ; End of assembly
