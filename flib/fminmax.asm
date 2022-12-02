    name fminmax          ; module name

    ;最大値
    MAX_FLOAT0  equ     127
    MAX_FLOAT1  equ     255

    ;最小値(有効な数のうちマイナスかつ絶対値が最も大きい数値)
    MIN_FLOAT0  equ     80h + MAX_FLOAT0
    MIN_FLOAT1  equ     MAX_FLOAT1

    ;-------------------
    ;fmin
    ;[FStack+r3+0][FStack+r3+1] = min( [FStack+r1+0][FStack+r1+1], [FStack+r2+0][FStack+r2+1] )
    ;r0,r1,r2,r3,Temporary0を使用.  r1,r2,r3は変化しない.
fmin:
    stra,r3 Temporary0P1
    bsta,un fcom
    bctr,lt _fmin_r1

    loda,r3 Temporary0P1
    loda,r0 FStack+0,r2
    stra,r0 FStack+0,r3
    loda,r0 FStack+1,r2
    stra,r0 FStack+1,r3
    retc,un

_fmin_r1:
    loda,r3 Temporary0P1
    loda,r0 FStack+0,r1
    stra,r0 FStack+0,r3
    loda,r0 FStack+1,r1
    stra,r0 FStack+1,r3
    retc,un
    
    ;-------------------
    ;fmax
    ;[FStack+r3+0][FStack+r3+1] = max( [FStack+r1+0][FStack+r1+1], [FStack+r2+0][FStack+r2+1] )
    ;r0,r1,r2,r3,Temporary0を使用.  r1,r2,r3は変化しない.
fmax:
    stra,r3 Temporary0P1
    bsta,un fcom
    bctr,gt _fmax_r1

    loda,r3 Temporary0P1
    loda,r0 FStack+0,r2
    stra,r0 FStack+0,r3
    loda,r0 FStack+1,r2
    stra,r0 FStack+1,r3
    retc,un

_fmax_r1:
    loda,r3 Temporary0P1
    loda,r0 FStack+0,r1
    stra,r0 FStack+0,r3
    loda,r0 FStack+1,r1
    stra,r0 FStack+1,r3
    retc,un

end ; End of assembly
