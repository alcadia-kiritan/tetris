    name vec3          ; module name

    ;-------------------
    ;vdot3
    ;[FStack+0][FStack+1] = 
    ;   [FStack+r1+0][FStack+r1+1] * [FStack+r2+0][FStack+r2+1] + 
    ;   [FStack+r1+2][FStack+r1+3] * [FStack+r2+2][FStack+r2+3] + 
    ;   [FStack+r1+4][FStack+r1+5] * [FStack+r2+4][FStack+r2+5]
    ;r0,r1,r2,r3,Temporary0,Temporary1,FStack+2~7を使用
vdot3:
    stra,r1 Temporary0P1
    stra,r2 Temporary1P1
    bsta,un fmul

    ;x1*x2をFStack+2へ退避
    loda,r0 FStack+0
    stra,r0 FStack+2
    loda,r0 FStack+1
    stra,r0 FStack+3

    lodi,r1 2
    lodi,r2 2
    adda,r1 Temporary0P1
    adda,r2 Temporary1P1
    bsta,un fmul

    ;y1*y2をFStack+4へ退避
    loda,r0 FStack+0
    stra,r0 FStack+4
    loda,r0 FStack+1
    stra,r0 FStack+5

    lodi,r1 4
    lodi,r2 4
    adda,r1 Temporary0P1
    adda,r2 Temporary1P1
    bsta,un fmul

    ;z1*z2をFStack+6へ退避
    loda,r0 FStack+0
    stra,r0 FStack+6
    loda,r0 FStack+1
    stra,r0 FStack+7
    
    ;FStack+2~7を加算
    lodi,r1 2
    bctr,un vsum3

    ;-------------------
    ;vnorm2
    ;[FStack+0][FStack+1] = [FStack+r1+0][FStack+r1+1]^2 + [FStack+r1+2][FStack+r1+3]^2 + [FStack+r1+4][FStack+r1+5]^2
    ;r0,r1,r2,r3,FStack+2~7を使用.
    ;r1が0だと正常動作しないので注意
vnorm2:
    ;FStack+r1+0~5をFStack+2~7へ２乗してコピー
    lodi,r2 2
    bsta,un fsq

    addi,r1 2
    addi,r2 2
    bsta,un fsq

    addi,r1 2
    addi,r2 2
    bsta,un fsq

    lodi,r1 2
    ;vsum3へこのまま落す

    ;-------------------
    ;vsum3
    ;[FStack+0][FStack+1] = [FStack+r1+0][FStack+r1+1] + [FStack+r1+2][FStack+r1+3] + [FStack+r1+4][FStack+r1+5]
    ;情報落ち緩和のために値の小さいものから加算する. 
    ;r0,r1,r2,r3を使用.
    ;r1に0~1が含まれていると正しく動かないので注意
    ;
    ;MEMO:カハンの加算アルゴとかの方がいいか？
    ;精度は間違いなくカハンのが良いんだけどfadd/fsub演算回数が２回から６回になんのよなあ。
    ;[カハンいれてどれだけの精度向上があるか] とそれが [fadd/fsubが＋４回] に釣り合うか
    ;どうかって話になるけど、
    ;足す数が３つだけだと、切り捨てられるビットの合計の最大値が
    ;最終結果の仮数部の下位1bit分で、その分真値に近づくだけ（＝仮数部下位1bitの改善可能性）なので釣り合わない。
vsum3:
    loda,r0 FStack+0,r1
    strz r3

    loda,r0 FStack+2,r1

    comz r3
    bctr,lt _vsum3_2lt0

    ;FStack+2 >= FStack+0 
    strz r3

    loda,r0 FStack+4,r1

    comz r3
    bctr,lt _vsum3_2ge0_4lt2
    ; FStack+4 >= FStack+2 && FStack+2 >= FStack+0 
    ; 0と2を足して、そこに4を加える

_vsum3_2ge0_4ge2:    
    lodz r1
    strz r2
    addi,r2 2
    bsta,un fadd

    lodi,r1 0
    addi,r2 2
    bcta,un fadd

_vsum3_2ge0_4lt2:
    ; FStack+4 < FStack+2 && FStack+2 >= FStack+0 
    ; 0と4を足して、そこに2を加える

    lodz r1
    strz r2
    addi,r2 4
    bsta,un fadd

    lodi,r1 0
    subi,r2 2
    bcta,un fadd

_vsum3_2lt0:
    ;FStack+2 < FStack+0 

    loda,r0 FStack+4,r1

    comz r3
    bcfr,lt _vsum3_2ge0_4ge2

    ; FStack+4 < FStack+0 && FStack+2 < FStack+0 
    ; 2と4を足して、そこに0を加える

    lodz r1
    strz r2
    addi,r1 2
    addi,r2 4
    bsta,un fadd

    lodi,r1 0
    subi,r2 4
    bcta,un fadd


end ; End of assembly
