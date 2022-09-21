    name DrawBlock          ; module name

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

    ppsl 00000010b           ; COM=1
    
    ;-------------------------------------------------------------------------
    ;変数定義
    ;----
    ;RAM1 $18D0..$18EF
    
    ;テトリス関係
    TetrominoData               equ 18D0h
    TetrominoX                  equ TetrominoData+0        ;操作テトリミノのX座標 (0,0)-(31,25)
    TetrominoY                  equ TetrominoData+1        ;操作テトリミノのY座標 (0,0)-(31,25)
    TetrominoRotate             equ TetrominoData+2        ;操作テトリミノの回転(0-3)
    TetrominoType               equ TetrominoData+3        ;操作テトリミノのタイプ(0-6)

    NextTetrominoX              equ TetrominoData+4        ;移動先の操作テトリミノのX座標 (0,0)-(31,25)
    NextTetrominoY              equ TetrominoData+5        ;移動先の操作テトリミノのY座標 (0,0)-(31,25)
    NextTetrominoRotate         equ TetrominoData+6        ;移動先の操作テトリミノの回転(0-3)
    NextTetrominoType           equ TetrominoData+7        ;ホールドでチェンジしたときの操作テトリミノのタイプ(0-6)
    
    UpdatedTetrominoSprites     equ TetrominoData+8        ;操作テトリミノの位置を更新するかどうか,0:更新しない 1:更新, 2:削除
    GhostTetrominoY             equ TetrominoData+9        ;ゴーストテトリミノのY座標

    TetrominoData2              equ TetrominoData+10
    FallFrame                   equ TetrominoData2+0        ;操作テトリミノが落下するまでのフレーム数.固定値.
    FallFrameCounter            equ TetrominoData2+1        ;操作テトリミノが落下するまでのフレーム数のカウント
    FallDistance                equ TetrominoData2+2        ;操作テトリミノが落下する量.固定値.

    HoldTetrominoType           equ TetrominoData2+3        ;ホールドしてるテトロミノのタイプ
    EnabledHoldTetromino        equ TetrominoData2+4        ;ホールドが有効かどうか
    DrawHoldTetromino           equ TetrominoData2+5        ;ホールドテトリミノを描画するかどうか

    NextOperationTetrominoType0 equ TetrominoData2+6        ;次に落ちてくるテトロミノのタイプ
    NextOperationTetrominoType1 equ TetrominoData2+7        ;２個次に落ちてくるテトロミノのタイプ
    NextOperationTetrominoType2 equ TetrominoData2+8        ;３個次に落ちてくるテトロミノのタイプ

    ;キー関係
    KeyData                     equ TetrominoData2+9
    PrevP1LeftKeys              equ KeyData+0           ;１フレーム前のP1LEFTKEYSの値
    CountRepeatedP1LeftKeys     equ KeyData+1           ;押し続けた時のリピート処理用カウンタ, 前フレームと同じ値が来ると減算されて０になると押してる扱いになる
    PrevP1MiddleKeys            equ KeyData+2           ;１フレーム前のP1MIDDLEKEYSの値
    CountRepeatedP1MiddleKeys   equ KeyData+3    
    PrevP1RightKeys             equ KeyData+4           ;１フレーム前のP1RIGHTKEYSの値
    CountRepeatedP1RightKeys    equ KeyData+5    
    PrevP1Pad                   equ KeyData+6           ;１フレーム前のP1PADDLEの値を0,1(左),2(右)にした値
    CountRepeatedP1Pad          equ KeyData+7    
    P1Pad                       equ KeyData+8           ;現フレームのP1PADDLEの値を0,1(左),2(右)にした値
            

    ;シーン制御系
    GameManagedData             equ KeyData+9
    SceneIndex                  equ GameManagedData+0     ;現在処理中のシーンのインデックス（の３倍の値）
    NextSceneIndex              equ GameManagedData+1     ;次に処理するシーンのインデックス（の３倍の値）

    ;領域超過チェック用！　最後の変数の変更に注意！
    EndRAM1                     equ NextSceneIndex

    IF EndRAM1 > 18EFh
        error RAM1がオーバーしてるよ
    ENDIF

    ;----
    ;RAM2 $18F8..$18FB
    ;なんかの引数や退避領域として使う
    Temporary0 equ 18F8h       ;汎用領域
    Temporary1 equ 18F9h       ;汎用領域
    Temporary2 equ 18FAh       ;汎用領域
    Temporary3 equ 18FBh       ;汎用領域

    ;----
    ;RAM3 $1AD0..$1AFF

    ;消す行の情報 or 操作テトロミノのブロックの座標
    ;時系列で同時に使うことが無いので被せる
    TetrominoData3             equ 1AD0h
    FallLineIndex              equ TetrominoData3+0    ;行をずらし始める行
    FallFuncionIndex           equ TetrominoData3+1    ;どういうずらし方をするか

    OperationTetrominoX0        equ TetrominoData3+0    ;操作テトロミノのブロック座標郡
    OperationTetrominoY0        equ TetrominoData3+1
    OperationTetrominoX1        equ TetrominoData3+2
    OperationTetrominoY1        equ TetrominoData3+3
    OperationTetrominoX2        equ TetrominoData3+4
    OperationTetrominoY2        equ TetrominoData3+5
    OperationTetrominoX3        equ TetrominoData3+6
    OperationTetrominoY3        equ TetrominoData3+7

    ; ドロップ系
    TetrominoData4                  equ TetrominoData3+8
    DoHardDrop                      equ TetrominoData4+0    ;ハードドロップするかどうか
    LockDownOperationCount          equ TetrominoData4+1    ;ロックダウンカウント中にやった操作回数
    LockDownCounter                 equ TetrominoData4+2    ;ロックダウンされるまでのフレームのカウント.
    LockDownFrames                  equ TetrominoData4+3    ;ロックダウンされるまでのフレーム.固定値.(ex:30 = 0.5s
    
    ;乱数系
    RandomData                  equ TetrominoData4+4 +PAGE1
    RandomBytes0                equ RandomData+0        ;乱数制御用のデータ
    RandomBytes1                equ RandomData+1   

    ;テトロミノのシャッフル用
    ShuffleTetromino            equ RandomData+2
    ShuffleTetromino0           equ ShuffleTetromino+0   ;テトロミノ７種類のシャッフルに使う変数群
    ShuffleTetromino1           equ ShuffleTetromino+1
    ShuffleTetromino2           equ ShuffleTetromino+2
    ShuffleTetromino3           equ ShuffleTetromino+3
    ShuffleTetromino4           equ ShuffleTetromino+4
    ShuffleTetromino5           equ ShuffleTetromino+5
    ShuffleTetromino6           equ ShuffleTetromino+6
    ShuffleIndex                equ ShuffleTetromino+7   ;現在シャッフルの何番目か

    ;音系
    SoundData                   equ ShuffleTetromino+8 -PAGE1
    SoundFrameCount             equ SoundData+0         ;音節を何フレーム回すか
    SoundPriority               equ SoundData+1
    SoundDataAddress0           equ SoundData+2         ;次に鳴らす音データのアドレス,01は並んでいること
    SoundDataAddress1           equ SoundData+3
    

    ;デバッグ用, 都度適当に使う
    Debug                       equ SoundData+4
    Debug0                      equ Debug + 0
    Debug1                      equ Debug + 1
    Debug2                      equ Debug + 2
    Debug3                      equ Debug + 3

    ;領域超過チェック用！　最後の変数の変更に注意！
    EndRAM3                     equ Debug3

    IF EndRAM3 > 1AFFh
        error RAM3がオーバーしてるよ
    ENDIF

    ;-------------------------------------------------------------------------
    ;定数定義

    ;------
    ;ゲーム関係
    MAX_LOCK_DOWN_OPERATION equ 15          ;接地状態で最大何回操作可能か

    ;------
    ;入力関係
    FIRST_REPEAT_INTERVAL   equ 10-1        ;ボタンおしっぱのときに最初にリピート入力が有効になるまでのフレーム数
    REPEAT_INTERVAL         equ 5-1         ;リピート入力の間隔

    ;------
    ;色関係
    EDGE_COLOR              equ     40h     ;00h,40h,80h,c0h        ;フィールドの左右下にあるブロックか線かの色
    TETROMINO_COLOR         equ     00h     ;テトリミノの色
    GHOST_COLOR             equ     0C0h    ;ゴーストの色
    NEXT_TETROMINO_COLOR    equ     00h     ;NEXTのテトリミノの色
    HOLD_ENABLE_COLOR       equ     00h    
    HOLD_DISABLE_COLOR      equ     80h

    ;-----
    ;
    BLOCK_SPRITE_INDEX      equ     03Ch
    EMPTY_2BLOCK            equ     BLOCK_SPRITE_INDEX + TETROMINO_COLOR

    ;------
    ;ここから下画面関係

    SCROLL_Y            equ 208                             ;スクロール位置
    SPRITE_OFFSET_Y     equ (SCROLL_Y*3+42-624+24-39)/3     ;描画領域の一番下の行に合う位置
    SPRITE_OFFSET_X     equ (156+102)/6                     ;描画領域の一番左の列に合う位置

    SCREEN_CHARA_WIDTH          equ 16                          ;アルカディアのキャラクター(8x4)での横幅
    HALF_SCREEN_CHARA_HEIGHT    equ 13              
    SCREEN_CHARA_HEIGHT         equ HALF_SCREEN_CHARA_HEIGHT*2  ;アルカディアのキャラクター(8x4)での立幅

    ;[テトリスの座標系]
    ;画面左下を(0,0), 右上を(31,25)とする32x26の座標系

    SCREEN_WIDTH        equ SCREEN_CHARA_WIDTH*2             ;テトリスの座標系での画面の横幅
    SCREEN_HEIGHT       equ SCREEN_CHARA_HEIGHT              ;テトリスの座標系での画面の高さ

    FIELD_WIDTH         equ 10              ;テトリスのフィールドの横幅
    FIELD_HEIGHT        equ 20              ;テトリスのフィールドの立幅
    FIELD_START_X       equ 10              ;フィールドの開始座標、左下のX
    FIELD_START_Y       equ 2               ;フィールドの開始座標、左下のY

    ;上下画面でのフィールドの縦幅
    FIELD_HEIGHT_ON_LOWER_SCREEN    equ HALF_SCREEN_CHARA_HEIGHT - FIELD_START_Y
    FIELD_HEIGHT_ON_UPPER_SCREEN    equ FIELD_HEIGHT - FIELD_HEIGHT_ON_LOWER_SCREEN

    ;ホールドブロックを表示する位置(テトリス座標系)
    HOLD_TETROMINO_X            equ 2
    HOLD_TETROMINO_Y            equ 20
    EMPTY_HOLD_TETROMINO_TYPE   equ 0ffh
    HOLD_TETROMINO_DATA         equ SCRUPDATA+(SCREEN_CHARA_HEIGHT - HOLD_TETROMINO_Y)*10h+HOLD_TETROMINO_X/2

    ;次のブロックを表示する位置
    NEXT_TETROMINO_X        equ 25
    NEXT_TETROMINO_Y        equ 20
    NEXT_TETROMINO_Y_STEP   equ 3
    NEXT_TETROMINO_DATA     equ SCRUPDATA+(SCREEN_CHARA_HEIGHT - NEXT_TETROMINO_Y)*10h+NEXT_TETROMINO_X/2

    ;新規テトロミノの位置
    NEW_TETROMINO_X        equ FIELD_START_X + FIELD_WIDTH / 2
    NEW_TETROMINO_Y        equ FIELD_START_Y + FIELD_HEIGHT

    ;-----
    ;テトリスに関係ない系

    ;通常描画モードでの0とA
    CHAR_0          equ 10h
    CHAR_0_OFFSET   equ 10h - '0'       ; CHAR_0_OFFSET+'0' を描画すると0が出る
    CHAR_A          equ 1Ah
    CHAR_A_OFFSET   equ 1Ah - 'A'

    PAGE1    equ 2000h

    ;-------------------------------------------------------------------------

    ;ramをクリア
    bsta,un clear_ram
    
    ;変数初期化
    lodi,r0 FIELD_START_X + 3
    stra,r0 TetrominoX
    stra,r0 NextTetrominoX
    lodi,r0 FIELD_START_Y + 3
    stra,r0 TetrominoY
    stra,r0 NextTetrominoY
    eorz r0
    stra,r0 TetrominoType
    stra,r0 TetrominoRotate

    ;スクロール位置を画面上端へ
    lodi,r0 SCROLL_Y
    stra,r0 CRTCVPR

    ;高解像度モードへ切り替え
    lodi,r0 01000000b       ;ノーマルモード&高解像度
    stra,r0 RESOLUTION
    lodi,r0 11000111b       ;高解像度&背景緑    ,取得するパッド軸を横方向
    stra,r0 BGCOLOUR

    ;-------------------
    ;ブロックのデータをユーザー定義のキャラ領域(UDC[0-4]DATA)へ転送
    lodi,r1 32                ;転送サイズ
set_user_characters:
    loda,r0 BLOCK00a,r1-
    stra,r0 UDC0DATA,r1
    brnr,r1 set_user_characters       ;r1が0でなければset_user_charactersへ分岐

    ;-------------------
    ;１ブロックだけ描く用のデータを、ユーザー定義のスプライト領域(SPRITE[0-4]DATA)へ転送
    lodi,r1 8                ;転送サイズ
set_user_sprites:
    loda,r0 BLOCK10a,r1-
    stra,r0 SPRITE0DATA,r1
    stra,r0 SPRITE1DATA,r1
    stra,r0 SPRITE2DATA,r1
    stra,r0 SPRITE3DATA,r1
    brnr,r1 set_user_sprites       ;r1が0でなければset_user_spritesへ分岐

    ;スプライトの設定を書き込み
    lodi,r0 11110110b           ;スプライトをdoubleheightの青色に設定
    stra,r0 SPRITES01CTRL
    stra,r0 SPRITES23CTRL

    bsta,un wait_vsync
    bsta,un reset_tetromino_field
    lodi,r0 40
    stra,r0 FallFrame
    lodi,r0 1
    stra,r0 FallDistance

    lodi,r0 SCENE_GAME_NEW_TETROMINO
    stra,r0 NextSceneIndex

    lodi,r0 0
    stra,r0 NextOperationTetrominoType0
    lodi,r0 0
    stra,r0 NextOperationTetrominoType1
    lodi,r0 0
    stra,r0 NextOperationTetrominoType2

    lodi,r0 1
    stra,r0 EnabledHoldTetromino

    lodi,r0 EMPTY_HOLD_TETROMINO_TYPE
    stra,r0 HoldTetrominoType

    lodi,r0 30
    stra,r0 LockDownFrames

    bsta,un init_random_tetromino
    ;bsta,un wait_vsync
    
    ;ボリューム
    lodi,r0 0001011b
    stra,r0 VOLUMESCROLL

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
    stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-2)*10h+3
    ;stra,r0 SCRLODATA+FIELD_START_X/2+(FIELD_HEIGHT_ON_LOWER_SCREEN-4)*10h+3

    bcta,un skiptest

    lodi,r3 2
    ;lodi,r3 16
    ;lodi,r3 13
