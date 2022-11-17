    name fcom0          ; module name

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
    iorz r0                 ;ltをセット
    retc,un


end ; End of assembly
