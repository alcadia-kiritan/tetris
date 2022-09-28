;新しいテトリミノを発生させるシーン

    ;-------------------
    ;game_new_tetromino
    ;新しいテトロミノを発生させるシーン
    ;r0,r1,r2,r3, データの保存にTemporary2を使用
game_new_tetromino:

    ;操作テトリミノの位置/回転をリセット
    lodi,r0 NEW_TETROMINO_X
    stra,r0 TetrominoX
    stra,r0 NextTetrominoX

    lodi,r0 NEW_TETROMINO_Y
    stra,r0 TetrominoY
    stra,r0 NextTetrominoY

    eorz r0
    stra,r0 TetrominoRotate
    stra,r0 NextTetrominoRotate

    ;次に落すテトロミノをずらす
    loda,r0 NextOperationTetrominoType0
    stra,r0 TetrominoType
    stra,r0 NextTetrominoType

    loda,r0 NextOperationTetrominoType1
    stra,r0 NextOperationTetrominoType0

    loda,r0 NextOperationTetrominoType2
    stra,r0 NextOperationTetrominoType1

    ;ランダムなテトリミノを設定
    bsta,un get_random_tetromino_index
    stra,r0 NextOperationTetrominoType2

    ;次のフレームではメインに戻る
    lodi,r0 SCENE_GAME_MAIN
    stra,r0 NextSceneIndex
    
    ;カウンタ類をリセット
    eorz r0
    stra,r0 FallFrameCounter
    stra,r0 LockDownCounter
    stra,r0 LockDownOperationCount
    stra,r0 DoHardDrop
    stra,r0 LastOperationIsRotated

    retc,un

    ;-------------------
    ;game_new_tetromino_after_vsync
    ;新しいテトロミノを発生させるシーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_new_tetromino_after_vsync:

    ;操作テトロミノを描画
    bsta,un bake_operation_tetromino

    ;ホールドテトロミノを有効に戻す
    bsta,un set_enabled_hold_tetromino

    ;NEXTテトロミノを描画, 直return
    bctr,un draw_next_tetromino

    ;-------------------
    ;draw_next_tetromino
    ;次のテトロミノを描画する
    ;r0,r1,r2,r3を使用
draw_next_tetromino:

    ;無回転だと4x2の下記マスを使いうる, 消すには4byte埋めるのが手っ取り早い
    ;(-1,0)(-1,1)
    ;(0,0)(0,1)
    ;(1,0)(1,1)
    ;(2,0)

    ;一番上のNextテトリミノを描画
    lodi,r0 NEXT_TETROMINO_COLOR + 3Ch
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*0 - 1)*10h + 0
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*0 - 1)*10h + 1
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*0 + 0)*10h + 0
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*0 + 0)*10h + 1
    
    loda,r3 NextOperationTetrominoType0
    lodi,r0 NEXT_TETROMINO_X
    stra,r0 Temporary0
    lodi,r0 NEXT_TETROMINO_Y - NEXT_TETROMINO_Y_STEP*0 - 1
    stra,r0 Temporary1
    bstr,un set_tetromino
    
    ;二個目のNextテトリミノを描画
    lodi,r0 NEXT_TETROMINO_COLOR + 3Ch
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*1 - 1)*10h + 0
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*1 - 1)*10h + 1
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*1 + 0)*10h + 0
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*1 + 0)*10h + 1
    
    loda,r3 NextOperationTetrominoType1
    lodi,r0 NEXT_TETROMINO_X
    stra,r0 Temporary0
    lodi,r0 NEXT_TETROMINO_Y - NEXT_TETROMINO_Y_STEP*1 - 1
    stra,r0 Temporary1
    bstr,un set_tetromino

    ;３個目のNextテトリミノを描画
    lodi,r0 NEXT_TETROMINO_COLOR + 3Ch
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*2 - 1)*10h + 0
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*2 - 1)*10h + 1
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*2 + 0)*10h + 0
    stra,r0 NEXT_TETROMINO_DATA + (NEXT_TETROMINO_Y_STEP*2 + 0)*10h + 1

    loda,r3 NextOperationTetrominoType2
    lodi,r0 NEXT_TETROMINO_X
    stra,r0 Temporary0
    lodi,r0 NEXT_TETROMINO_Y - NEXT_TETROMINO_Y_STEP*2 - 1
    stra,r0 Temporary1
    bctr,un set_tetromino

    
    ;-------------------
    ;set_tetromino
    ;テトロミノを描画する. 回転は初期状態.
    ;- r3にテトロミノの種類
    ;- Temporary0にX描画位置
    ;- Temporary1にY描画位置
    ;r0,r1,r2,r3,Temporary0,Temporary1を使用
