;操作テトリミノをフィールドに設置するシーン

    ;-------------------
    ;game_lock_down
    ;操作テトリミノをフィールドに設置するシーン
    ;r0,r1,r2,r3, Temporary0, Temporary1, Temporary2を使用
game_lock_down:

    ;次は新テトロミノ生成に行く
    lodi,r0 SCENE_GAME_NEW_TETROMINO
    stra,r0 NextSceneIndex+PAGE1

    ;チェックするY座標データ(CLEAR_CHECK_Y_OFFSETS)へのオフセット作ってr1に入れる
    loda,r1 TetrominoType+PAGE1
    loda,r0 TetrominoRotate+PAGE1
    rrl,r1
    rrl,r1
    addz r1
    rrl,r0
    strz r1

    ;チェック開始するY座標を生成(r2)
    loda,r0 TetrominoY+PAGE1
    adda,r0 CLEAR_CHECK_Y_OFFSETS,r1
    strz r2

    ;チェックする行数(r3)
    loda,r0 CLEAR_CHECK_Y_OFFSETS+1,r1
    strz r3
    
    ;削除チェック１行目
    ;Y=r2～r2+r3-1の行をチェック
_gld_check_line_1:
    lodz r2
    bsta,un check_cleared    
    bctr,eq _gld_clear_1        ;この行は消せる
    addi,r2 1
    bdrr,r3 _gld_check_line_1

    ;１行も消えなかった. 新しいテトロミノ生成
    ;落下処理をしないフラグを立てておく
    lodi,r0 GLD_NOT_FALL
    stra,r0 FallFuncionIndex+PAGE1
    bcta,un play_se9        ;効果音鳴らしてreturn
    
_gld_clear_1:
    ;1行消えた
    stra,r2 FallLineIndex+PAGE1
    subi,r3 1
    bctr,eq _gld_check_line_2_end

_gld_check_line_2:
    addi,r2 1
    lodz r2
    bsta,un check_cleared    
    bctr,eq _gld_clear_2        ;この行は消せる
    bdrr,r3 _gld_check_line_2

_gld_check_line_2_end:
    ;１行だけ消えた
    lodi,r0 GLD_FALL_LINES_1
    stra,r0 FallFuncionIndex+PAGE1
    bcta,un play_se4    ;音鳴らす, 直return

_gld_clear_2:
    ;2行目が消えた
    stra,r2 Temporary1+PAGE1
    subi,r3 1
    bctr,eq _gld_check_line_3_end

_gld_check_line_3:
    addi,r2 1
    lodz r2
    bsta,un check_cleared
    bctr,eq _gld_clear_3        ;この行は消せる
    bdrr,r3 _gld_check_line_3

_gld_check_line_3_end:
    ;２行だけ消えた. 1+1+1+1の２パターン. 1+2+1の２パターン. 2+2の２パターン
    bsta,un play_se6    ;音鳴らす
    loda,r1 FallLineIndex+PAGE1
    loda,r0 Temporary1+PAGE1
    subi,r0 1
    comz r1
    bctr,eq _gld_serial2
    
    ;消えた２行は連続してない
    ;1+1+1, 1+2+1のどちらか
    ;1+1+1ならr1が1, 1+2+1ならr1が2になる
    subz r1                    ;１つ目の行でずらす行数(r0) ＝ ２つ目の行-1 - １つ目の行
    lodi,r2 GLD_FALL_LINES_1_1_1
    comi,r0 1
    bctr,eq _gld_check_line_3_end2
    lodi,r2 GLD_FALL_LINES_1_2_1
_gld_check_line_3_end2:
    stra,r2 FallFuncionIndex+PAGE1
    retc,un

_gld_serial2:
    ;消えた２行は連続している(FallLineIndex == Temporary1-1)
    ;1+2+1, 2+2のどのパターンでも２マスずらす
    lodi,r0 GLD_FALL_LINES_2
    stra,r0 FallFuncionIndex+PAGE1    
    retc,un

