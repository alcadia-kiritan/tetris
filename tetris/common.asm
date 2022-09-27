    ;複数のファイルから共通して使うサブルーチン郡

    ;-------------------
    ;button_process
    ;押されているボタンのビットを立ててr0に格納して返す
    ;押されていると判断される条件は、次の２つ
    ;１．前フレームで押されていないボタンが押されていないとき
    ;２．ボタン押しっぱなしで以前押されたとされた状態から5フレーム経過したとき
    ;引数
    ;- r0: あるキーの状態(ビット単位で押されている押されてないが格納されている値, P1LEFTKEYSを読み取った値とか)
    ;- r1: 前フレームのキー状態のデータへのオフセット(KeyDataからのオフセット、PrevP1LeftKeys-KeyDataとか)
    ;
    ;r0,r1,r2を使用
    ;複数ボタンが押されてるとリピート回りが微妙な気がするけどヨシ！
button_process:

    strz r2                 ;現フレームのキー情報をr2へ退避    
    loda,r0 KeyData,r1      ;前のフレームのキー情報をr0に読み取り

    comz r2
    bctr,eq _button_process_same_button_state        ;前のフレームとキー状態が同じか？

    ;前のフレームとキー状態が異なる
    eori,r0 0ffh        ;前のフレームの情報を反転
    andz r2             ;今のフレームで押されたビット　＝　not 前のフレーム　and 今のフレーム
    retc,eq             ;ボタンが押されてなければ終了

    ;どこかのボタンが押された
    strz r2                 ;押されたボタンの情報をr2へ退避
    lodi,r0 FIRST_REPEAT_INTERVAL
    stra,r0 KeyData+1,r1    ;リピートのカウントを設定, 初回だけちょっと長め
    lodz r2
    retc,un                 ;終了

_button_process_same_button_state:
    ;前のフレームとキー状態が同じ
    comi,r2 0
    retc,eq             ;ボタンが押されてなければ終了

    loda,r0 KeyData+1,r1   ;リピートカウントを読み取り
    bcfr,eq _button_process_not_repeated

    ;リピートカウントが0になった
    lodi,r0 REPEAT_INTERVAL               ;リピートカウントをリセットして保存
    stra,r0 KeyData+1,r1
    lodz r2
    retc,un

_button_process_not_repeated:
    subi,r0 1
    stra,r0 KeyData+1,r1    ;減らしたリピートカウントを保存
    eorz r0                 ;ボタン何も押してない
    retc,un

    ;-------------------
    ;bake_operation_tetromino
    ;操作テトロミノ(TetrominoX/Y)がある位置にブロックを配置(配置というかflip)
    ;r0,r1,r2,r3を使用
bake_operation_tetromino:

    ;r3にデータへのオフセットを格納
    bsta,un get_tetromino_data_offset

    ;ひとつ目のブロック
    loda,r0 TETROMINOS+1,r3     ; y0
    adda,r0 TetrominoY          ; r0 = TetrominoY + y0
    strz r1
    loda,r0 TETROMINOS-1,r3+    ; x0
    adda,r0 TetrominoX          ; r0 = TetrominoX + x0
    bstr,un flip_block

    ;２つ目のブロック
    loda,r0 TETROMINOS+1,r3+
    adda,r0 TetrominoY
    strz r1 
    loda,r0 TETROMINOS-1,r3+
    adda,r0 TetrominoX
    bstr,un flip_block

    ;３つ目のブロック
    loda,r0 TETROMINOS+1,r3+
    adda,r0 TetrominoY
    strz r1 
    loda,r0 TETROMINOS-1,r3+
    adda,r0 TetrominoX
    bstr,un flip_block

    ;４つ目のブロック
    loda,r0 TETROMINOS+1,r3+
    adda,r0 TetrominoY
    strz r1 
    loda,r0 TETROMINOS-1,r3+
    adda,r0 TetrominoX
    bctr,un flip_block

    ;-------------------
    ;flip_block
    ;X=r0,Y=r1のブロックを反転させる
    ;画面全体を32x26のブロックの集合としたとき、左下を(0,0)、右上を(31,25)とする座標系で
    ;(X,Y)が指すブロック位置のビットを反転させる。
    ;r0,r1,r2を使用
