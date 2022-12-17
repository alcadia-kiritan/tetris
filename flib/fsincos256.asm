    name fsincos256          ; module name

    ;-------------------
    ;fsin256
    ;sin(r0/256*2PI)を[FStack+r1+0][FStack+r1+1]へ書き込む.
    ;r0,r1,r2を使用.  r1は変化しない.
fsin256:
    subi,r0 64
    ;cosに流す

    ;-------------------
    ;fcos256
    ;cos(r0/256*2PI)を[FStack+r1+0][FStack+r1+1]へ書き込む.
    ;r0,r1,r2を使用.  r1は変化しない.
fcos256:
    iorz r0     ;r0を比較
    bcfr,lt _fc_gt
    ; 128 <= r0     -1~0~1

    comi,r0 191
    bctr,gt _fc_gt191

    ; 128 <= r0 <= 191
    subi,r0 128
    strz r2
    loda,r0 _fcos64_table_lo,r2
    stra,r0 FStack+1,r1
    loda,r0 _fcos64_table_hi,r2
    addi,r0 80h
    stra,r0 FStack+0,r1
    retc,un

_fc_gt191:
    ; 192 <= r0 <= 255
    eori,r0 255                 ; 63 >= r0 >= 0
    addi,r0 1                   ; 64 >= r0 >= 1
    strz r2
    loda,r0 _fcos64_table_lo,r2
    stra,r0 FStack+1,r1
    loda,r0 _fcos64_table_hi,r2
    stra,r0 FStack+0,r1
    retc,un

_fc_gt:
    ; r0 < 128      1~0~-1
    comi,r0 63
    bctr,gt _fc_gt_63

_fc_lt_64:
    ; 0 <= r0 <= 63
    strz r2
    loda,r0 _fcos64_table_lo,r2
    stra,r0 FStack+1,r1
    loda,r0 _fcos64_table_hi,r2
    stra,r0 FStack+0,r1
    retc,un

_fc_gt_63:
    ; 64 <= r0 < 128   0~-1
    eori,r0 127                 ; 63 >= r0 >= 0
    addi,r0 1                   ; 64 >= r0 >= 1
    strz r2
    loda,r0 _fcos64_table_lo,r2
    stra,r0 FStack+1,r1
    loda,r0 _fcos64_table_hi,r2
    addi,r0 80h
    stra,r0 FStack+0,r1
    retc,un
    
_fcos64_table_hi:
    db EXPONENT_OFFSET + 0
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -5
    db EXPONENT_OFFSET + -6
    db 0

_fcos64_table_lo:
    db 000h
    db 0FFh
    db 0FFh
    db 0FEh
    db 0FDh
    db 0FCh
    db 0FAh
    db 0F8h
    db 0F6h
    db 0F3h
    db 0F0h
    db 0EDh
    db 0E9h
    db 0E6h
    db 0E2h
    db 0DDh
    db 0D9h
    db 0D4h
    db 0CEh
    db 0C9h
    db 0C3h
    db 0BDh
    db 0B7h
    db 0B0h
    db 0A9h
    db 0A2h
    db 09Bh
    db 093h
    db 08Bh
    db 083h
    db 07Bh
    db 072h
    db 06Ah
    db 061h
    db 057h
    db 04Eh
    db 044h
    db 03Ah
    db 030h
    db 026h
    db 01Ch
    db 011h
    db 007h
    db 0F8h
    db 0E2h
    db 0CCh
    db 0B5h
    db 09Eh
    db 087h
    db 070h
    db 058h
    db 041h
    db 029h
    db 011h
    db 0F1h
    db 0C0h
    db 08Fh
    db 05Eh
    db 02Ch
    db 0F5h
    db 091h
    db 02Dh
    db 091h
    db 092h
    db 0

end ; End of assembly
