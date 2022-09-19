;mod2~7を定義しているファイル
;mod2,mod4,mod7を除き、COM=1前提なことに注意

    ;-------------------
    ;mod2
    ;r0%2をr0に入れて返す
    ;r0を使用
mod2:
    andi,r0 1
    retc,un

    ;-------------------
    ;mod3
    ;r0%3をr0に入れて返す
    ;r0を使用
mod3:
    comi,r0 43*3
    bctr,lt _mod3_skip43
    subi,r0 43*3
_mod3_skip43:
    comi,r0 22*3
    bctr,lt _mod3_skip22
    subi,r0 22*3
_mod3_skip22:
    comi,r0 11*3
    bctr,lt _mod3_skip11
    subi,r0 11*3
_mod3_skip11:
    comi,r0 6*3
    bctr,lt _mod3_skip6
    subi,r0 6*3
_mod3_skip6:
    loda,r0 mod3_table_19,r0
    retc,un

mod3_table_19:
    db 0
    db 1
    db 2
    db 0
    db 1
    db 2
    db 0
    db 1
    db 2
    db 0
    db 1
    db 2
    db 0
    db 1
    db 2
    db 0
    db 1
    db 2
    db 0

    ;-------------------
    ;mod4
    ;r0%4をr0に入れて返す
    ;r0を使用
mod4:
    andi,r0 3
    retc,un

    ;-------------------
    ;mod5
    ;r0%5をr0に入れて返す
    ;r0を使用
mod5:
    comi,r0 32*5
    bctr,lt _mod5_skip32
    subi,r0 32*5
_mod5_skip32:
    comi,r0 16*5
    bctr,lt _mod5_skip16
    subi,r0 16*5
_mod5_skip16:
    comi,r0 8*5
    bctr,lt _mod5_skip8
    subi,r0 8*5
_mod5_skip8:
    comi,r0 4*5
    bctr,lt _mod5_skip4
    subi,r0 4*5
_mod5_skip4:
    loda,r0 mod5_table20,r0
    retc,un

mod5_table20:
    db 0
    db 1
    db 2
    db 3
    db 4
    db 0
    db 1
    db 2
    db 3
    db 4
    db 0
    db 1
    db 2
    db 3
    db 4
    db 0
    db 1
    db 2
    db 3
    db 4

    ;-------------------
    ;mod6
    ;r0%6をr0に入れて返す
    ;r0を使用
mod6:
    comi,r0 22*6
    bctr,lt _mod6_skip22
    subi,r0 22*6
_mod6_skip22:
    comi,r0 11*6
    bctr,lt _mod6_skip11
    subi,r0 11*6
_mod6_skip11:
    comi,r0 6*6
    bctr,lt _mod6_skip6
    subi,r0 6*6
_mod6_skip6:
    comi,r0 3*6
    bctr,lt _mod6_skip3
    subi,r0 3*6
_mod6_skip3:
    loda,r0 mod6_table_19,r0
    retc,un

mod6_table_19:
    db 0
    db 1
    db 2
    db 3
    db 4
    db 5
    db 0
    db 1
    db 2
    db 3
    db 4
    db 5
    db 0
    db 1
    db 2
    db 3
    db 4
    db 5
    db 0

    ;-------------------
    ;mod7
    ;r0%7をr0に入れて返す
    ;r0,r1を使用
mod7:
    strz r1     ; r1 = r0 & 7
    andi,r1 7
    rrr,r0      ; r0 >>= 3
    rrr,r0
    rrr,r0
    andi,r0 01Fh    
    addz r1     ; r0 += r1
    comi,r0 21  ; if( r0 >= 21 ) r0 -= 21
    bctr,lt _mod7
    subi,r0 21
_mod7:
    loda,r0 mod7_table21,r0 ; 21 = max(39 - 21, 21)
    retc,un

mod7_table21:
    db 00h
    db 01h
    db 02h
    db 03h
    db 04h
    db 05h
    db 06h
    db 00h
    db 01h
    db 02h
    db 03h
    db 04h
    db 05h
    db 06h
    db 00h
    db 01h
    db 02h
    db 03h
    db 04h
    db 05h
    db 06h

end
