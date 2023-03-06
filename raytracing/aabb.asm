    name aabb          ; module name

    ;当たらなかった
_iraa_not_hit:
    ;FStack+0へ-1を格納, CCへltを格納してreturn
    eorz r0 
    stra,r0 FStack+3
    lodi,r0 80h + EXPONENT_OFFSET
    stra,r0 FStack+2
    retc,un

    ;-------------------
    ;intersection_ray_and_aabb
    ;AABBとレイ(B+Dt)の交差判定を行い衝突位置のtを[FStack+2~3]へ格納, t>=0で衝突しない場合はマイナス値を格納
    ;t>=0で衝突する場合はgtかeq, t<0の場合はltをCCへ返す
    ;当たった場合,X,Y,Zのいずれの面で当たったか(0~2)をTemporary2へ格納する
    ;
    ;[FStack+r1+0~5]に正規化されたレイの方向(D)
    ;[FStack+r1+6~11]にレイの開始位置(B)
    ;[FStack+r2+0~3]にAABBのminX,maxX
    ;[FStack+r2+4~7]にAABBのminY,maxY
    ;[FStack+r2+8~11]にAABBのminZ,maxZ
    ;r0,r1,r2,r3,Temporary0,Temporary1,Temporary2,[FStack+2~5]を使用.　
intersection_ray_and_aabb:

    stra,r1 Temporary0P1
    stra,r2 Temporary1P1

    ;事前の簡易判定
    ;各軸iに対して下記を満たすことをとりま確認. 満たさない場合は衝突しないので終了
    ;D_i >  0 なら B_i < max_i
    ;D_i <  0 なら B_i > min_i
    ;D_i == 0 なら min_i < B_i < max_i

    bsta,un f_is_eps
    bctr,eq _iraa_eq_dx_simple
    bctr,lt _iraa_lt_dx_simple

    ;Dx > 0
    addi,r1 6
    addi,r2 2
    bsta,un fcom    ;Bx ope maxX
    bcfr,lt _iraa_not_hit
    bctr,un _iraa_simple_y

_iraa_lt_dx_simple:
    ;Dx < 0
    addi,r1 6
    bsta,un fcom    ;Bx ope minX
    bcfr,gt _iraa_not_hit
    bctr,un _iraa_simple_y

_iraa_eq_dx_simple:
    ;Dx == 0
    
    addi,r1 6
    bsta,un fcom    ;Bx ope minX
    bcfr,gt _iraa_not_hit

    addi,r2 2
    bsta,un fcom    ;Bx ope maxX
    bcfr,lt _iraa_not_hit
    
_iraa_simple_y:

    addi,r1 -6+2
    loda,r2 Temporary1P1

    bsta,un f_is_eps
    bctr,eq _iraa_eq_dy_simple
    bctr,lt _iraa_lt_dy_simple

    ;Dy > 0
    addi,r1 6
    addi,r2 6
    bsta,un fcom    ;By ope maxY
    bcfa,lt _iraa_not_hit
    bctr,un _iraa_simple_z

_iraa_lt_dy_simple:
    ;Dy < 0
    addi,r1 6
    addi,r2 4
    bsta,un fcom    ;By ope minY
    bcfa,gt _iraa_not_hit
    bctr,un _iraa_simple_z

_iraa_eq_dy_simple:
    ;Dy == 0
    
    addi,r1 6
    addi,r2 4
    bsta,un fcom    ;By ope minY
    bcfa,gt _iraa_not_hit

    addi,r2 2
    bsta,un fcom    ;By ope maxY
    bcfa,lt _iraa_not_hit

_iraa_simple_z:

    addi,r1 -6+2
    loda,r2 Temporary1P1

    bsta,un f_is_eps
    bctr,eq _iraa_eq_dz_simple
    bctr,lt _iraa_lt_dz_simple

    ;Dz > 0
    addi,r1 6
    addi,r2 10
    bsta,un fcom    ;Bz ope maxZ
    bcfa,lt _iraa_not_hit
    bctr,un _iraa_simple_end

_iraa_lt_dz_simple:

    ;Dz < 0
    addi,r1 6
    addi,r2 8
    bsta,un fcom    ;Bz ope minZ
    bcfa,gt _iraa_not_hit
    bctr,un _iraa_simple_end

_iraa_eq_dz_simple:

    ;Dz == 0    
    addi,r1 6
    addi,r2 8
    bsta,un fcom    ;Bz ope minZ
    bcfa,gt _iraa_not_hit

    addi,r2 2
    bsta,un fcom    ;Bz ope maxZ
    bcfa,lt _iraa_not_hit

