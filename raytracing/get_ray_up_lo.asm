    name get_ray_up_lo          ; module name

    ;-------------------
    ;get_ray_up
    ;r1を上画面VRAMのオフセットとみなして、その画素の位置へのレイをFStack+RayDirFStackOffset+0~5へ格納する
    ;r0,r1を使用
get_ray_up:
    lodz r1
    andi,r0 0f0h    ;r0 = Y座標
    andi,r1 00fh    ;r1 = X座標

    rrr,r0  ;Xの列数が8なのでYを右シフト

    comi,r1 8
    bctr,lt _gru_lt_x8
    ;x >= 8, x座標は符号反転する

    eori,r1 0ffh       ; 8~15 => -9~-16
    addi,r1 1+15       ; -9~-16 => 7~0

    addz r1
    strz r1

    ;xを座標反転してコピー
    loda,r0 ray_vectors_x_hi,r1
    eori,r0 80h
    stra,r0 FStack+RayDirFStackOffset+0-PAGE1
    loda,r0 ray_vectors_x_lo,r1
    stra,r0 FStack+RayDirFStackOffset+1-PAGE1

    ;yをコピー
    loda,r0 ray_vectors_y_hi,r1
    stra,r0 FStack+RayDirFStackOffset+2-PAGE1
    loda,r0 ray_vectors_y_lo,r1
    stra,r0 FStack+RayDirFStackOffset+3-PAGE1

    ;zをコピー
    loda,r0 ray_vectors_z_hi,r1
    stra,r0 FStack+RayDirFStackOffset+4-PAGE1
    loda,r0 ray_vectors_z_lo,r1
    stra,r0 FStack+RayDirFStackOffset+5-PAGE1

    retc,un

_gru_lt_x8:
    ;x < 8

    addz r1
    strz r1

    ;xをコピー
    loda,r0 ray_vectors_x_hi,r1
    stra,r0 FStack+RayDirFStackOffset+0-PAGE1
    loda,r0 ray_vectors_x_lo,r1
    stra,r0 FStack+RayDirFStackOffset+1-PAGE1

    ;yをコピー
    loda,r0 ray_vectors_y_hi,r1
    stra,r0 FStack+RayDirFStackOffset+2-PAGE1
    loda,r0 ray_vectors_y_lo,r1
    stra,r0 FStack+RayDirFStackOffset+3-PAGE1

    ;zをコピー
    loda,r0 ray_vectors_z_hi,r1
    stra,r0 FStack+RayDirFStackOffset+4-PAGE1
    loda,r0 ray_vectors_z_lo,r1
    stra,r0 FStack+RayDirFStackOffset+5-PAGE1

    retc,un


    ;-------------------
    ;get_ray_lo
    ;r1を下画面VRAMのオフセットとみなして、その画素の位置へのレイをFStack+RayDirFStackOffset+0~5へ格納する
    ;r0,r1を使用
get_ray_lo:
    lodz r1
    andi,r0 0f0h    ;r0 = Y座標
    andi,r1 00fh    ;r1 = X座標

    eori,r0 0ffh        ; 0~192 -> -1~-193
    addi,r0 1+192          ;-1~-193 -> 192~0
    rrr,r0  ;Xの列数が8なのでYを右シフト    (0~12)*16 -> (0~12)*8

    comi,r1 8
    bctr,lt _grl_lt_x8
    ;x >= 8, x座標は符号反転する

    eori,r1 0ffh       ; 8~15 => -9~-16
    addi,r1 1+15       ; -9~-16 => 7~0

    addz r1
    strz r1

    ;xを符号反転してコピー
    loda,r0 ray_vectors_x_hi,r1
    eori,r0 80h
    stra,r0 FStack+RayDirFStackOffset+0-PAGE1
    loda,r0 ray_vectors_x_lo,r1
    stra,r0 FStack+RayDirFStackOffset+1-PAGE1

    ;yを符号反転してコピー
    loda,r0 ray_vectors_y_hi,r1
    eori,r0 80h
    stra,r0 FStack+RayDirFStackOffset+2-PAGE1
    loda,r0 ray_vectors_y_lo,r1
    stra,r0 FStack+RayDirFStackOffset+3-PAGE1

    ;zをコピー
    loda,r0 ray_vectors_z_hi,r1
    stra,r0 FStack+RayDirFStackOffset+4-PAGE1
    loda,r0 ray_vectors_z_lo,r1
    stra,r0 FStack+RayDirFStackOffset+5-PAGE1

    retc,un

