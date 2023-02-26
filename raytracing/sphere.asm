    name sphere          ; module name

    ;-------------------
    ;intersection_ray_and_sphere
    ;球(|P-C|=r)とレイ(B+Dt)の交差判定を行い衝突位置のtを[FStack+0~1]へ格納, t>=0で衝突しない場合はマイナス値を格納
    ;t>=0で衝突する場合はgtかeq, t<0の場合はltをCCへ返す
    ;
    ;[FStack+r1+0~5]に正規化されたレイの方向(D)
    ;[FStack+r1+6~11]にレイの開始位置(B)
    ;[FStack+r2+0~5]に球の中心位置(C)
    ;[FStack+r2+6~7]に球の半径の二乗(r^2)
    ;r0,r1,r2,r3,Temporary0,Temporary1,Temporary2,[FStack+2~15]を使用.　
intersection_ray_and_sphere:

    stra,r2 Temporary2P1

    ;レイのベクトル方程式 P=B+Dt   (|D|=1)
    ;球のベクトル方程式 |P|^2=r^2
    ;を解いてtの二次元方程式にすると
    ; at^2 + bt + c = 0
    ; a = |D|^2 = 1
    ; b = dot(B,D)
    ; c = |B|^2 - r^2
    ; t = -b +- sqrt(b^2-c)

    ;B: 球の中心が原点になるように移動したレイの開始位置をFStack+8~13へ書き込み
    lodi,r0 8
    addi,r1 6
    bsta,un vsub3

    ;-b: レイの開始位置とレイの方向の内積の符号を逆転したものをFStack+14~15へ書き込み
    subi,r1 6+4
    lodi,r2 8
    bsta,un vdot3
    loda,r0 FStack+0
    eori,r0 80h         ;符号反転
    stra,r0 FStack+14
    loda,r0 FStack+1
    stra,r0 FStack+15

    ;c: レイの開始位置のノルム - 球の半径の二乗をFStack+0~1へ書き込み
    lodi,r1 8
    bsta,un vnorm2
    lodi,r1 0
    loda,r2 Temporary2P1
    addi,r2 6
    bsta,un fsub

    ;b^2をFStack+2~3へ書き込み
    lodi,r1 14
    lodi,r2 2
    bsta,un fsq

    ;b^2-cをFStack+0~1へ書き込み
    lodi,r1 2
    lodi,r2 0
    bsta,un fsub

    lodi,r1 0
    bsta,un fcom0
    retc,lt                      ;b^2-cがマイナスなら交点なし

    ;sqrt(b^2-c)をFStack+2~3へ書き込み
    lodi,r1 0
    lodi,r2 2
    bsta,un fsqrt

    ;t0 = -b+sqrt(b^2-c)
    lodi,r1 14
    bsta,un fadd
    lodi,r1 0
    bsta,un fcom0
    bcfr,lt _iras_plus

    ;t0の結果がマイナスだった,答えにはならない

    ;t1=-b-sqrt(b^2-c)を計算
    lodi,r1 14
    bsta,un fsub

    lodi,r1 0
    bcta,un fcom0   ;t1を答え候補にして0と比較して直return

_iras_plus:

    ;t0の結果がプラスだった,答え候補, FStack+4~5へ保存
    loda,r0 FStack+0
    stra,r0 FStack+4
    loda,r0 FStack+1
    stra,r0 FStack+5

    ;t1=-b-sqrt(b^2-c)を計算
    lodi,r1 14
    bsta,un fsub

    lodi,r1 0
    bsta,un fcom0       ;t1を0と比較
    bctr,lt _iras_t0    ;t1がマイナスならt0を採用して終了

    ;t0,t1ともに0以上なので小さい方を返す

    lodi,r2 4
    bsta,un fcom        ;t1とt0を比較
    bctr,gt _iras_t0

    ;t1の方が小さいか同じ. 
    loda,r0 FStack+0    ;CC=gt or eq
    retc,un

_iras_t0:
    loda,r0 FStack+5
    stra,r0 FStack+1
    loda,r0 FStack+4    ;CC=gt or eq
    stra,r0 FStack+0
    retc,un

    ;-------------------
    ;simple_intersection_ray_and_sphere_without_normalized
    ;球(|P-C|=r)とレイ(B+Dt)の交差判定を行い
    ;0 <= t <= 1 で衝突する場合はgtかeq, それ以外ではltをCCへ返す
    ;
    ;[FStack+r1+0~5]にレイの方向(D)(正規化されていない)
    ;[FStack+r1+6~11]にレイの開始位置(B)
    ;[FStack+r2+0~5]に球の中心位置(C)
    ;[FStack+r2+6~7]に球の半径の二乗(r^2)
    ;r0,r1,r2,r3,Temporary0,Temporary1,Temporary2,Temporary3[FStack+2~17]を使用.　
