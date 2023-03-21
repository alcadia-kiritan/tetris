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

    comi,r2 0
    retc,eq     ;r2が0なら終了
    
    addz r0     ;C=0, cpslより小さいし速い
    
    ppsl WC  ;WCをセット. キャリーをありにする

    ;r1:r0 にr3をr2回足していく
_m8_loop:
    addz r3
    addi,r1 0
    bdrr,r2 _m8_loop

    cpsl WC+C  ;WCをリセット
    retc,un

end ; End of assembly
