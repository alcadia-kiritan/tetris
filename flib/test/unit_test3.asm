    name unit_test           ; module name

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
    
    lodi,r0 00000000b       ;ノーマルモード&通常解像度
    stra,r0 RESOLUTION
    lodi,r0 00000000b       ;通常解像度&背景白
    stra,r0 BGCOLOUR
    
    ;スクロール位置を画面上端へ
    lodi,r0 0F0h
    stra,r0 CRTCVPR
    
    ;RAM1           equ 18D0h   ;$18D0..$18EF are user RAM1 - 32 Byte 
    Sign            equ 18D0h 
    DataOffset0     equ 18D1h 
    DataOffset1     equ 18D2h 
    Counter         equ 18D3h

    ;RAM2            equ 18F8h   ;$18F8..$18FB are user RAM2 -  4 Byte
    Temporary0      equ 18F8h
    Temporary1      equ 18F9h
    Temporary2      equ 18FAh
    Temporary3      equ 18FBh
    Temporary0P1    equ 18F8h + 8*1024
    Temporary1P1    equ 18F9h + 8*1024
    Temporary2P1    equ 18FAh + 8*1024
    Temporary3P1    equ 18FBh + 8*1024

    FStack equ 1AD0h + PAGE1        ;$1AD0..$1AFF are user RAM3 - 48 Byte

    ;-------
    ;fcos256/fsin256のテスト
    bcta,un _fsincos256_test