_gld_clear_3:
    ;3行目が消えた
    stra,r2 Temporary2+PAGE1
    subi,r3 1
    bctr,eq _gld_check_line_4_end

    addi,r2 1
    lodz r2
    bsta,un check_cleared
    bcta,eq _gld_clear_4        ;この行は消せる
    ;Iテトロミノでの４マスが上限なのでこれ以上繰り返す必要はない

_gld_check_line_4_end:
    ;３行だけ消えた. 1+1+2パターン. 2+1+1パターン. 1+3パターン. 3+1パターン.の４通りがありうる
    bsta,un play_se7    ;音鳴らす
    loda,r1 FallLineIndex+PAGE1
    loda,r0 Temporary1+PAGE1
    subi,r0 1
    comz r1         ;消えた1行目と2行目が連続しているか？
    bctr,eq _gld_serial3

    ;消えた1行目と2行目が連続してない
    ;1+1+2パターン確定
    lodi,r0 GLD_FALL_LINES_1_1_2
    stra,r0 FallFuncionIndex+PAGE1
    retc,un

_gld_serial3:
    ;消えた1行目と2行目が連続している
    ;2+1+1パターンか1+3パターンか3+1パターン
    loda,r2 Temporary2+PAGE1
    subi,r2 2
    comz r2                 ;消えた１～３行目が連続しているか？
    bctr,eq _gld_serial4
    ;３行目は連続してない. 2+1+1パターン確定
    lodi,r0 GLD_FALL_LINES_2_1_1
    stra,r0 FallFuncionIndex+PAGE1
    retc,un

_gld_serial4:
    ;1~3行目が連続している
    ;1+3パターンか3+1パターン確定
    lodi,r0 GLD_FALL_LINES_3
    stra,r0 FallFuncionIndex+PAGE1
    retc,un

_gld_clear_4:
    ;４行消えた. パターンは1個だけ
    lodi,r0 GLD_FALL_LINES_4
    stra,r0 FallFuncionIndex+PAGE1
    bcta,un play_se8    ;音鳴らして直return

    ;-------------------
    ;check_cleared
    ;Y=r0の行が消せるかどうかをccに入れて返す. 消せるならeq, 消せないならgt
    ;r0,r1を使用
check_cleared:

    comi,r0 13
    bctr,lt _cc_lower_screen

    ;上画面
    ;r0をVRAMのオフセットに変換
    ;r1 = (25 - r0) * 16 = (25 + (r0^0xFF) + 1) * 16 = (26 + (r0^0xFF)) * 16

    eori,r0 255
    addi,r0 26
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    lodi,r0 EMPTY_2BLOCK+3   ;２マス埋まってる数値

    coma,r0 SCRUPDATA+FIELD_START_X/2+PAGE1,r1
    retc,gt ;2マス埋まってない
    coma,r0 SCRUPDATA+FIELD_START_X/2+PAGE1,r1+
    retc,gt
    coma,r0 SCRUPDATA+FIELD_START_X/2+PAGE1,r1+
    retc,gt
    coma,r0 SCRUPDATA+FIELD_START_X/2+PAGE1,r1+
    retc,gt
    coma,r0 SCRUPDATA+FIELD_START_X/2+PAGE1,r1+
    retc,un
    
