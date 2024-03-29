    name Mul8          ; module name

    ;-------------------
    ;mul8
    ;r0*r1をr1:r0に格納する
    ;r0,r1,r2,r3を使用
mul8:
    strz r3     ;r3 = r0
    eorz r0     ;r2 = r0 = 0
    strz r2     
    addz r0     ;キャリーをリセット, cpslより速いし小さい

    ppsl WC  ;WCをセット. シフトでのキャリーをありにする

    ;r0:r2(をシフトしたもの) にr3:0を足していく
    
    tmi,r1 00000001b
    bcfr,eq _m8_0    
    addz r3
_m8_0:
    rrr,r0      ;結果の上位byteの右シフト＆addzでのオーバーフローを最上位ビットへ取り込む
    rrr,r2      ;結果の下位byteの右シフト＆キャリーへの０セット

    tmi,r1 00000010b
    bcfr,eq _m8_1
    addz r3
_m8_1:
    rrr,r0
    rrr,r2

    tmi,r1 00000100b
    bcfr,eq _m8_2   
    addz r3
_m8_2:
    rrr,r0
    rrr,r2

    tmi,r1 00001000b
    bcfr,eq _m8_3
    addz r3
_m8_3:
    rrr,r0
    rrr,r2

    tmi,r1 00010000b
    bcfr,eq _m8_4    
    addz r3
_m8_4:
    rrr,r0
    rrr,r2

    tmi,r1 00100000b
    bcfr,eq _m8_5
    addz r3
_m8_5:
    rrr,r0
    rrr,r2

    tmi,r1 01000000b
    bcfr,eq _m8_6  
    addz r3
_m8_6:
    rrr,r0
    rrr,r2

    andi,r1 10000000b   ;tmiよりandiのが速い, 最後なのでr1が破壊されてもOK
    bcfr,lt _m8_7
    addz r3
_m8_7:
    rrr,r0
    rrr,r2

    ;r1:r0 = r0:r2
    strz r1
    lodz r2

    cpsl WC+C  ;WC（とついでにC)をリセット
    retc,un

end ; End of assembly
