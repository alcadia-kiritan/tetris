    name fcom          ; module name

    ;-------------------
    ;fneg
    ;[FStack+r2+0][FStack+r2+1] = -[FStack+r1+0][FStack+r1+1]
    ;r0,r1,r2を使用.  r1,r2は変化しない.
fneg:
    loda,r0 FStack+0,r1
    eori,r0 80h
    stra,r0 FStack+0,r2
    loda,r0 FStack+1,r1
    stra,r0 FStack+1,r2
    retc,un

    ;-------------------
    ;fneg2
    ;[FStack+r1+0][FStack+r1+1] = -[FStack+r1+0][FStack+r1+1]
    ;r0,r1を使用.  r1は変化しない.
fneg2:
    loda,r0 FStack+0,r1
    eori,r0 80h
    stra,r0 FStack+0,r1
    retc,un

end ; End of assembly
