    name fcom          ; module name

    ;-------------------
    ;fcom0
    ;[FStack+r1+0][FStack+r1+1]と0を比較し、その結果をCC1,CC0へ格納する
    ;r0,r1を使用.  r1は変化しない.
fcom0:

    loda,r0 FStack+0,r1
    retc,gt                 ; > 0
    bctr,lt _fcom0_minus
    retc,un                 ; == 0

_fcom0_minus:
    ;符号ビットが立ってる＝マイナス or 0
    comi,r0 80h
    retc,eq                 ; == 0

    ; < 0 確定
    iorz r0                 ;マイナス値に対してorやってCCへltをセット
    retc,un


    ;-------------------
    ;fcom
    ;[FStack+r1+0][FStack+r1+1]と[FStack+r2+0][FStack+r2+1]を比較し、その結果をCC1,CC0へ格納する
    ;r0,r1,r2,r3を使用.  r1,r2は変化しない.
fcom:

    loda,r0 FStack+0,r1
    bctr,lt _fcom_minus_r1
    bctr,eq _fcom_zero_r1

    ;r1はプラス
    strz r3
    loda,r0 FStack+0,r2

    bcfr,gt _fcom_gt        ;r1はプラス,r2はゼロかマイナス, gt確定

    comz r3
    bctr,lt _fcom_gt        ;r1の指数のが大きい,gt
    bctr,gt _fcom_lt        ;r1の指数のが小さい,lt

    ;プラスで指数が一致
    loda,r0 FStack+1,r1
    coma,r0 FStack+1,r2
    retc,un

_fcom_gt:                       ; r1 > r2
    lodi,r0 1
    retc,un

_fcom_minus_r1:
    ;r1はゼロかマイナス
    comi,r0 080h
    bctr,eq _fcom_zero_r1

    ;r1はマイナス
    strz r3
    loda,r0 FStack+0,r2
    bctr,lt _fcom_both_minus

    ;r2はプラスorゼロ,r1はマイナスなのでlt確定
    
_fcom_lt:                        ;r1 < r2
    lodi,r0 80h
    retc,un

_fcom_both_minus:
    comi,r0 80h
    bctr,eq _fcom_lt             ;r2がゼロだった

    ;両方マイナス
    comz r3
    bctr,eq _fcom_eq_exponent_minus
    retc,un

_fcom_eq_exponent_minus:
    ;マイナスで指数が一致
    loda,r0 FStack+1,r2
    coma,r0 FStack+1,r1
    retc,un

_fcom_zero_r1:
    ;r1はゼロ
    loda,r0 FStack+0,r2
    retc,eq                 ;r2もゼロ

    ;r2の指数が80hとイコールならeq
    ;r2の指数が80hより大きいならr2がマイナスgt(r1>r2)
    ;r2の指数が80hより小さいならr2がプラスlt(r1<r2)
    comi,r0 80h
    retc,un

    ;-------------------
    ;f_is_eps
    ;[FStack+r1+0][FStack+r1+1]の絶対値が極小(1.996/512)ならCCにeq, それ以外で０より大きいならgt, ０より小さいならltを返す
    ;極小値を計算に使うと誤差が出て困るところでfcom0の代替に使う
    ;1.966/512は特に根拠なく設定した適当な数値.
    ;r0,r1を使用.  r1は変化しない.
f_is_eps:

    loda,r0 FStack+0,r1
    bctr,gt _fie_gt
    
    andi,r0 7fh
    retc,eq                 ; == 0

    ; x < 0
    comi,r0 EXPONENT_OFFSET-9
    bctr,lt _fie_is_eps

    lodi,r0 80h   ;lt確定
    retc,un

_fie_is_eps:
    eorz r0 ;CC=eq
    retc,un

_fie_gt:
    ; x > 0    

    comi,r0 EXPONENT_OFFSET-9
    bctr,lt _fie_is_eps

    iorz r0   ;gt確定
    retc,un


end ; End of assembly