test_init:
    lodi,r0 010h
    lodi,r1 FIELD_HEIGHT_ON_LOWER_SCREEN
    lodi,r2 (FIELD_HEIGHT_ON_LOWER_SCREEN-1)*10h
setscreen_lower:
    stra,r0 SCRLODATA+FIELD_START_X/2+0,r2
    addi,r0 40h
    stra,r0 SCRLODATA+FIELD_START_X/2+1,r2
    addi,r0 40h
    stra,r0 SCRLODATA+FIELD_START_X/2+2,r2
    addi,r0 40h
    stra,r0 SCRLODATA+FIELD_START_X/2+3,r2
    addi,r0 40h
    stra,r0 SCRLODATA+FIELD_START_X/2+4,r2
    addi,r0 40h
    subi,r2 010h
    addi,r0 1
    bdrr,r1 setscreen_lower
    
    ;lodi,r0 010h
    lodi,r1 FIELD_HEIGHT_ON_UPPER_SCREEN+1
    lodi,r2 (HALF_SCREEN_CHARA_HEIGHT-1)*10h
setscreen_upper:
    stra,r0 SCRUPDATA+FIELD_START_X/2+0,r2
    addi,r0 40h
    stra,r0 SCRUPDATA+FIELD_START_X/2+1,r2
    addi,r0 40h
    stra,r0 SCRUPDATA+FIELD_START_X/2+2,r2
    addi,r0 40h
    stra,r0 SCRUPDATA+FIELD_START_X/2+3,r2
    addi,r0 40h
    stra,r0 SCRUPDATA+FIELD_START_X/2+4,r2
    addi,r0 40h
    subi,r2 010h
    addi,r0 1
    bdrr,r1 setscreen_upper