_fsincos256_data:
    db EXPONENT_OFFSET + 0
    db 000h
    db 0
    db 0
    db EXPONENT_OFFSET + -1
    db 0FFh
    db EXPONENT_OFFSET + -6
    db 092h
    db EXPONENT_OFFSET + -1
    db 0FFh
    db EXPONENT_OFFSET + -5
    db 091h
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + -4
    db 02Dh
    db EXPONENT_OFFSET + -1
    db 0FDh
    db EXPONENT_OFFSET + -4
    db 091h
    db EXPONENT_OFFSET + -1
    db 0FCh
    db EXPONENT_OFFSET + -4
    db 0F5h
    db EXPONENT_OFFSET + -1
    db 0FAh
    db EXPONENT_OFFSET + -3
    db 02Ch
    db EXPONENT_OFFSET + -1
    db 0F8h
    db EXPONENT_OFFSET + -3
    db 05Eh
    db EXPONENT_OFFSET + -1
    db 0F6h
    db EXPONENT_OFFSET + -3
    db 08Fh
    db EXPONENT_OFFSET + -1
    db 0F3h
    db EXPONENT_OFFSET + -3
    db 0C0h
    db EXPONENT_OFFSET + -1
    db 0F0h
    db EXPONENT_OFFSET + -3
    db 0F1h
    db EXPONENT_OFFSET + -1
    db 0EDh
    db EXPONENT_OFFSET + -2
    db 011h
    db EXPONENT_OFFSET + -1
    db 0E9h
    db EXPONENT_OFFSET + -2
    db 029h
    db EXPONENT_OFFSET + -1
    db 0E6h
    db EXPONENT_OFFSET + -2
    db 041h
    db EXPONENT_OFFSET + -1
    db 0E2h
    db EXPONENT_OFFSET + -2
    db 058h
    db EXPONENT_OFFSET + -1
    db 0DDh
    db EXPONENT_OFFSET + -2
    db 070h
    db EXPONENT_OFFSET + -1
    db 0D9h
    db EXPONENT_OFFSET + -2
    db 087h
    db EXPONENT_OFFSET + -1
    db 0D4h
    db EXPONENT_OFFSET + -2
    db 09Eh
    db EXPONENT_OFFSET + -1
    db 0CEh
    db EXPONENT_OFFSET + -2
    db 0B5h
    db EXPONENT_OFFSET + -1
    db 0C9h
    db EXPONENT_OFFSET + -2
    db 0CCh
    db EXPONENT_OFFSET + -1
    db 0C3h
    db EXPONENT_OFFSET + -2
    db 0E2h
    db EXPONENT_OFFSET + -1
    db 0BDh
    db EXPONENT_OFFSET + -2
    db 0F8h
    db EXPONENT_OFFSET + -1
    db 0B7h
    db EXPONENT_OFFSET + -1
    db 007h
    db EXPONENT_OFFSET + -1
    db 0B0h
    db EXPONENT_OFFSET + -1
    db 011h
    db EXPONENT_OFFSET + -1
    db 0A9h
    db EXPONENT_OFFSET + -1
    db 01Ch
    db EXPONENT_OFFSET + -1
    db 0A2h
    db EXPONENT_OFFSET + -1
    db 026h
    db EXPONENT_OFFSET + -1
    db 09Bh
    db EXPONENT_OFFSET + -1
    db 030h
    db EXPONENT_OFFSET + -1
    db 093h
    db EXPONENT_OFFSET + -1
    db 03Ah
    db EXPONENT_OFFSET + -1
    db 08Bh
    db EXPONENT_OFFSET + -1
    db 044h
    db EXPONENT_OFFSET + -1
    db 083h
    db EXPONENT_OFFSET + -1
    db 04Eh
    db EXPONENT_OFFSET + -1
    db 07Bh
    db EXPONENT_OFFSET + -1
    db 057h
    db EXPONENT_OFFSET + -1
    db 072h
    db EXPONENT_OFFSET + -1
    db 061h
    db EXPONENT_OFFSET + -1
    db 06Ah
    db EXPONENT_OFFSET + -1
    db 06Ah
    db EXPONENT_OFFSET + -1
    db 061h
    db EXPONENT_OFFSET + -1
    db 072h
    db EXPONENT_OFFSET + -1
    db 057h
    db EXPONENT_OFFSET + -1
    db 07Bh
    db EXPONENT_OFFSET + -1
    db 04Eh
    db EXPONENT_OFFSET + -1
    db 083h
    db EXPONENT_OFFSET + -1
    db 044h
    db EXPONENT_OFFSET + -1
    db 08Bh
    db EXPONENT_OFFSET + -1
    db 03Ah
    db EXPONENT_OFFSET + -1
    db 093h
    db EXPONENT_OFFSET + -1
    db 030h
    db EXPONENT_OFFSET + -1
    db 09Bh
    db EXPONENT_OFFSET + -1
    db 026h
    db EXPONENT_OFFSET + -1
    db 0A2h
    db EXPONENT_OFFSET + -1
    db 01Ch
    db EXPONENT_OFFSET + -1
    db 0A9h
    db EXPONENT_OFFSET + -1
    db 011h
    db EXPONENT_OFFSET + -1
    db 0B0h
    db EXPONENT_OFFSET + -1
    db 007h
    db EXPONENT_OFFSET + -1
    db 0B7h
    db EXPONENT_OFFSET + -2
    db 0F8h
    db EXPONENT_OFFSET + -1
    db 0BDh
    db EXPONENT_OFFSET + -2
    db 0E2h
    db EXPONENT_OFFSET + -1
    db 0C3h
    db EXPONENT_OFFSET + -2
    db 0CCh
    db EXPONENT_OFFSET + -1
    db 0C9h
    db EXPONENT_OFFSET + -2
    db 0B5h
    db EXPONENT_OFFSET + -1
    db 0CEh
    db EXPONENT_OFFSET + -2
    db 09Eh
    db EXPONENT_OFFSET + -1
    db 0D4h
    db EXPONENT_OFFSET + -2
    db 087h
    db EXPONENT_OFFSET + -1
    db 0D9h
    db EXPONENT_OFFSET + -2
    db 070h
    db EXPONENT_OFFSET + -1
    db 0DDh
    db EXPONENT_OFFSET + -2
    db 058h
    db EXPONENT_OFFSET + -1
    db 0E2h
    db EXPONENT_OFFSET + -2
    db 041h
    db EXPONENT_OFFSET + -1
    db 0E6h
    db EXPONENT_OFFSET + -2
    db 029h
    db EXPONENT_OFFSET + -1
    db 0E9h
    db EXPONENT_OFFSET + -2
    db 011h
    db EXPONENT_OFFSET + -1
    db 0EDh
    db EXPONENT_OFFSET + -3
    db 0F1h
    db EXPONENT_OFFSET + -1
    db 0F0h
    db EXPONENT_OFFSET + -3
    db 0C0h
    db EXPONENT_OFFSET + -1
    db 0F3h
    db EXPONENT_OFFSET + -3
    db 08Fh
    db EXPONENT_OFFSET + -1
    db 0F6h
    db EXPONENT_OFFSET + -3
    db 05Eh
    db EXPONENT_OFFSET + -1
    db 0F8h
    db EXPONENT_OFFSET + -3
    db 02Ch
    db EXPONENT_OFFSET + -1
    db 0FAh
    db EXPONENT_OFFSET + -4
    db 0F5h
    db EXPONENT_OFFSET + -1
    db 0FCh
    db EXPONENT_OFFSET + -4
    db 091h
    db EXPONENT_OFFSET + -1
    db 0FDh
    db EXPONENT_OFFSET + -4
    db 02Dh
    db EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + -5
    db 091h
    db EXPONENT_OFFSET + -1
    db 0FFh
    db EXPONENT_OFFSET + -6
    db 092h
    db EXPONENT_OFFSET + -1
    db 0FFh
    db 0
    db 0
    db EXPONENT_OFFSET + 0
    db 000h
    db 80h + EXPONENT_OFFSET + -6
    db 092h
    db EXPONENT_OFFSET + -1
    db 0FFh
    db 80h + EXPONENT_OFFSET + -5
    db 091h
    db EXPONENT_OFFSET + -1
    db 0FFh
    db 80h + EXPONENT_OFFSET + -4
    db 02Dh
    db EXPONENT_OFFSET + -1
    db 0FEh
    db 80h + EXPONENT_OFFSET + -4
    db 091h
    db EXPONENT_OFFSET + -1
    db 0FDh
    db 80h + EXPONENT_OFFSET + -4
    db 0F5h
    db EXPONENT_OFFSET + -1
    db 0FCh
    db 80h + EXPONENT_OFFSET + -3
    db 02Ch
    db EXPONENT_OFFSET + -1
    db 0FAh
    db 80h + EXPONENT_OFFSET + -3
    db 05Eh
    db EXPONENT_OFFSET + -1
    db 0F8h
    db 80h + EXPONENT_OFFSET + -3
    db 08Fh
    db EXPONENT_OFFSET + -1
    db 0F6h
    db 80h + EXPONENT_OFFSET + -3
    db 0C0h
    db EXPONENT_OFFSET + -1
    db 0F3h
    db 80h + EXPONENT_OFFSET + -3
    db 0F1h
    db EXPONENT_OFFSET + -1
    db 0F0h
    db 80h + EXPONENT_OFFSET + -2
    db 011h
    db EXPONENT_OFFSET + -1
    db 0EDh
    db 80h + EXPONENT_OFFSET + -2
    db 029h
    db EXPONENT_OFFSET + -1
    db 0E9h
    db 80h + EXPONENT_OFFSET + -2
    db 041h
    db EXPONENT_OFFSET + -1
    db 0E6h
    db 80h + EXPONENT_OFFSET + -2
    db 058h
    db EXPONENT_OFFSET + -1
    db 0E2h
    db 80h + EXPONENT_OFFSET + -2
    db 070h
    db EXPONENT_OFFSET + -1
    db 0DDh
    db 80h + EXPONENT_OFFSET + -2
    db 087h
    db EXPONENT_OFFSET + -1
    db 0D9h
    db 80h + EXPONENT_OFFSET + -2
    db 09Eh
    db EXPONENT_OFFSET + -1
    db 0D4h
    db 80h + EXPONENT_OFFSET + -2
    db 0B5h
    db EXPONENT_OFFSET + -1
    db 0CEh
    db 80h + EXPONENT_OFFSET + -2
    db 0CCh
    db EXPONENT_OFFSET + -1
    db 0C9h
    db 80h + EXPONENT_OFFSET + -2
    db 0E2h
    db EXPONENT_OFFSET + -1
    db 0C3h
    db 80h + EXPONENT_OFFSET + -2
    db 0F8h
    db EXPONENT_OFFSET + -1
    db 0BDh
    db 80h + EXPONENT_OFFSET + -1
    db 007h
    db EXPONENT_OFFSET + -1
    db 0B7h
    db 80h + EXPONENT_OFFSET + -1
    db 011h
    db EXPONENT_OFFSET + -1
    db 0B0h
    db 80h + EXPONENT_OFFSET + -1
    db 01Ch
    db EXPONENT_OFFSET + -1
    db 0A9h
    db 80h + EXPONENT_OFFSET + -1
    db 026h
    db EXPONENT_OFFSET + -1
    db 0A2h
    db 80h + EXPONENT_OFFSET + -1
    db 030h
    db EXPONENT_OFFSET + -1
    db 09Bh
    db 80h + EXPONENT_OFFSET + -1
    db 03Ah
    db EXPONENT_OFFSET + -1
    db 093h
    db 80h + EXPONENT_OFFSET + -1
    db 044h
    db EXPONENT_OFFSET + -1
    db 08Bh
    db 80h + EXPONENT_OFFSET + -1
    db 04Eh
    db EXPONENT_OFFSET + -1
    db 083h
    db 80h + EXPONENT_OFFSET + -1
    db 057h
    db EXPONENT_OFFSET + -1
    db 07Bh
    db 80h + EXPONENT_OFFSET + -1
    db 061h
    db EXPONENT_OFFSET + -1
    db 072h
    db 80h + EXPONENT_OFFSET + -1
    db 06Ah
    db EXPONENT_OFFSET + -1
    db 06Ah
    db 80h + EXPONENT_OFFSET + -1
    db 072h
    db EXPONENT_OFFSET + -1
    db 061h
    db 80h + EXPONENT_OFFSET + -1
    db 07Bh
    db EXPONENT_OFFSET + -1
    db 057h
    db 80h + EXPONENT_OFFSET + -1
    db 083h
    db EXPONENT_OFFSET + -1
    db 04Eh
    db 80h + EXPONENT_OFFSET + -1
    db 08Bh
    db EXPONENT_OFFSET + -1
    db 044h
    db 80h + EXPONENT_OFFSET + -1
    db 093h
    db EXPONENT_OFFSET + -1
    db 03Ah
    db 80h + EXPONENT_OFFSET + -1
    db 09Bh
    db EXPONENT_OFFSET + -1
    db 030h
    db 80h + EXPONENT_OFFSET + -1
    db 0A2h
    db EXPONENT_OFFSET + -1
    db 026h
    db 80h + EXPONENT_OFFSET + -1
    db 0A9h
    db EXPONENT_OFFSET + -1
    db 01Ch
    db 80h + EXPONENT_OFFSET + -1
    db 0B0h
    db EXPONENT_OFFSET + -1
    db 011h
    db 80h + EXPONENT_OFFSET + -1
    db 0B7h
    db EXPONENT_OFFSET + -1
    db 007h
    db 80h + EXPONENT_OFFSET + -1
    db 0BDh
    db EXPONENT_OFFSET + -2
    db 0F8h
    db 80h + EXPONENT_OFFSET + -1
    db 0C3h
    db EXPONENT_OFFSET + -2
    db 0E2h
    db 80h + EXPONENT_OFFSET + -1
    db 0C9h
    db EXPONENT_OFFSET + -2
    db 0CCh
    db 80h + EXPONENT_OFFSET + -1
    db 0CEh
    db EXPONENT_OFFSET + -2
    db 0B5h
    db 80h + EXPONENT_OFFSET + -1
    db 0D4h
    db EXPONENT_OFFSET + -2
    db 09Eh
    db 80h + EXPONENT_OFFSET + -1
    db 0D9h
    db EXPONENT_OFFSET + -2
    db 087h
    db 80h + EXPONENT_OFFSET + -1
    db 0DDh
    db EXPONENT_OFFSET + -2
    db 070h
    db 80h + EXPONENT_OFFSET + -1
    db 0E2h
    db EXPONENT_OFFSET + -2
    db 058h
    db 80h + EXPONENT_OFFSET + -1
    db 0E6h
    db EXPONENT_OFFSET + -2
    db 041h
    db 80h + EXPONENT_OFFSET + -1
    db 0E9h
    db EXPONENT_OFFSET + -2
    db 029h
    db 80h + EXPONENT_OFFSET + -1
    db 0EDh
    db EXPONENT_OFFSET + -2
    db 011h
    db 80h + EXPONENT_OFFSET + -1
    db 0F0h
    db EXPONENT_OFFSET + -3
    db 0F1h
    db 80h + EXPONENT_OFFSET + -1
    db 0F3h
    db EXPONENT_OFFSET + -3
    db 0C0h
    db 80h + EXPONENT_OFFSET + -1
    db 0F6h
    db EXPONENT_OFFSET + -3
    db 08Fh
    db 80h + EXPONENT_OFFSET + -1
    db 0F8h
    db EXPONENT_OFFSET + -3
    db 05Eh
    db 80h + EXPONENT_OFFSET + -1
    db 0FAh
    db EXPONENT_OFFSET + -3
    db 02Ch
    db 80h + EXPONENT_OFFSET + -1
    db 0FCh
    db EXPONENT_OFFSET + -4
    db 0F5h
    db 80h + EXPONENT_OFFSET + -1
    db 0FDh
    db EXPONENT_OFFSET + -4
    db 091h
    db 80h + EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + -4
    db 02Dh
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db EXPONENT_OFFSET + -5
    db 091h
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db EXPONENT_OFFSET + -6
    db 092h
    db 80h + EXPONENT_OFFSET + 0
    db 000h
    db 0
    db 0
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db 80h + EXPONENT_OFFSET + -6
    db 092h
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db 80h + EXPONENT_OFFSET + -5
    db 091h
    db 80h + EXPONENT_OFFSET + -1
    db 0FEh
    db 80h + EXPONENT_OFFSET + -4
    db 02Dh
    db 80h + EXPONENT_OFFSET + -1
    db 0FDh
    db 80h + EXPONENT_OFFSET + -4
    db 091h
    db 80h + EXPONENT_OFFSET + -1
    db 0FCh
    db 80h + EXPONENT_OFFSET + -4
    db 0F5h
    db 80h + EXPONENT_OFFSET + -1
    db 0FAh
    db 80h + EXPONENT_OFFSET + -3
    db 02Ch
    db 80h + EXPONENT_OFFSET + -1
    db 0F8h
    db 80h + EXPONENT_OFFSET + -3
    db 05Eh
    db 80h + EXPONENT_OFFSET + -1
    db 0F6h
    db 80h + EXPONENT_OFFSET + -3
    db 08Fh
    db 80h + EXPONENT_OFFSET + -1
    db 0F3h
    db 80h + EXPONENT_OFFSET + -3
    db 0C0h
    db 80h + EXPONENT_OFFSET + -1
    db 0F0h
    db 80h + EXPONENT_OFFSET + -3
    db 0F1h
    db 80h + EXPONENT_OFFSET + -1
    db 0EDh
    db 80h + EXPONENT_OFFSET + -2
    db 011h
    db 80h + EXPONENT_OFFSET + -1
    db 0E9h
    db 80h + EXPONENT_OFFSET + -2
    db 029h
    db 80h + EXPONENT_OFFSET + -1
    db 0E6h
    db 80h + EXPONENT_OFFSET + -2
    db 041h
    db 80h + EXPONENT_OFFSET + -1
    db 0E2h
    db 80h + EXPONENT_OFFSET + -2
    db 058h
    db 80h + EXPONENT_OFFSET + -1
    db 0DDh
    db 80h + EXPONENT_OFFSET + -2
    db 070h
    db 80h + EXPONENT_OFFSET + -1
    db 0D9h
    db 80h + EXPONENT_OFFSET + -2
    db 087h
    db 80h + EXPONENT_OFFSET + -1
    db 0D4h
    db 80h + EXPONENT_OFFSET + -2
    db 09Eh
    db 80h + EXPONENT_OFFSET + -1
    db 0CEh
    db 80h + EXPONENT_OFFSET + -2
    db 0B5h
    db 80h + EXPONENT_OFFSET + -1
    db 0C9h
    db 80h + EXPONENT_OFFSET + -2
    db 0CCh
    db 80h + EXPONENT_OFFSET + -1
    db 0C3h
    db 80h + EXPONENT_OFFSET + -2
    db 0E2h
    db 80h + EXPONENT_OFFSET + -1
    db 0BDh
    db 80h + EXPONENT_OFFSET + -2
    db 0F8h
    db 80h + EXPONENT_OFFSET + -1
    db 0B7h
    db 80h + EXPONENT_OFFSET + -1
    db 007h
    db 80h + EXPONENT_OFFSET + -1
    db 0B0h
    db 80h + EXPONENT_OFFSET + -1
    db 011h
    db 80h + EXPONENT_OFFSET + -1
    db 0A9h
    db 80h + EXPONENT_OFFSET + -1
    db 01Ch
    db 80h + EXPONENT_OFFSET + -1
    db 0A2h
    db 80h + EXPONENT_OFFSET + -1
    db 026h
    db 80h + EXPONENT_OFFSET + -1
    db 09Bh
    db 80h + EXPONENT_OFFSET + -1
    db 030h
    db 80h + EXPONENT_OFFSET + -1
    db 093h
    db 80h + EXPONENT_OFFSET + -1
    db 03Ah
    db 80h + EXPONENT_OFFSET + -1
    db 08Bh
    db 80h + EXPONENT_OFFSET + -1
    db 044h
    db 80h + EXPONENT_OFFSET + -1
    db 083h
    db 80h + EXPONENT_OFFSET + -1
    db 04Eh
    db 80h + EXPONENT_OFFSET + -1
    db 07Bh
    db 80h + EXPONENT_OFFSET + -1
    db 057h
    db 80h + EXPONENT_OFFSET + -1
    db 072h
    db 80h + EXPONENT_OFFSET + -1
    db 061h
    db 80h + EXPONENT_OFFSET + -1
    db 06Ah
    db 80h + EXPONENT_OFFSET + -1
    db 06Ah
    db 80h + EXPONENT_OFFSET + -1
    db 061h
    db 80h + EXPONENT_OFFSET + -1
    db 072h
    db 80h + EXPONENT_OFFSET + -1
    db 057h
    db 80h + EXPONENT_OFFSET + -1
    db 07Bh
    db 80h + EXPONENT_OFFSET + -1
    db 04Eh
    db 80h + EXPONENT_OFFSET + -1
    db 083h
    db 80h + EXPONENT_OFFSET + -1
    db 044h
    db 80h + EXPONENT_OFFSET + -1
    db 08Bh
    db 80h + EXPONENT_OFFSET + -1
    db 03Ah
    db 80h + EXPONENT_OFFSET + -1
    db 093h
    db 80h + EXPONENT_OFFSET + -1
    db 030h
    db 80h + EXPONENT_OFFSET + -1
    db 09Bh
    db 80h + EXPONENT_OFFSET + -1
    db 026h
    db 80h + EXPONENT_OFFSET + -1
    db 0A2h
    db 80h + EXPONENT_OFFSET + -1
    db 01Ch
    db 80h + EXPONENT_OFFSET + -1
    db 0A9h
    db 80h + EXPONENT_OFFSET + -1
    db 011h
    db 80h + EXPONENT_OFFSET + -1
    db 0B0h
    db 80h + EXPONENT_OFFSET + -1
    db 007h
    db 80h + EXPONENT_OFFSET + -1
    db 0B7h
    db 80h + EXPONENT_OFFSET + -2
    db 0F8h
    db 80h + EXPONENT_OFFSET + -1
    db 0BDh
    db 80h + EXPONENT_OFFSET + -2
    db 0E2h
    db 80h + EXPONENT_OFFSET + -1
    db 0C3h
    db 80h + EXPONENT_OFFSET + -2
    db 0CCh
    db 80h + EXPONENT_OFFSET + -1
    db 0C9h
    db 80h + EXPONENT_OFFSET + -2
    db 0B5h
    db 80h + EXPONENT_OFFSET + -1
    db 0CEh
    db 80h + EXPONENT_OFFSET + -2
    db 09Eh
    db 80h + EXPONENT_OFFSET + -1
    db 0D4h
    db 80h + EXPONENT_OFFSET + -2
    db 087h
    db 80h + EXPONENT_OFFSET + -1
    db 0D9h
    db 80h + EXPONENT_OFFSET + -2
    db 070h
    db 80h + EXPONENT_OFFSET + -1
    db 0DDh
    db 80h + EXPONENT_OFFSET + -2
    db 058h
    db 80h + EXPONENT_OFFSET + -1
    db 0E2h
    db 80h + EXPONENT_OFFSET + -2
    db 041h
    db 80h + EXPONENT_OFFSET + -1
    db 0E6h
    db 80h + EXPONENT_OFFSET + -2
    db 029h
    db 80h + EXPONENT_OFFSET + -1
    db 0E9h
    db 80h + EXPONENT_OFFSET + -2
    db 011h
    db 80h + EXPONENT_OFFSET + -1
    db 0EDh
    db 80h + EXPONENT_OFFSET + -3
    db 0F1h
    db 80h + EXPONENT_OFFSET + -1
    db 0F0h
    db 80h + EXPONENT_OFFSET + -3
    db 0C0h
    db 80h + EXPONENT_OFFSET + -1
    db 0F3h
    db 80h + EXPONENT_OFFSET + -3
    db 08Fh
    db 80h + EXPONENT_OFFSET + -1
    db 0F6h
    db 80h + EXPONENT_OFFSET + -3
    db 05Eh
    db 80h + EXPONENT_OFFSET + -1
    db 0F8h
    db 80h + EXPONENT_OFFSET + -3
    db 02Ch
    db 80h + EXPONENT_OFFSET + -1
    db 0FAh
    db 80h + EXPONENT_OFFSET + -4
    db 0F5h
    db 80h + EXPONENT_OFFSET + -1
    db 0FCh
    db 80h + EXPONENT_OFFSET + -4
    db 091h
    db 80h + EXPONENT_OFFSET + -1
    db 0FDh
    db 80h + EXPONENT_OFFSET + -4
    db 02Dh
    db 80h + EXPONENT_OFFSET + -1
    db 0FEh
    db 80h + EXPONENT_OFFSET + -5
    db 091h
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db 80h + EXPONENT_OFFSET + -6
    db 092h
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db 0
    db 0
    db 80h + EXPONENT_OFFSET + 0
    db 000h
    db EXPONENT_OFFSET + -6
    db 092h
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db EXPONENT_OFFSET + -5
    db 091h
    db 80h + EXPONENT_OFFSET + -1
    db 0FFh
    db EXPONENT_OFFSET + -4
    db 02Dh
    db 80h + EXPONENT_OFFSET + -1
    db 0FEh
    db EXPONENT_OFFSET + -4
    db 091h
    db 80h + EXPONENT_OFFSET + -1
    db 0FDh
    db EXPONENT_OFFSET + -4
    db 0F5h
    db 80h + EXPONENT_OFFSET + -1
    db 0FCh
    db EXPONENT_OFFSET + -3
    db 02Ch
    db 80h + EXPONENT_OFFSET + -1
    db 0FAh
    db EXPONENT_OFFSET + -3
    db 05Eh
    db 80h + EXPONENT_OFFSET + -1
    db 0F8h
    db EXPONENT_OFFSET + -3
    db 08Fh
    db 80h + EXPONENT_OFFSET + -1
    db 0F6h
    db EXPONENT_OFFSET + -3
    db 0C0h
    db 80h + EXPONENT_OFFSET + -1
    db 0F3h
    db EXPONENT_OFFSET + -3
    db 0F1h
    db 80h + EXPONENT_OFFSET + -1
    db 0F0h
    db EXPONENT_OFFSET + -2
    db 011h
    db 80h + EXPONENT_OFFSET + -1
    db 0EDh
    db EXPONENT_OFFSET + -2
    db 029h
    db 80h + EXPONENT_OFFSET + -1
    db 0E9h
    db EXPONENT_OFFSET + -2
    db 041h
    db 80h + EXPONENT_OFFSET + -1
    db 0E6h
    db EXPONENT_OFFSET + -2
    db 058h
    db 80h + EXPONENT_OFFSET + -1
    db 0E2h
    db EXPONENT_OFFSET + -2
    db 070h
    db 80h + EXPONENT_OFFSET + -1
    db 0DDh
    db EXPONENT_OFFSET + -2
    db 087h
    db 80h + EXPONENT_OFFSET + -1
    db 0D9h
    db EXPONENT_OFFSET + -2
    db 09Eh
    db 80h + EXPONENT_OFFSET + -1
    db 0D4h
    db EXPONENT_OFFSET + -2
    db 0B5h
    db 80h + EXPONENT_OFFSET + -1
    db 0CEh
    db EXPONENT_OFFSET + -2
    db 0CCh
    db 80h + EXPONENT_OFFSET + -1
    db 0C9h
    db EXPONENT_OFFSET + -2
    db 0E2h
    db 80h + EXPONENT_OFFSET + -1
    db 0C3h
    db EXPONENT_OFFSET + -2
    db 0F8h
    db 80h + EXPONENT_OFFSET + -1
    db 0BDh
    db EXPONENT_OFFSET + -1
    db 007h
    db 80h + EXPONENT_OFFSET + -1
    db 0B7h
    db EXPONENT_OFFSET + -1
    db 011h
    db 80h + EXPONENT_OFFSET + -1
    db 0B0h
    db EXPONENT_OFFSET + -1
    db 01Ch
    db 80h + EXPONENT_OFFSET + -1
    db 0A9h
    db EXPONENT_OFFSET + -1
    db 026h
    db 80h + EXPONENT_OFFSET + -1
    db 0A2h
    db EXPONENT_OFFSET + -1
    db 030h
    db 80h + EXPONENT_OFFSET + -1
    db 09Bh
    db EXPONENT_OFFSET + -1
    db 03Ah
    db 80h + EXPONENT_OFFSET + -1
    db 093h
    db EXPONENT_OFFSET + -1
    db 044h
    db 80h + EXPONENT_OFFSET + -1
    db 08Bh
    db EXPONENT_OFFSET + -1
    db 04Eh
    db 80h + EXPONENT_OFFSET + -1
    db 083h
    db EXPONENT_OFFSET + -1
    db 057h
    db 80h + EXPONENT_OFFSET + -1
    db 07Bh
    db EXPONENT_OFFSET + -1
    db 061h
    db 80h + EXPONENT_OFFSET + -1
    db 072h
    db EXPONENT_OFFSET + -1
    db 06Ah
    db 80h + EXPONENT_OFFSET + -1
    db 06Ah
    db EXPONENT_OFFSET + -1
    db 072h
    db 80h + EXPONENT_OFFSET + -1
    db 061h
    db EXPONENT_OFFSET + -1
    db 07Bh
    db 80h + EXPONENT_OFFSET + -1
    db 057h
    db EXPONENT_OFFSET + -1
    db 083h
    db 80h + EXPONENT_OFFSET + -1
    db 04Eh
    db EXPONENT_OFFSET + -1
    db 08Bh
    db 80h + EXPONENT_OFFSET + -1
    db 044h
    db EXPONENT_OFFSET + -1
    db 093h
    db 80h + EXPONENT_OFFSET + -1
    db 03Ah
    db EXPONENT_OFFSET + -1
    db 09Bh
    db 80h + EXPONENT_OFFSET + -1
    db 030h
    db EXPONENT_OFFSET + -1
    db 0A2h
    db 80h + EXPONENT_OFFSET + -1
    db 026h
    db EXPONENT_OFFSET + -1
    db 0A9h
    db 80h + EXPONENT_OFFSET + -1
    db 01Ch
    db EXPONENT_OFFSET + -1
    db 0B0h
    db 80h + EXPONENT_OFFSET + -1
    db 011h
    db EXPONENT_OFFSET + -1
    db 0B7h
    db 80h + EXPONENT_OFFSET + -1
    db 007h
    db EXPONENT_OFFSET + -1
    db 0BDh
    db 80h + EXPONENT_OFFSET + -2
    db 0F8h
    db EXPONENT_OFFSET + -1
    db 0C3h
    db 80h + EXPONENT_OFFSET + -2
    db 0E2h
    db EXPONENT_OFFSET + -1
    db 0C9h
    db 80h + EXPONENT_OFFSET + -2
    db 0CCh
    db EXPONENT_OFFSET + -1
    db 0CEh
    db 80h + EXPONENT_OFFSET + -2
    db 0B5h
    db EXPONENT_OFFSET + -1
    db 0D4h
    db 80h + EXPONENT_OFFSET + -2
    db 09Eh
    db EXPONENT_OFFSET + -1
    db 0D9h
    db 80h + EXPONENT_OFFSET + -2
    db 087h
    db EXPONENT_OFFSET + -1
    db 0DDh
    db 80h + EXPONENT_OFFSET + -2
    db 070h
    db EXPONENT_OFFSET + -1
    db 0E2h
    db 80h + EXPONENT_OFFSET + -2
    db 058h
    db EXPONENT_OFFSET + -1
    db 0E6h
    db 80h + EXPONENT_OFFSET + -2
    db 041h
    db EXPONENT_OFFSET + -1
    db 0E9h
    db 80h + EXPONENT_OFFSET + -2
    db 029h
    db EXPONENT_OFFSET + -1
    db 0EDh
    db 80h + EXPONENT_OFFSET + -2
    db 011h
    db EXPONENT_OFFSET + -1
    db 0F0h
    db 80h + EXPONENT_OFFSET + -3
    db 0F1h
    db EXPONENT_OFFSET + -1
    db 0F3h
    db 80h + EXPONENT_OFFSET + -3
    db 0C0h
    db EXPONENT_OFFSET + -1
    db 0F6h
    db 80h + EXPONENT_OFFSET + -3
    db 08Fh
    db EXPONENT_OFFSET + -1
    db 0F8h
    db 80h + EXPONENT_OFFSET + -3
    db 05Eh
    db EXPONENT_OFFSET + -1
    db 0FAh
    db 80h + EXPONENT_OFFSET + -3
    db 02Ch
    db EXPONENT_OFFSET + -1
    db 0FCh
    db 80h + EXPONENT_OFFSET + -4
    db 0F5h
    db EXPONENT_OFFSET + -1
    db 0FDh
    db 80h + EXPONENT_OFFSET + -4
    db 091h
    db EXPONENT_OFFSET + -1
    db 0FEh
    db 80h + EXPONENT_OFFSET + -4
    db 02Dh
    db EXPONENT_OFFSET + -1
    db 0FFh
    db 80h + EXPONENT_OFFSET + -5
    db 091h
    db EXPONENT_OFFSET + -1
    db 0FFh
    db 80h + EXPONENT_OFFSET + -6
    db 092h
