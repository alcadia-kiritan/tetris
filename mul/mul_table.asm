    name Mul8          ; module name

    ;-------------------
    ;mul8
    ;r0*r1をr1:r0に格納する
    ;r0,r1,r2,r3,Temporary0,Temporary1を使用
mul8:

    ;r0 = a*2^4 + b
    ;r1 = c*2^4 + d
    
    stra,r0 Temporary0
    stra,r1 Temporary1
    andi,r0 0f0h
    andi,r1 00fh
    addz r1
    loda,r0 mul_4x4,r0
    strz r2                 ;r2 = a*d

    loda,r0 Temporary0
    loda,r1 Temporary1
    andi,r0 00fh
    andi,r1 0f0h
    addz r1
    loda,r0 mul_4x4,r0
    addz r2                 ;r0 = a*d + b*c    C = a*d+b*c > 255
    rrr,r0 
    rrr,r0 
    rrr,r0 
    rrr,r0 
    strz r2                 ;r2 = ((a*d+b*c) << 4) | ((a*d+b*c) >> 4)
    strz r3                 ;r3 = r2

    andi,r2 0f0h
    andi,r3 00fh

    ; Cの値に応じてr3にキャリーを足しておく
    tpsl 01b
    bcfr,eq _m8_not_of
    addi,r3 010h            
_m8_not_of:

    loda,r0 Temporary0
    rrr,r0
    rrr,r0
    rrr,r0
    rrr,r0
    stra,r0 Temporary0      ;r0 = Temporary0 = b*2^4 + a

    ;下位byteの計算
    andi,r0 0f0h
    loda,r1 Temporary1
    andi,r1 00fh
    addz r1
    loda,r0 mul_4x4,r0      ; b*d
    addz r2                 
    strz r2                 ; r2 = b*d + ((a*d+b*c)<<4)

    tpsl 01b
    bcfr,eq _m8_not_of2
    addi,r3 1
_m8_not_of2:

    ;上位byteの計算
    loda,r0 Temporary0
    loda,r1 Temporary1
    andi,r0 00fh
    andi,r1 0f0h
    addz r1
    loda,r0 mul_4x4,r0      ; a*c
    addz r3                 ; r0 = a*c + ((a*d+b*c)>>4)
    
    strz r1
    lodz r2

    retc,un

mul_4x4:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
    db 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30
    db 0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45
    db 0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60
    db 0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75
    db 0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90
    db 0,7,14,21,28,35,42,49,56,63,70,77,84,91,98,105
    db 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120
    db 0,9,18,27,36,45,54,63,72,81,90,99,108,117,126,135
    db 0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150
    db 0,11,22,33,44,55,66,77,88,99,110,121,132,143,154,165
    db 0,12,24,36,48,60,72,84,96,108,120,132,144,156,168,180
    db 0,13,26,39,52,65,78,91,104,117,130,143,156,169,182,195
    db 0,14,28,42,56,70,84,98,112,126,140,154,168,182,196,210
    db 0,15,30,45,60,75,90,105,120,135,150,165,180,195,210,225

end ; End of assembly