_iraa_simple_end:

    ;FStack+2-3に0.0を格納, tmin
    eorz r0
    stra,r0 FStack+2
    stra,r0 FStack+3

    ;FStack+4-5に最大値を格納, tmax
    lodi,r0 MAX_FLOAT0
    stra,r0 FStack+4
    lodi,r0 MAX_FLOAT1
    stra,r0 FStack+5

    ;各軸iに対して下記を計算しtmin(初期値0),tmax(初期値FMAX)を更新
    ;if D_i > 0なら
    ;  tmin = max(tmin, (min_i-B_i)/D_i)
    ;  tmax = min(tmax, (max_i-B_i)/D_i)
    ;if D_i < 0なら
    ;  tmin = max(tmin, (max_i-B_i)/D_i)
    ;  tmax = min(tmax, (min_i-B_i)/D_i)
    ;if D_i == 0ならスルー
    ;途中でtmin >= tmaxにならないなら最小のtの面に対し交点を持つ

    
    loda,r1 Temporary0P1
    loda,r2 Temporary1P1

    ;Dxを0と比較
    bsta,un f_is_eps
    bcta,eq _iraa_skip_x_end    ;Dx == 0ならxの判定をスキップ
    bcta,gt _iraa_gt_dx     ;Dx > 0

    ;Dx < 0

    loda,r1 Temporary1P1
    addi,r1 2
    loda,r2 Temporary0P1
    addi,r2 6
    bsta,un fsub        ; Fstack+0 = maxX - Bx

    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dx

    ;初手のtminなので0超ならOK
    lodi,r1 0
    bsta,un fcom0
    bcfr,gt _iraa_skip_ltdx

    ;tminを更新
    loda,r0 FStack+0
    stra,r0 FStack+2
    loda,r0 FStack+1
    stra,r0 FStack+3

    eorz r0                 ;X面でヒット
    stra,r0 Temporary2P1

_iraa_skip_ltdx:

    loda,r1 Temporary1P1
    loda,r2 Temporary0P1
    addi,r2 6
    bsta,un fsub        ; Fstack+0 = minX - Bx
    
    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dx

    ;初手のtmaxなので,確定でtminを超える. tmaxを更新
    loda,r0 FStack+0
    stra,r0 FStack+4
    loda,r0 FStack+1
    stra,r0 FStack+5

    bcta,un _iraa_skip_x

_iraa_gt_dx:
    ;Dx > 0
    
    loda,r1 Temporary1P1
    loda,r2 Temporary0P1
    addi,r2 6
    bsta,un fsub        ; Fstack+0 = minX - Bx
    
    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dx

    ;初手のtminなので0超ならOK
    lodi,r1 0
    bsta,un fcom0
    bcfr,gt _iraa_skip_ltdx2

    ;tminを更新
    loda,r0 FStack+0
    stra,r0 FStack+2
    loda,r0 FStack+1
    stra,r0 FStack+3

    eorz r0                 ;X面でヒット
    stra,r0 Temporary2P1
    
_iraa_skip_ltdx2:

    loda,r1 Temporary1P1
    addi,r1 2
    loda,r2 Temporary0P1
    addi,r2 6
    bsta,un fsub        ; Fstack+0 = maxX - Bx

    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dx
    
    ;初手のtmaxなので,確定でtminを超える. tmaxを更新
    loda,r0 FStack+0
    stra,r0 FStack+4
    loda,r0 FStack+1
    stra,r0 FStack+5

_iraa_skip_x:
    loda,r1 Temporary0P1
    loda,r2 Temporary1P1

_iraa_skip_x_end:

    ;Dyを0と比較
    addi,r1 2
    bsta,un f_is_eps
    bcta,eq _iraa_skip_y_end    ;Dy == 0ならyの判定をスキップ
    bcta,gt _iraa_gt_dy     ;Dy > 0

    ;Dy < 0

    loda,r1 Temporary1P1
    addi,r1 6
    loda,r2 Temporary0P1
    addi,r2 8
    bsta,un fsub        ; Fstack+0 = maxY - By

    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dy

    ;tminと比較
    lodi,r1 0
    lodi,r2 2
    bsta,un fcom
    bcfr,gt _iraa_skip_ltdy

    ;tminを更新
    loda,r0 FStack+0
    stra,r0 FStack+2
    loda,r0 FStack+1
    stra,r0 FStack+3

    lodi,r0 1                 ;Y面でヒット
    stra,r0 Temporary2P1

_iraa_skip_ltdy:

    loda,r1 Temporary1P1
    loda,r2 Temporary0P1
    addi,r1 4
    addi,r2 8
    bsta,un fsub        ; Fstack+0 = minY - By
    
    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dy

    bcta,un _iraa_check_tmax

