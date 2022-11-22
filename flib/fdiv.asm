    name fdiv          ; module name

_fdiv_zero:
    eorz r0
    stra,r0 FStack+0
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
    subz r2
    subi,r1 1
    ;r1は1なのでCは確定で1 
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
    subi,r1 0           ;r1 -= 1 / C=1      ppsl Cの代替,ppslより速い
    subz r2
    subi,r1 0
    ;r1は2なのでCは確定で1 

_fdiv1:
    rrl,r0
    rrl,r1
    andi,r0 0feh    ;最下位ビットにキャリーが入ってるので消す
    ;C=0, r1の上位ビットは0なのでCは確定で0

    comi,r1 1
    bctr,lt _fdiv1_lt
    bctr,gt _fdiv1_gt

    ;r1 == 1
    comz r2
    bctr,lt _fdiv1_lt

_fdiv1_gt:
    subi,r1 0
    subz r2
    subi,r1 0
    addi,r3 0       ; r3 += 1   ↑のsubiのr1は1以上なのでC=1確定
    ;C=0
    
_fdiv1_lt:
    ;r1:r0を左シフト
    rrl,r0
    rrl,r1
    andi,r0 0feh
    ;r1の上位ビットは0なのでCは確定で0
    rrl,r3      ;答えの仮数部を左シフト
    ;r3の上位ビットは0なのでCは確定で0

_fdiv2:
    comi,r1 1
    bctr,lt _fdiv2_lt
    bctr,gt _fdiv2_gt
    comz r2
    bctr,lt _fdiv2_lt
_fdiv2_gt:
    subi,r1 0
    subz r2
    subi,r1 0
    addi,r3 0
_fdiv2_lt:
    rrl,r0
    rrl,r1
    rrl,r3

_fdiv3:
    comi,r1 1
    bctr,lt _fdiv3_lt
    bctr,gt _fdiv3_gt
    comz r2
    bctr,lt _fdiv3_lt
_fdiv3_gt:
    subi,r1 0
    subz r2
    subi,r1 0
    addi,r3 0
_fdiv3_lt:
    rrl,r0
    rrl,r1
    rrl,r3

_fdiv4:
    comi,r1 1
    bctr,lt _fdiv4_lt
    bctr,gt _fdiv4_gt
    comz r2
    bctr,lt _fdiv4_lt
_fdiv4_gt:
    subi,r1 0
    subz r2
    subi,r1 0
    addi,r3 0
_fdiv4_lt:
    rrl,r0
    rrl,r1
    rrl,r3

_fdiv5:
    comi,r1 1
    bctr,lt _fdiv5_lt
    bctr,gt _fdiv5_gt
    comz r2
    bctr,lt _fdiv5_lt
_fdiv5_gt:
    subi,r1 0
    subz r2
    subi,r1 0
    addi,r3 0
_fdiv5_lt:
    rrl,r0
    rrl,r1
    rrl,r3

_fdiv6:
    comi,r1 1
    bctr,lt _fdiv6_lt
    bctr,gt _fdiv6_gt
    comz r2
    bctr,lt _fdiv6_lt
_fdiv6_gt:
    subi,r1 0
    subz r2
    subi,r1 0
    addi,r3 0
_fdiv6_lt:
    rrl,r0
    rrl,r1
    rrl,r3

_fdiv7:
    comi,r1 1
    bctr,lt _fdiv7_lt
    bctr,gt _fdiv7_gt
    comz r2
    bctr,lt _fdiv7_lt
_fdiv7_gt:
    subi,r1 0
    subz r2
    subi,r1 0
    addi,r3 0
_fdiv7_lt:
    rrl,r0
    rrl,r1
    rrl,r3

_fdiv8:
    comi,r1 1
    bctr,lt _fdiv8_lt
    bctr,gt _fdiv8_gt
    comz r2
    bctr,lt _fdiv8_lt
_fdiv8_gt:
    addi,r3 1
_fdiv8_lt:

    stra,r3 FStack+1    ;仮数部を保存

    cpsl WC+C   ;キャリーとCをOFF
    retc,un

end ; End of assembly