_cc_lower_screen:
    ;下画面
    ;r1をVRAMのオフセットに変換
    ;r1 = (12 - r0) * 16 = (12 + (r0^0xFF) + 1) * 16 = (13 + (r0^0xFF)) * 16

    eori,r0 255
    addi,r0 13
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    lodi,r0 EMPTY_2BLOCK+3   ;２マス埋まってる数値

    coma,r0 SCRLODATA+FIELD_START_X/2+PAGE1,r1
    retc,gt ;2マス埋まってない
    coma,r0 SCRLODATA+FIELD_START_X/2+PAGE1,r1+
    retc,gt
    coma,r0 SCRLODATA+FIELD_START_X/2+PAGE1,r1+
    retc,gt
    coma,r0 SCRLODATA+FIELD_START_X/2+PAGE1,r1+
    retc,gt
    coma,r0 SCRLODATA+FIELD_START_X/2+PAGE1,r1+
    retc,un

    ;-------------------
    ;game_lock_down_after_vsync
    ;操作テトリミノをフィールドに設置するシーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_lock_down_after_vsync:

    ;落下処理がないなら終了
    loda,r3 FallFuncionIndex+PAGE1
    retc,eq

    ;-------
    ;ゴーストスプライトを画面領域外に飛ばして見えなくする
    eorz r0 
    stra,r0 SPRITE0X+PAGE1
    stra,r0 SPRITE0Y+PAGE1
    stra,r0 SPRITE1X+PAGE1
    stra,r0 SPRITE1Y+PAGE1
    stra,r0 SPRITE2X+PAGE1
    stra,r0 SPRITE2Y+PAGE1
    stra,r0 SPRITE3X+PAGE1
    stra,r0 SPRITE3Y+PAGE1
    
    ;落下処理を呼び出して、呼び出し元に直接return
    loda,r1 FallLineIndex+PAGE1
    bxa fall_process_table-3,r3 

    ;---------------
    ;落下処理のテーブルのインデックス
    GLD_NOT_FALL            equ 0
    GLD_FALL_LINES_1        equ 1*3     ;*3=sizeof(bcta)
    GLD_FALL_LINES_2        equ 2*3
    GLD_FALL_LINES_3        equ 3*3
    GLD_FALL_LINES_4        equ 4*3
    GLD_FALL_LINES_1_1_1    equ 5*3     ;１行消えて、１行消えずに、１行消える、の意
    GLD_FALL_LINES_1_1_2    equ 6*3     ;１行消えて、１行消えずに、２行消える、の意
    GLD_FALL_LINES_1_2_1    equ 7*3     ;１行消えて、２行消えずに、１行消える、の意
    GLD_FALL_LINES_2_1_1    equ 8*3     ;２行消えて、１行消えずに、１行消える、の意

fall_process_table:
    bcta,un fall_lines_1
    bcta,un fall_lines_2
    bcta,un fall_lines_3
    bcta,un fall_lines_4
    bcta,un fall_lines_1_1_1
    bcta,un fall_lines_1_1_2
    bcta,un fall_lines_1_2_1
    bcta,un fall_lines_2_1_1
    
    ;-------------------
    ;fall_lines_1
    ;Y=r1の行へ1行上から行を落下させる
    ;r0,r1,r2を使用
fall_lines_1:

    comi,r1 HALF_SCREEN_CHARA_HEIGHT-1
    bctr,lt _fall_lines_1_lower
    bctr,eq _fall_lines_1_lu     ;上画面と下画面の境目から転送開始

    ;上画面から転送
    ;転送行数r2 = FIELD_HEIGHT_ON_UPPER_SCREEN - (r1-HALF_SCREEN_CHARA_HEIGHT+1)
    ;          = FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-1-r1
    lodi,r0 FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-1
    subz r1 
    bcta,eq _fall_lines_1_last     ;転送行が0なら消すだけで終了
    strz r2
    
    ; オフセット/10h = SCREEN_CHARA_HEIGHT-1 - r1
    lodi,r0 SCREEN_CHARA_HEIGHT-1
    subz r1 
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    bcta,un _fall_lines_1_uu_loop
    
_fall_lines_1_lower:
    ;r1が12未満,下画面が転送開始行
    
    ;転送行数r2 = 12-r1
    lodi,r0 HALF_SCREEN_CHARA_HEIGHT-1
    subz r1
    strz r2

    ;r0をVRAM上のオフセットに変換
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

