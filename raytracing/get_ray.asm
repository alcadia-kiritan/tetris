    name get_ray          ; module name

    ;-------------------
    ;get_ray
    ;r1をVRAMのオフセットとみなして、その画素の位置へのレイをFStack+RayDirFStackOffset+0~5へ格納する
    ;r0,r1を使用
get_ray:
    lodz r1
    andi,r0 0f0h    ;r0 = Y座標
    andi,r1 00fh    ;r1 = X座標

    rrl,r1          ; 0~15 => 0~30

    comi,r1 16
    bcta,lt _gr_lt_x8
    ;x >= 8, x座標は符号反転する

    eori,r1 0ffh
    addi,r1 1+30       ; 16~30 => 14~0

    comi,r0 70h
    bctr,lt _gr_gt_x8_lt_y70
    ; y >= 70h

    eori,r0 0ffh    
    addi,r0 1h+0c0h      ;70h~C0h => 50h~00h
    addz r1    
    strz r1

    ;xを座標反転してコピー
    loda,r0 ray_vectors_x+0,r1
    eori,r0 80h
    stra,r0 FStack+RayDirFStackOffset+0-PAGE1
    loda,r0 ray_vectors_x+1,r1
    stra,r0 FStack+RayDirFStackOffset+1-PAGE1

    ;yを座標反転してコピー
    loda,r0 ray_vectors_y+0,r1
    eori,r0 80h
    stra,r0 FStack+RayDirFStackOffset+2-PAGE1
    loda,r0 ray_vectors_y+1,r1
    stra,r0 FStack+RayDirFStackOffset+3-PAGE1

    ;zをコピー
    loda,r0 ray_vectors_z+0,r1
    stra,r0 FStack+RayDirFStackOffset+4-PAGE1
    loda,r0 ray_vectors_z+1,r1
    stra,r0 FStack+RayDirFStackOffset+5-PAGE1

    retc,un

_gr_gt_x8_lt_y70:
    ; y < 70h
    addz r1
    strz r1

    ;xを座標反転してコピー
    loda,r0 ray_vectors_x+0,r1
    eori,r0 80h
    stra,r0 FStack+RayDirFStackOffset+0-PAGE1
    loda,r0 ray_vectors_x+1,r1
    stra,r0 FStack+RayDirFStackOffset+1-PAGE1

    ;y,zをコピー
    loda,r0 ray_vectors_y+0,r1
    stra,r0 FStack+RayDirFStackOffset+2-PAGE1
    loda,r0 ray_vectors_y+1,r1
    stra,r0 FStack+RayDirFStackOffset+3-PAGE1
    loda,r0 ray_vectors_z+0,r1
    stra,r0 FStack+RayDirFStackOffset+4-PAGE1
    loda,r0 ray_vectors_z+1,r1
    stra,r0 FStack+RayDirFStackOffset+5-PAGE1

    retc,un

_gr_lt_x8:
    ;x < 8

    comi,r0 70h
    bctr,lt _gr_lt_x8_lt_y70
    ; y >= 70h

    eori,r0 0ffh    
    addi,r0 1h+0c0h      ;70h~C0h => 50h~00h
    addz r1
    strz r1

    ;xをコピー
    loda,r0 ray_vectors_x+0,r1
    stra,r0 FStack+RayDirFStackOffset+0-PAGE1
    loda,r0 ray_vectors_x+1,r1
    stra,r0 FStack+RayDirFStackOffset+1-PAGE1

    ;yを座標反転してコピー
    loda,r0 ray_vectors_y+0,r1
    eori,r0 80h
    stra,r0 FStack+RayDirFStackOffset+2-PAGE1
    loda,r0 ray_vectors_y+1,r1
    stra,r0 FStack+RayDirFStackOffset+3-PAGE1

    ;zをコピー
    loda,r0 ray_vectors_z+0,r1
    stra,r0 FStack+RayDirFStackOffset+4-PAGE1
    loda,r0 ray_vectors_z+1,r1
    stra,r0 FStack+RayDirFStackOffset+5-PAGE1

    retc,un

