    ;テトリスの抽選関係のサブルーチン群

    ;====================================
    ;外部から呼び出すサブルーチン
    ;====================================
    ;init_random_tetromino
    ;乱数系の初期化
    ;
    ;inc_random_seed
    ;シード値をインクリメントする
    ;
    ;get_random_tetromino_index
    ;ランダムなテトロミノのインデックス(0~6)を返す
    ;
    ;====================================
    ;定義が必要な変数群
    ;====================================    
    ;RandomBytes0            equ 18D0h   ;乱数, xorshiftの内部状態
    ;RandomBytes1            equ 18D1h   
    ;ShuffleTetromino0       equ 18D2h   ;テトロミノ７種類のシャッフルに使う変数群, 0~6が並んでいること
    ;ShuffleTetromino1       equ 18D3h
    ;ShuffleTetromino2       equ 18D4h
    ;ShuffleTetromino3       equ 18D5h
    ;ShuffleTetromino4       equ 18D6h
    ;ShuffleTetromino5       equ 18D7h
    ;ShuffleTetromino6       equ 18D8h
    ;ShuffleIndex            equ 18D9h   ;現在シャッフルの何番目か


    ;-------------------
    ;init_random_tetromino
    ;乱数系の初期化
    ;r0を使用
init_random_tetromino:
    ;ShuffleTetromino[0-6]にシャッフルした0-6を入れる
    eorz r0
    stra,r0 ShuffleTetromino3
    lodi,r0 1
    stra,r0 ShuffleTetromino6
    lodi,r0 2
    stra,r0 ShuffleTetromino0
    lodi,r0 3
    stra,r0 ShuffleTetromino1
    lodi,r0 4
    stra,r0 ShuffleTetromino5
    lodi,r0 5
    stra,r0 ShuffleTetromino2
    lodi,r0 6
    stra,r0 ShuffleTetromino4
    stra,r0 ShuffleIndex
    bcta,un init_random ;乱数初期化して元の場所に戻る

    ;-------------------
    ;get_random_tetromino_index
    ;ランダムなテトロミノのインデックス(0~6)をr0に入れて返す
    ;r0,r1,r2,r3を使用
get_random_tetromino_index:

    ;Fisher–Yates shuffleでシャッフルしつつ値を返す
    loda,r0 ShuffleIndex
    bctr,eq _grti_last      ;シャッフル７回目か？

    ;ランダムなシャッフル位置を取得
    bsta,un get_shuffle_index

    ;---
    ;[ShuffleTetromino0+r0]と[ShuffleTetromino0+[ShuffleIndex]]を交換する
    
    ;r2 <- [ShuffleTetromino0+r0]
    strz r1 
    loda,r0 ShuffleTetromino0,r1
    strz r2

    ;r0 <- [ShuffleTetromino0+[ShuffleIndex]]
    loda,r3 ShuffleIndex
    loda,r0 ShuffleTetromino0,r3

    ;[ShuffleTetromino0+r0] <- r0
    stra,r0 ShuffleTetromino0,r1

    ;[ShuffleTetromino0+[ShuffleIndex]] <- r2
    lodz r2
    stra,r0 ShuffleTetromino0,r3

    ;---
    ;ShuffleIndexを減らして保存
    subi,r3 1
    stra,r3 ShuffleIndex

    retc,un
    
_grti_last:
    ;ShuffleIndexを末端に戻す
    lodi,r1 6
    stra,r1 ShuffleIndex
    loda,r0 ShuffleTetromino0
    retc,un
    
    ;-------------------
    ;get_shuffle_index
    ;r0の値に応じてランダムな0~6をr0に入れて返す
    ;   0~1 if r0 == 1
    ;   0~2 if r0 == 2
    ;   0~3 if r0 == 3
    ;   0~4 if r0 == 4
    ;   0~5 if r0 == 5
    ;   0~6 if r0 == 6
    ;
    ; r0,r1,r2,r3を使用
get_shuffle_index:
    ;get_random_tableから各bctaへのオフセット(r0*3)を計算してr3へ格納
    subi,r0 1
    strz r3
    addz r3
    addz r3
    strz r3
    bxa get_random_table,r3     ;get_random_[0-5]_6をr0に応じて呼び出し, 呼び出し元に直接戻る

