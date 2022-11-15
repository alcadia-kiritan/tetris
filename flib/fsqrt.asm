    name fsqrt          ; module name

    ;-------
    ;[FStack+r2+0][FStack+r2+1]へ0を書き込んで返す
_fsqrt_zero:
    eorz r0
    stra,r0 FStack+0,r2
    stra,r0 FStack+1,r2
    retc,un

    ;-------------------
    ;fsqrt
    ;[FStack+r2+0][FStack+r2+1] = sqrt([FStack+r1+0][FStack+r1+1])
    ;[FStack+r1+0][FStack+r1+1]がマイナス値の場合はプラス値として計算される
    ;r0,r1,r2を使用.  r1,r2は変化しない.
fsqrt:

    loda,r0 FStack+0,r1 ;指数部読み込み
    andi,r0 7fh
    bctr,eq _fsqrt_zero

    subi,r0 EXPONENT_OFFSET
    bctr,lt _fsqrt_minus

    ;指数がプラス

    rrr,r0                      ;全体を２分の１にして、最下位ビットを最上位ビットへ
    bctr,lt _fsqrt_plus_odd

    ;指数がプラスかつ偶数
    addi,r0 EXPONENT_OFFSET
    stra,r0 FStack+0,r2         ;指数部を書き込み

    loda,r0 FStack+1,r1
    loda,r0 sqrt_even_table,r0
    stra,r0 FStack+1,r2         ;仮数部を書き込み
    retc,un

_fsqrt_plus_odd:

    ;指数がプラスかつ奇数
    addi,r0 80h + EXPONENT_OFFSET   ;最上位ビットがたってるのでそれを消すのに80hを入れる
    stra,r0 FStack+0,r2             ;指数部を書き込み

    loda,r0 FStack+1,r1
    loda,r0 sqrt_odd_table,r0
    stra,r0 FStack+1,r2         ;仮数部を書き込み
    retc,un

_fsqrt_minus:
    ;指数がマイナス -1~-64

    rrr,r0                      ;全体を２分の１にして、最下位ビットを最上位ビットへ
    bctr,lt _fsqrt_minus_odd

    ;指数がプラスかつ偶数
    addi,r0 80h + EXPONENT_OFFSET     ;マイナス値の最上位ビットを右シフトした数値と、EXPONENT_OFFSETが合わさって繰り上がって最上位が消える
    stra,r0 FStack+0,r2         ;指数部を書き込み

    loda,r0 FStack+1,r1
    loda,r0 sqrt_even_table,r0
    stra,r0 FStack+1,r2         ;仮数部を書き込み
    retc,un

IF EXPONENT_OFFSET <> (80h>>1)
    warning EXPONENT_OFFSETが最上位ビットを右シフトした数値と一致しない
ENDIF
    
_fsqrt_minus_odd:
    ;指数がマイナスかつ奇数
    addi,r0 EXPONENT_OFFSET         ;マイナス値の最上位ビットを右シフトした数値と、EXPONENT_OFFSETが合わさって繰り上がって最上位が消える
    stra,r0 FStack+0,r2             ;指数部を書き込み

    loda,r0 FStack+1,r1
    loda,r0 sqrt_odd_table,r0
    stra,r0 FStack+1,r2         ;仮数部を書き込み
    retc,un