_iraa_gt_dy:
    ;Dy > 0
    
    loda,r1 Temporary1P1
    loda,r2 Temporary0P1
    addi,r1 4
    addi,r2 8
    bsta,un fsub        ; Fstack+0 = minY - By
    
    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dy

    ;tminを比較
    lodi,r1 0
    lodi,r2 2
    bsta,un fcom
    bcfr,gt _iraa_skip_lt_dy2

    ;tminを更新
    loda,r0 FStack+0
    stra,r0 FStack+2
    loda,r0 FStack+1
    stra,r0 FStack+3

    lodi,r0 1                ;Y面でヒット
    stra,r0 Temporary2P1
    
_iraa_skip_lt_dy2:

    loda,r1 Temporary1P1
    addi,r1 6
    loda,r2 Temporary0P1
    addi,r2 8
    bsta,un fsub        ; Fstack+0 = maxY - By

    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dy

_iraa_check_tmax:

    ;tmaxと比較
    lodi,r1 0
    lodi,r2 4
    bsta,un fcom
    bcfr,lt _iraa_skip_y_end

    ;tmaxを更新
    loda,r0 FStack+0
    stra,r0 FStack+4
    loda,r0 FStack+1
    stra,r0 FStack+5

    lodi,r1 2
    lodi,r2 4
    bsta,un fcom
    bcfa,lt _iraa_not_hit

_iraa_skip_y_end:

    loda,r1 Temporary0P1
    loda,r2 Temporary1P1

    ;Dzを0と比較
    addi,r1 4
    bsta,un f_is_eps
    bcta,eq _iraa_skip_z_end    ;Dz == 0ならzの判定をスキップ
    bcta,gt _iraa_gt_dz     ;Dz > 0

    ;Dz < 0

    loda,r1 Temporary1P1
    addi,r1 10
    loda,r2 Temporary0P1
    addi,r2 10
    bsta,un fsub        ; Fstack+0 = maxY - Bz

    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dz

    ;tminと比較
    lodi,r1 0
    lodi,r2 2
    bsta,un fcom
    bcfr,gt _iraa_skip_ltdz

    ;tminを更新
    loda,r0 FStack+0
    stra,r0 FStack+2
    loda,r0 FStack+1
    stra,r0 FStack+3

    lodi,r0 2                 ;Z面でヒット
    stra,r0 Temporary2P1

_iraa_skip_ltdz:

    loda,r1 Temporary1P1
    loda,r2 Temporary0P1
    addi,r1 8
    addi,r2 10
    bsta,un fsub        ; Fstack+0 = minZ - Bz
    
    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dz

    bcta,un _iraa_check_tmax_z

_iraa_gt_dz:
    ;Dz > 0
    
    loda,r1 Temporary1P1
    loda,r2 Temporary0P1
    addi,r1 8
    addi,r2 10
    bsta,un fsub        ; Fstack+0 = minZ - Bz
    
    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dz

    ;tminを比較
    lodi,r1 0
    lodi,r2 2
    bsta,un fcom
    bcfr,gt _iraa_skip_lt_dz2

    ;tminを更新
    loda,r0 FStack+0
    stra,r0 FStack+2
    loda,r0 FStack+1
    stra,r0 FStack+3

    lodi,r0 2                ;Z面でヒット
    stra,r0 Temporary2P1
    
_iraa_skip_lt_dz2:

    loda,r1 Temporary1P1
    addi,r1 10
    loda,r2 Temporary0P1
    addi,r2 10
    bsta,un fsub        ; Fstack+0 = maxY - Bz

    lodi,r1 0
    subi,r2 6
    bsta,un fdiv        ; FStack+0 = FStack+0 / Dz

_iraa_check_tmax_z:

    ;tmaxと比較
    lodi,r1 0
    lodi,r2 4
    bstr,un fcom
    bcfr,lt _iraa_skip_z_end

    ;tmaxを更新
    loda,r0 FStack+0
    stra,r0 FStack+4
    loda,r0 FStack+1
    stra,r0 FStack+5

_iraa_skip_z_end:

    lodi,r1 2
    lodi,r0 10h
    bsta,un fadd_mantissa   ;ゴミが出ることがあるので対策
    
    lodi,r2 4
    bstr,un fcom
    bcfa,lt _iraa_not_hit
    
    lodi,r0 MAX_FLOAT0
    coma,r0 FStack+4
    retc,gt

    bcta,un _iraa_not_hit

    eorz r0 ; CC=eq
    retc,un

end ; End of assembly
