    name fadd          ; module name

    ;-------------------
    ;fsub
    ;[FStack+0][FStack+1] = [FStack+r1][FStack+r1+1] - [FStack+r2+0][FStack+r2+1]
    ;r0,r1,r2,r3を使用.  r1,r2は変化しない.
fsub:
    loda,r0 FStack,r2
    eori,r0 80h
    stra,r0 FStack,r2

    bstr,un fadd

    comi,r2 0
    retc,eq         ;r2が0(FStack+0)なら符号を戻さず終了

    loda,r0 FStack,r2
    eori,r0 80h
    stra,r0 FStack,r2

    retc,un

    ;-------------------
    ;fadd
    ;[FStack+0][FStack+1] = [FStack+r1][FStack+r1+1] + [FStack+r2+0][FStack+r2+1]
    ;r0,r1,r2,r3を使用.  r1,r2は変化しない.
fadd:

    ;符号&指数部をr0,r3へ読み取り
    loda,r0 FStack+0,r2
    strz r3

    loda,r0 FStack+0,r1

    ;r1が0ならr2で上書きして終了
    comi,r0 00h
    bctr,eq _fadd_overwrite_r2
    comi,r0 80h
    bctr,eq _fadd_overwrite_r2

    ;r2が0ならr1で上書きして終了
    comi,r3 00h
    bctr,eq _fadd_overwrite_r1_
    comi,r3 80h
    bctr,eq _fadd_overwrite_r1_

    ;符号&指数部をxor
    eorz r3
    tmi,r0 080h
    bcta,eq _fa_diffsign

    ;同符号

    eorz r3 ; r0をxorする前の数値に戻す
    subz r3
    bcta,eq _fa_eqsign_0
    comi,r0 9
    bctr,lt _fa_eqsign_lt9_r1
    comi,r0 -9
    bcta,gt _fa_eqsign_gt9_r1

    ;指数差が9以上. どちらかに上書きして終了
    ;MEMO: 9ジャストなら仮数部を+1した方が真値に近くなるけどやるべき？
    ;+1による（恐らく極々わずかな）精度向上 vs １０未満の命令の実行速度   
    ;判断がつかない・・とりま無しで
    tmi,r0 80h
    bctr,lt _fadd_overwrite_r1 ; [FStack+r1+0] - [FStack+r2+0] の結果の符号が+, r1のが大きい.

_fadd_overwrite_r2:
    ;[FStack+0][FStack+1] = [FStack+r2+0][FStack+r2+1]
    stra,r3 FStack+0
    loda,r0 FStack+1,r2
    stra,r0 FStack+1
    retc,un

_fadd_overwrite_r1:
    ;[FStack+0][FStack+1] = [FStack+r1+0][FStack+r1+1]
    addz r3 
_fadd_overwrite_r1_:
    stra,r0 FStack+0
    loda,r0 FStack+1,r1
    stra,r0 FStack+1
    retc,un
    
_fa_eqsign_lt9_r1:
    ;r1のが大きい, 指数の差は1~8

    ;r2の仮数部をシフトしてr1の仮数部の桁とそろえる
    strz r3
    loda,r0 FStack+1,r2
    bsta,un mantissa_rshift
    
    ;仮数部を加算
    adda,r0 FStack+1,r1
    tpsl 1                  ;仮数部の加算で桁上がりが起こったか
    bcfr,eq _fa_eqsign_lt9_r1_nc

    ;桁上がりが起こった. ケチ表現のビットと合わさって 1.0xxxになる
    rrr,r0
    andi,r0 7fh
    stra,r0 FStack+1        ;仮数部を保存

    loda,r0 FStack+0,r1
    strz r3
    addi,r0 1
    stra,r0 FStack+0        ;指数部を保存

    ;符号ビットが変化してないかチェック
    eorz r3
    tmi,r0 80h
    retc,lt
    bsta,eq fexception      ;インクリメントして符号ビットが変化した=指数部がオーバーフローした
    