testloop:
    
    bsta,un post_key_process        ;現フレームのキー情報を退避
    bsta,un wait_vsync                  ;垂直帰線期間を待つ
    bsta,un get_padd_status_player1     ;パッドの状態を取得しておく

    loda,r0 P1LEFTKEYS
    lodi,r1 PrevP1LeftKeys - KeyData
    bsta,un button_process    

    ;Qキー
    tmi,r0 0100b
    bcfr,eq testloop

    lodz r3
    strz r1
    ;bsta,un fall_lines_1
    ;bsta,un fall_lines_2
    ;bsta,un fall_lines_3
    ;bsta,un fall_lines_4
    ;bsta,un fall_lines_1_1_1
    ;bsta,un fall_lines_1_1_2
    ;bsta,un fall_lines_1_2_1
    bsta,un fall_lines_2_1_1
    addi,r3 1

    lodi,r1 30
wait_one_sec:
    bsta,un wait_vsync
    bdrr,r1 wait_one_sec

    bcta,un test_init


    bctr,un testloop
skiptest:
    
    ;============================================================================
    ;メインループ

loopforever:

    ;bsta,un store_charline_debug0       ;負荷を見るためのデバッグ用コード

    ;シーンのインデックスを読み込み
    loda,r0 NextSceneIndex
    stra,r0 SceneIndex
    strz r3

    ;メイン処理
    bsxa scene_table,r3

    ;bsta,un store_charline_debug1       ;負荷を見るためのデバッグ用コード

    ;垂直帰線期間を待つ
    bsta,un wait_vsync

    ;音処理
    bsta,un sound_process

    ;bsta,un store_charline_debug2       ;負荷を見るためのデバッグ用コード

    ;垂直同期後の処理, ここからタイミングが限られてる系の処理（主に描画
    loda,r3 SceneIndex
    bsxa scene_table+3,r3
    
    
    bctr,un loopforever  ; Loop forever
    ;============================================================================

    ;============
    ;シーンテーブル
    ;垂直同期前に実行されるサブルーチンと、垂直同期後に実行されるサブルーチンのペア
    
    SCENE_GAME_MAIN                 equ     0 * 6       ;6=bcta命令2個分  
    SCENE_GAME_NEW_TETROMINO        equ     1 * 6
    SCENE_GAME_LOCK_DOWN            equ     2 * 6

scene_table:
    bcta,un game_main
    bcta,un game_main_after_vsync
    bcta,un game_new_tetromino
    bcta,un game_new_tetromino_after_vsync
    bcta,un game_lock_down
    bcta,un game_lock_down_after_vsync

    ;///////////////////////////////////////////////////////////
    ;ゲームのメイン処理
game_main:

    bsta,un store_operation_tetromino_positions
    bsta,un move_tetromino
    bsta,un set_ghost_tetromino_y
    bsta,un fall_operation_tetromino

    bsta,un post_key_process        ;現フレームのキー情報を退避
    retc,un

    ;ゲームのメイン処理のうち垂直同期後にやる処理
game_main_after_vsync:

    bsta,un get_padd_status_player1     ;パッドの状態を取得しておく
    bsta,un draw_ghost_tetromino            ;ゴーストの描画, スプライト更新があるので優先度高め

    bsta,un draw_hold_tetromino         ;ホールドテトロミノの描画

    ;bsta,un bake_operation_tetromino
    bsta,un update_operation_tetromino      ;操作テトリミノの更新

    

    retc,un
    ;///////////////////////////////////////////////////////////

    ;-------------------
    ;hold_operation_tetromino
    ;操作テトロミノをホールドする
    ;r0,r1,r2 r4,r5,r6を使用
hold_operation_tetromino:
    loda,r0 EnabledHoldTetromino
    bcta,eq play_se2    ;ホールド出来ない. 効果音鳴らして終了

    loda,r0 HoldTetrominoType
    comi,r0 EMPTY_HOLD_TETROMINO_TYPE
    bcta,eq _hot_empty                  ;ホールドしてるテトロミノが無い

    ;ホールドしているテトロミノをNextへ
    loda,r0 HoldTetrominoType
    stra,r0 NextTetrominoType
    
    ppsl 10000b                 ;RSをセット. 裏レジスタを使用
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    bcta,eq _hot_movable        ;移動(交換)できた

    ;右に１マスずらす
    loda,r1 NextTetrominoX
    addi,r1 1
    stra,r1 NextTetrominoX

    ppsl 10000b                 ;RSをセット. 裏レジスタを使用
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使
    bcta,eq _hot_movable        ;移動(交換)できた

    ;左に１マスずらす
    subi,r1 2
    stra,r1 NextTetrominoX

    ppsl 10000b                 ;RSをセット. 裏レジスタを使用
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使
    bcta,eq _hot_movable        ;移動(交換)できた

    ;移動を元に戻して、左回転を試行
    addi,r1 1
    stra,r1 NextTetrominoX
    loda,r1 NextTetrominoRotate
    addi,r1 1
    andi,r1 3
    stra,r1 NextTetrominoRotate

    ppsl 10000b                 ;RSをセット. 裏レジスタを使用
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使
    bctr,eq _hot_movable        ;移動(交換)できた

    ;右回転を試行
    addi,r1 2
    andi,r1 3
    stra,r1 NextTetrominoRotate

    ppsl 10000b                 ;RSをセット. 裏レジスタを使用
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使
    bctr,eq _hot_movable        ;移動(交換)できた
    
    ;ホールドしてるテトロミノと交換出来なかった（周りにスペースがない
    ;回転をもとに戻す
    addi,r1 1
    andi,r1 3
    stra,r1 NextTetrominoRotate

    ;テトリミノのタイプを元に戻す
    loda,r0 TetrominoType
    stra,r0 NextTetrominoType

    ;ホールドを無効にする. ホールドはテトリミノが落ちるまで１回だけ有効
    eorz r0
    stra,r0 EnabledHoldTetromino
    
    ;有効無効が切り替わったのでホールドテトロミノの描画フラグ立てる
    lodi,r0 1
    stra,r0 DrawHoldTetromino

    bcta,un play_se2    ;ホールド出来なかった. 効果音鳴らして終了

_hot_movable:
    ;交換可能

    ;ホールドテトリミノのタイプを書き換え
    loda,r0 TetrominoType
    stra,r0 HoldTetrominoType

    ;フラグ立てる
    lodi,r0 1
    stra,r0 DrawHoldTetromino
    stra,r0 UpdatedTetrominoSprites
    
    ;フラグ落す. ホールドはテトリミノが落ちるまで１回だけ有効
    eorz r0
    stra,r0 EnabledHoldTetromino

    bcta,un play_se3    ;ホールド出来た. 効果音鳴らして終了
    