get_random_table:
    bcta,un get_random_2
    bcta,un get_random_3
    bcta,un get_random_4
    bcta,un get_random_5
    bcta,un get_random_6
    bcta,un get_random_7

get_random_7:
    bsta,un next_random
    loda,r0 RandomBytes1
    comi,r0 7*36
    bctr,lt _gr7_less252   ;252未満ならループ抜ける
    loda,r0 RandomBytes0
    comi,r0 7*36
    bcfr,lt get_random_7  ;RandomBytes1も252以上ならリロール
_gr7_less252:
    bcta,un mod7            ;乱数をmod7して呼び出し元に直接戻る

get_random_6:
    bsta,un next_random
    loda,r0 RandomBytes1
    comi,r0 6*42
    bctr,lt _gr6_less252   ;252未満ならループ抜ける
    loda,r0 RandomBytes0
    comi,r0 6*42
    bcfr,lt get_random_6  ;RandomBytes1も252以上ならリロール
_gr6_less252:
    bcta,un mod6            ;乱数をmod6

get_random_5:
    bsta,un next_random
    loda,r0 RandomBytes1
    comi,r0 5*51
    bctr,lt _gr5_less255   ;255未満ならループ抜ける
    loda,r0 RandomBytes0
    comi,r0 5*51
    bcfr,lt get_random_5  ;RandomBytes1も255以上ならリロール
_gr5_less255:
    bcta,un mod5            ;乱数をmod5

get_random_4:
    bsta,un next_random
    loda,r0 RandomBytes0
    andi,r0 3               ;mod4
    retc,un

get_random_3:
    bsta,un next_random
    loda,r0 RandomBytes1
    comi,r0 3*85
    bctr,lt _gr3_less255   ;255未満ならループ抜ける
    loda,r0 RandomBytes0
    comi,r0 3*85
    bcfr,lt get_random_3  ;RandomBytes1も255以上ならリロール
_gr3_less255:
    bcta,un mod3            ;乱数をmod3

get_random_2:
    bsta,un next_random
    loda,r0 RandomBytes0
    andi,r0 1               ;mod2
    retc,un

    ;-------------------
    ;init_random
    ;乱数を初期化する
    ;r0を使用
    ;RandomBytesをinc_random_seedで適当にいじると尚良し, ただし0x0000にすると働かなくなるので注意
init_random:
    lodi,r0 0ffh
    stra,r0 RandomBytes0 
    stra,r0 RandomBytes1
    retc,un ; return

    ;-------------------
    ;inc_random_seed
    ;シード値をインクリメントする
    ;r0,r1を使用
inc_random_seed:
    loda,r1 RandomBytes1
    birr,r1 _inc_random_seed_end2      ;r1が0でなければ終わり
    loda,r0 RandomBytes0
    birr,r0 _inc_random_seed_end1      ;r0が0でなければ終わり
    lodi,r1 1
_inc_random_seed_end1:
    stra,r0 RandomBytes0
_inc_random_seed_end2:
    stra,r1 RandomBytes1
    retc,un

    ;-------------------
    ;next_random
    ;RandomBytes0,1にxorshift(16bitver)で生成した乱数を入れる
    ;r0,r1,r2を使用
next_random:
    ppsl 1000b  ;WCをセット. シフトでのキャリーをありにする
    loda,r1 RandomBytes0   ;上位バイトをr1へ格納
    loda,r2 RandomBytes1   ;下位バイトをr2へ格納

    lodz r1     ;r0 = r1
    rrr,r0      ;carry = r0 & 1    r0の下位1bitをキャリーに転送
    lodz r2     ;r0 = r2
    rrr,r0      ;r0 = (carry << 7) + (r0 >> 1)  ついでにr2の下位1bitがキャリーへ
    eorz r1     ;r0 ^= r1
    strz r1     ;r1 = r0
    rrr,r0      ;r0 = (carry << 7) + (r0 >> 1)
    eorz r2     ;r0 ^= r2
    stra,r0 RandomBytes1
    eorz r1     ;r0 ^ =r1
    stra,r0 RandomBytes0

    cpsl 1000b  ;WCをリセット
    retc,un ; return


end ; End of assembly
