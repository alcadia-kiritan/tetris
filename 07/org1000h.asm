    name org1000h          ; module name

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

    ;ページ1のルーチンに分岐
    ;実際は1000hじゃなく2000hなので1000hを足す
    bcta,un welcome_page1+1000h
    
    ;------
    ;ここから下はページ1.
    ;指定は1000hだけど、メモリ上では2000hに配置される
    org         1000h

welcome_page1:

    lodi,r1 13

_loop2:
    ;実際のwelcome_page1_textのアドレスは welcome_page1_text - 1000h + 2000h.
    ;lodaのアクセスはページの先頭(2000h)からの相対アドレスになるので 2000hを引く
    ;welcome_page1_text - 1000h = welcome_page1_text - 1000h + 2000h - 2000h

    ;welcome_page1をVRAMへ転送
    loda,r0 welcome_page1_text-1000h,r1-        
    stra,r0 SCRUPDATA,r1
    brnr,r1 _loop2
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