set_tetromino:

    ;テトリミノの種類をデータオフセットに変換(5bit左シフト)
    rrr,r3
    rrr,r3
    rrr,r3

    ;ひとつ目のブロック
    loda,r0 TETROMINOS+1,r3     ; y0
    adda,r0 Temporary1          ; r0 = Temporary1 + y0
    strz r1
    loda,r0 TETROMINOS-1,r3+    ; x0
    adda,r0 Temporary0          ; r0 = Temporary0 + x0
    bsta,un flip_block

    ;２つ目のブロック
    loda,r0 TETROMINOS+1,r3+
    adda,r0 Temporary1
    strz r1 
    loda,r0 TETROMINOS-1,r3+
    adda,r0 Temporary0
    bsta,un flip_block

    ;３つ目のブロック
    loda,r0 TETROMINOS+1,r3+
    adda,r0 Temporary1
    strz r1 
    loda,r0 TETROMINOS-1,r3+
    adda,r0 Temporary0
    bsta,un flip_block

    ;４つ目のブロック
    loda,r0 TETROMINOS+1,r3+
    adda,r0 Temporary1
    strz r1 
    loda,r0 TETROMINOS-1,r3+
    adda,r0 Temporary0
    bcta,un flip_block  ;直return

    ;-------------------
    ;set_enabled_hold_tetromino
    ;r0を使用
set_enabled_hold_tetromino:

    IF HOLD_DISABLE_COLOR < HOLD_ENABLE_COLOR
        WARNING 色変更がandiで出来なくなってない？
    ENDIF
    
    ;色を有効の色に戻す
    loda,r0 HOLD_TETROMINO_DATA-1*10h+0
    andi,r0 255-HOLD_DISABLE_COLOR
    stra,r0 HOLD_TETROMINO_DATA-1*10h+0

    loda,r0 HOLD_TETROMINO_DATA-1*10h+1
    andi,r0 255-HOLD_DISABLE_COLOR
    stra,r0 HOLD_TETROMINO_DATA-1*10h+1

    loda,r0 HOLD_TETROMINO_DATA-0*10h+0
    andi,r0 255-HOLD_DISABLE_COLOR
    stra,r0 HOLD_TETROMINO_DATA-0*10h+0

    loda,r0 HOLD_TETROMINO_DATA-0*10h+1
    andi,r0 255-HOLD_DISABLE_COLOR
    stra,r0 HOLD_TETROMINO_DATA-0*10h+1
    
    ;フラグを有効にする
    lodi,r0 1
    stra,r0 EnabledHoldTetromino

    retc,un

    ;-------------------
    ;set_disabled_hold_tetromino
    ;r0を使用
set_disabled_hold_tetromino:

    IF HOLD_DISABLE_COLOR < HOLD_ENABLE_COLOR
        WARNING 色変更がandiで出来なくなってない？
    ENDIF
    
    ;色を有効の色に戻す
    loda,r0 HOLD_TETROMINO_DATA-1*10h+0
    andi,r0 255-HOLD_DISABLE_COLOR
    stra,r0 HOLD_TETROMINO_DATA-1*10h+0

    loda,r0 HOLD_TETROMINO_DATA-1*10h+1
    andi,r0 255-HOLD_DISABLE_COLOR
    stra,r0 HOLD_TETROMINO_DATA-1*10h+1

    loda,r0 HOLD_TETROMINO_DATA-0*10h+0
    andi,r0 255-HOLD_DISABLE_COLOR
    stra,r0 HOLD_TETROMINO_DATA-0*10h+0

    loda,r0 HOLD_TETROMINO_DATA-0*10h+1
    andi,r0 255-HOLD_DISABLE_COLOR
    stra,r0 HOLD_TETROMINO_DATA-0*10h+1
    
    ;フラグを有効にする
    lodi,r0 1
    stra,r0 EnabledHoldTetromino

    retc,un

end ; End of assembly
