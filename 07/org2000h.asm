    name org2000h          ; module name

    include "inc\arcadia.h"      ; v1.01

    org         0000H        ; Start of Arcadia ROM

programentry:
    eorz  r0                 ; Zero-out register 0
    bctr,un     programstart ; Branch to start of program
    retc,un                  ; Called on VSYNC or VBLANK?
                             ; As suggested by Paul Robson

programstart:
    ppsu        00100000b    ; Set Interrupt Inhibit bit
                             ; The Tech doc that Paul
                             ; wrote infers that Inter-
                             ; rupts aren't used
    
    ppsl 00000010b           ; COM=1

    ASCII_OFFSET    equ 1Ah - 'A'
    DIGIT_OFFSET    equ 10h - '0'
    CHAR_COLOR      equ 0C0h

    
    ;スクロール位置を画面上端へ
    lodi,r0 0C0h
    stra,r0 CRTCVPR

    ;ページ１のルーチンに分岐
    bcta,un welcome_page1
    
    ;------
    ;ここから下はページ1.
    PAGE1       equ 2000h
    org         PAGE1

welcome_page1:
    
    lodi,r1 13

_loop:
    loda,r0 welcome_page1_text,r1-
    ;stra,r0 SCRUPDATA,r1           ;ページが異なるのでエラーになる
    stra,r0 SCRUPDATA+PAGE1,r1
    brnr,r1 _loop
    halt

welcome_page1_text:
    db ('W'+ASCII_OFFSET+CHAR_COLOR)
    db ('E'+ASCII_OFFSET+CHAR_COLOR)
    db ('L'+ASCII_OFFSET+CHAR_COLOR)
    db ('C'+ASCII_OFFSET+CHAR_COLOR)
    db ('O'+ASCII_OFFSET+CHAR_COLOR)
    db ('M'+ASCII_OFFSET+CHAR_COLOR)
    db ('E'+ASCII_OFFSET+CHAR_COLOR)
    db 0
    db ('P'+ASCII_OFFSET+CHAR_COLOR)
    db ('A'+ASCII_OFFSET+CHAR_COLOR)
    db ('G'+ASCII_OFFSET+CHAR_COLOR)
    db ('E'+ASCII_OFFSET+CHAR_COLOR)
    db ('1'+DIGIT_OFFSET+CHAR_COLOR)


end ; End of assembly
