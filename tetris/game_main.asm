;ゲームのメイン処理

    ;-------------------
    ;game_main
    ;ゲームのメイン
game_main:

    bsta,un store_operation_tetromino_positions
    bsta,un move_tetromino
    bsta,un set_ghost_tetromino_y
    bsta,un fall_operation_tetromino

    retc,un

    ;-------------------
    ;game_main_after_vsync
    ;ゲームのメイン処理のうち垂直同期後にやる処理
game_main_after_vsync:

    bsta,un draw_ghost_tetromino            ;ゴーストの描画, スプライト更新があるので優先度高め

    bsta,un draw_hold_tetromino             ;ホールドテトロミノの描画

    bsta,un update_operation_tetromino      ;操作テトリミノの更新

    retc,un

    ;-------------------
    ;hold_operation_tetromino
    ;操作テトロミノをホールドする
    ;r0,r1,r2, r4,r5,r6を使用
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
    ;r0,r1,r2,r3,Temporary1を使用
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
    bcta,un set_tetromino

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
    ;r0,r1,r2,r3,r4,r5,r6, Temporary0を使用
move_tetromino:

    ;---
    ;パッド操作, カーソルの左右でテトロミノの回転をする
    loda,r0 P1Pad
    lodi,r1 PrevP1Pad - KeyData
    bsta,un button_process
    bcta,eq _move_tetromino_skip_rotate     ;何も押されてない、スキップ
    tmi,r0 11b
    bcta,eq _move_tetromino_skip_rotate     ;右左両方押されてる. スキップ

    
    tmi,r0 01b
    bcfr,eq _move_tetromino_right_key      ;左は押されてない.

    ;左に回せるなら回す
    bsta,un rotate_to_left_if_possiable
    bcfr,eq _move_tetromino_skip_rotate   ;回せなかった

    ;左に回せた
    lodi,r0 1
    stra,r0 UpdatedTetrominoSprites
    stra,r0 LastOperationIsRotated
    bsta,un play_se1
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
    stra,r0 LastOperationIsRotated
    bsta,un play_se1

_move_tetromino_skip_rotate:

    ;---
    ;Xの位置を退避
    loda,r0 NextTetrominoX
    stra,r0 Temporary0

    ;---
    ;1,q,a,zキー
    loda,r0 P1LEFTKEYS
    lodi,r1 PrevP1LeftKeys - KeyData
    bsta,un button_process    

    ;Qキー, ホールド
    tmi,r0 0100b
    ;ホールドは複数回の判定を行って重くなる可能性があるので他のカーソル操作はスキップ(直return)する
    bcta,eq hold_operation_tetromino

    ;Aキー左移動, Temporary0を-1
    tmi,r0 0010b
    bcfr,eq _move_tetromino_skip_A_key
    loda,r1 Temporary0
    addi,r1 -1
    stra,r1 Temporary0
    strz r3
    bsta,un play_se11
    lodz r3
    lodi,r3 0
    stra,r3 LastOperationIsRotated
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
    bsta,un play_se10
    eorz r0
    stra,r0 LastOperationIsRotated
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
    bctr,un _move_tetromino_moved
_move_tetromino_skip_W_key:

    loda,r0 TetrominoX
    coma,r0 Temporary0
    retc,eq ;移動が無かった終了
    
    ;移動があった, Temporary0とNextTetrominoXを交換
    ;NextTetrominoXの座標はチェックに使う
    ;現NextTetrominoXは回転で既に初期値から変化してる可能性があるので残しておく必要がある
    loda,r0 Temporary0
    loda,r1 NextTetrominoX
    stra,r1 Temporary0
    stra,r0 NextTetrominoX
    
    bsta,un can_block_moved
    bctr,eq _move_tetromino_moved   ;移動できたら飛ぶ

    ;移動できなかった. NextTetrominoXを元に戻して終了
    loda,r0 Temporary0
    stra,r0 NextTetrominoX
    retc,un

_move_tetromino_moved:
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
    
    ;ロックダウンカウントをリセット. ついでに最終操作をリセット(落ちるか操作しないと接地しないのが確定してる)
    eorz r0
    stra,r0 LockDownCounter
    stra,r0 LastOperationIsRotated

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
    stra,r0 LastOperationIsRotated

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

end ; End of assembly
