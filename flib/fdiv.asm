    name fdiv          ; module name

_fdiv_zero:
    eorz r0
    stra,r0 FStack+0
    stra,r0 FStack+1
    retc,un

_fdiv_zero_mantissa:
    ;除数の仮数部が0, 被除数の仮数部がそのままになる
    loda,r0 FStack+1,r1
    stra,r0 FStack+1
    retc,un

    ;-------------------
    ;fdiv
    ;[FStack+0][FStack+1] = [FStack+r1][FStack+r1+1] / [FStack+r2+0][FStack+r2+1]
    ;r0,r1,r2,r3を使用.
    ;fadd/fsubと異なり、r1,r2が破壊される.
fdiv:
    loda,r0 FStack+0,r2
    andi,r0 07fh
    bcta,eq fexception      ;0除算
    strz r3

    loda,r0 FStack+0,r1
    andi,r0 07fh
    bctr,eq _fdiv_zero      ;被除数が0

    ;指数部を計算
    subz r3
    addi,r0 EXPONENT_OFFSET
    bcfa,gt fexception          ;lt,eqは指数部のオーバーフロー
    
    strz r3

    ;符号ビットを取り出す
    loda,r0 FStack+0,r1
    eora,r0 FStack+0,r2
    andi,r0 80h

    addz r3
    stra,r0 FStack+0            ;指数部を保存
    
    ;r0,r2に仮数部を読み取り
    loda,r0 FStack+1,r2
    bctr,eq _fdiv_zero_mantissa     ;除数の仮数部が0?
    strz r2
    loda,r0 FStack+1,r1

    ;r1:r0 = 1:[FStack+1+r1]    被除数
    ;   r2 =   [FStack+1+r2]    除数
    ;   r3 = 0                  商

    lodi,r1 1
    lodi,r3 0

    ppsl WC+C   ;キャリーとCをON

    ;r1:r0 から 256+r2を引いていく

    comz r2
    bctr,lt _fdiv0_lt

    ;r0 >= r2
    subi,r1 1   ; r1 -= 1
    subz r2
    
    ;r0>=r2なのでCは確定で1 
    bctr,un _fdiv1

_fdiv0_lt:
    ;r0 < r2

    ;r1:r0の左シフト分、指数部を-1
    loda,r3 FStack+0
    subi,r3 1
    stra,r3 FStack+0
    andi,r3 07fh
    bcta,eq fexception
    lodi,r3 0

    ;r1:r0を左シフトしてr2を引く
    rrl,r0
    rrl,r1
    andi,r0 0feh        ;最下位ビットにキャリーが入ってるので消す
    subi,r1 0           ;C=1, cpslより速い
    subz r2
    subi,r1 0
    ;r1は2なのでCは確定で1 

_fdiv1:
    subi,r2 1                       ;除数を-1, C=0の状態で計算をできるようにする
    rrl,r0
    andi,r0 0feh    ;最下位ビットにキャリーが入ってるので消す
    rrl,r1
    ;C=0, r1の上位ビットは0なのでCは確定で0

    bctr,eq _fdiv1_lt   ;上位byteが0なので256+r2を引けない

    ;とりあえず256+r2を引いてみる
    subz r2
    subi,r1 1
    bcfr,lt _fdiv1_lt

    ;引けなかったので元に戻す
    subi,r1 0   ;r1 -= 1, C=1
    addz r2
    addi,r1 1
    subi,r1 0ffh        ;C=0    r1 += 1     r1>0は４つ上のbcfrで保証されてて,r1>=2は引けなかったことからない.引く前のr1は1確定. ffhが引けてC=1になる心配はない

_fdiv1_lt:
    rrl,r3      ;答えの仮数部を左シフト&C=1なら最下位ビットに1がセット
    ;r3の上位ビットは0なのでCは確定で0
    ;r1:r0を左シフト
    rrl,r0
    rrl,r1
    ;r1の上位ビットは0なのでCは確定で0

    bctr,eq _fdiv2_lt
    subz r2
    subi,r1 1
    bcfr,lt _fdiv2_lt
    subi,r1 0
    addz r2
    addi,r1 1
    subi,r1 0ffh
_fdiv2_lt:
    rrl,r3
    rrl,r0
    rrl,r1

    bctr,eq _fdiv3_lt
    subz r2
    subi,r1 1
    bcfr,lt _fdiv3_lt
    subi,r1 0
    addz r2
    addi,r1 1
    subi,r1 0ffh
_fdiv3_lt:
    rrl,r3
    rrl,r0
    rrl,r1

_fdiv4:
    bctr,eq _fdiv4_lt
    subz r2
    subi,r1 1
    bcfr,lt _fdiv4_lt
    subi,r1 0
    addz r2
    addi,r1 1
    subi,r1 0ffh
_fdiv4_lt:
    rrl,r3
    rrl,r0
    rrl,r1

_fdiv5:
    bctr,eq _fdiv5_lt
    subz r2
    subi,r1 1
    bcfr,lt _fdiv5_lt
    subi,r1 0
    addz r2
    addi,r1 1
    subi,r1 0ffh
_fdiv5_lt:
    rrl,r3
    rrl,r0
    rrl,r1

_fdiv6:
    bctr,eq _fdiv6_lt
    subz r2
    subi,r1 1
    bcfr,lt _fdiv6_lt
    subi,r1 0
    addz r2
    addi,r1 1
    subi,r1 0ffh
_fdiv6_lt:
    rrl,r3
    rrl,r0
    rrl,r1
    
_fdiv7:
    bctr,eq _fdiv7_lt
    subz r2
    subi,r1 1
    bcfr,lt _fdiv7_lt
    subi,r1 0
    addz r2
    addi,r1 1
    subi,r1 0ffh
_fdiv7_lt:
    rrl,r3
    rrl,r0
    rrl,r1

_fdiv8:
    ;最後の一桁はr1:r0が破壊されても構わない.
    subz r2
    subi,r1 1       ;引けたらC=1, 引けなかったらC=0
    rrl,r3

    stra,r3 FStack+1    ;仮数部を保存

    cpsl WC+C   ;キャリーとCをOFF
    retc,un

end ; End of assembly
