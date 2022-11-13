    name Mul8          ; module name

    ;-------------------
    ;mul8
    ;r0*r1をr1:r0に格納する
    ;r0,r1,r2,r3を使用
mul8:
    strz r3     ;r3 = r0
    eorz r0     ;r0 = 0
    addz r0     ;C=0
    lodi,r2 8
    ppsl 1000b  ;WCをセット. シフトでのキャリーをありにする

_m8_loop:
    rrl,r0
    rrl,r1
    tpsl 1
    bcfr,eq _m8_not_add
    cpsl 1
    addz r3
    addi,r1 0
_m8_not_add:
    bdrr,r2 _m8_loop

    cpsl 1000b  ;WCをリセット
    retc,un

end ; End of assembly