_grl_lt_x8:
    ;x < 8

    addz r1
    strz r1

    ;xをコピー
    loda,r0 ray_vectors_x_hi,r1
    stra,r0 FStack+RayDirFStackOffset+0-PAGE1
    loda,r0 ray_vectors_x_lo,r1
    stra,r0 FStack+RayDirFStackOffset+1-PAGE1

    ;yを符号反転してコピー
    loda,r0 ray_vectors_y_hi,r1
    eori,r0 80h
    stra,r0 FStack+RayDirFStackOffset+2-PAGE1
    loda,r0 ray_vectors_y_lo,r1
    stra,r0 FStack+RayDirFStackOffset+3-PAGE1

    ;zをコピー
    loda,r0 ray_vectors_z_hi,r1
    stra,r0 FStack+RayDirFStackOffset+4-PAGE1
    loda,r0 ray_vectors_z_lo,r1
    stra,r0 FStack+RayDirFStackOffset+5-PAGE1

    retc,un

    ;画面左上を(0,0)、右下を(15,24)として
    ;-Zの方向から画角９０度で左上の４分の１の領域(0,0)-(7,0)-(0,12)-(7,12)を見たときの正規化されたレイを定義
ray_vectors_x_hi:
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -1
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -2
    db 80h + EXPONENT_OFFSET + -3
    db 80h + EXPONENT_OFFSET + -5
ray_vectors_x_lo:
    db 030h
    db 014h
    db 0E7h
    db 09Eh
    db 04Dh
    db 0E9h
    db 02Bh
    db 092h
    db 036h
    db 019h
    db 0F3h
    db 0A9h
    db 056h
    db 0F7h
    db 034h
    db 09Fh
    db 03Bh
    db 01Fh
    db 0FEh
    db 0B3h
    db 05Fh
    db 002h
    db 03Dh
    db 0ABh
    db 041h
    db 025h
    db 004h
    db 0BDh
    db 068h
    db 009h
    db 045h
    db 0B7h
    db 046h
    db 02Ah
    db 009h
    db 0C7h
    db 071h
    db 010h
    db 04Eh
    db 0C3h
    db 04Bh
    db 02Fh
    db 00Eh
    db 0D0h
    db 079h
    db 016h
    db 056h
    db 0CEh
    db 04Fh
    db 033h
    db 013h
    db 0D9h
    db 080h
    db 01Ch
    db 05Eh
    db 0D9h
    db 053h
    db 037h
    db 017h
    db 0E0h
    db 087h
    db 022h
    db 065h
    db 0E3h
    db 057h
    db 03Bh
    db 01Ah
    db 0E7h
    db 08Dh
    db 026h
    db 06Bh
    db 0EBh
    db 059h
    db 03Eh
    db 01Dh
    db 0EDh
    db 092h
    db 02Ah
    db 070h
    db 0F3h
    db 05Bh
    db 040h
    db 01Fh
    db 0F1h
    db 096h
    db 02Eh
    db 075h
    db 0F8h
    db 05Dh
    db 042h
    db 021h
    db 0F4h
    db 098h
    db 030h
    db 077h
    db 0FCh
    db 05Eh
    db 042h
    db 021h
    db 0F5h
    db 09Ah
    db 031h
    db 079h
    db 0FEh
ray_vectors_y_hi:
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -1
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
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
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -3
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
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -2
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -3
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -4
    db EXPONENT_OFFSET + -6
    db EXPONENT_OFFSET + -6
    db EXPONENT_OFFSET + -6
    db EXPONENT_OFFSET + -6
    db EXPONENT_OFFSET + -6
    db EXPONENT_OFFSET + -6
    db EXPONENT_OFFSET + -6
    db EXPONENT_OFFSET + -6
