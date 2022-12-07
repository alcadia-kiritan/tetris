    name futil          ; module name

    ;-------------------
    ;fadd_mantissa
    ;[FStack+r1+0][FStack+r1+1]の仮数部へr0を加算する
    ;誤差対策に数値を少しだけ大きくしたい時とかに使う. FStack+r1は0以外であること.
    ;絶対値を 2^指数 * r0/256 だけ大きくするのに等しい
    ;r0,r1を使用.  r1は変化しない.
fadd_mantissa:
    adda,r0 FStack+1,r1
    tpsl C
    bctr,eq _fm_ovf

    ;オーバーフローなし、仮数部を保存して終了
    stra,r0 FStack+1,r1
    retc,un

_fm_ovf:
    ;r0を足して仮数部がオーバーフローした, 仮数部を右シフトして指数部を+1

    ;右シフトした仮数部を保存
    rrr,r0 
    andi,r0 07fh
    stra,r0 FStack+1,r1

    ;指数部を+1
    loda,r0 FStack+0,r1
    addi,r0 1
    stra,r0 FStack+0,r1

    andi,r0 07fh
    retc,gt

    bcta,un fexception  ;指数部が０になってる。仮数部がオーバーフローした

end ; End of assembly