_fsincos256_data_end:
_fsincos256_test:

    lodi,r0 _fsincos256_data >> 8
    stra,r0 DataOffset0
    lodi,r0 _fsincos256_data & 255
    stra,r0 DataOffset1

    eorz r0
    stra,r0 Counter

    lodi,r0 0DDh            ;マーカー
    stra,r0 SCRUPDATA

_fsincos256_test_:
    

    lodi,r0 0DEh            ;マーカー
    stra,r0 SCRUPDATA
        
    loda,r0 Counter
    lodi,r1 4
    bsta,un fcos256

    comi,r1 4
    bcfa,eq failed_unit_test
    
    lodi,r1 2
    loda,r0 *DataOffset0,r1-
    stra,r0 FStack+2-PAGE1,r1
    loda,r0 *DataOffset0,r1-
    stra,r0 FStack+2-PAGE1,r1

    lodi,r0 0DFh            ;マーカー
    stra,r0 SCRUPDATA

    lodi,r1 2
    lodi,r2 4
    bsta,un fcom
    bcfa,eq failed_unit_test


    lodi,r0 0E0h            ;マーカーG
    stra,r0 SCRUPDATA
        
    loda,r0 Counter
    lodi,r1 6
    bsta,un fsin256

    comi,r1 6
    bcfa,eq failed_unit_test
    
    lodi,r1 4
    loda,r0 *DataOffset0,r1-
    stra,r0 FStack+2-PAGE1,r1
    loda,r0 *DataOffset0,r1-
    stra,r0 FStack+2-PAGE1,r1

    lodi,r0 0E1h            ;マーカーH
    stra,r0 SCRUPDATA

    lodi,r1 4
    lodi,r2 6
    bsta,un fcom
    bcfa,eq failed_unit_test


    lodi,r0 1
    adda,r0 Counter
    stra,r0 Counter

    loda,r0 DataOffset1
    addi,r0 4
    stra,r0 DataOffset1
    tpsl C
    bcfr,eq _fsincos256_test_not_ovf
    loda,r0 DataOffset0
    addi,r0 1
    stra,r0 DataOffset0
