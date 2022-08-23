      name FillTest          ; module name

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


    ;スクロール位置を画面上端へ
    lodi,r0 0F0h
    stra,r0 CRTCVPR

    ;高解像度モードへ切り替え
    lodi,r0 01000000b       ;ノーマルモード&高解像度
    stra,r0 RESOLUTION
    lodi,r0 10000011b       ;高解像度&背景緑
    stra,r0 BGCOLOUR

loopforever:

    ;画面を白色で埋める
    bsta,un wait_vsync              ;垂直帰線期間を待つ
    
    lodi,r0 003h                ;白い■
    ;bsta,un fill_all_screen    ;画面全体を埋めるサブルーチンを呼び出し
    bsta,un fill_upper_half_screen    ;画面半分を埋めるサブルーチンを呼び出し
    ;bsta,un fill_lower_half_screen    ;画面半分を埋めるサブルーチンを呼び出し

    ;画面を青色で埋める
    bsta,un wait_vsync              ;垂直帰線期間を待つ

    lodi,r0 0C3h                ;青い■
    ;bsta,un fill_all_screen
    bsta,un fill_upper_half_screen
    ;bsta,un fill_lower_half_screen

    bctr,un     loopforever  ; Loop forever

    ;-------------------
    ;wait_vsync
    ;垂直帰線期間に入るまで待機
wait_vsync:
    tpsu 080h
    bctr,eq wait_vsync    ;非垂直帰線期間に入るのを待つ 7bit目が0になるのを待つ（垂直帰線期間で呼ばれてたらそれが終わるまで待つ
_wait_vsync:
    tpsu 080h
    bcfr,eq _wait_vsync    ;垂直帰線期間に入るのを待つ 7bit目が1になるのを待つ
    retc,un ; return

    ;-------------------
    ;fill_all_screen
    ;画面全体をr0で埋めるサブルーチン
    ;r0とr1を使用

fill_all_screen:
    
    lodi,r1 0d0h    

_fill_all_screen:
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRLODATA,r1        ; *(SCRLODATA+r1) = r0
    brna,r1 _fill_all_screen    ; if(r1 != 0) goto 

    retc,un ;return

    ;-------------------
    ;fill_upper_half_screen
    ;画面の上半分をr0で埋めるサブルーチン
    ;r0とr1を使用

fill_upper_half_screen:
    
    lodi,r1 0d0h    

_fill_upper_half_screen:
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    stra,r0 SCRUPDATA,r1-       ; *(SCRUPDATA+--r1) = r0
    brnr,r1 _fill_upper_half_screen    ; if(r1 != 0) goto 

    retc,un ;return

    ;-------------------
    ;fill_lower_half_screen
    ;画面の下半分をr0で埋めるサブルーチン
    ;r0とr1を使用

fill_lower_half_screen:
    
    lodi,r1 0d0h    

_fill_lower_half_screen:
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    stra,r0 SCRLODATA,r1-       ; *(SCRLODATA+--r1) = r0
    brnr,r1 _fill_lower_half_screen    ; if(r1 != 0) goto 

    retc,un ;return

end ; End of assembly