sqrt_even_table:
    db 0
    db 0
    db 0
    db 1
    db 1
    db 2
    db 2
    db 3
    db 3
    db 4
    db 4
    db 5
    db 5
    db 6
    db 6
    db 7
    db 7
    db 8
    db 8
    db 9
    db 9
    db 10
    db 10
    db 11
    db 11
    db 12
    db 12
    db 13
    db 13
    db 14
    db 14
    db 15
    db 15
    db 16
    db 16
    db 16
    db 17
    db 17
    db 18
    db 18
    db 19
    db 19
    db 20
    db 20
    db 21
    db 21
    db 22
    db 22
    db 22
    db 23
    db 23
    db 24
    db 24
    db 25
    db 25
    db 26
    db 26
    db 27
    db 27
    db 27
    db 28
    db 28
    db 29
    db 29
    db 30
    db 30
    db 31
    db 31
    db 32
    db 32
    db 32
    db 33
    db 33
    db 34
    db 34
    db 35
    db 35
    db 35
    db 36
    db 36
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
    db 42
    db 42
    db 42
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
    db 48
    db 49
    db 49
    db 50
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
    db 55
    db 56
    db 56
    db 57
    db 57
    db 57
    db 58
    db 58
    db 59
    db 59
    db 59
    db 60
    db 60
    db 61
    db 61
    db 61
    db 62
    db 62
    db 63
    db 63
    db 64
    db 64
    db 64
    db 65
    db 65
    db 65
    db 66
    db 66
    db 67
    db 67
    db 67
    db 68
    db 68
    db 69
    db 69
    db 69
    db 70
    db 70
    db 71
    db 71
    db 71
    db 72
    db 72
    db 73
    db 73
    db 73
    db 74
    db 74
    db 75
    db 75
    db 75
    db 76
    db 76
    db 76
    db 77
    db 77
    db 78
    db 78
    db 78
    db 79
    db 79
    db 80
    db 80
    db 80
    db 81
    db 81
    db 81
    db 82
    db 82
    db 83
    db 83
    db 83
    db 84
    db 84
    db 84
    db 85
    db 85
    db 86
    db 86
    db 86
    db 87
    db 87
    db 87
    db 88
    db 88
    db 89
    db 89
    db 89
    db 90
    db 90
    db 90
    db 91
    db 91
    db 91
    db 92
    db 92
    db 93
    db 93
    db 93
    db 94
    db 94
    db 94
    db 95
    db 95
    db 96
    db 96
    db 96
    db 97
    db 97
    db 97
    db 98
    db 98
    db 98
    db 99
    db 99
    db 99
    db 100
    db 100
    db 101
    db 101
    db 101
    db 102
    db 102
    db 102
    db 103
    db 103
    db 103
    db 104
    db 104
    db 104
    db 105
    db 105

sqrt_odd_table:
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
    db 113
    db 113
    db 114
    db 115
    db 115
    db 116
    db 117
    db 117
    db 118
    db 119
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
    db 128
    db 128
    db 129
    db 129
    db 130
    db 131
    db 131
    db 132
    db 133
    db 133
    db 134
    db 135
    db 135
    db 136
    db 137
    db 137
    db 138
    db 139
    db 139
    db 140
    db 141
    db 141
    db 142
    db 143
    db 143
    db 144
    db 144
    db 145
    db 146
    db 146
    db 147
    db 148
    db 148
    db 149
    db 150
    db 150
    db 151
    db 151
    db 152
    db 153
    db 153
    db 154
    db 155
    db 155
    db 156
    db 156
    db 157
    db 158
    db 158
    db 159
    db 160
    db 160
    db 161
    db 161
    db 162
    db 163
    db 163
    db 164
    db 164
    db 165
    db 166
    db 166
    db 167
    db 167
    db 168
    db 169
    db 169
    db 170
    db 170
    db 171
    db 172
    db 172
    db 173
    db 173
    db 174
    db 175
    db 175
    db 176
    db 176
    db 177
    db 178
    db 178
    db 179
    db 179
    db 180
    db 181
    db 181
    db 182
    db 182
    db 183
    db 183
    db 184
    db 185
    db 185
    db 186
    db 186
    db 187
    db 187
    db 188
    db 189
    db 189
    db 190
    db 190
    db 191
    db 192
    db 192
    db 193
    db 193
    db 194
    db 194
    db 195
    db 195
    db 196
    db 197
    db 197
    db 198
    db 198
    db 199
    db 199
    db 200
    db 201
    db 201
    db 202
    db 202
    db 203
    db 203
    db 204
    db 204
    db 205
    db 206
    db 206
    db 207
    db 207
    db 208
    db 208
    db 209
    db 209
    db 210
    db 211
    db 211
    db 212
    db 212
    db 213
    db 213
    db 214
    db 214
    db 215
    db 215
    db 216
    db 217
    db 217
    db 218
    db 218
    db 219
    db 219
    db 220
    db 220
    db 221
    db 221
    db 222
    db 222
    db 223
    db 224
    db 224
    db 225
    db 225
    db 226
    db 226
    db 227
    db 227
    db 228
    db 228
    db 229
    db 229
    db 230
    db 230
    db 231
    db 231
    db 232
    db 232
    db 233
    db 234
    db 234
    db 235
    db 235
    db 236
    db 236
    db 237
    db 237
    db 238
    db 238
    db 239
    db 239
    db 240
    db 240
    db 241
    db 241
    db 242
    db 242
    db 243
    db 243
    db 244
    db 244
    db 245
    db 245
    db 246
    db 246
    db 247
    db 247
    db 248
    db 248
    db 249
    db 249
    db 250
    db 250
    db 251
    db 251
    db 252
    db 252
    db 253
    db 253
    db 254
    db 254
    db 255

end ; End of assembly