_hot_empty:
    ;ホールドが空
    ;現在持ってるテトロミノをホールドに回す
    loda,r0 TetrominoType
    stra,r0 HoldTetrominoType

    ;描画フラグ立てる
    lodi,r0 2       ;現在の操作テトロミノは消さない
    stra,r0 DrawHoldTetromino
    stra,r0 UpdatedTetrominoSprites     

    ;新しいテトロミノを生成する.
    lodi,r0 SCENE_GAME_NEW_TETROMINO
    stra,r0 NextSceneIndex
    
    bcta,un play_se3    ;ホールド出来た. 効果音鳴らして終了

    ;-------------------
    ;draw_hold_tetromino
    ;ホールドテトロミノを描画する
    ;r0,r1,r2,r3を使用
draw_hold_tetromino:
    loda,r0 DrawHoldTetromino
    retc,eq

    ;フラグ落す
    eorz r0
    stra,r0 DrawHoldTetromino

    ;---
    ;描画領域をクリア

    ;r1に色を設定
    lodi,r1 HOLD_DISABLE_COLOR + BLOCK_SPRITE_INDEX
    loda,r0 EnabledHoldTetromino
    bctr,eq _dht_disable_color
    lodi,r1 HOLD_ENABLE_COLOR + BLOCK_SPRITE_INDEX
_dht_disable_color:

    stra,r1 HOLD_TETROMINO_DATA-1*10h+0
    stra,r1 HOLD_TETROMINO_DATA-1*10h+1
    stra,r1 HOLD_TETROMINO_DATA+0*10h+0
    stra,r1 HOLD_TETROMINO_DATA+0*10h+1

    ;ホールドテトロミノを描画    
    lodi,r0 HOLD_TETROMINO_X+1
    stra,r0 Temporary0
    lodi,r0 HOLD_TETROMINO_Y-1
    stra,r0 Temporary1
    loda,r3 HoldTetrominoType
    bsta,un set_tetromino

    retc,un


    ;-------------------
    ;store_operation_tetromino_position
    ;操作中のテトロミノのブロックの座標をOperationTetromino[XY][0-4]に書き込む
    ;いくつかの判定で自ブロック操作ブロックかどうかを判定するために利用する
    ;r0,r1,r2,r3を使用
store_operation_tetromino_positions:
    
    ;r3にデータへのオフセットを格納
    bsta,un get_tetromino_data_offset

    loda,r1 TetrominoX
    loda,r2 TetrominoY

    loda,r0 TETROMINOS,r3
    addz r1
    stra,r0 OperationTetrominoX0

    loda,r0 TETROMINOS,r3+
    addz r2
    stra,r0 OperationTetrominoY0

    loda,r0 TETROMINOS,r3+
    addz r1
    stra,r0 OperationTetrominoX1

    loda,r0 TETROMINOS,r3+
    addz r2
    stra,r0 OperationTetrominoY1

    loda,r0 TETROMINOS,r3+
    addz r1
    stra,r0 OperationTetrominoX2

    loda,r0 TETROMINOS,r3+
    addz r2
    stra,r0 OperationTetrominoY2

    loda,r0 TETROMINOS,r3+
    addz r1
    stra,r0 OperationTetrominoX3

    loda,r0 TETROMINOS,r3+
    addz r2
    stra,r0 OperationTetrominoY3

    retc,un

    ;-------------------
    ;update_operation_tetromino
    ;操作テトロミノを移動させる
    ;r0を使用
update_operation_tetromino:
    loda,r0 UpdatedTetrominoSprites
    retc,eq ;更新なし終了

    comi,r0 2   ;削除オンリー？
    bctr,eq _uot_remove_only

    ;現在の操作テトロミノを消す
    bsta,un bake_operation_tetromino

    ;次の位置に更新
    loda,r0 NextTetrominoX
    stra,r0 TetrominoX
    loda,r0 NextTetrominoY
    stra,r0 TetrominoY
    loda,r0 NextTetrominoRotate
    stra,r0 TetrominoRotate
    loda,r0 NextTetrominoType
    stra,r0 TetrominoType

_uot_remove_only:

    eorz r0 
    stra,r0 UpdatedTetrominoSprites     ;フラグ落す

    ;更新された位置で操作テトロミノを再描画 or 現在の操作テトロミノを消す, ついでにreturn
    bcta,un bake_operation_tetromino

    ;-------------------
    ;move_tetromino
    ;- キー入力(WASD)に応じてNextTetrominoX,NextTetrominoYを増減させる
    ;- キー入力(カーソル左右,パッド)に応じてNextTetrominoRotateを変化させる
    ;r0,r1,r2,r3,r4,r5,r6, Temporary0, Temporary1を使用
move_tetromino:

    ;---
    ;パッド操作, カーソルの左右でテトロミノの回転をする
    loda,r0 P1Pad
    lodi,r1 PrevP1Pad - KeyData
    bsta,un button_process
    bcta,eq _move_tetromino_skip_rotate     ;何も押されてない、スキップ
    tmi,r0 11b
    bcta,eq _move_tetromino_skip_rotate     ;右左両方押されてる. スキップ

    bsta,un play_se1
    
    tmi,r0 01b
    bcfr,eq _move_tetromino_right_key      ;左は押されてない.

    ;左に回せるなら回す
    bsta,un rotate_to_left_if_possiable
    bcfr,eq _move_tetromino_skip_rotate   ;回せなかった

    ;左に回せた
    lodi,r0 1
    stra,r0 UpdatedTetrominoSprites
    bctr,un _move_tetromino_skip_rotate

_move_tetromino_right_key:
    tmi,r0 010b
    bcfr,eq _move_tetromino_skip_rotate     ;右は押されてない
    
    ;右に回せるなら回す
    bsta,un rotate_to_right_if_possiable
    bcfr,eq _move_tetromino_skip_rotate   ;回せなかった

    ;右に回せた
    lodi,r0 1
    stra,r0 UpdatedTetrominoSprites
    bctr,un _move_tetromino_skip_rotate

_move_tetromino_skip_rotate:

    ;---
    ;X,Yの位置を退避
    loda,r0 NextTetrominoX
    stra,r0 Temporary0
    loda,r0 NextTetrominoY
    stra,r0 Temporary1

    ;---
    ;1,q,a,zキー
    loda,r0 P1LEFTKEYS
    lodi,r1 PrevP1LeftKeys - KeyData
    bsta,un button_process    

    ;Qキー, ホールド
    tmi,r0 0100b
    bcfr,eq _move_tetromino_skip_Q_key
    ;ホールドは複数回の判定を行って重くなる可能性があるので他のカーソル操作はスキップする
    bcta,un hold_operation_tetromino
_move_tetromino_skip_Q_key:

    ;Aキー左移動, Temporary0を-1
    tmi,r0 0010b
    bcfr,eq _move_tetromino_skip_A_key
    loda,r1 Temporary0
    addi,r1 -1
    stra,r1 Temporary0
    strz r3
    bsta,un play_se11
    lodz r3
_move_tetromino_skip_A_key:

    tmi,r0 0001b
    bcfr,eq _move_tetromino_skip_Z_key
    bsta,un bake_operation_tetromino
_move_tetromino_skip_Z_key:

    ;3,e,d,cキー
    loda,r0 P1RIGHTKEYS
    lodi,r1 PrevP1RightKeys - KeyData
    bsta,un button_process   

    ;Dキー右移動, Temporary0を+1
    tmi,r0 0010b
    bcfr,eq _move_tetromino_skip_D_key
    loda,r1 Temporary0
    addi,r1 1
    stra,r1 Temporary0
    strz r3
    bsta,un play_se10
    lodz r3
_move_tetromino_skip_D_key:

    ;2,w,s,xキー
    loda,r0 P1MIDDLEKEYS
    lodi,r1 PrevP1MiddleKeys - KeyData
    bsta,un button_process

    ;sキー、ソフトドロップ
    tmi,r0 0010b
    bcfr,eq _move_tetromino_skip_S_key
    loda,r1 FallFrameCounter
    addi,r1 20
    stra,r1 FallFrameCounter
    loda,r1 LockDownCounter
    addi,r1 10
    stra,r1 LockDownCounter
