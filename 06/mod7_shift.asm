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
    ;r0,r1,r2を使用
mod7:
    ppsl 0Ah  ;WC,COMを1に, キャリーありの論理比較モードに変更

    strz r2

    lodi,r1 0   ; 上位バイト
    cpsl 1      ; Cをリセット

    ; r1:r0 <<= 3
    rrl,r0
    rrl,r1
    rrl,r0
    rrl,r1
    rrl,r0
    rrl,r1

    ; r1:r0 += r2
    addz r2
    addi,r1 0

    ; r1:r0 <<= 3
    rrl,r0
    rrl,r1
    rrl,r0
    rrl,r1
    rrl,r0
    rrl,r1

    ; r1:r0 += r2
    addz r2
    addi,r1 0

    ; r1:r0 += 36
    addi,r0 36
    addi,r1 0
    
    ; r0 = r1:r0 >> 9
    rrr,r1
    lodz r1

    ; r0 += (r1*2 + r1) * 2   r0を7倍
    cpsl 01b      ; Cをリセット
    rrl,r0
    addz r1
    rrl,r0
    addz r1

    ; r0 = 最初の数値 - r0/7*7
    strz r1
    lodz r2

    cpsl 0Bh ;WC,COMを0に戻す  引き算でキャリーが邪魔なのでここで戻す
    subz r1
  
    retc,un

end ; End of assembly
