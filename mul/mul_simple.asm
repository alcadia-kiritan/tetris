    name Mul8          ; module name

    ;-------------------
    ;mul8
    ;r0*r1をr1:r0に格納する
    ;r0,r1,r2,r3を使用
mul8:
    strz r3     ;r3 = r0
    lodz r1     ;r2 = r1
    strz r2 
    eorz r0     ;r1 = r0 = 0
    strz r1
    addz r0     ;C=0
    
    ppsl 1000b  ;WCをセット. キャリーをありにする

    ;r2が0なら終了
    comi,r2 0
    bctr,eq _end

    ;r1:r0 にr3をr2回足していく
_m8_loop:
    addz r3
    addi,r1 0
    bdrr,r2 _m8_loop

_end:
    cpsl 1000b  ;WCをリセット
    retc,un

end ; End of assembly