_fall_lines_1_ll:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4,r1
    subi,r1 10h
    bdrr,r2 _fall_lines_1_ll

    ;上画面の最下段から下画面の最上段への転送
_fall_lines_1_lu:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4

    ;上画面を１行ずらす
    lodi,r1 (HALF_SCREEN_CHARA_HEIGHT-1)*10h
    lodi,r2 FIELD_HEIGHT_ON_UPPER_SCREEN-1

_fall_lines_1_uu_loop:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+4,r1
    subi,r1 10h
    bdrr,r2 _fall_lines_1_uu_loop
    
_fall_lines_1_last:
    ;一番上の行を消す
    lodi,r0 EMPTY_2BLOCK
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN)+4

    retc,un

    ;-------------------
    ;fall_lines_2
    ;Y=r1の行へ2行上から行を落下させる
    ;r0,r1,r2を使用
fall_lines_2:

    comi,r1 HALF_SCREEN_CHARA_HEIGHT-2
    bctr,lt _fall_lines_2_lower
    bcta,eq _fall_lines_2_lu_2           ;上画面と下画面の境目から転送開始
    comi,r1 HALF_SCREEN_CHARA_HEIGHT-1
    bcta,eq _fall_lines_2_lu_1           ;上画面と下画面の境目から転送開始

    ;上画面から転送
    ;転送行数r2 = FIELD_HEIGHT_ON_UPPER_SCREEN - (r1-HALF_SCREEN_CHARA_HEIGHT+2)
    ;          = FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-2-r1
    lodi,r0 FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-2
    subz r1 
    bcta,eq _fall_lines_2_last       ;最上段を消すだけ
    strz r2

    ; オフセット/10h = SCREEN_CHARA_HEIGHT-1 - r1
    lodi,r0 SCREEN_CHARA_HEIGHT-1
    subz r1 
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    bcta,un _fall_lines_2_uu_loop
    
_fall_lines_2_lower:
    ;r1が11未満,下画面が転送開始行
    
    ;転送行数r2 = HALF_SCREEN_CHARA_HEIGHT-2-r1
    lodi,r0 HALF_SCREEN_CHARA_HEIGHT-2
    subz r1
    strz r2

    ;r0をVRAM上のオフセットに変換
    addi,r0 1
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

_fall_lines_2_ll:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4,r1
    subi,r1 10h
    bdrr,r2 _fall_lines_2_ll

    ;上画面の最下段から下画面の最上段+1への転送
_fall_lines_2_lu_2:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+4

_fall_lines_2_lu_1:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4

_fall_lines_2_uu:
    ;上画面を2行ずらす
    lodi,r1 (HALF_SCREEN_CHARA_HEIGHT-1)*10h
    lodi,r2 FIELD_HEIGHT_ON_UPPER_SCREEN-2

_fall_lines_2_uu_loop:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+4,r1
_fall_lines_2_uu_loop_end:
    subi,r1 10h
    bdrr,r2 _fall_lines_2_uu_loop
    
_fall_lines_2_last:
    ;一番上の行を消す
    lodi,r0 EMPTY_2BLOCK
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+4
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+4

    retc,un


    ;-------------------
    ;fall_lines_3
    ;Y=r1の行へ3行上から行を落下させる
    ;r0,r1,r2を使用
fall_lines_3:

    comi,r1 HALF_SCREEN_CHARA_HEIGHT-3
    bctr,lt _fall_lines_3_lower
    bcta,eq _fall_lines_3_lu_3           ;上画面と下画面の境目から転送開始
    comi,r1 HALF_SCREEN_CHARA_HEIGHT-2
    bcta,eq _fall_lines_3_lu_2           ;上画面と下画面の境目から転送開始
    comi,r1 HALF_SCREEN_CHARA_HEIGHT-1
    bcta,eq _fall_lines_3_lu_1           ;上画面と下画面の境目から転送開始

    ;上画面から転送
    ;転送行数r2 = FIELD_HEIGHT_ON_UPPER_SCREEN - (r1-HALF_SCREEN_CHARA_HEIGHT+3)
    ;          = FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-3-r1
    lodi,r0 FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-3
    subz r1 
    bcta,eq _fall_lines_3_last       ;最上段を消すだけ
    strz r2

    ; オフセット/10h = SCREEN_CHARA_HEIGHT-1 - r1
    lodi,r0 SCREEN_CHARA_HEIGHT-1
    subz r1 
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    bcta,un _fall_lines_3_uu_loop
    