_fsincos256_test_not_ovf:

    lodi,r0 _fsincos256_data_end & 255
    coma,r0 DataOffset1
    bcfa,eq _fsincos256_test_

    lodi,r0 _fsincos256_data_end >> 8
    coma,r0 DataOffset0
    bcfa,eq _fsincos256_test_

    ;--------
    ;テストOK
    lodi,r0 010000011b  ;背景緑
    stra,r0 BGCOLOUR
    halt

_page0_last_:
    if _page0_last_ > 4*1024
        warning "page0の末尾が4K超えてるよ"
    endif

    PAGE1 equ   8*1024
    org PAGE1

    ;-------
    ;テスト失敗
failed_unit_test:
    ;halt
    lodi,r0 010000101b  ;背景赤
    stra,r0 BGCOLOUR+PAGE1
    halt


    include "flib\floating_point_number.asm"
    include "flib\fadd.asm"
    include "flib\mantissa_rshift.asm"
    include "flib\vec3.asm"
    include "flib\fsq.asm"
    include "flib\fmul.asm"
    include "flib\fminmax.asm"
    include "flib\fcom.asm"
    include "flib\futil.asm"
    include "flib\fsincos256.asm"

_page1_last_:
    if _page1_last_ > 12*1024
        warning "page1の末尾が12K超えてるよ"
    endif

end ; End of assembly