simple_intersection_ray_and_sphere_without_normalized:

    stra,r1 Temporary2P1
    stra,r2 Temporary3P1

    ;レイのベクトル方程式 P=B+Dt   (|D|=1)
    ;球のベクトル方程式 |P|^2=r^2
    ;を解いてtの二次元方程式にすると
    ; at^2 + bt + c = 0
    ; a = |D|^2
    ; b = dot(B,D)
    ; c = |B|^2 - r^2
    ; t = (-b +- sqrt(b^2-ac))/a

    ;B: 球の中心が原点になるように移動したレイの開始位置をFStack+8~13へ書き込み
    lodi,r0 8
    addi,r1 6
    bsta,un vsub3

    ;-b: レイの開始位置とレイの方向の内積の符号を逆転したものをFStack+14~15へ書き込み
    subi,r1 6+4
    lodi,r2 8
    bsta,un vdot3
    loda,r0 FStack+0
    eori,r0 80h         ;符号反転
    stra,r0 FStack+14
    loda,r0 FStack+1
    stra,r0 FStack+15

    ;a: レイの方向のノルムをFStack+16~17へ書き込み
    loda,r1 Temporary2P1
    bsta,un vnorm2
    loda,r0 FStack+0
    stra,r0 FStack+16
    loda,r0 FStack+1
    stra,r0 FStack+17

    ;誤差対策にちょっと膨らませる
    lodi,r0 3
    lodi,r1 16
    bsta,un fadd_mantissa

    ;c: レイの開始位置のノルム - 球の半径の二乗をFStack+0~1へ書き込み
    lodi,r1 8
    bsta,un vnorm2
    lodi,r1 0
    loda,r2 Temporary3P1
    addi,r2 6
    bsta,un fsub

    ;FStack+0~1をcからacへ
    lodi,r2 16
    bsta,un fmul

    ;b^2をFStack+2~3へ書き込み
    lodi,r1 14
    lodi,r2 2
    bsta,un fsq

    ;b^2-acをFStack+0~1へ書き込み
    lodi,r1 2
    lodi,r2 0
    bsta,un fsub

    lodi,r1 0
    bsta,un fcom0
    retc,lt                      ;b^2-acがマイナスなら交点なし

    ;sqrt(b^2-ac)をFStack+2~3へ書き込み
    lodi,r1 0
    lodi,r2 2
    bsta,un fsqrt

    ;t0 = -b+sqrt(b^2-ac)
    lodi,r1 14
    bsta,un fadd
    lodi,r1 0
    bsta,un fcom0
    bcfr,lt _siras_plus

    ;t0の結果がマイナスだった,答えにはならない

    ;t1=-b-sqrt(b^2-ac)を計算
    lodi,r1 14
    bsta,un fsub

    lodi,r1 0
    bsta,un fcom0   ;t1を0と比較
    retc,lt         ;t1もマイナスだった

    lodi,r1 16
    lodi,r2 0      
    bcta,un fcom    ;a ope t1 を比較, 0 <= t <= 1ならgt,eqになる。直return

_siras_plus:

    ;t0の結果がプラスだった,答え候補, FStack+4~5へ保存
    loda,r0 FStack+0
    stra,r0 FStack+4
    loda,r0 FStack+1
    stra,r0 FStack+5

    ;t1=-b-sqrt(b^2-ac)を計算
    lodi,r1 14
    bsta,un fsub

    lodi,r1 0
    bsta,un fcom0       ;t1を0と比較
    bctr,lt _siras_t0    ;t1がマイナスならt0をaと比較

    ;t0,t1ともに0以上なので小さい方を選択

    lodi,r2 4
    bsta,un fcom        ;t1とt0を比較
    bctr,gt _siras_t0

    ;t1の方が小さいか同じ. 
    lodi,r1 16
    lodi,r2 0      
    bcta,un fcom    ;a ope t1 を比較, 0 <= t <= 1ならgt,eqになる。直return

_siras_t0:
    lodi,r1 16
    lodi,r2 4     
    bcta,un fcom    ;a ope t0 を比較, 0 <= t <= 1ならgt,eqになる。直return

end ; End of assembly
