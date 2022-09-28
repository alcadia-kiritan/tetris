    ;変数と定数の定義

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

    LastOperationIsRotated      equ TetrominoData+10        ;最後の操作が回転か

    TetrominoData2              equ TetrominoData+11
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
    PrevP1LeftKeys              equ KeyData+0           ;1フレーム前のP1LEFTKEYSの値
    CountRepeatedP1LeftKeys     equ KeyData+1           ;押し続けた時のリピート処理用カウンタ, 前フレームと同じ値が来ると減算されて０になると押してる扱いになる
    PrevP1MiddleKeys            equ KeyData+2           ;1フレーム前のP1MIDDLEKEYSの値
    CountRepeatedP1MiddleKeys   equ KeyData+3    
    PrevP1RightKeys             equ KeyData+4           ;1フレーム前のP1RIGHTKEYSの値
    CountRepeatedP1RightKeys    equ KeyData+5    
    PrevP1Pad                   equ KeyData+6           ;1フレーム前のP1PADDLEの値を0,1(左),2(右)にした値
    CountRepeatedP1Pad          equ KeyData+7    
    P1Pad                       equ KeyData+8           ;現フレームのP1PADDLEの値を0,1(左),2(右)にした値

    ;シーン制御系
    GameManagedData             equ KeyData+9
    SceneIndex                  equ GameManagedData+0     ;現在処理中のシーンのインデックス（の３倍の値）
    NextSceneIndex              equ GameManagedData+1     ;次に処理するシーンのインデックス（の３倍の値）

    Debug0                      equ GameManagedData+2

    ;領域超過チェック用！　最後の変数の変更に注意！
    EndRAM1                     equ Debug0

    IF EndRAM1 > 18EFh
        WARNING "RAM1がオーバーしてるよ"
    ENDIF

    ;----
    ;RAM2 $18F8..$18FB
    
    ;なんかの引数や退避領域として使う
    Temporary0 equ 18F8h       ;汎用領域
    Temporary1 equ 18F9h       ;汎用領域
    
    GameMode        equ 18FAh       ;ゲームモード
    FrameCount6     equ 18FBh       ;0-5のカウンタ

    ;----
    ;RAM3 $1AD0..$1AFF

    ;消す行の情報 
    ;  or ゲームオーバー系の変数 
    ;  or タイトル画面の変数
    ;  or クリア画面の変数
    ;  or 操作テトロミノのブロックの座標
    ;時系列的に同時に使うことが無いので被せる
    TetrominoData3              equ 1AD0h
    FallLineIndex               equ TetrominoData3+0    ;行をずらし始める行
    FallFuncionIndex            equ TetrominoData3+1    ;どういうずらし方をするか
    FallTempLine0               equ TetrominoData3+2
    FallTempLine1               equ TetrominoData3+3

    GameOverFrameCount          equ TetrominoData3+0    ;ゲームオーバの描画用のカウンタ
    GameOverFillLineIndex       equ TetrominoData3+1

    GameTitleFrameCount         equ TetrominoData3+0

    GameClearFrameCount         equ TetrominoData3+0
    GameClearHighScoreUpdated   equ TetrominoData3+1

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
    RandomBytes0                equ RandomData+0        ;乱数制御用のデータ, xorshift16
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

    ;スコア系
    ScoreData                   equ ShuffleTetromino+8
    TspinCountBCD0              equ ScoreData+0
    TspinCountBCD1              equ ScoreData+1
    LineCountBCD0               equ ScoreData+2
    LineCountBCD1               equ ScoreData+3
    TetrisCountBCD0             equ ScoreData+4
    TetrisCountBCD1             equ ScoreData+5
    
    ScoreCountBCD0              equ ScoreData+6
    ScoreCountBCD1              equ ScoreData+7
    ScoreCountBCD2              equ ScoreData+8

    Timer10sBCD                 equ ScoreData+6 ;スプリントモードでしか使わないのでスコアと被せる
    Timer100msBCD               equ ScoreData+7
    Timer1msBCD                 equ ScoreData+8
    
    UpdateScoreText             equ ScoreData+9
    EnabledTimer                equ ScoreData+10
    LvBCD0                      equ ScoreData+11
    LvBCD1                      equ ScoreData+12
    LastScoreValue              equ ScoreData+13 ;最後のマーカ. 変数としては使ってない
    
    ;ハイスコア系
    HighScoreData               equ LastScoreValue+0
    BestTimer10sBCD             equ HighScoreData+0
    BestTimer100msBCD           equ HighScoreData+1
    BestTimer1msBCD             equ HighScoreData+2

    HighNormalScoreBCD0         equ HighScoreData+3
    HighNormalScoreBCD1         equ HighScoreData+4
    HighNormalScoreBCD2         equ HighScoreData+5

    HighTGM20GScoreBCD0         equ HighScoreData+6
    HighTGM20GScoreBCD1         equ HighScoreData+7
    HighTGM20GScoreBCD2         equ HighScoreData+8

    
    ;音系
    SoundData                   equ HighScoreData+9 -PAGE1
    SoundFrameCount             equ SoundData+0         ;音節を何フレーム回すか
    SoundPriority               equ SoundData+1
    SoundDataAddress0           equ SoundData+2         ;次に鳴らす音データのアドレス,01は並んでいること
    SoundDataAddress1           equ SoundData+3

    ;領域超過チェック用！　最後の変数の変更に注意！
    EndRAM3                     equ SoundDataAddress1

    IF EndRAM3 > 1AFFh
        WARNING "RAM3がオーバーしてるよ"
    ENDIF

    ;-------------------------------------------------------------------------
    ;定数定義

    ;------
    ;ゲーム関係
    MAX_LOCK_DOWN_OPERATION equ 15          ;接地状態で最大何回操作可能か

    SPRINT_CLEAR_LINES_BCD  equ 20h         ;スプリントモードのクリア行数のBCD表記

    CLEAR_LEVEL_BCD         equ 99h          ;スプリント以外でクリアになるレベルのBCD表記

    GAME_MODE_NORMAL        equ 1
    GAME_MODE_SPRINT        equ 0
    GAME_MODE_TGM20G        equ 2

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

    SCROLL_Y            equ 222                             ;スクロール位置
    SPRITE_OFFSET_Y     equ (SCROLL_Y*3+42-624+24-39)/3     ;描画領域の一番下の行に合う位置
    SPRITE_OFFSET_X     equ (156+102)/6                     ;描画領域の一番左の列に合う位置

    SCREEN_CHARA_WIDTH          equ 16                          ;アルカディアのキャラクター(8x4)での横幅
    HALF_SCREEN_CHARA_HEIGHT    equ 13              
    SCREEN_CHARA_HEIGHT         equ HALF_SCREEN_CHARA_HEIGHT*2  ;アルカディアのキャラクター(8x4)での縦幅

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
    NEW_TETROMINO_X        equ FIELD_START_X + FIELD_WIDTH/2-1
    NEW_TETROMINO_Y        equ FIELD_START_Y + FIELD_HEIGHT
    
    ;テキスト系, 上画面、下画面でのcharacter座標系
    ;スコア関係の描画位置
    SCORE_TEXT_X           equ 11
    SCORE_TEXT_Y           equ 1
    LINE_TEXT_X            equ 11
    LINE_TEXT_Y            equ 4
    TETRIS_TEXT_X          equ 11
    TETRIS_TEXT_Y          equ 7
    TSPIN_TEXT_X           equ 11
    TSPIN_TEXT_Y           equ 10
    LV_TEXT_X              equ 0
    LV_TEXT_Y              equ 1
    

    ;-----
    ;テトリスに関係ない系

    ;通常描画モードでの0とA
    CHAR_0          equ 10h
    CHAR_0_OFFSET   equ 10h - '0'       ; CHAR_0_OFFSET+'0' を描画すると0が出る
    CHAR_A          equ 1Ah
    CHAR_A_OFFSET   equ 1Ah - 'A'
    ASCII_OFFSET    equ 1Ah - 'A'
    DIGIT_OFFSET    equ 10h - '0'

    PAGE1    equ 2000h

end
