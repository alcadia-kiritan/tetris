    name DebugWithCarry          ; module name

    include "arcadia.h"      ; v1.01

org         0000H        ; Start of Arcadia ROM

    ;ppsl 01000b ; WC=1

    ; r1:r0 = 00FFh
    lodi,r0 0ffh
    lodi,r1 0

    ; r1:r0 += 1
    addi,r0 1
    addi,r1 0  ; r1 += 0 + (WC && carry ? 1 : 0)

    ; r1:r0 = 0100h
    lodi,r0 0
    lodi,r1 1

    ppsl 1 ; C=1       引き算ではC=1のときに0なる

    ; r1:r0 -= 1
    subi,r0 1  ; r0 -= 1 + (WC && carry ? 0 : 1)
    subi,r1 0  ; r1 -= 0 + (WC && carry ? 0 : 1)

    halt

end ; End of assembly