_fall_lines_3_lower:
    ;r1が11未満,下画面が転送開始行
    
    ;転送行数r2 = HALF_SCREEN_CHARA_HEIGHT-3-r1
    lodi,r0 HALF_SCREEN_CHARA_HEIGHT-3
    subz r1
    strz r2

    ;r0をVRAM上のオフセットに変換
    addi,r0 2
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

_fall_lines_3_ll:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*3+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*3+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*3+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*3+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*3+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4,r1
    subi,r1 10h
    bdrr,r2 _fall_lines_3_ll

    ;上画面の最下段から下画面の最上段+2への転送
    
_fall_lines_3_lu_3:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+4

_fall_lines_3_lu_2:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+4

_fall_lines_3_lu_1:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4

_fall_lines_3_uu:
    ;上画面を3行ずらす
    lodi,r1 (HALF_SCREEN_CHARA_HEIGHT-1)*10h
    lodi,r2 FIELD_HEIGHT_ON_UPPER_SCREEN-3

_fall_lines_3_uu_loop:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-30h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-30h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-30h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-30h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-30h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+4,r1
_fall_lines_3_uu_loop_end:
    subi,r1 10h
    bdrr,r2 _fall_lines_3_uu_loop
    
_fall_lines_3_last:
    ;一番上の3行を消す
    lodi,r0 EMPTY_2BLOCK
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+4
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+4
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+4

    retc,un


    ;-------------------
    ;fall_lines_4
    ;Y=r1の行へ4行上から行を落下させる
    ;r0,r1,r2を使用
fall_lines_4:

    comi,r1 HALF_SCREEN_CHARA_HEIGHT-4
    bctr,lt _fall_lines_4_lower
    bcta,eq _fall_lines_4_lu_4           ;上画面と下画面の境目から転送開始
    comi,r1 HALF_SCREEN_CHARA_HEIGHT-3
    bcta,eq _fall_lines_4_lu_3           ;上画面と下画面の境目から転送開始
    comi,r1 HALF_SCREEN_CHARA_HEIGHT-2
    bcta,eq _fall_lines_4_lu_2           ;上画面と下画面の境目から転送開始
    comi,r1 HALF_SCREEN_CHARA_HEIGHT-1
    bcta,eq _fall_lines_4_lu_1           ;上画面と下画面の境目から転送開始

    ;上画面から転送
    ;転送行数r2 = FIELD_HEIGHT_ON_UPPER_SCREEN - (r1-HALF_SCREEN_CHARA_HEIGHT+4)
    ;          = FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-4-r1
    lodi,r0 FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-4
    subz r1 
    bcta,eq _fall_lines_4_last       ;最上段を消すだけ
    strz r2

    ; オフセット/10h = SCREEN_CHARA_HEIGHT-1 - r1
    lodi,r0 SCREEN_CHARA_HEIGHT-1
    subz r1 
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    bcta,un _fall_lines_4_uu_loop
    
_fall_lines_4_lower:
    ;r1が11未満,下画面が転送開始行
    
    ;転送行数r2 = HALF_SCREEN_CHARA_HEIGHT-4-r1
    lodi,r0 HALF_SCREEN_CHARA_HEIGHT-4
    subz r1
    strz r2

    ;r0をVRAM上のオフセットに変換
    addi,r0 3
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