_move_tetromino_skip_S_key:

    ;wキー、ハードドロップ
    tmi,r0 0100b
    bcfr,eq _move_tetromino_skip_W_key
    stra,r0 DoHardDrop  ;ハードドロップ. 0以外なら何でもいい
    bsta,un play_se5
    bctr,un _move_tetromino_moved2
_move_tetromino_skip_W_key:

    loda,r0 TetrominoX
    coma,r0 Temporary0
    bcfr,eq _move_tetromino_moved       ;移動があった

    loda,r0 TetrominoY
    coma,r0 Temporary1
    retc,eq ;移動が無かった終了

_move_tetromino_moved:
    loda,r0 Temporary0
    stra,r0 NextTetrominoX
    loda,r0 Temporary1
    stra,r0 NextTetrominoY

_move_tetromino_moved2:
    lodi,r0 1
    stra,r0 UpdatedTetrominoSprites
    retc,un

    ;-------------------
    ;rotate_to_left_if_possiable
    ;左回転が可能ならテトロミノを左に回転しeq状態で返す. 回転できない場合はeq状態以外で返す. 
    ;r0,r1,r2,r3,r4,r5,r6,を使用
rotate_to_left_if_possiable:

    ;回転情報を左に回してNextへ格納
    loda,r0 TetrominoRotate
    addi,r0 1
    andi,r0 3
    stra,r0 NextTetrominoRotate

    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq                     ;回転可能なら終了

    ;-----
    ;回転できなかった. SRSに基づいたキック操作を試す
    ;https://tetris.wiki/Super_Rotation_System

    ;---
    ;r1にキックする量の配列へのオフセットを入れる

    ;現在の回転状態に応じたオフセットを計算(8倍)に足す
    loda,r0 NextTetrominoRotate
    rrl,r0
    rrl,r0
    rrl,r0
    
    ;Iかそれ以外(Oなら回転に成功してる)かで切り替え
    IF RKO90_I_TETROMINO_0 - ROTATE90_KICK_OFFSETS <> 0 
        error RKO90_I_TETROMINO_0 が先頭前提(オフセット0)のコードがあるから要修正
    ENDIF
    lodi,r1 I_TETROMINO_INDEX
    coma,r1 TetrominoType
    bctr,eq rtlip_tetromino_i
    addi,r0 RKO90_JLSTZ_TETROMINO_0 - ROTATE90_KICK_OFFSETS
rtlip_tetromino_i:
    strz r1

    loda,r2 TetrominoX
    loda,r3 TetrominoY

    loda,r0 ROTATE90_KICK_OFFSETS+1,r1      ;dy読み込み
    addz r3 
    stra,r0 NextTetrominoY
    loda,r0 ROTATE90_KICK_OFFSETS-1,r1+     ;dx読み込み
    addz r2
    stra,r0 NextTetrominoX

    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq ;移動できた. 終了

    loda,r0 ROTATE90_KICK_OFFSETS+1,r1+    ;dy読み込み
    addz r3 
    stra,r0 NextTetrominoY
    loda,r0 ROTATE90_KICK_OFFSETS-1,r1+    ;dx読み込み
    addz r2
    stra,r0 NextTetrominoX
    
    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq ;移動できた. 終了

    loda,r0 ROTATE90_KICK_OFFSETS+1,r1+    ;dy読み込み
    addz r3 
    stra,r0 NextTetrominoY
    loda,r0 ROTATE90_KICK_OFFSETS-1,r1+    ;dx読み込み
    addz r2
    stra,r0 NextTetrominoX
    
    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq ;移動できた. 終了

    loda,r0 ROTATE90_KICK_OFFSETS+1,r1+    ;dy読み込み
    addz r3 
    stra,r0 NextTetrominoY
    loda,r0 ROTATE90_KICK_OFFSETS-1,r1+    ;dx読み込み
    addz r2
    stra,r0 NextTetrominoX
    
    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq ;移動できた. 終了

    ;回転出来なかった. 各Next変数の状態を戻して終了
    loda,r0 TetrominoRotate
    stra,r0 NextTetrominoRotate
    loda,r0 TetrominoY
    stra,r0 NextTetrominoY
    loda,r0 TetrominoX          ;X(とY)は,フィールド範囲内で0のパターンがないのでここでフラグがeq以外になる
    stra,r0 NextTetrominoX      
    retc,un
    

    ;-------------------
    ;rotate_to_right_if_possiable
    ;左回転が可能ならテトロミノを右に回転しeq状態で返す. 回転できない場合はeq状態以外で返す. 
    ;r0,r1,r2,r3,r4,r5,r6,を使用
rotate_to_right_if_possiable:

    ;回転情報を右に回してNextへ格納
    loda,r0 TetrominoRotate
    addi,r0 3
    andi,r0 3
    stra,r0 NextTetrominoRotate

    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq                     ;回転可能なら終了

    ;-----
    ;回転できなかった. SRSに基づいたキック操作を試す
    ;https://tetris.wiki/Super_Rotation_System

    ;---
    ;r1にキックする量の配列へのオフセットを入れる

    ;現在の回転状態に応じたオフセットを計算(8倍)に足す
    loda,r0 NextTetrominoRotate
    rrl,r0
    rrl,r0
    rrl,r0
    
    ;Iかそれ以外(Oなら回転に成功してる)かで切り替え
    IF RKO270_I_TETROMINO_0 - ROTATE270_KICK_OFFSETS <> 0 
        error RKO270_I_TETROMINO_0 が先頭前提(オフセット0)のコードがあるから要修正
    ENDIF
    lodi,r1 I_TETROMINO_INDEX
    coma,r1 TetrominoType
    bctr,eq rtrip_tetromino_i
    addi,r0 RKO270_JLSTZ_TETROMINO_0 - ROTATE270_KICK_OFFSETS
rtrip_tetromino_i:
    strz r1

    loda,r2 TetrominoX
    loda,r3 TetrominoY

    loda,r0 ROTATE270_KICK_OFFSETS+1,r1      ;dy読み込み
    addz r3 
    stra,r0 NextTetrominoY
    loda,r0 ROTATE270_KICK_OFFSETS-1,r1+     ;dx読み込み
    addz r2
    stra,r0 NextTetrominoX

    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq ;移動できた. 終了

    loda,r0 ROTATE270_KICK_OFFSETS+1,r1+    ;dy読み込み
    addz r3 
    stra,r0 NextTetrominoY
    loda,r0 ROTATE270_KICK_OFFSETS-1,r1+    ;dx読み込み
    addz r2
    stra,r0 NextTetrominoX
    
    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq ;移動できた. 終了

    loda,r0 ROTATE270_KICK_OFFSETS+1,r1+    ;dy読み込み
    addz r3 
    stra,r0 NextTetrominoY
    loda,r0 ROTATE270_KICK_OFFSETS-1,r1+    ;dx読み込み
    addz r2
    stra,r0 NextTetrominoX
    
    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq ;移動できた. 終了

    loda,r0 ROTATE270_KICK_OFFSETS+1,r1+    ;dy読み込み
    addz r3 
    stra,r0 NextTetrominoY
    loda,r0 ROTATE270_KICK_OFFSETS-1,r1+    ;dx読み込み
    addz r2
    stra,r0 NextTetrominoX
    
    ppsl 10000b                 ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un can_block_moved
    cpsl 10000b                 ;RSをリセット. 表レジスタを使用
    retc,eq ;移動できた. 終了

    ;回転出来なかった. 各Next変数の状態を戻して終了
    loda,r0 TetrominoRotate
    stra,r0 NextTetrominoRotate
    loda,r0 TetrominoY
    stra,r0 NextTetrominoY
    loda,r0 TetrominoX          ;X(とY)は,フィールド範囲内で0のパターンがないのでここでフラグがeq以外になる
    stra,r0 NextTetrominoX      
    retc,un

    ;-------------------
    ;can_block_moved
    ;NextTetrominoX/Y/Rotateへの操作テトロミノの移動が可能かどうかを返す
    ;可能ならCCがeq,できないならそれ以外になる
    ;r0,r1,r2,r3を使用
