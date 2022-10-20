      name Mod7          ; module name

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
    
    ;画面をmod7で埋める用
    ;bcta,un gen_mod7_to_upper_screen

    ;クロック計測用
    lodi,r3 0       ;0=256
clock_test:
    lodz r3
    bsta,un mod7
    bdrr,r3 clock_test
    eorz  r0
    halt

    ;上画面にmod7を埋める用
gen_mod7_to_upper_screen:

    ;スクロール位置を画面上端へ
    lodi,r0 0F0h
    stra,r0 CRTCVPR

    ;高解像度モードへ切り替え
    lodi,r0 01000000b       ;ノーマルモード&高解像度
    stra,r0 RESOLUTION
    lodi,r0 10000011b       ;高解像度&背景緑
    stra,r0 BGCOLOUR

    lodi,r1 0
    lodi,r2 -1
    lodi,r3 16*13

_gen_mod7_to_upper_screen:
    ;mod7する対象をr0に格納＆インクリメント
    lodz r1
    addi,r1 1

    ppsl 10000b  ;RSをセット. 裏レジスタを使用, r1,r2,r3を退避
    bsta,un mod7
    cpsl 10000b  ;RSをリセット. 表レジスタを使用

    ;生成したmod7を、SCRUPDATAに書く（閲覧用）
    addi,r0 0D0h
    stra,r0 SCRUPDATA,r2+

    bdrr,r3 _gen_mod7_to_upper_screen

    lodi,r3 16*13
    lodi,r2 -1

gen_mod7_to_lower_screen:

    ;mod7をr0に格納
    lodz r1
    addi,r1 1
    ppsl 10000b  ;RSをセット. 裏レジスタを使用
    bsta,un mod7
    cpsl 10000b  ;RSをリセット. 表レジスタを使用

    addi,r0 0D0h
    stra,r0 SCRLODATA,r2+
    bdrr,r3 gen_mod7_to_lower_screen

    lodz r0
    halt

    ;-------------------
    ;mod7
    ;r0%7をr0に入れて返す
    ;r0を使用
mod7:
    loda,r0 mod7_table,r0
    retc,un

    include "06\mod7_table.h"

end ; End of assembly