_fall_lines_4_ll:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*4+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*4+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*4+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*4+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*4+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4,r1
    subi,r1 10h
    bdrr,r2 _fall_lines_4_ll

    ;上画面の最下段から下画面の最上段+3への転送
    
_fall_lines_4_lu_4:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*3+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*3+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*3+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*3+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*3+4

_fall_lines_4_lu_3:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*2+4

_fall_lines_4_lu_2:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-3)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+4

_fall_lines_4_lu_1:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-4)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-4)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-4)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-4)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-4)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4

    ;上画面を2行ずらす
    lodi,r1 (HALF_SCREEN_CHARA_HEIGHT-1)*10h
    lodi,r2 FIELD_HEIGHT_ON_UPPER_SCREEN-4

_fall_lines_4_uu_loop:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-40h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-40h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-40h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-40h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-40h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+4,r1
    subi,r1 10h
    bdrr,r2 _fall_lines_4_uu_loop
    
_fall_lines_4_last:
    ;一番上の4行を消す
    lodi,r0 EMPTY_2BLOCK
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+0)+4
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+1)+4
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+2)+4
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+3)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+3)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+3)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+3)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-FIELD_HEIGHT_ON_UPPER_SCREEN+3)+4

    retc,un

    ;-------------------
    ;fall_lines_1_1_1
    ;Y=r1の行へ1行上と３行上以降から行を落下させる
    ;r0,r1,r2を使用
fall_lines_1_1_1:

    comi,r1 HALF_SCREEN_CHARA_HEIGHT-1
    bctr,lt _fall_lines_1_1_1_lower
    bcta,eq _fall_lines_1_1_1_lu     ;上画面と下画面の境目から転送開始

    ;上画面から転送
    lodi,r0 FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-1-1
    subz r1
    strz r2
    
    ; オフセット/10h = SCREEN_CHARA_HEIGHT-1 - r1
    lodi,r0 SCREEN_CHARA_HEIGHT-1
    subz r1 
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    ;上画面から上画面への転送
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+4,r1
    bcta,un _fall_lines_2_uu_loop_end   ;2行落下処理に移動
    
_fall_lines_1_1_1_lower:
    ;r1が12未満,下画面が転送開始行
    
    ;転送行数r2 = 12-r1
    lodi,r0 HALF_SCREEN_CHARA_HEIGHT-1
    subz r1
    strz r2

    ;r0をVRAM上のオフセットに変換
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

_fall_lines_1_1_1_ll:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4,r1
    subi,r1 10h
    subi,r2 1
    bcta,eq _fall_lines_2_lu_1
    comi,r2 1
    bcta,eq _fall_lines_2_lu_2
    subi,r2 1
    bcta,un _fall_lines_2_ll
    

    ;上画面の最下段から下画面の最上段への転送
_fall_lines_1_1_1_lu:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4
    bcta,un _fall_lines_2_uu   ;2行落下処理に移動
    

    ;-------------------
    ;fall_lines_1_1_2
    ;Y=r1の行へ1行上と4行上以降から行を落下させる
    ;r0,r1,r2を使用
fall_lines_1_1_2:

    comi,r1 HALF_SCREEN_CHARA_HEIGHT-1
    bctr,lt _fall_lines_1_1_2_lower
    bcta,eq _fall_lines_1_1_2_lu     ;上画面と下画面の境目から転送開始

    ;上画面から転送
    lodi,r0 FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-1-1
    subz r1
    strz r2
    
    ; オフセット/10h = SCREEN_CHARA_HEIGHT-1 - r1
    lodi,r0 SCREEN_CHARA_HEIGHT-1
    subz r1 
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    ;上画面から上画面への転送
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+4,r1
    bcta,un _fall_lines_3_uu_loop_end   ;3行落下処理に移動
    
_fall_lines_1_1_2_lower:
    ;r1が12未満,下画面が転送開始行
    
    ;転送行数r2 = 12-r1
    lodi,r0 HALF_SCREEN_CHARA_HEIGHT-1
    subz r1
    strz r2

    ;r0をVRAM上のオフセットに変換
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

