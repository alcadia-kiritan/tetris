    name mantissa_rshift          ; module name

    ;-------------------
    ;mantissa_rshift
    ;r0を仮数部とみなして(ケチ表現が9bit目にいる）r3(1~8)分右シフトした数をr0へ格納する
    ;r0,r3を使用. r0,r3は破壊される
    ;WC=0前提
mantissa_rshift:
    ;r3 = r3 * sizeof(bctr)
    rrl,r3
    bxa _mrs_table-2,r3

_mrs_table:
    bctr,un _mrs1
    bctr,un _mrs2
    bctr,un _mrs3
    bctr,un _mrs4
    bctr,un _mrs5
    bctr,un _mrs6
    bctr,un _mrs7
    bctr,un _mrs8

_mrs1:
    rrr,r0
    iori,r0 80h ;ケチ表現のビット
    retc,un

_mrs2:
    rrr,r0
    rrr,r0
    andi,r0 3fh
    iori,r0 40h ;ケチ表現のビット
    retc,un

_mrs3:
    rrr,r0
    rrr,r0
    rrr,r0
    andi,r0 1fh
    iori,r0 20h ;ケチ表現のビット
    retc,un

_mrs4:
    rrl,r0
    rrl,r0
    rrl,r0
    rrl,r0
    andi,r0 0fh
    iori,r0 10h ;ケチ表現のビット
    retc,un

_mrs5:
    rrl,r0
    rrl,r0
    rrl,r0
    andi,r0 07h
    iori,r0 08h ;ケチ表現のビット
    retc,un

_mrs6:
    rrl,r0
    rrl,r0
    andi,r0 03h
    iori,r0 04h ;ケチ表現のビット
    retc,un

_mrs7:
    rrl,r0
    andi,r0 01h
    iori,r0 02h ;ケチ表現のビット
    retc,un

_mrs8:
    lodi,r0 1 ;ケチ表現のビットが最下位ビットに来る
    retc,un

end ; End of assembly
