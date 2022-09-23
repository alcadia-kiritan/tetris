
    ;--------------
    ;play_se1   ;回転音
    ;r0,r1,r2を使用
    ;ピコッ
play_se1:
    lodi,r0 se1_data>>8
    lodi,r1 se1_data&0ffh
    bcta,un play_sound
se1_data:
    db 01h   ;鳴らすフレーム数
    db 0ah   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se2       ;ホールドキャンセル
    ;r0,r1,r2を使用
    ;キピ(キャンセルっぽいおと？)
play_se2:
    lodi,r0 se2_data>>8
    lodi,r1 se2_data&0ffh
    bcta,un play_sound
se2_data:
    db 01h   ;鳴らすフレーム数
    db 08h   ;ピッチ
    db 01h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se3       ;t-spin
    ;r0,r1,r2を使用
    ;キポッ
play_se3:
    lodi,r0 se3_data>>8
    lodi,r1 se3_data&0ffh
    lodi,r2 6
    bcta,un play_sound_with_priority
se3_data:
    db 03h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 19h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 06h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se4       1行消えたとき
    ;r0,r1,r2を使用
    ;ピコッ
play_se4:
    lodi,r0 se4_data>>8
    lodi,r1 se4_data&0ffh
    lodi,r2 7
    bcta,un play_sound_with_priority
    
se4_data:
    db 02h   ;鳴らすフレーム数
    db 0ch   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 0bh   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se5   ハードドロップ
    ;r0,r1,r2を使用
    ;ぴぽっ
play_se5:
    lodi,r0 se5_data>>8
    lodi,r1 se5_data&0ffh
    bcta,un play_sound
    
se5_data:
    db 04h   ;鳴らすフレーム数
    db 0ch   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 1ah   ;ピッチ
    db 0     ;終端


    ;--------------
    ;play_se6       2行消えたとき
    ;r0,r1,r2を使用
    ;ぴここっ
play_se6:
    lodi,r0 se6_data>>8
    lodi,r1 se6_data&0ffh
    lodi,r2 8
    bcta,un play_sound_with_priority
    
se6_data:
    db 03h   ;鳴らすフレーム数
    db 08h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 10h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 14h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se7       3行消えたとき
    ;r0,r1,r2を使用
    ;ピロリロッ↘
play_se7:
    lodi,r0 se7_data>>8
    lodi,r1 se7_data&0ffh
    lodi,r2 9
    bcta,un play_sound_with_priority
    
se7_data:
    db 03h   ;鳴らすフレーム数
    db 04h   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 08h   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 0ch   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 10h   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 14h   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 18h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se8   ４行消えたとき
    ;r0,r1,r2を使用
    ;ピロリロピ
play_se8:
    lodi,r0 se8_data>>8
    lodi,r1 se8_data&0ffh
    lodi,r2 10
    bcta,un play_sound_with_priority
    
se8_data:
    db 03h   ;鳴らすフレーム数
    db 10h   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 0eh   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 0ch   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 0ah   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 08h   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 06h   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 04h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se9           ;行確定
    ;r0,r1,r2を使用
    ;ピロッ
play_se9:
    lodi,r0 se9_data>>8
    lodi,r1 se9_data&0ffh
    bcta,un play_sound
    
se9_data:
    db 02h   ;鳴らすフレーム数
    db 10h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 0ch   ;ピッチ
    db 0     ;終端


    ;--------------
    ;play_se10      ;左右移動
    ;r0,r1,r2を使用
    ;ピペツ
play_se10:
    lodi,r0 se10_data>>8
    lodi,r1 se10_data&0ffh
    bcta,un play_sound
se10_data:
    db 02h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 0ch   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se11      ;左右移動
    ;r0,r1,r2を使用
    ;ピペツ
play_se11:
    lodi,r0 se11_data>>8
    lodi,r1 se11_data&0ffh
    bcta,un play_sound
se11_data:
    db 02h   ;鳴らすフレーム数
    db 0ch   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se12      ;ゲームオーバー
    ;r0,r1,r2を使用
    ;ピペツ
play_se12:
    lodi,r0 se12_data>>8
    lodi,r1 se12_data&0ffh
    lodi,r2 20
    bcta,un play_sound_with_priority
se12_data:
    db 04h   ;鳴らすフレーム数
    db 30h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 34h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 38h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 3Ch   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 40h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 44h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 48h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 4Ch   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 50h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 54h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 58h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 5Ch   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 60h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 64h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 68h   ;ピッチ
    db 30h   ;鳴らすフレーム数
    db 6Ch   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se13      ;ゲームスタート
    ;r0,r1,r2を使用
    ;
play_se13:
    lodi,r0 se13_data>>8
    lodi,r1 se13_data&0ffh
    lodi,r2 20
    bcta,un play_sound_with_priority
se13_data:
    db 04h   ;鳴らすフレーム数
    db 20h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 1Ch   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 18h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 14h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 10h   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 0Ch   ;ピッチ
    db 04h   ;鳴らすフレーム数
    db 0Ah   ;ピッチ
    db 14h   ;鳴らすフレーム数
    db 09h   ;ピッチ
    db 0     ;終端

end