can_block_moved:

    ;r3にデータへのオフセットを格納
    bsta,un get_next_tetromino_data_offset

    ;r0,r1に移動先のテトロミノのブロック１個目の座標を入れる
    loda,r0 TETROMINOS+1,r3
    adda,r0 NextTetrominoY
    strz r1
    loda,r0 TETROMINOS-1,r3+
    adda,r0 NextTetrominoX

    ;操作テトリミノと被ってるか？
    bsta,un is_block_on_operation_tetromino
    bctr,eq _itm_skip0  ;被ってる

    ;ブロックがあるか？
    bsta,un is_block_exists
    retc,gt ;ブロックがある

_itm_skip0:

    ;r0,r1に移動先のテトロミノのブロック２個目の座標を入れる
    loda,r0 TETROMINOS+1,r3+
    adda,r0 NextTetrominoY
    strz r1
    loda,r0 TETROMINOS-1,r3+
    adda,r0 NextTetrominoX

    ;操作テトリミノと被ってるか？
    bsta,un is_block_on_operation_tetromino
    bctr,eq _itm_skip1  ;被ってる

    ;ブロックがあるか？
    bsta,un is_block_exists
    retc,gt ;ブロックがある

_itm_skip1:

    ;r0,r1に移動先のテトロミノのブロック３個目の座標を入れる
    loda,r0 TETROMINOS+1,r3+
    adda,r0 NextTetrominoY
    strz r1
    loda,r0 TETROMINOS-1,r3+
    adda,r0 NextTetrominoX

    ;操作テトリミノと被ってるか？
    bsta,un is_block_on_operation_tetromino
    bctr,eq _itm_skip2  ;被ってる

    ;ブロックがあるか？
    bsta,un is_block_exists
    retc,gt ;ブロックがある

_itm_skip2:

    ;r0,r1に移動先のテトロミノのブロック３個目の座標を入れる
    loda,r0 TETROMINOS+1,r3+
    adda,r0 NextTetrominoY
    strz r1
    loda,r0 TETROMINOS-1,r3+
    adda,r0 NextTetrominoX

    ;操作テトリミノと被ってるか？
    bsta,un is_block_on_operation_tetromino
    retc,eq ;被ってる移動して問題なし

    ;ブロックがあるか？, 直接コール元に戻る
    bcta,un is_block_exists

    ;-------------------
    ;get_padd_status_player1
    ;プレイヤー１のパッド状態を取得し、1(左),0,2(右)のいずれかをP1Padに書き込む
    ;*垂直帰線期間に入った後に呼ぶこと
    ;r0,r1を使用
get_padd_status_player1:
    loda,r0 P1PADDLE
    comi,r0 040h
    bctr,gt _get_button_status_1    ;if( padd > 40h ) 
    lodi,r1 1                       ;左押してるときのパッドの値
    bctr,un _get_button_status_end
_get_button_status_1:
    comi,r0 0A0h
    bctr,lt _get_button_status_2    ;if( padd < a0h ) 
    lodi,r1 2                      ;右押してるときのパッドの値
    bctr,un _get_button_status_end
_get_button_status_2:
    lodi,r1 0                       ;何も押されてないときのパッドの値
_get_button_status_end:
    stra,r1 P1Pad
    retc,un

    ;-------------------
    ;post_key_process
    ;現在の各キーの情報を前フレームの変数へ退避する
    ;r0を使用
post_key_process:
    loda,r0 P1Pad
    stra,r0 PrevP1Pad
    loda,r0 P1LEFTKEYS
    stra,r0 PrevP1LeftKeys
    loda,r0 P1MIDDLEKEYS
    stra,r0 PrevP1MiddleKeys
    loda,r0 P1RIGHTKEYS
    stra,r0 PrevP1RightKeys
    retc,un

    ;-------------------
    ;fall_operation_tetromino
    ;操作テトロミノの落下処理
    ;set_ghost_tetromino_yで最大何マス落ちれるか分かってる前提で動作
    ;r0,r1を使用
fall_operation_tetromino:

    loda,r0 DoHardDrop
    bcta,gt _fot_hard_drop      ;ハードドロップ有効？

    loda,r0 NextTetrominoY
    coma,r0 GhostTetrominoY
    bcta,eq _fot_on_block       ;接地状態？

    ;非接地状態
    
    ;ロックダウンカウントをリセット
    eorz r0
    stra,r0 LockDownCounter

    ;落下カウンターをインクリメント
    loda,r0 FallFrameCounter
    addi,r0 1
    stra,r0 FallFrameCounter

    loda,r1 FallFrame
    comz r1 
    retc,lt ;規定値に達していなければ終了

    ;落下カウンター, ロックダウンカウントをリセット
    eorz r0 
    stra,r0 FallFrameCounter
    stra,r0 LockDownCounter

    ;r0に落下予定座標を格納
    loda,r0 NextTetrominoY
    suba,r0 FallDistance

    ;最大落下可能座標
    loda,r1 GhostTetrominoY

    ;最大落下可能座標の方が小さい
    comz r1
    bctr,gt _fot_default

    ;落下位置をゴースト位置にする
    lodz r1
    
_fot_default:
    ;落下位置を書き込み
    stra,r0 NextTetrominoY

    lodi,r0 1
    stra,r0 UpdatedTetrominoSprites
    retc,un

_fot_hard_drop:
    
    ;接地状態でハードドロップしたなら固定する
    loda,r0 NextTetrominoY
    coma,r0 GhostTetrominoY
    bcta,eq _fot_lock_down

    ;ハードドロップ. ゴースト位置にテトロミノを移動
    loda,r0 GhostTetrominoY
    stra,r0 NextTetrominoY

    ;フラグ戻す
    eorz r0
    stra,r0 DoHardDrop

    retc,un

_fot_on_block:
    ;接地状態

    ;移動あるいは回転がおきたかどうか
    loda,r0 TetrominoX
    coma,r0 NextTetrominoX
    bcfr,eq _fot_on_block_moved
    loda,r0 TetrominoY
    coma,r0 NextTetrominoY
    bcfr,eq _fot_on_block_moved
    loda,r0 TetrominoRotate
    coma,r0 NextTetrominoRotate
    bcfr,eq _fot_on_block_moved

    ;移動も回転もしてない(=操作してない)
    bctr,un _fot_count_lock_down

_fot_on_block_moved:
    ;ロックダウンカウントをリセット
    eorz r0
    stra,r0 LockDownCounter

    ;操作可能カウントをインクリメント
    loda,r0 LockDownOperationCount
    addi,r0 1
    stra,r0 LockDownOperationCount
    comi,r0 MAX_LOCK_DOWN_OPERATION
    bcfr,lt _fot_lock_down              ;一定回数以上操作してたら固定する

_fot_count_lock_down:
    ;ロックダウンカウントを進める
    loda,r0 LockDownCounter
    addi,r0 1
    stra,r0 LockDownCounter
    coma,r0 LockDownFrames
    retc,lt                 ;カウントが規定値に達してない.終了
    
_fot_lock_down:

    ;テトロミノの固定
    lodi,r0 SCENE_GAME_LOCK_DOWN
    stra,r0 NextSceneIndex

    retc,un

    ;-------------------
    ;set_ghost_tetromino_y
    ;ゴーストテトロミノ（落下位置）の位置Yを更新する
    ;r0,r1,r2,r3,Temporary0,Temporary1を使用