_fall_lines_1_1_2_ll:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4,r1
    subi,r1 10h
    subi,r2 1
    bcta,eq _fall_lines_3_lu_1      ;下画面に１行残ってるパターン
    comi,r2 1
    bcta,eq _fall_lines_3_lu_2      ;下画面に２行残ってるパターン
    comi,r2 2
    bcta,eq _fall_lines_3_lu_3      ;下画面に３行残ってるパターン
    subi,r2 2
    bcta,un _fall_lines_3_ll
    
    ;上画面の最下段から下画面の最上段への転送
_fall_lines_1_1_2_lu:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4
    bcta,un _fall_lines_3_uu   ;3行落下処理に移動

    ;-------------------
    ;fall_lines_1_2_1
    ;Y=r1の行へ1行上から２行、４行上以降から行を落下させる
    ;r0,r1,r2を使用
fall_lines_1_2_1:

    comi,r1 HALF_SCREEN_CHARA_HEIGHT-2
    bcta,lt _fall_lines_1_2_1_lower
    bcta,eq _fall_lines_1_2_1_lu     ;上画面と下画面の境目から転送開始
    comi,r1 HALF_SCREEN_CHARA_HEIGHT-1
    bcta,eq _fall_lines_1_2_1_lu2     ;上画面と下画面の境目から転送開始

    ;上画面から転送
    lodi,r0 FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-1-2
    subz r1
    strz r2
    
    ; オフセット/10h = SCREEN_CHARA_HEIGHT-2 - r1
    lodi,r0 SCREEN_CHARA_HEIGHT-2
    subz r1 
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    ;上画面から上画面への転送
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h+4,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-10h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-00h+4,r1

    bcta,un _fall_lines_2_uu_loop_end   ;2行落下処理に移動
    
_fall_lines_1_2_1_lower:
    ;r1が11未満,下画面が転送開始行
    
    ;転送行数r2 = 12-r1
    lodi,r0 HALF_SCREEN_CHARA_HEIGHT-1
    subz r1
    strz r2

    ;r0をVRAM上のオフセットに変換
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

_fall_lines_1_2_1_ll:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-20h*1+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-20h*1+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-20h*1+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-20h*1+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-20h*1+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*1+4,r1

    subi,r1 20h
    subi,r2 2
    bcta,eq _fall_lines_2_lu_1
    comi,r2 1
    bcta,eq _fall_lines_2_lu_2
    subi,r2 1
    bcta,un _fall_lines_2_ll
    

    ;下画面の１行目から２行目へ転送＆上画面の最下段から下画面の１段目への転送
_fall_lines_1_2_1_lu:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+0
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+2
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+3
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+4

    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4
    bcta,un _fall_lines_2_uu   ;2行落下処理に移動

    ;上画面の最下段から下画面の１段目への転送＆上画面の最下段-１行目から最下段へ転送
_fall_lines_1_2_1_lu2:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4
    
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+0
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+2
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+3
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+4
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    
    lodi,r1 (HALF_SCREEN_CHARA_HEIGHT-2)*10h
    lodi,r2 FIELD_HEIGHT_ON_UPPER_SCREEN-3
    bcta,un _fall_lines_2_uu_loop

    ;-------------------
    ;fall_lines_2_1_1
    ;Y=r1の行へ２行上と４行上以降から行を落下させる
    ;r0,r1,r2を使用
