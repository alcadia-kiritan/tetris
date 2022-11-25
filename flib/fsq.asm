    name fsq          ; module name

    ;-------
    ;[FStack+r2+0][FStack+r2+1]へ0を書き込んで返す
_fsq_zero:
    eorz r0
    stra,r0 FStack+0,r2
    stra,r0 FStack+1,r2
    retc,un

    ;-------------------
    ;fsq
    ;[FStack+r2+0][FStack+r2+1] = [FStack+r1+0][FStack+r1+1] * [FStack+r1+0][FStack+r1+1]
    ;r0,r1,r2を使用.  r1,r2は変化しない.
fsq:
    loda,r0 FStack+1,r1
    comi,r0 107
    bctr,lt _fsq_lt107

    ;仮数部が107以上, 指数が*2に加え+1される
    loda,r0 sq_table,r0
    stra,r0 FStack+1,r2     ;仮数部保存
    
    loda,r0 FStack+0,r1
    addz r0
    bctr,eq _fsq_zero
    subi,r0 EXPONENT_OFFSET-1
    bsfa,gt fexception      ;指数部がオーバーフロー

    stra,r0 FStack+0,r2     ;指数部保存
    retc,un
    
_fsq_lt107:
    ;仮数部が107未満, 指数が*2

    loda,r0 sq_table,r0
    stra,r0 FStack+1,r2     ;仮数部保存
    
    loda,r0 FStack+0,r1
    addz r0
    bctr,eq _fsq_zero
    subi,r0 EXPONENT_OFFSET
    bsfa,gt fexception      ;指数部がオーバーフロー

    stra,r0 FStack+0,r2     ;指数部保存
    retc,un

sq_table:
    db 000h
    db 002h
    db 004h
    db 006h
    db 008h
    db 00Ah
    db 00Ch
    db 00Eh
    db 010h
    db 012h
    db 014h
    db 016h
    db 018h
    db 01Ah
    db 01Ch
    db 01Eh
    db 021h
    db 023h
    db 025h
    db 027h
    db 029h
    db 02Bh
    db 02Dh
    db 030h
    db 032h
    db 034h
    db 036h
    db 038h
    db 03Bh
    db 03Dh
    db 03Fh
    db 041h
    db 044h
    db 046h
    db 048h
    db 04Ah
    db 04Dh
    db 04Fh
    db 051h
    db 053h
    db 056h
    db 058h
    db 05Ah
    db 05Dh
    db 05Fh
    db 061h
    db 064h
    db 066h
    db 069h
    db 06Bh
    db 06Dh
    db 070h
    db 072h
    db 074h
    db 077h
    db 079h
    db 07Ch
    db 07Eh
    db 081h
    db 083h
    db 086h
    db 088h
    db 08Bh
    db 08Dh
    db 090h
    db 092h
    db 095h
    db 097h
    db 09Ah
    db 09Ch
    db 09Fh
    db 0A1h
    db 0A4h
    db 0A6h
    db 0A9h
    db 0ABh
    db 0AEh
    db 0B1h
    db 0B3h
    db 0B6h
    db 0B9h
    db 0BBh
    db 0BEh
    db 0C0h
    db 0C3h
    db 0C6h
    db 0C8h
    db 0CBh
    db 0CEh
    db 0D0h
    db 0D3h
    db 0D6h
    db 0D9h
    db 0DBh
    db 0DEh
    db 0E1h
    db 0E4h
    db 0E6h
    db 0E9h
    db 0ECh
    db 0EFh
    db 0F1h
    db 0F4h
    db 0F7h
    db 0FAh
    db 0FDh
    db 0FFh
    db 001h
    db 002h
    db 004h
    db 005h
    db 007h
    db 008h
    db 009h
    db 00Bh
    db 00Ch
    db 00Eh
    db 00Fh
    db 011h
    db 012h
    db 014h
    db 015h
    db 017h
    db 018h
    db 01Ah
    db 01Bh
    db 01Dh
    db 01Eh
    db 020h
    db 021h
    db 023h
    db 024h
    db 026h
    db 027h
    db 029h
    db 02Ah
    db 02Ch
    db 02Dh
    db 02Fh
    db 030h
    db 032h
    db 033h
    db 035h
    db 036h
    db 038h
    db 03Ah
    db 03Bh
    db 03Dh
    db 03Eh
    db 040h
    db 041h
    db 043h
    db 045h
    db 046h
    db 048h
    db 049h
    db 04Bh
    db 04Dh
    db 04Eh
    db 050h
    db 052h
    db 053h
    db 055h
    db 056h
    db 058h
    db 05Ah
    db 05Bh
    db 05Dh
    db 05Fh
    db 060h
    db 062h
    db 064h
    db 065h
    db 067h
    db 069h
    db 06Ah
    db 06Ch
    db 06Eh
    db 06Fh
    db 071h
    db 073h
    db 074h
    db 076h
    db 078h
    db 07Ah
    db 07Bh
    db 07Dh
    db 07Fh
    db 081h
    db 082h
    db 084h
    db 086h
    db 088h
    db 089h
    db 08Bh
    db 08Dh
    db 08Fh
    db 090h
    db 092h
    db 094h
    db 096h
    db 097h
    db 099h
    db 09Bh
    db 09Dh
    db 09Fh
    db 0A0h
    db 0A2h
    db 0A4h
    db 0A6h
    db 0A8h
    db 0A9h
    db 0ABh
    db 0ADh
    db 0AFh
    db 0B1h
    db 0B3h
    db 0B4h
    db 0B6h
    db 0B8h
    db 0BAh
    db 0BCh
    db 0BEh
    db 0C0h
    db 0C2h
    db 0C3h
    db 0C5h
    db 0C7h
    db 0C9h
    db 0CBh
    db 0CDh
    db 0CFh
    db 0D1h
    db 0D3h
    db 0D4h
    db 0D6h
    db 0D8h
    db 0DAh
    db 0DCh
    db 0DEh
    db 0E0h
    db 0E2h
    db 0E4h
    db 0E6h
    db 0E8h
    db 0EAh
    db 0ECh
    db 0EEh
    db 0F0h
    db 0F2h
    db 0F4h
    db 0F6h
    db 0F8h
    db 0FAh
    db 0FCh
    db 0FEh

end ; End of assembly
