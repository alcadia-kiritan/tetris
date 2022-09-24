I_TETROMINO_INDEX       equ 0
J_TETROMINO_INDEX       equ 1
L_TETROMINO_INDEX       equ 2
O_TETROMINO_INDEX       equ 3
S_TETROMINO_INDEX       equ 4
T_TETROMINO_INDEX       equ 5
Z_TETROMINO_INDEX       equ 6
    
    ;-------------------
    ;テトリミノの定義
    ;あるテトリミノのある回転角度でのブロックの座標が(0,0)からの相対位置で４つ並んでいる
    ;角度は０から始まって９０度ずつ回転した定義が４つ並んでいる
    ;０、９０，１８０，２７０度の定義が終わると次のテトリミノの定義になる
    ;
    ;並びは I, J, L, O, S, T, Z
    ;
    ;１テトリミノのデータサイズは32byte( (X + Y) * 4block * 4rotate )
TETROMINOS: ;テトリミノのブロックのオフセット
I_TETROMINO_0:          ;I型テトリミノの無回転でのブロック座標
    db          -1      ;1個目のブロックのxの相対位置
    db          0       ;1個目のブロックのyの相対位置
    db          0
    db          0
    db          1
    db          0
    db          2
    db          0

I_TETROMINO_90:
    db          0
    db          -2
    db          0
    db          -1
    db          0
    db          0
    db          0
    db          1

I_TETROMINO_180:
    db          2
    db          -1
    db          1
    db          -1
    db          0
    db          -1
    db          -1
    db          -1

I_TETROMINO_270:
    db          1
    db          1
    db          1
    db          0
    db          1
    db          -1
    db          1
    db          -2

J_TETROMINO_0:
    db          -1
    db          1
    db          -1
    db          0
    db          0
    db          0
    db          1
    db          0

J_TETROMINO_90:
    db          -1
    db          -1
    db          0
    db          -1
    db          0
    db          0
    db          0
    db          1

J_TETROMINO_180:
    db          1
    db          -1
    db          1
    db          0
    db          0
    db          0
    db          -1
    db          0

J_TETROMINO_270:
    db          1
    db          1
    db          0
    db          1
    db          0
    db          0
    db          0
    db          -1

L_TETROMINO_0:
    db          -1
    db          0
    db          0
    db          0
    db          1
    db          0
    db          1
    db          1

L_TETROMINO_90:
    db          0
    db          -1
    db          0
    db          0
    db          0
    db          1
    db          -1
    db          1

L_TETROMINO_180:
    db          1
    db          0
    db          0
    db          0
    db          -1
    db          0
    db          -1
    db          -1

L_TETROMINO_270:
    db          0
    db          1
    db          0
    db          0
    db          0
    db          -1
    db          1
    db          -1

O_TETROMINO_0:
    db          0
    db          0
    db          0
    db          1
    db          1
    db          0
    db          1
    db          1

O_TETROMINO_90:
    db          0
    db          0
    db          0
    db          1
    db          1
    db          0
    db          1
    db          1

O_TETROMINO_180:
    db          0
    db          0
    db          0
    db          1
    db          1
    db          0
    db          1
    db          1

O_TETROMINO_270:
    db          0
    db          0
    db          0
    db          1
    db          1
    db          0
    db          1
    db          1

S_TETROMINO_0:
    db          -1
    db          0
    db          0
    db          0
    db          0
    db          1
    db          1
    db          1

S_TETROMINO_90:
    db          0
    db          -1
    db          0
    db          0
    db          -1
    db          0
    db          -1
    db          1

S_TETROMINO_180:
    db          1
    db          0
    db          0
    db          0
    db          0
    db          -1
    db          -1
    db          -1

S_TETROMINO_270:
    db          0
    db          1
    db          0
    db          0
    db          1
    db          0
    db          1
    db          -1

T_TETROMINO_0:
    db          -1
    db          0
    db          0
    db          0
    db          0
    db          1
    db          1
    db          0