_fa_eqsign_lt9_r1_nc:
    stra,r0 FStack+1        ;仮数部を保存
    loda,r0 FStack+0,r1 
    stra,r0 FStack+0        ;指数部を保存
    retc,un
    
_fa_eqsign_gt9_r1:
    ;r2のが大きい, 指数の差は-1～-8

    ;r0に入ってる指数差の符号反転
    eori,r0 0ffh
    addi,r0 1   

    ;r1の仮数部をシフトしてr2の仮数部の桁とそろえる
    strz r3
    loda,r0 FStack+1,r1
    bsta,un mantissa_rshift
    
    ;仮数部を加算
    adda,r0 FStack+1,r2
    tpsl 1                  ;仮数部の加算で桁上がりが起こったか
    bcfr,eq _fa_eqsign_gt9_r1_nc

    ;桁上がりが起こった. ケチ表現のビットと合わさって 1.0xxxになる
    rrr,r0
    andi,r0 7fh
    stra,r0 FStack+1        ;仮数部を保存

    loda,r0 FStack+0,r2
    strz r3
    addi,r0 1
    stra,r0 FStack+0        ;指数部を保存

    ;符号ビットが変化してないかチェック
    eorz r3
    tmi,r0 80h
    retc,lt
    bsta,eq fexception      ;インクリメントして符号ビットが変化した=指数部がオーバーフローした
    
_fa_eqsign_gt9_r1_nc:
    stra,r0 FStack+1        ;仮数部を保存
    loda,r0 FStack+0,r2 
    stra,r0 FStack+0        ;指数部を保存
    retc,un
    
_fa_eqsign_0:
    ;指数差がない. 仮数部をそのまま加算
    
    loda,r0 FStack+1,r1
    adda,r0 FStack+1,r2
    rrr,r0              ;ケチ表現の仮数部の最上位ビットで桁上がりが発生している.ので現仮数部を右に１つずらす.  1.cxxx = 1.aaa + 1.bbb
    andi,r0 07fh        ;10.xxx = 1.aaa + 1.bbb とりま0にする
    tpsl 1              ;仮数部の加算で桁上がりが起こったか
    
    bcfr,eq _fa_eqsign_0_not_carry
    iori,r0 080h        ;11.xxx = 1.aaa + 1.bbb  桁上がりが起きたので仮数部の最上位に1をセット
_fa_eqsign_0_not_carry:

    ;仮数部を保存
    stra,r0 FStack+1

    ;指数をr0に読み込んで+1して保存   1x.yyyを1.xyyyへ
    lodz r3
    addi,r0 1
    stra,r0 FStack+0

    ;符号ビットが変化してないかチェック
    eorz r3
    tmi,r0 80h
    retc,lt
    bsta,eq fexception  ;加算して符号ビットが変化した=指数部がオーバーフローした

_fa_diffsign:

    ;異符号
    eorz r3 ; r0をxorする前の数値に戻す
    andi,r0 07fh    ;異符号なので指数部だけ比べるために符号ビット消す
    andi,r3 07fh
    subz r3
    bcta,eq _fa_diff_e_eq
    comi,r0 9
    bctr,lt _fa_diff_lt9_r1
    comi,r0 -9
    bctr,gt _fa_diff_gt9_r1
    
    ;指数差が9以上. どっちかに上書きして終了
    ;MEMO: 9ジャストなら-1した方が真値に近くなるけどやるべき？

    tmi,r0 80h
    bctr,lt _fa_ds_overwrite_r1 ; [FStack+r1+0] - [FStack+r2+0] の結果の符号が+, r1のが大きい.

_fa_ds_overwrite_r2:
    ;[FStack+0][FStack+1] = [FStack+r2+0][FStack+r2+1]
    loda,r0 FStack+0,r2
    stra,r0 FStack+0
    loda,r0 FStack+1,r2
    stra,r0 FStack+1
    retc,un

