    name fmul          ; module name

    ;-------------------
    ;fdouble
    ;[FStack+r1+0][FStack+r1+1] = [FStack+r1+0][FStack+r1+1] * 2.0
    ;r0,r1を使用, r1は変化しない
fdouble:

    loda,r0 FStack+0,r1
    retc,eq             ;0なら終了

    comi,r0 80h
    retc,eq             ;0なら終了

    addi,r0 1
    stra,r0 FStack+0,r1
    retc,un

    ;-------------------
    ;fquadruple
    ;[FStack+r1+0][FStack+r1+1] = [FStack+r1+0][FStack+r1+1] * 4.0
    ;r0,r1を使用, r1は変化しない
fquadruple:

    loda,r0 FStack+0,r1
    retc,eq             ;0なら終了

    comi,r0 80h
    retc,eq             ;0なら終了

    addi,r0 2
    stra,r0 FStack+0,r1
    retc,un

    ;-------------------
    ;vmul3
    ;[FStack+r0+0~4][FStack+r0+1~5] = [FStack+r1+0][FStack+r1+1] * [FStack+r2+0~4][FStack+r2+1~5]
    ;r2(３次元ベクトル）のr1（スカラー）倍をr3（３次元ベクトル）へ書き込む
    ;r0,r1,r2,r3,Temporary0,Temporary1,Temporary2,FStack+0~1を使用
vmul3:
    stra,r1 Temporary0P1
    stra,r2 Temporary1P1
    stra,r0 Temporary2P1

    bsta,un fmul
    loda,r3 Temporary2P1
    loda,r0 FStack+0
    stra,r0 FStack+0,r3
    loda,r0 FStack+1
    stra,r0 FStack+1,r3

    loda,r1 Temporary0P1
    loda,r2 Temporary1P1
    addi,r2 2
    bstr,un fmul
    loda,r3 Temporary2P1
    loda,r0 FStack+0
    stra,r0 FStack+2,r3
    loda,r0 FStack+1
    stra,r0 FStack+3,r3

    loda,r1 Temporary0P1
    loda,r2 Temporary1P1
    addi,r2 4
    bstr,un fmul
    loda,r3 Temporary2P1
    loda,r0 FStack+0
    stra,r0 FStack+4,r3
    loda,r0 FStack+1
    stra,r0 FStack+5,r3

    retc,un


    ;-----
    ;[FStack+0][FStack+1]へ0を書き込んで返す
_fmul_zero:
    ;0確定
    eorz r0
    stra,r0 FStack+0
    stra,r0 FStack+1
    retc,un

    ;-------------------
    ;fmul
    ;[FStack+0][FStack+1] = [FStack+r1][FStack+r1+1] * [FStack+r2+0][FStack+r2+1]
    ;精度は下駄含めて8bit, 下駄を含めなければ7bit.
    ;仮数部の最下位ビットは真値と同じかどうかは保証されない.
    ;r0,r1,r2,r3を使用.
    ;fadd/fsubと異なり、r1,r2が破壊される.
fmul:

    loda,r0 FStack+0,r1
    andi,r0 07fh
    bctr,eq _fmul_zero      ;0確定
    strz r3

    loda,r0 FStack+0,r2
    andi,r0 07fh
    bctr,eq _fmul_zero      ;0確定

    ;指数部を加算してr3へ格納
    addz r3
    subi,r0 EXPONENT_OFFSET ;下駄が２個分あるので１つ消す
    bsfa,gt fexception      ;ltかeqなら指数がオーバーフローしてる
    strz r3
    
    ;符号を計算
    loda,r0 FStack+0,r1
    eora,r0 FStack+0,r2    
    andi,r0 080h
    
    addz r3 
    stra,r0 FStack+0        ;途中まで計算した指数部を書き込み

    ;r2/r1の仮数部を読み込み
    loda,r0 FStack+1,r2
    strz r2
    
    loda,r0 FStack+1,r1
    strz r1
    
    bstr,un _mantissa_mul8
    stra,r0 FStack+1        ;仮数部を書き込み
    ;右シフト量がr1に入ってる

    ;途中まで計算した指数部をr0,r2へ読み取り
    loda,r0 FStack+0
    strz r2

    addz r1
    stra,r0 FStack+0        ;指数部を書き込み

    eorz r2
    
    ;r1は0~1の加算のみなので符号ビットの変化だけ見ればOK
    bsta,lt fexception              ;lt,指数がオーバーフローした
    
    retc,un

    ;------
    ;r0(=r1)とr2を仮数部とみなして,
    ;その乗算結果のケチ表現の上位8bitをr0へ格納する
    ;r1へ仮数部の右シフト量を格納する
    ;
    ;r0,r1,r2,r3を使用
_mantissa_mul8:

    subz r2                 ;r0 = r1の仮数部 - r2の仮数部

    tpsl C
    bctr,eq _fmul_not_swap

    eori,r0 255
    addi,r0 1
    strz r3                 ;r3 = r0 = r2の仮数部 - r1の仮数部
    addz r1
    addz r1                 ;r0 = r1の仮数部 + r2の仮数部
    bctr,un _fmul_check_mantissa_ovf

_fmul_not_swap:
    ;r1の仮数部の方が大きい
    strz r3                 ;r3 = r1の仮数部 - r2の仮数部
    addz r2
    addz r2                 ;r0 = r1の科数部 + r2の仮数部

_fmul_check_mantissa_ovf:
    ;仮数部を足した数値が256以上かどうかをチェック
    strz r2                 ;r2 = r1の仮数部 + r2の仮数部
    tpsl C
    bctr,eq _fmul_mantissa_ovf

    ;仮数部を足した数値は256未満    
    ;(2^8+m1)*(2^8+m2) = 2^16 + (m1+m2)*2^8 + m1*m2
    ;の(m1+m2)がオーバーフローしない

    loda,r0 mul_table0_hi,r2
    suba,r0 mul_table0_hi,r3
    lodi,r1 0
    addz r2

    tpsl C          ;addz,r2で桁溢れしてたか？
    retc,lt         ;してないので終了

    ;[(m1+m2)] + [(m1*m2)の上位8bit] で桁上がり発生
    rrr,r0
    andi,r0 7fh
    addi,r1 1
    retc,un
    
_fmul_mantissa_ovf:
    ;仮数部を足した数値は256以上
    ;(2^8+m1)*(2^8+m2) = 2^16 + (m1+m2)*2^8 + m1*m2
    ;の(m1+m2)がオーバーフローする

    loda,r0 mul_table256_hi,r2
    suba,r0 mul_table0_hi,r3
    lodi,r1 1
    addz r2
    rrr,r0
    andi,r0 7fh
    
    tpsl C          ;addz,r2で桁溢れしてたか？
    retc,lt         ;してないので終了

    ;[(m1+m2)] + [(m1*m2)の上位8bit] で桁上がり発生
    iori,r0 80h     ; (m1+m2)のオーバーフローと今回の桁上がりで計２つなので最上位ビットを1に
    retc,un

mul_table0_hi:
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 0
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 1
    db 2
    db 2
    db 2
    db 2
    db 2
    db 2
    db 2
    db 2
    db 2
    db 2
    db 3
    db 3
    db 3
    db 3
    db 3
    db 3
    db 3
    db 3
    db 4
    db 4
    db 4
    db 4
    db 4
    db 4
    db 4
    db 4
    db 5
    db 5
    db 5
    db 5
    db 5
    db 5
    db 5
    db 6
    db 6
    db 6
    db 6
    db 6
    db 6
    db 7
    db 7
    db 7
    db 7
    db 7
    db 7
    db 8
    db 8
    db 8
    db 8
    db 8
    db 9
    db 9
    db 9
    db 9
    db 9
    db 9
    db 10
    db 10
    db 10
    db 10
    db 10
    db 11
    db 11
    db 11
    db 11
    db 12
    db 12
    db 12
    db 12
    db 12
    db 13
    db 13
    db 13
    db 13
    db 14
    db 14
    db 14
    db 14
    db 15
    db 15
    db 15
    db 15
    db 16
    db 16
    db 16
    db 16
    db 17
    db 17
    db 17
    db 17
    db 18
    db 18
    db 18
    db 18
    db 19
    db 19
    db 19
    db 19
    db 20
    db 20
    db 20
    db 21
    db 21
    db 21
    db 21
    db 22
    db 22
    db 22
    db 23
    db 23
    db 23
    db 24
    db 24
    db 24
    db 25
    db 25
    db 25
    db 25
    db 26
    db 26
    db 26
    db 27
    db 27
    db 27
    db 28
    db 28
    db 28
    db 29
    db 29
    db 29
    db 30
    db 30
    db 30
    db 31
    db 31
    db 31
    db 32
    db 32
    db 33
    db 33
    db 33
    db 34
    db 34
    db 34
    db 35
    db 35
    db 36
    db 36
    db 36
    db 37
    db 37
    db 37
    db 38
    db 38
    db 39
    db 39
    db 39
    db 40
    db 40
    db 41
    db 41
    db 41
    db 42
    db 42
    db 43
    db 43
    db 43
    db 44
    db 44
    db 45
    db 45
    db 45
    db 46
    db 46
    db 47
    db 47
    db 48
    db 48
    db 49
    db 49
    db 49
    db 50
    db 50
    db 51
    db 51
    db 52
    db 52
    db 53
    db 53
    db 53
    db 54
    db 54
    db 55
    db 55
    db 56
    db 56
    db 57
    db 57
    db 58
    db 58
    db 59
    db 59
    db 60
    db 60
    db 61
    db 61
    db 62
    db 62
    db 63
    db 63

mul_table256_hi:
    db 64
    db 64
    db 65
    db 65
    db 66
    db 66
    db 67
    db 67
    db 68
    db 68
    db 69
    db 69
    db 70
    db 70
    db 71
    db 71
    db 72
    db 72
    db 73
    db 73
    db 74
    db 74
    db 75
    db 76
    db 76
    db 77
    db 77
    db 78
    db 78
    db 79
    db 79
    db 80
    db 81
    db 81
    db 82
    db 82
    db 83
    db 83
    db 84
    db 84
    db 85
    db 86
    db 86
    db 87
    db 87
    db 88
    db 89
    db 89
    db 90
    db 90
    db 91
    db 92
    db 92
    db 93
    db 93
    db 94
    db 95
    db 95
    db 96
    db 96
    db 97
    db 98
    db 98
    db 99
    db 100
    db 100
    db 101
    db 101
    db 102
    db 103
    db 103
    db 104
    db 105
    db 105
    db 106
    db 106
    db 107
    db 108
    db 108
    db 109
    db 110
    db 110
    db 111
    db 112
    db 112
    db 113
    db 114
    db 114
    db 115
    db 116
    db 116
    db 117
    db 118
    db 118
    db 119
    db 120
    db 121
    db 121
    db 122
    db 123
    db 123
    db 124
    db 125
    db 125
    db 126
    db 127
    db 127
    db 128
    db 129
    db 130
    db 130
    db 131
    db 132
    db 132
    db 133
    db 134
    db 135
    db 135
    db 136
    db 137
    db 138
    db 138
    db 139
    db 140
    db 141
    db 141
    db 142
    db 143
    db 144
    db 144
    db 145
    db 146
    db 147
    db 147
    db 148
    db 149
    db 150
    db 150
    db 151
    db 152
    db 153
    db 153
    db 154
    db 155
    db 156
    db 157
    db 157
    db 158
    db 159
    db 160
    db 160
    db 161
    db 162
    db 163
    db 164
    db 164
    db 165
    db 166
    db 167
    db 168
    db 169
    db 169
    db 170
    db 171
    db 172
    db 173
    db 173
    db 174
    db 175
    db 176
    db 177
    db 178
    db 178
    db 179
    db 180
    db 181
    db 182
    db 183
    db 183
    db 184
    db 185
    db 186
    db 187
    db 188
    db 189
    db 189
    db 190
    db 191
    db 192
    db 193
    db 194
    db 195
    db 196
    db 196
    db 197
    db 198
    db 199
    db 200
    db 201
    db 202
    db 203
    db 203
    db 204
    db 205
    db 206
    db 207
    db 208
    db 209
    db 210
    db 211
    db 212
    db 212
    db 213
    db 214
    db 215
    db 216
    db 217
    db 218
    db 219
    db 220
    db 221
    db 222
    db 223
    db 224
    db 225
    db 225
    db 226
    db 227
    db 228
    db 229
    db 230
    db 231
    db 232
    db 233
    db 234
    db 235
    db 236
    db 237
    db 238
    db 239
    db 240
    db 241
    db 242
    db 243
    db 244
    db 245
    db 246
    db 247
    db 248
    db 249
    db 250
    db 251
    db 252
    db 253
    db 254

end ; End of assembly