T_TETROMINO_90:
    db          0
    db          -1
    db          0
    db          0
    db          -1
    db          0
    db          0
    db          1

T_TETROMINO_180:
    db          1
    db          0
    db          0
    db          0
    db          0
    db          -1
    db          -1
    db          0

T_TETROMINO_270:
    db          0
    db          1
    db          0
    db          0
    db          1
    db          0
    db          0
    db          -1

Z_TETROMINO_0:
    db          -1
    db          1
    db          0
    db          1
    db          0
    db          0
    db          1
    db          0

Z_TETROMINO_90:
    db          -1
    db          -1
    db          -1
    db          0
    db          0
    db          0
    db          0
    db          1

Z_TETROMINO_180:
    db          1
    db          -1
    db          0
    db          -1
    db          0
    db          0
    db          -1
    db          0

Z_TETROMINO_270:
    db          1
    db          1
    db          1
    db          0
    db          0
    db          0
    db          0
    db          -1

FALL_CHECK_OFFSETS: ;落下処理するときにチェックするブロックのオフセット. チェックしなくて良い所は0CCh
FCO_I_TETROMINO_0:
    db          -1
    db          0
    db          0
    db          0
    db          1
    db          0
    db          2
    db          0

FCO_I_TETROMINO_90:
    db          0
    db          -2
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_I_TETROMINO_180:
    db          2
    db          -1
    db          1
    db          -1
    db          0
    db          -1
    db          -1
    db          -1

FCO_I_TETROMINO_270:
    db          1
    db          -2
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_J_TETROMINO_0:
    db          -1
    db          0
    db          0
    db          0
    db          1
    db          0
    db          0CCh
    db          0CCh

FCO_J_TETROMINO_90:
    db          -1
    db          -1
    db          0
    db          -1
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_J_TETROMINO_180:
    db          1
    db          -1
    db          0
    db          0
    db          -1
    db          0
    db          0CCh
    db          0CCh

FCO_J_TETROMINO_270:
    db          1
    db          1
    db          0
    db          -1
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_L_TETROMINO_0:
    db          -1
    db          0
    db          0
    db          0
    db          1
    db          0
    db          0CCh
    db          0CCh

FCO_L_TETROMINO_90:
    db          0
    db          -1
    db          -1
    db          1
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_L_TETROMINO_180:
    db          1
    db          0
    db          0
    db          0
    db          -1
    db          -1
    db          0CCh
    db          0CCh

FCO_L_TETROMINO_270:
    db          0
    db          -1
    db          1
    db          -1
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_O_TETROMINO_0:
    db          0
    db          0
    db          1
    db          0
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_O_TETROMINO_90:
    db          0
    db          0
    db          1
    db          0
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_O_TETROMINO_180:
    db          0
    db          0
    db          1
    db          0
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_O_TETROMINO_270:
    db          0
    db          0
    db          1
    db          0
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_S_TETROMINO_0:
    db          -1
    db          0
    db          0
    db          0
    db          1
    db          1
    db          0CCh
    db          0CCh

FCO_S_TETROMINO_90:
    db          0
    db          -1
    db          -1
    db          0
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_S_TETROMINO_180:
    db          1
    db          0
    db          0
    db          -1
    db          -1
    db          -1
    db          0CCh
    db          0CCh

FCO_S_TETROMINO_270:
    db          0
    db          0
    db          1
    db          -1
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_T_TETROMINO_0:
    db          -1
    db          0
    db          0
    db          0
    db          1
    db          0
    db          0CCh
    db          0CCh

FCO_T_TETROMINO_90:
    db          0
    db          -1
    db          -1
    db          0
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_T_TETROMINO_180:
    db          1
    db          0
    db          0
    db          -1
    db          -1
    db          0
    db          0CCh
    db          0CCh

FCO_T_TETROMINO_270:
    db          1
    db          0
    db          0
    db          -1
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_Z_TETROMINO_0:
    db          -1
    db          1
    db          0
    db          0
    db          1
    db          0
    db          0CCh
    db          0CCh

FCO_Z_TETROMINO_90:
    db          -1
    db          -1
    db          0
    db          0
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

