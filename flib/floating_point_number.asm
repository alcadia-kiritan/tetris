    name floating_point_number          ; module name

    ;浮動小数点仕様
    ;１つ辺り2byte(16bit)で各bitの役割は下記
    ;[s:符号ビット(1bit)][e:指数部(7bit)][m:仮数部(8bit)]
    ;数値 = -1^s * 2^(e-64) * (1 + m/256.0)
    ;
    ;上位byteが00h,80hのものは0として扱う

    ;指数部の下駄
    EXPONENT_OFFSET       equ     64

    ;最大値
    MAX_FLOAT0  equ     127
    MAX_FLOAT1  equ     255

    ;最小値(有効な数のうちマイナスかつ絶対値が最も大きい数値)
    MIN_FLOAT0  equ     80h + MAX_FLOAT0
    MIN_FLOAT1  equ     MAX_FLOAT1

    ;-------------------
    ;浮動小数点例外（もとい対応したくないケース）で呼ばれる関数
fexception:
    ;halt
    lodi,r0 010000001b  ;背景黄色

    stra,r0 BGCOLOUR+(8*1024)
    halt

end ; End of assembly