_fa_ds_overwrite_r1:
    ;[FStack+0][FStack+1] = [FStack+r1+0][FStack+r1+1]
    loda,r0 FStack+0,r1
    stra,r0 FStack+0
    loda,r0 FStack+1,r1
    stra,r0 FStack+1
    retc,un


_fa_diff_lt9_r1:
    ;r1のが大きい, 指数の差は1~8

    ;r2の仮数部をシフトしてr1の仮数部の桁とそろえる
    strz r3
    loda,r0 FStack+1,r2
    bsta,un mantissa_rshift
    strz r3

    ;仮数部を減算
    loda,r0 FStack+1,r1
    subz r3

    strz r3
    loda,r0 FStack+0,r1
    tpsl 1
    bcfa,eq _fa_diff_sub_r1_normalized    ;Cが立ってなければ正規化するフローに回す    
    
    ;Cが立ってる＝引き算で桁を借りなかった
    stra,r3 FStack+1    ;仮数部を保存
    stra,r0 FStack+0    ;指数部を保存
    retc,un

_fa_diff_gt9_r1:
    ;r2のが大きい, 指数の差は-1～-8

    ;r0に入ってる指数差の符号反転
    eori,r0 0ffh
    addi,r0 1   

    ;r1の仮数部をシフトしてr2の仮数部の桁とそろえる
    strz r3
    loda,r0 FStack+1,r1
    bsta,un mantissa_rshift
    strz r3

    ;仮数部を減算
    loda,r0 FStack+1,r2
    subz r3

    strz r3
    loda,r0 FStack+0,r2
    tpsl 1
    bcfr,eq _fa_diff_sub_r2_normalized    ;Cが立ってなければ正規化するフローに回す    
    
    ;Cが立ってる＝引き算で桁を借りなかった
    stra,r3 FStack+1    ;仮数部を保存
    stra,r0 FStack+0    ;指数部を保存
    retc,un

_fa_diff_e_eq:
    ;指数が同じ
    loda,r0 FStack+1,r1
    suba,r0 FStack+1,r2
    bcta,eq _fa_diff_e_eq_zero   ;指数が同じで仮数部も同じで符号だけ違う＝答えは０
    strz r3 
    tpsl 1                       ;suba,r0のキャリーをチェック
    bctr,eq _fa_diff_e_eq_r1     ;Cがたってる=減算時に桁を借りなかった.r1の仮数部の方が大きい

    ;r2の仮数部のが大きい. 結果の符号を反転
    eori,r3 0ffh
    addi,r3 1

    loda,r0 FStack,r2
    
_fa_diff_sub_r2_normalized:
    rrl,r3
    subi,r0 1
    tmi,r3 00000001b
    bcfr,eq _fa_diff_sub_r2_normalized
    andi,r3 0feh

    ;結果を保存
    stra,r0 FStack+0
    stra,r3 FStack+1

    ;オーバーフローチェック
    eora,r0 FStack,r2
    tmi,r0 80h
    bsta,eq fexception      ;符号ビットが変化した,オーバフロー発生

    andi,r0 7fh
    retc,gt
    bsta,un fexception      ;指数部が0になった
    
_fa_diff_e_eq_r1:
    ;r1の仮数部のが大きい
    loda,r0 FStack,r1
    
_fa_diff_sub_r1_normalized:
    rrl,r3
    subi,r0 1
    tmi,r3 00000001b
    bcfr,eq _fa_diff_sub_r1_normalized
    andi,r3 0feh

    ;結果を保存
    stra,r0 FStack+0
    stra,r3 FStack+1

    ;オーバーフローチェック
    eora,r0 FStack,r1
    tmi,r0 80h
    bsta,eq fexception      ;符号ビットが変化した,オーバフロー発生
    
    andi,r0 7fh
    retc,gt
    bsta,un fexception      ;指数部が0になった
    
_fa_diff_e_eq_zero:
    eorz r0
    stra,r0 FStack+0
    stra,r0 FStack+1
    retc,un

end ; End of assembly
