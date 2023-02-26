    name plane          ; module name

    ;-------------------
    ;intersection_ray_and_y_plane
    ;y=dの平面とレイ(P+Dt)の交差判定を行い衝突位置のtを[FStack+0~1]へ格納, t>=0で衝突しない場合はマイナス値を格納
    ;t>=0で衝突する場合はgtかeq, t<0の場合はltをCCへ返す
    ;
    ;[FStack+r1+0~5]に正規化されたレイの方向(D)
    ;[FStack+r1+6~11]にレイの位置(P)
    ;[FStack+r2+0~1]に平面ax+by+cz+d=0(x=z=0,y=1)のdの値
    ;r0,r1,r2,r3,[FStack+2~3]を使用.　
intersection_ray_and_y_plane:

    addi,r1 2
    bsta,un fcom0
    bctr,eq _irayp_no_intersection  ;レイのyが0,衝突しない

    ;平面が原点を通るようにレイの開始位置Yをずらした数をFStack+0へ格納
    addi,r1 6
    bsta,un fsub

    ;レイのY方向のオフセットをr2へ格納
    lodz r1
    strz r2
    subi,r2 6

    ;レイの開始点と平面のY距離を、レイのY方向で割る
    lodi,r1 0
    bsta,un fdiv

    lodi,r1 0
    bsta,un fneg2

    ;tを0と比較し呼び出し元に直return
    bcta,un fcom0

    ;ltをCCへ格納しreturn
_irayp_no_intersection:
    lodi,r0 80h ;CC=lt
    retc,un

    ;-------------------
    ;intersection_ray_and_z_plane
    ;z=dの平面とレイ(P+Dt)の交差判定を行い衝突位置のtを[FStack+0~1]へ格納, t>=0で衝突しない場合はマイナス値を格納
    ;t>=0で衝突する場合はgtかeq, t<0の場合はltをCCへ返す. ltの場合はFStack+0~1は不定
    ;
    ;[FStack+r1+0~5]に正規化されたレイの方向(D)
    ;[FStack+r1+6~11]にレイの位置(P)
    ;[FStack+r2+0~1]に平面ax+by+cz+d=0(x=y=0,z=1)のdの値
    ;r0,r1,r2,r3,[FStack+2~3]を使用.　
intersection_ray_and_z_plane:

    addi,r1 4
    bsta,un fcom0
    bctr,eq _irayp_no_intersection  ;レイのzが0,衝突しない

    ;平面が原点を通るようにレイの開始位置をずらした数をFStack+0へ格納
    addi,r1 6
    bsta,un fsub

    ;レイのZ方向のオフセットをr2へ格納
    lodz r1
    strz r2
    subi,r2 6

    ;レイの開始点と平面のZ距離を、レイのY方向で割る
    lodi,r1 0
    bsta,un fdiv

    lodi,r1 0
    bsta,un fneg2

    ;tを0と比較し呼び出し元に直return
    bcta,un fcom0



end ; End of assembly