flip_block:

    ;X座標の下位1bitをr2へ抽出し、0ならr2=1、1ならr2=2をいれておく。 1or2はeorzで使うやつ
    strz r2     
    andi,r2 1
    addi,r2 1

    ;X座標の下位1bitを除いた値を抽出
    rrr,r0
    andi,r0 0Fh

    comi,r1 12
    bcfr,gt _flip_block_set_upper_screen

    ;Y(r1)が12超(=13以上)
    ;上画面に描画する Y=13~25
    
    ;下画面にとってのY=0の位置へ合わせる
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
    eorz r2                     ;X座標の下位1bitから作られたマスクでビット反転
    stra,r0 SCRUPDATA,r1        ;書き戻す

    retc,un

_flip_block_set_upper_screen:
    ;上画面に描画する Y=0~12

    eori,r1 0FFh
    addi,r1 13
    rrl,r1      ;Yを画面バッファでのオフセットに変換
    rrl,r1 
    rrl,r1 
    rrl,r1 
    addz r1     ;X(オフセットの下位4bit)を加算し、r0を画面バッファのオフセットにする
    strz r1

    loda,r0 SCRLODATA,r1        ;現在のブロック情報を読み込み
    eorz r2                     ;X座標の下位1bitから作られたマスクでビット反転
    stra,r0 SCRLODATA,r1        ;書き戻す

    retc,un

    ;-------------------
    ;get_tetromino_data_offset
    ;TetrominoType, TetrominoRotateからテトロミノのデータのオフセットを計算しr3に格納する
    ;r0,r1,r3を使用
get_tetromino_data_offset:

    ;テトロミノのデータオフセットをr3に格納 r3 = TetrominoType * 32 + TetrominoRotate * 8
    loda,r0 TetrominoType
    rrl,r0
    rrl,r0
    loda,r1 TetrominoRotate
    addz r1
    rrl,r0
    rrl,r0
    rrl,r0
    strz r3

    retc,un
    
    ;-------------------
    ;get_next_tetromino_data_offset
    ;NextTetrominoType, NextTetrominoRotateからテトロミノのデータのオフセットを計算しr3に格納する
    ;r0,r1,r3を使用
get_next_tetromino_data_offset:

    ;テトロミノのデータオフセットをr3に格納 r3 = NextTetrominoType * 32 + NextTetrominoRotate * 8
    loda,r0 NextTetrominoType
    rrl,r0
    rrl,r0
    loda,r1 NextTetrominoRotate
    addz r1
    rrl,r0
    rrl,r0
    rrl,r0
    strz r3

    retc,un

    ;-------------------
    ;scroll_to_bottom
    ;CRTCVPRが0になるまで１フレームr2ずつ下げ続ける
    ;r0,r1,r2を使用
scroll_to_bottom:
    bsta,un wait_vsync
    bsta,un sound_process

    loda,r0 CRTCVPR
    comz r2 
    bctr,lt _stb_end

    subz r2
    stra,r0 CRTCVPR

    ;スクロールと一緒にスプライト位置も下げていく
    loda,r0 SPRITE0Y
    subz r2 
    stra,r0 SPRITE0Y
    loda,r0 SPRITE1Y
    subz r2 
    stra,r0 SPRITE1Y
    loda,r0 SPRITE2Y
    subz r2 
    stra,r0 SPRITE2Y
    loda,r0 SPRITE3Y
    subz r2 
    stra,r0 SPRITE3Y
    
    bctr,un scroll_to_bottom

_stb_end:
    eorz r0
    stra,r0 CRTCVPR
    retc,un

    ;-------------------
    ;wait_for_frame
    ;r2フレーム待機する
    ;r0,r1,r2を使用
wait_for_frame:
    bsta,un wait_vsync
    bsta,un sound_process
    bdrr,r2 wait_for_frame
    retc,un


end ; End of assembly