set_ghost_tetromino_y:

    ;r3にデータへのオフセットを格納
    bsta,un get_next_tetromino_data_offset
    
    ;チェックするブロック１個目の位置をr0,r1に読み込み
    loda,r0 FALL_CHECK_OFFSETS+1,r3
    adda,r0 NextTetrominoY
    strz r1
    loda,r0 FALL_CHECK_OFFSETS-1,r3+
    adda,r0 NextTetrominoX
    stra,r3 Temporary0

    bsta,un check_fall_distance
    stra,r3 Temporary1              ;落ちれる距離をT1に記録

    ;チェックするブロック２個目の位置をr0,r1に読み込み
    loda,r3 Temporary0
    loda,r0 FALL_CHECK_OFFSETS+1,r3+
    comi,r0 0CCh                            ;チェックの最後まで来た
    bcta,eq _set_ghost_tetromino_y_end
    adda,r0 NextTetrominoY
    strz r1
    loda,r0 FALL_CHECK_OFFSETS-1,r3+
    adda,r0 NextTetrominoX
    stra,r3 Temporary0
    
    bsta,un check_fall_distance
    coma,r3 Temporary1                      ;既に記録してる距離より短いか？
    bctr,gt _set_ghost_tetromino_y_skip1    
    stra,r3 Temporary1                      ;落ちれる距離をT1に記録
_set_ghost_tetromino_y_skip1:

    ;チェックするブロック３個目の位置をr0,r1に読み込み
    loda,r3 Temporary0
    loda,r0 FALL_CHECK_OFFSETS+1,r3+
    comi,r0 0CCh                            ;チェックの最後まで来た
    bctr,eq _set_ghost_tetromino_y_end
    adda,r0 NextTetrominoY
    strz r1 
    loda,r0 FALL_CHECK_OFFSETS-1,r3+
    adda,r0 NextTetrominoX
    stra,r3 Temporary0

    bsta,un check_fall_distance
    coma,r3 Temporary1                      ;既に記録してる距離より短いか？
    bctr,gt _set_ghost_tetromino_y_skip2
    stra,r3 Temporary1                      ;落ちれる距離をT1に記録
_set_ghost_tetromino_y_skip2:

    ;チェックするブロック４個目の位置をr0,r1に読み込み
    loda,r3 Temporary0
    loda,r0 FALL_CHECK_OFFSETS+1,r3+
    comi,r0 0CCh                            ;チェックの最後まで来た
    bctr,eq _set_ghost_tetromino_y_end
    adda,r0 NextTetrominoY
    strz r1 
    loda,r0 FALL_CHECK_OFFSETS-1,r3+
    adda,r0 NextTetrominoX
    
    bsta,un check_fall_distance
    coma,r3 Temporary1                      ;既に記録してる距離より短いか？
    bctr,gt _set_ghost_tetromino_y_skip3
    stra,r3 Temporary1                      ;落ちれる距離をT1に記録
_set_ghost_tetromino_y_skip3:

_set_ghost_tetromino_y_end:

    ;現在位置から落下できる距離を足したものをGhostに保存
    loda,r0 NextTetrominoY
    suba,r0 Temporary1
    stra,r0 GhostTetrominoY
    
    ;もし4マス以上落ちれるならロックダウンまでの操作回数をリセットする
    ;上の方に引っかかっただけとかのときは操作回数を減らさない
    lodi,r0 4
    coma,r0 Temporary1
    retc,lt

    eorz r0
    stra,r0 LockDownOperationCount
    retc,un

    ;-------------------
    ;is_block_on_operation_tetromino
    ;(r0,r1)に操作中のテトロミノがあれば、eq状態にして返す
    ;r0,r1を使用 r0,r1は参照のみ
is_block_on_operation_tetromino:

    coma,r0 OperationTetrominoX0
    bcfr,eq _iboot_1
    coma,r1 OperationTetrominoY0        ;一致するのがあった
    retc,eq

_iboot_1:
    coma,r0 OperationTetrominoX1
    bcfr,eq _iboot_2
    coma,r1 OperationTetrominoY1        ;一致するのがあった
    retc,eq

_iboot_2:
    coma,r0 OperationTetrominoX2
    bcfr,eq _iboot_3
    coma,r1 OperationTetrominoY2        ;一致するのがあった
    retc,eq

_iboot_3:
    coma,r0 OperationTetrominoX3
    bcfr,eq _iboot_end
    coma,r1 OperationTetrominoY3        ;一致するのがあった
    ;retc,eq    ;CC0,CC1で返してるからいらない

_iboot_end:
    retc,un

    ;-------------------
    ;check_fall_distance
    ;(r0,r1)にあるブロックが何ブロック落ちれるかをr3に入れて返す
    ;r0,r1,r2,r3を使用
check_fall_distance:

    subi,r1 1   ;チェックを開始するマスにする（１マス下げる
    
    ;チェック開始するマスに操作中のテトロミノがあるか？
    bstr,un is_block_on_operation_tetromino
    bcfr,eq _check_fall_distance_skip0           ;無かった

    ;チェックを開始したマスは現在操作テトロミノの上だった、１マス下げる
    subi,r1 1   

    bstr,un is_block_on_operation_tetromino
    bcfr,eq _check_fall_distance_skip1

    ;３マス以上は被らない
    subi,r1 1
    lodi,r3 2   ;何マス落ちれるかのカウンタ
    bctr,un _check_fall_distance_skip

_check_fall_distance_skip1:
    lodi,r3 1   ;何マス落ちれるかのカウンタ
    bctr,un _check_fall_distance_skip

_check_fall_distance_skip0:
    lodi,r3 0   ;何マス落ちれるかのカウンタ

_check_fall_distance_skip:

    ;X座標の下位1bitをr2へ抽出し、0ならr2=1、1ならr2=2をいれておく。 1or2はandzで使うやつ
    strz r2     
    andi,r2 1
    addi,r2 1

    ;X座標の下位1bitを除いた値を抽出
    rrr,r0
    andi,r0 0Fh

    comi,r1 13
    bctr,lt _check_fall_distance_lower_screen

    ;Y(r1)が13以上. 上画面をチェックする Y=13～25

    ;r1 = 25 - r1 = 25 + (r1^0xFF) + 1 = 26 + (r1^0xFF)
    eori,r1 0FFh
    addi,r1 26

    rrl,r1      ;Yを画面バッファでのオフセットに変換
    rrl,r1 
    rrl,r1 
    rrl,r1 
    addz r1     ;X(オフセットの下位4bit)を加算し、r0を画面バッファのオフセットにする
    strz r1

_check_fall_distance_upper_screen:
    loda,r0 SCRUPDATA,r1        ;現在のブロック情報を読み込み
    andz r2                     ;X座標の下位1bitから作られたマスクでブロック確認
    retc,gt                     ;ブロックがあったので終了
    addi,r3 1
    addi,r1 10h                 ;下の行に移動
    comi,r1 SCREEN_CHARA_WIDTH*HALF_SCREEN_CHARA_HEIGHT  ;画面からはみ出したか？
    bctr,gt _check_fall_distance_over_upper_screen

    ;ループアンロール
    loda,r0 SCRUPDATA,r1        ;現在のブロック情報を読み込み
    andz r2                     ;X座標の下位1bitから作られたマスクでブロック確認
    retc,gt                     ;ブロックがあったので終了
    addi,r3 1
    addi,r1 10h                 ;下の行に移動
    comi,r1 SCREEN_CHARA_WIDTH*HALF_SCREEN_CHARA_HEIGHT  ;画面からはみ出したか？
    bctr,gt _check_fall_distance_over_upper_screen
    
    bctr,un _check_fall_distance_upper_screen


_check_fall_distance_over_upper_screen:
    ;上画面からはみ出した
    subi,r1 SCREEN_CHARA_WIDTH*HALF_SCREEN_CHARA_HEIGHT  ;オフセットを画面の一番上に移動する
    bctr,un __check_fall_distance_lower_screen

