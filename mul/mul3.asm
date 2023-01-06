    name Mul8          ; module name

_mul8_zero:
    strz r1
    retc,un 

    ;-------------------
    ;mul8
    ;r0*r1をr0:r1に格納する
    ;r0,r1,r2,r3を使用
mul8:
    strz r3     ;r3 = r0
    bctr,eq _mul8_zero

    subi,r3 1   ;r3 -= 1    ループ内でキャリーの補正がかかる分-1しておく
    eorz r0     ;r0 = 0
    addz r0     ;C=0
    lodi,r2 8
    ppsl WC     ;WCをセット. シフトでのキャリーをありにする

    rrr,r1
_m8_loop: 
    tpsl C
    bcfr,eq _m8_not_add
    addz r3
_m8_not_add:
    rrr,r0
    rrr,r1
    
    bdrr,r2 _m8_loop

    cpsl WC     ;WCをリセット
    
    retc,un

end ; End of assembly
