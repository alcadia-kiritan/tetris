    name Mul8          ; module name

    ;-------------------
    ;mul8
    ;r0*r1をr0:r1に格納する
    ;r0,r1,r2,r3を使用
mul8:
    strz r3     ;r3 = -r0
    eori,r3 255
    addi,r3 1
    eorz r0     ;r0 = 0
    addz r0     ;C=0
    lodi,r2 8
    ppsl 1000b  ;WCをセット. シフトでのキャリーをありにする


    rrr,r1

_m8_loop: 
    tpsl 1
    bcfr,eq _m8_not_add
    subz r3
_m8_not_add:
    rrr,r0
    rrr,r1
    bdrr,r2 _m8_loop

    cpsl 1001b  ;WCをリセット
    retc,un

end ; End of assembly