_gr_lt_x8_lt_y70:
    ; y < 70h
    addz r1
    strz r1

    ;x,y,zをコピー
    loda,r0 ray_vectors_x+0,r1
    stra,r0 FStack+RayDirFStackOffset+0-PAGE1
    loda,r0 ray_vectors_x+1,r1
    stra,r0 FStack+RayDirFStackOffset+1-PAGE1
    loda,r0 ray_vectors_y+0,r1
    stra,r0 FStack+RayDirFStackOffset+2-PAGE1
    loda,r0 ray_vectors_y+1,r1
    stra,r0 FStack+RayDirFStackOffset+3-PAGE1
    loda,r0 ray_vectors_z+0,r1
    stra,r0 FStack+RayDirFStackOffset+4-PAGE1
    loda,r0 ray_vectors_z+1,r1
    stra,r0 FStack+RayDirFStackOffset+5-PAGE1

    retc,un


    ;画面左上を(0,0)、右下を(15,12)として
    ;-Zの方向から画角９０度で左上の４分の１の領域(0,0)-(7,0)-(0,6)-(7,6)を見たときの正規化されたレイを定義
ray_vectors_x:
    db 80h + EXPONENT_OFFSET + -1
    db 033h
    db 80h + EXPONENT_OFFSET + -1
    db 017h
    db 80h + EXPONENT_OFFSET + -2
    db 0EDh
    db 80h + EXPONENT_OFFSET + -2
    db 0A4h
    db 80h + EXPONENT_OFFSET + -2
    db 052h
    db 80h + EXPONENT_OFFSET + -3
    db 0F0h
    db 80h + EXPONENT_OFFSET + -3
    db 02Fh
    db 80h + EXPONENT_OFFSET + -5
    db 099h
    db 80h + EXPONENT_OFFSET + -1
    db 03Eh
    db 80h + EXPONENT_OFFSET + -1
    db 022h
    db 80h + EXPONENT_OFFSET + -1
    db 001h
    db 80h + EXPONENT_OFFSET + -2
    db 0B8h
    db 80h + EXPONENT_OFFSET + -2
    db 064h
    db 80h + EXPONENT_OFFSET + -2
    db 006h
    db 80h + EXPONENT_OFFSET + -3
    db 041h
    db 80h + EXPONENT_OFFSET + -5
    db 0B1h
    db 80h + EXPONENT_OFFSET + -1
    db 048h
    db 80h + EXPONENT_OFFSET + -1
    db 02Ch
    db 80h + EXPONENT_OFFSET + -1
    db 00Ch
    db 80h + EXPONENT_OFFSET + -2
    db 0CCh
    db 80h + EXPONENT_OFFSET + -2
    db 075h
    db 80h + EXPONENT_OFFSET + -2
    db 013h
    db 80h + EXPONENT_OFFSET + -3
    db 052h
    db 80h + EXPONENT_OFFSET + -5
    db 0C9h
    db 80h + EXPONENT_OFFSET + -1
    db 051h
    db 80h + EXPONENT_OFFSET + -1
    db 036h
    db 80h + EXPONENT_OFFSET + -1
    db 015h
    db 80h + EXPONENT_OFFSET + -2
    db 0DDh
    db 80h + EXPONENT_OFFSET + -2
    db 084h
    db 80h + EXPONENT_OFFSET + -2
    db 01Fh
    db 80h + EXPONENT_OFFSET + -3
    db 062h
    db 80h + EXPONENT_OFFSET + -5
    db 0DEh
    db 80h + EXPONENT_OFFSET + -1
    db 058h
    db 80h + EXPONENT_OFFSET + -1
    db 03Ch
    db 80h + EXPONENT_OFFSET + -1
    db 01Ch
    db 80h + EXPONENT_OFFSET + -2
    db 0EAh
    db 80h + EXPONENT_OFFSET + -2
    db 090h
    db 80h + EXPONENT_OFFSET + -2
    db 029h
    db 80h + EXPONENT_OFFSET + -3
    db 06Eh
    db 80h + EXPONENT_OFFSET + -5
    db 0EFh
    db 80h + EXPONENT_OFFSET + -1
    db 05Ch
    db 80h + EXPONENT_OFFSET + -1
    db 041h
    db 80h + EXPONENT_OFFSET + -1
    db 020h
    db 80h + EXPONENT_OFFSET + -2
    db 0F3h
    db 80h + EXPONENT_OFFSET + -2
    db 097h
    db 80h + EXPONENT_OFFSET + -2
    db 02Fh
    db 80h + EXPONENT_OFFSET + -3
    db 076h
    db 80h + EXPONENT_OFFSET + -5
    db 0FBh
    db 80h + EXPONENT_OFFSET + -1
    db 05Eh
    db 80h + EXPONENT_OFFSET + -1
    db 042h
    db 80h + EXPONENT_OFFSET + -1
    db 022h
    db 80h + EXPONENT_OFFSET + -2
    db 0F6h
    db 80h + EXPONENT_OFFSET + -2
    db 09Ah
    db 80h + EXPONENT_OFFSET + -2
    db 031h
    db 80h + EXPONENT_OFFSET + -3
    db 079h
    db 80h + EXPONENT_OFFSET + -5
    db 0FFh