ray_vectors_y_lo:
    db 0FBh
    db 009h
    db 015h
    db 020h
    db 029h
    db 032h
    db 037h
    db 03Ah
    db 0DBh
    db 0F2h
    db 004h
    db 00Fh
    db 019h
    db 021h
    db 027h
    db 02Ah
    db 0BAh
    db 0D0h
    db 0E7h
    db 0FCh
    db 007h
    db 00Fh
    db 015h
    db 018h
    db 097h
    db 0ACh
    db 0C2h
    db 0D6h
    db 0E9h
    db 0F8h
    db 002h
    db 005h
    db 072h
    db 086h
    db 09Ah
    db 0AEh
    db 0C0h
    db 0CFh
    db 0D9h
    db 0DFh
    db 04Bh
    db 05Eh
    db 070h
    db 083h
    db 094h
    db 0A2h
    db 0ACh
    db 0B1h
    db 022h
    db 033h
    db 045h
    db 055h
    db 065h
    db 072h
    db 07Bh
    db 080h
    db 0F2h
    db 007h
    db 017h
    db 025h
    db 033h
    db 03Fh
    db 047h
    db 04Ch
    db 09Bh
    db 0B4h
    db 0CEh
    db 0E7h
    db 0FFh
    db 009h
    db 010h
    db 014h
    db 042h
    db 056h
    db 06Bh
    db 07Fh
    db 092h
    db 0A2h
    db 0AEh
    db 0B4h
    db 0CFh
    db 0EDh
    db 005h
    db 014h
    db 022h
    db 02Eh
    db 036h
    db 03Bh
    db 017h
    db 029h
    db 03Bh
    db 04Dh
    db 05Eh
    db 06Dh
    db 077h
    db 07Dh
    db 075h
    db 08Dh
    db 0A5h
    db 0BEh
    db 0D4h
    db 0E8h
    db 0F6h
    db 0FEh
ray_vectors_z_hi:
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
ray_vectors_z_lo:
    db 044h
    db 053h
    db 062h
    db 070h
    db 07Dh
    db 087h
    db 08Fh
    db 092h
    db 04Ah
    db 05Bh
    db 06Bh
    db 07Ah
    db 087h
    db 092h
    db 09Bh
    db 09Fh
    db 050h
    db 062h
    db 073h
    db 083h
    db 092h
    db 09Eh
    db 0A6h
    db 0ABh
    db 056h
    db 068h
    db 07Ah
    db 08Ch
    db 09Ch
    db 0A9h
    db 0B2h
    db 0B7h
    db 05Ch
    db 06Fh
    db 082h
    db 094h
    db 0A5h
    db 0B3h
    db 0BEh
    db 0C3h
    db 061h
    db 075h
    db 089h
    db 09Dh
    db 0AFh
    db 0BEh
    db 0C9h
    db 0CEh
    db 066h
    db 07Ah
    db 090h
    db 0A4h
    db 0B7h
    db 0C7h
    db 0D3h
    db 0D9h
    db 06Ah
    db 07Fh
    db 095h
    db 0ABh
    db 0BFh
    db 0D0h
    db 0DCh
    db 0E3h
    db 06Dh
    db 084h
    db 09Bh
    db 0B1h
    db 0C6h
    db 0D7h
    db 0E5h
    db 0EBh
    db 070h
    db 087h
    db 09Fh
    db 0B6h
    db 0CBh
    db 0DEh
    db 0EBh
    db 0F3h
    db 073h
    db 08Ah
    db 0A2h
    db 0BAh
    db 0D0h
    db 0E3h
    db 0F1h
    db 0F8h
    db 074h
    db 08Ch
    db 0A4h
    db 0BCh
    db 0D3h
    db 0E6h
    db 0F5h
    db 0FCh
    db 075h
    db 08Dh
    db 0A5h
    db 0BEh
    db 0D4h
    db 0E8h
    db 0F6h
    db 0FEh

end ; End of assembly