fall_lines_2_1_1:

    comi,r1 HALF_SCREEN_CHARA_HEIGHT-2
    bctr,lt _fall_lines_2_1_1_lower
    bcta,eq _fall_lines_2_1_1_lu1     ;上画面と下画面の境目から転送開始
    comi,r1 HALF_SCREEN_CHARA_HEIGHT-1
    bcta,eq _fall_lines_2_1_1_lu2     ;上画面と下画面の境目から転送開始

    ;上画面から転送
    lodi,r0 FIELD_HEIGHT_ON_UPPER_SCREEN+HALF_SCREEN_CHARA_HEIGHT-1-2
    subz r1
    strz r2
    
    ; オフセット/10h = SCREEN_CHARA_HEIGHT-1 - r1
    lodi,r0 SCREEN_CHARA_HEIGHT-1
    subz r1 
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

    ;上画面から上画面への転送
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+0,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+0,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+1,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+1,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+2,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+2,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+3,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+3,r1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1-20h+4,r1
    stra,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+00h+4,r1
    bcta,un _fall_lines_3_uu_loop_end   ;2行落下処理に移動
    
_fall_lines_2_1_1_lower:
    ;r1が11未満,下画面が転送開始行
    
    ;転送行数r2 = 12-r1
    lodi,r0 HALF_SCREEN_CHARA_HEIGHT-1
    subz r1
    strz r2

    ;r0をVRAM上のオフセットに変換
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    strz r1

_fall_lines_2_1_1_ll:
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+0,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+1,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+2,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+3,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3,r1
    loda,r0 SCRLODATA+FIELD_START_X/2+PAGE1-10h*2+4,r1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4,r1
    subi,r1 10h
    comi,r2 2
    bcta,eq _fall_lines_3_lu_2
    comi,r2 3
    bcta,eq _fall_lines_3_lu_3
    subi,r2 1
    bcta,un _fall_lines_3_ll
    

    ;上画面の最下段から下画面の最上段+1への転送
_fall_lines_2_1_1_lu1:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-1)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*1+4
    bcta,un _fall_lines_3_lu_1   ;3行落下処理に移動
    
    ;上画面の最下段+1から下画面の最上段への転送
_fall_lines_2_1_1_lu2:
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+0
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+0
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+1
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+1
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+2
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+2
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+3
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+3
    loda,r0 SCRUPDATA+FIELD_START_X/2+PAGE1+10h*(HALF_SCREEN_CHARA_HEIGHT-2)+4
    stra,r0 SCRLODATA+FIELD_START_X/2+PAGE1+10h*0+4
    bcta,un _fall_lines_3_uu   ;3行落下処理に移動


CLEAR_CHECK_Y_OFFSETS: ;テトリミノを消すときにチェックするYオフセット. 1テトロミノに付きチェックを開始するY座標オフセットとチェックする行数の2byte.
CCYO_I0:
    db          0
    db          1
CCYO_I90:
    db          -2
    db          4
CCYO_I180:
    db          -1
    db          1
CCYO_I270:
    db          -2
    db          4
CCYO_J0:
    db          0
    db          2
CCYO_J90:
    db          -1
    db          3
CCYO_J180:
    db          -1
    db          2
CCYO_J270:
    db          -1
    db          3
CCYO_L0:
    db          0
    db          2
CCYO_L90:
    db          -1
    db          3
CCYO_L180:
    db          -1
    db          2
CCYO_L270:
    db          -1
    db          3
CCYO_O0:
    db          0
    db          2
CCYO_O90:
    db          0
    db          2
CCYO_O180:
    db          0
    db          2
CCYO_O270:
    db          0
    db          2
CCYO_S0:
    db          0
    db          2
CCYO_S90:
    db          -1
    db          3
CCYO_S180:
    db          -1
    db          2
CCYO_S270:
    db          -1
    db          3
CCYO_T0:
    db          0
    db          2
CCYO_T90:
    db          -1
    db          3
CCYO_T180:
    db          -1
    db          2
CCYO_T270:
    db          -1
    db          3
CCYO_Z0:
    db          0
    db          2
CCYO_Z90:
    db          -1
    db          3
CCYO_Z180:
    db          -1
    db          2
CCYO_Z270:
    db          -1
    db          3

end ; End of assembly