FCO_Z_TETROMINO_180:
    db          1
    db          -1
    db          0
    db          -1
    db          -1
    db          0
    db          0CCh
    db          0CCh

FCO_Z_TETROMINO_270:
    db          1
    db          0
    db          0
    db          -1
    db          0CCh
    db          0CCh
    db          0CCh
    db          0CCh

;https://tetris.wiki/Super_Rotation_System
ROTATE90_KICK_OFFSETS: ;テトリスを左に回すときにチェックするオフセット. IとJLSTZの２つのテーブルのみ.
RKO90_I_TETROMINO_0:
    db          2
    db          0
    db          -1
    db          0
    db          2
    db          1
    db          -1
    db          -2

RKO90_I_TETROMINO_90:
    db          -1
    db          0
    db          2
    db          0
    db          -1
    db          2
    db          2
    db          -1

RKO90_I_TETROMINO_180:
    db          -2
    db          0
    db          1
    db          0
    db          -2
    db          -1
    db          1
    db          2

RKO90_I_TETROMINO_270:
    db          1
    db          0
    db          -2
    db          0
    db          1
    db          -2
    db          -2
    db          1

RKO90_JLSTZ_TETROMINO_0:
    db          1
    db          0
    db          1
    db          -1
    db          0
    db          2
    db          1
    db          2

RKO90_JLSTZ_TETROMINO_90:
    db          1
    db          0
    db          1
    db          1
    db          0
    db          -2
    db          1
    db          -2

RKO90_JLSTZ_TETROMINO_180:
    db          -1
    db          0
    db          -1
    db          -1
    db          0
    db          2
    db          -1
    db          2

RKO90_JLSTZ_TETROMINO_270:
    db          -1
    db          0
    db          -1
    db          1
    db          0
    db          -2
    db          -1
    db          -2

ROTATE270_KICK_OFFSETS: ;テトリスを右に回すときにチェックするオフセット. IとJLSTZの２つのテーブルのみ.
RKO270_I_TETROMINO_0:
    db          1
    db          0
    db          -2
    db          0
    db          1
    db          -2
    db          -2
    db          1

RKO270_I_TETROMINO_90:
    db          2
    db          0
    db          -1
    db          0
    db          2
    db          1
    db          -1
    db          -2

RKO270_I_TETROMINO_180:
    db          -1
    db          0
    db          2
    db          0
    db          -1
    db          2
    db          2
    db          -1

RKO270_I_TETROMINO_270:
    db          -2
    db          0
    db          1
    db          0
    db          -2
    db          -1
    db          1
    db          2

RKO270_JLSTZ_TETROMINO_0:
    db          -1
    db          0
    db          -1
    db          -1
    db          0
    db          2
    db          -1
    db          2

RKO270_JLSTZ_TETROMINO_90:
    db          1
    db          0
    db          1
    db          1
    db          0
    db          -2
    db          1
    db          -2

RKO270_JLSTZ_TETROMINO_180:
    db          1
    db          0
    db          1
    db          -1
    db          0
    db          2
    db          1
    db          2

RKO270_JLSTZ_TETROMINO_270:
    db          -1
    db          0
    db          -1
    db          1
    db          0
    db          -2
    db          -1
    db          -2

    ;-------------------
    ;描画用スプライトの定義

    ;四隅が欠けてるやつ. 完全に矩形で塗りつぶしてると単色なことも相まって視認性が悪い
BLOCK00a:
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b
    db          00000000b

BLOCK10a:
    db          01100000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          11110000b
    db          01100000b

BLOCK01a:
    db          00000110b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00001111b
    db          00000110b

BLOCK11a:
    db          01100110b
    db          11111111b
    db          11111111b
    db          11111111b
    db          11111111b
    db          11111111b
    db          11111111b
    db          01100110b


GHOST_BLOCK:
    db          01100000b
    db          11110000b
    db          10010000b
    db          10010000b
    db          10010000b
    db          10010000b
    db          11110000b
    db          01100000b

end