ray_vectors_y:
    db EXPONENT_OFFSET + -2
    db 0EBh
    db EXPONENT_OFFSET + -1
    db 001h
    db EXPONENT_OFFSET + -1
    db 00Dh
    db EXPONENT_OFFSET + -1
    db 018h
    db EXPONENT_OFFSET + -1
    db 021h
    db EXPONENT_OFFSET + -1
    db 02Ah
    db EXPONENT_OFFSET + -1
    db 02Fh
    db EXPONENT_OFFSET + -1
    db 032h
    db EXPONENT_OFFSET + -2
    db 0A8h
    db EXPONENT_OFFSET + -2
    db 0BEh
    db EXPONENT_OFFSET + -2
    db 0D4h
    db EXPONENT_OFFSET + -2
    db 0E9h
    db EXPONENT_OFFSET + -2
    db 0FCh
    db EXPONENT_OFFSET + -1
    db 006h
    db EXPONENT_OFFSET + -1
    db 00Bh
    db EXPONENT_OFFSET + -1
    db 00Eh
    db EXPONENT_OFFSET + -2
    db 05Eh
    db EXPONENT_OFFSET + -2
    db 072h
    db EXPONENT_OFFSET + -2
    db 086h
    db EXPONENT_OFFSET + -2
    db 099h
    db EXPONENT_OFFSET + -2
    db 0AAh
    db EXPONENT_OFFSET + -2
    db 0B9h
    db EXPONENT_OFFSET + -2
    db 0C3h
    db EXPONENT_OFFSET + -2
    db 0C9h
    db EXPONENT_OFFSET + -2
    db 00Eh
    db EXPONENT_OFFSET + -2
    db 01Eh
    db EXPONENT_OFFSET + -2
    db 02Eh
    db EXPONENT_OFFSET + -2
    db 03Eh
    db EXPONENT_OFFSET + -2
    db 04Ch
    db EXPONENT_OFFSET + -2
    db 059h
    db EXPONENT_OFFSET + -2
    db 062h
    db EXPONENT_OFFSET + -2
    db 066h
    db EXPONENT_OFFSET + -3
    db 06Fh
    db EXPONENT_OFFSET + -3
    db 086h
    db EXPONENT_OFFSET + -3
    db 09Dh
    db EXPONENT_OFFSET + -3
    db 0B4h
    db EXPONENT_OFFSET + -3
    db 0C9h
    db EXPONENT_OFFSET + -3
    db 0DBh
    db EXPONENT_OFFSET + -3
    db 0E8h
    db EXPONENT_OFFSET + -3
    db 0EFh
    db EXPONENT_OFFSET + -4
    db 073h
    db EXPONENT_OFFSET + -4
    db 08Bh
    db EXPONENT_OFFSET + -4
    db 0A3h
    db EXPONENT_OFFSET + -4
    db 0BBh
    db EXPONENT_OFFSET + -4
    db 0D2h
    db EXPONENT_OFFSET + -4
    db 0E5h
    db EXPONENT_OFFSET + -4
    db 0F3h
    db EXPONENT_OFFSET + -4
    db 0FBh
    db 0
    db 000h
    db 0
    db 000h
    db 0
    db 000h
    db 0
    db 000h
    db 0
    db 000h
    db 0
    db 000h
    db 0
    db 000h
    db 0
    db 000h