_check_fall_distance_lower_screen:
    ;Y(r1)が13未満. 下画面をチェックする Y=0～12
    
    ;下画面にとってのY=0の位置へ合わせる
    ;r1 = 12 - r1 = 12 + (r1^0xFF) + 1 = 13 + (r1^0xFF)
    eori,r1 0FFh
    addi,r1 13

    rrl,r1      ;Yを画面バッファでのオフセットに変換
    rrl,r1 
    rrl,r1 
    rrl,r1 
    addz r1     ;X(オフセットの下位4bit)を加算し、r0を画面バッファのオフセットにする
    strz r1

    ;一番下にはブロック(0x03)が境界にある
__check_fall_distance_lower_screen:

    loda,r0 SCRLODATA,r1        ;現在のブロック情報を読み込み
    andz r2                     ;X座標の下位1bitから作られたマスクでブロック確認
    retc,gt                     ;ブロックがあったので終了
    addi,r3 1
    addi,r1 10h                 ;下の行に移動
    
    loda,r0 SCRLODATA,r1        ;現在のブロック情報を読み込み
    andz r2                     ;X座標の下位1bitから作られたマスクでブロック確認
    retc,gt                     ;ブロックがあったので終了
    addi,r3 1
    addi,r1 10h                 ;下の行に移動

    bctr,un __check_fall_distance_lower_screen

    ;-------------------
    ;is_block_exists
    ;X=r0,Y=r1にブロックがあるかどうかをr0/CC(ある:r0が0以外/gt, ない:r0が0/eq)に格納して返す
    ;r0,r1,r2を使用
is_block_exists:

    ;フィールドの右端と左端チェック
    comi,r0 FIELD_START_X+FIELD_WIDTH-1
    retc,gt ;フィールドの右端を超えてるならreturn
    comi,r0 FIELD_START_X ;フィールドの左端を超えてる?
    bcfr,lt _ibe_check
    lodi,r0 1
    retc,un 
    
_ibe_check:

    ;X座標の下位1bitをr2へ抽出し、0ならr2=1、1ならr2=2をいれておく。 1or2はandzで使うやつ
    strz r2     
    andi,r2 1
    addi,r2 1

    ;X座標の下位1bitを除いた値を抽出
    rrr,r0
    andi,r0 0Fh

    comi,r1 12
    bcfr,gt _is_block_exists_lower_screen

    ;Y(r1)が12超(=13以上)
    ;上画面に描画する Y=13~25
    
    ;上画面にとってのY=0の位置へ合わせる
    ;r1 = 25 - r1 = 25 + (r1^0xFF) + 1 = 26 + (r1^0xFF)
    eori,r1 0FFh
    addi,r1 26

    rrl,r1      ;Yを画面バッファでのオフセットに変換
    rrl,r1 
    rrl,r1 
    rrl,r1 
    addz r1     ;X(オフセットの下位4bit)を加算し、r0を画面バッファのオフセットにする
    strz r1

    loda,r0 SCRUPDATA,r1        ;現在のブロック情報を読み込み
    andz r2                     ;X座標の下位1bitから作られたマスクでブロック確認

    retc,un

_is_block_exists_lower_screen:
    ;下画面 Y=0~12

    eori,r1 0FFh
    addi,r1 13
    rrl,r1      ;Yを画面バッファでのオフセットに変換
    rrl,r1 
    rrl,r1 
    rrl,r1 
    addz r1     ;X(オフセットの下位4bit)を加算し、r0を画面バッファのオフセットにする
    strz r1

    loda,r0 SCRLODATA,r1        ;現在のブロック情報を読み込み
    andz r2                     ;X座標の下位1bitから作られたマスクでブロック確認

    retc,un

    
    ;-------------------
    ;draw_ghost_tetromino
    ;スプライトを使ってゴーストテトロミノを描画する
    ;r0,r1,r2,r3を使用
draw_ghost_tetromino:

    ;r3にデータへのオフセットを格納
    bsta,un get_next_tetromino_data_offset

    ;テトロミノの位置Xをスプライトのオフセット座標に変換
    loda,r1 NextTetrominoX
    rrl,r1
    rrl,r1
    addi,r1 SPRITE_OFFSET_X

    ;テトロミノの位置Yをスプライトのオフセット座標に変換
    loda,r2 GhostTetrominoY
    rrl,r2
    rrl,r2
    rrl,r2
    addi,r2 SPRITE_OFFSET_Y

    ;テトロミノを構成するブロックの１個目のX座標をスプライト座標に書き込む
    loda,r0 TETROMINOS,r3  ; x0
    rrl,r0
    rrl,r0
    andi,r0 0fch
    addz r1
    stra,r0 SPRITE0X

    ;テトロミノを構成するブロックの１個目のY座標をスプライト座標に書き込む
    loda,r0 TETROMINOS,r3+  ; y0
    rrl,r0
    rrl,r0
    rrl,r0
    andi,r0 0f8h
    addz r2
    stra,r0 SPRITE0Y

    loda,r0 TETROMINOS,r3+  ; x1
    rrl,r0
    rrl,r0
    andi,r0 0fch
    addz r1
    stra,r0 SPRITE1X

    loda,r0 TETROMINOS,r3+  ; y1
    rrl,r0
    rrl,r0
    rrl,r0
    andi,r0 0f8h
    addz r2
    stra,r0 SPRITE1Y

    loda,r0 TETROMINOS,r3+  ; x2
    rrl,r0
    rrl,r0
    andi,r0 0fch
    addz r1
    stra,r0 SPRITE2X

    loda,r0 TETROMINOS,r3+  ; y2
    rrl,r0
    rrl,r0
    rrl,r0
    andi,r0 0f8h
    addz r2
    stra,r0 SPRITE2Y
    
    loda,r0 TETROMINOS,r3+  ; x3
    rrl,r0
    rrl,r0
    andi,r0 0fch
    addz r1
    stra,r0 SPRITE3X

    loda,r0 TETROMINOS,r3+  ; y3
    rrl,r0
    rrl,r0
    rrl,r0
    andi,r0 0f8h
    addz r2
    stra,r0 SPRITE3Y

    retc,un ; return

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

    retc,un ; return

    IF FIELD_START_X-FIELD_START_X/2*2 > 0
        error FIELD_START_Xが奇数だよ。reset_tetromino_fieldでの書き込みがずれます
    ENDIF

    IF FIELD_WIDTH-FIELD_WIDTH/2*2 > 0
        error FIELD_WIDTHが奇数だよ。reset_tetromino_fieldでの書き込みがずれます
    ENDIF



    ;/////////////////////////

    ;共通処理
    include "tetris\common.asm"
    
    ;新しいテトリス生成するときの処理
    include "tetris\game_new_tetromino.asm"

    ;テトロミノ
    include "tetris\tetromino.h"

    ;音系
    include "tetris\sound.asm"
    include "tetris\se.asm"
    
_PAGE0END_:

    IF _PAGE0END_ >= 1000h
        WARNING "0ページ目の末端が4K超えてる"
    ENDIF
    
    ;-----
    ;ここから下はpage1
    org PAGE1
    
    ;テトリスを固定する処理
    include "tetris\game_lock_down.asm"

    ;汎用処理
    include "inc\util.h"
    
    ;mod2-mod7
    include "inc\mod.h"

    ;シャッフル関係
    include "tetris\shuffle.asm"

    ;/////////////////////////

_PAGE1END_:

    IF _PAGE1END_ >= PAGE1 + 1000h
        WARNING "1ページ目の末端が4K超えてる"
    ENDIF
    


    ;-------------------
    ;store_charline_debug0
    ;18FFhの垂直帰線位置をDebug0に書き込む
    ;r0を使用
store_charline_debug0:
    loda,r0 CHARLINE + PAGE1
    stra,r0 Debug0+PAGE1
    retc,un ; return

store_charline_debug1:
    loda,r0 CHARLINE + PAGE1
    stra,r0 Debug1+PAGE1
    retc,un ; return

store_charline_debug2:
    loda,r0 CHARLINE + PAGE1
    stra,r0 Debug2+PAGE1
    retc,un ; return

end ; End of assembly
