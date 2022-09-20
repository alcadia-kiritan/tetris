
    ;--------------
    ;play_se1   ;回転音
    ;r0,r1を使用
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
    ;r0,r1を使用
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
    ;play_se3
    ;r0,r1を使用
    ;ｷﾋﾟｯ（電子音っぽい高い音
play_se3:
    lodi,r0 se3_data>>8
    lodi,r1 se3_data&0ffh
    bcta,un play_sound
se3_data:
    db 02h   ;鳴らすフレーム数
    db 04h   ;ピッチ
    db 01h   ;鳴らすフレーム数
    db 03h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se4
    ;r0,r1を使用
    ;ピコッ
play_se4:
    lodi,r0 se4_data>>8
    lodi,r1 se4_data&0ffh
    bcta,un play_sound
    
se4_data:
    db 03h   ;鳴らすフレーム数
    db 0ch   ;ピッチ
    db 03h   ;鳴らすフレーム数
    db 0ah   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se5   ハードドロップ
    ;r0,r1を使用
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
    ;play_se6
    ;r0,r1を使用
    ;ぴここっ
play_se6:
    lodi,r0 se6_data>>8
    lodi,r1 se6_data&0ffh
    bcta,un play_sound
    
se6_data:
    db 080h   ;鳴らすフレーム数
    db 08h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 10h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 18h   ;ピッチ
    db 02h   ;鳴らすフレーム数
    db 20h   ;ピッチ
    db 0     ;終端

    ;--------------
    ;play_se7
    ;r0,r1を使用
    ;ピロリロッ↘
play_se7:
    lodi,r0 se7_data>>8
    lodi,r1 se7_data&0ffh
    bcta,un play_sound
    
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
    ;r0,r1を使用
    ;ピロリロピ
play_se8:
    lodi,r0 se8_data>>8
    lodi,r1 se8_data&0ffh
    bcta,un play_sound
    
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
    ;r0,r1を使用
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
    ;r0,r1を使用
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

end