ray_vectors_z:
    db EXPONENT_OFFSET + -1
    db 047h
    db EXPONENT_OFFSET + -1
    db 057h
    db EXPONENT_OFFSET + -1
    db 066h
    db EXPONENT_OFFSET + -1
    db 075h
    db EXPONENT_OFFSET + -1
    db 082h
    db EXPONENT_OFFSET + -1
    db 08Dh
    db EXPONENT_OFFSET + -1
    db 095h
    db EXPONENT_OFFSET + -1
    db 099h
    db EXPONENT_OFFSET + -1
    db 053h
    db EXPONENT_OFFSET + -1
    db 065h
    db EXPONENT_OFFSET + -1
    db 077h
    db EXPONENT_OFFSET + -1
    db 087h
    db EXPONENT_OFFSET + -1
    db 097h
    db EXPONENT_OFFSET + -1
    db 0A3h
    db EXPONENT_OFFSET + -1
    db 0ACh
    db EXPONENT_OFFSET + -1
    db 0B1h
    db EXPONENT_OFFSET + -1
    db 05Eh
    db EXPONENT_OFFSET + -1
    db 072h
    db EXPONENT_OFFSET + -1
    db 086h
    db EXPONENT_OFFSET + -1
    db 099h
    db EXPONENT_OFFSET + -1
    db 0AAh
    db EXPONENT_OFFSET + -1
    db 0B9h
    db EXPONENT_OFFSET + -1
    db 0C3h
    db EXPONENT_OFFSET + -1
    db 0C9h
    db EXPONENT_OFFSET + -1
    db 068h
    db EXPONENT_OFFSET + -1
    db 07Dh
    db EXPONENT_OFFSET + -1
    db 093h
    db EXPONENT_OFFSET + -1
    db 0A8h
    db EXPONENT_OFFSET + -1
    db 0BBh
    db EXPONENT_OFFSET + -1
    db 0CCh
    db EXPONENT_OFFSET + -1
    db 0D8h
    db EXPONENT_OFFSET + -1
    db 0DEh
    db EXPONENT_OFFSET + -1
    db 06Fh
    db EXPONENT_OFFSET + -1
    db 086h
    db EXPONENT_OFFSET + -1
    db 09Dh
    db EXPONENT_OFFSET + -1
    db 0B4h
    db EXPONENT_OFFSET + -1
    db 0C9h
    db EXPONENT_OFFSET + -1
    db 0DBh
    db EXPONENT_OFFSET + -1
    db 0E8h
    db EXPONENT_OFFSET + -1
    db 0EFh
    db EXPONENT_OFFSET + -1
    db 073h
    db EXPONENT_OFFSET + -1
    db 08Bh
    db EXPONENT_OFFSET + -1
    db 0A3h
    db EXPONENT_OFFSET + -1
    db 0BBh
    db EXPONENT_OFFSET + -1
    db 0D2h
    db EXPONENT_OFFSET + -1
    db 0E5h
    db EXPONENT_OFFSET + -1
    db 0F3h
    db EXPONENT_OFFSET + -1
    db 0FBh
    db EXPONENT_OFFSET + -1
    db 075h
    db EXPONENT_OFFSET + -1
    db 08Dh
    db EXPONENT_OFFSET + -1
    db 0A5h
    db EXPONENT_OFFSET + -1
    db 0BEh
    db EXPONENT_OFFSET + -1
    db 0D5h
    db EXPONENT_OFFSET + -1
    db 0E8h
    db EXPONENT_OFFSET + -1
    db 0F7h
    db EXPONENT_OFFSET + -1
    db 0FFh

end ; End of assembly
