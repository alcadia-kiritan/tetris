    ;サウンド関係のサブルーチン群

    ;-------------------------------------------------------------------------
    ;定義が必要な変数
    ;SoundFrameCount        ;音節を何フレーム回すか
    ;SoundPriority          ;鳴らしてる音の優先度
    ;SoundDataAddress0      ;次に鳴らす音データのアドレス,01は並んでいること
    ;SoundDataAddress1

    ;-------------------------------------------------------------------------
    ;サブルーチン
    ;play_sound                 [r0:r1]にある音データを再生. 優先度は0
    ;play_sound_with_priority   [r0:r1]にある音データをr2の優先度で再生. 優先度が大きい音は、優先度が低い音に邪魔されない.
    ;sound_process              PITCHへの処理をやるサブルーチン. 垂直帰線直後などの定期的に同じタイミングで通る場所で呼ぶことを推奨

    ;-------------------------------------------------------------------------
    ;音データ仕様. @の後ろはbyte数
    ;[音データ] = [音節@2]+
    ;[音節]     = [鳴らすフレーム数@1][ピッチ@1]
    ;鳴らすフレーム数が0の場合は再生終了
    ;
    ;例）ピコッって鳴るデータ
    ;se1_data:
    ;db 01h   ;鳴らすフレーム数
    ;db 0ah   ;ピッチ
    ;db 03h   ;鳴らすフレーム数
    ;db 09h   ;ピッチ
    ;db 0     ;終端

    ;-------------------
    ;play_sound
    ;[r0:r1]に入ってる音データを鳴らす. 優先度は0
    ;r0,r1,r2を使用
play_sound:
    loda,r2 SoundPriority
    retc,gt                 ;今再生してる優先度が０より大きい.ので再生しない

    ;音データのアドレスをSoundDataAddress0/1に保存
    stra,r0 SoundDataAddress0
    stra,r1 SoundDataAddress1

    ;現在鳴らしてる音を打ち切り（最終フレーム扱いにする
    lodi,r0 1
    stra,r0 SoundFrameCount

    retc,un

    ;-------------------
    ;play_sound_with_priority
    ;[r0:r1]に入ってる音データを鳴らす. [r0:r1]にある音データをr2の優先度で再生. 優先度が大きい音は、優先度が低い音に邪魔されない.
    ;r0,r1を使用
play_sound_with_priority:
    coma,r2 SoundPriority
    retc,lt                 ;再生中の音の優先度のが高い. ので再生しない.

    stra,r2 SoundPriority

    ;音データのアドレスをSoundDataAddress0/1に保存
    stra,r0 SoundDataAddress0
    stra,r1 SoundDataAddress1

    ;現在鳴らしてる音を打ち切り（最終フレーム扱いにする
    lodi,r0 1
    stra,r0 SoundFrameCount
    retc,un

    ;-------------------
    ;sound_process
    ;[SoundDataAddress0:SoundDataAddress1]に入ってる音データを鳴らす
    ;r0,r1を使用
sound_process:
    loda,r0 SoundFrameCount
    retc,eq                 ;音は鳴ってない.
    
    ;カウント減らす
    subi,r0 1
    stra,r0 SoundFrameCount
    retc,gt ;カウンタがまだ残ってる終了
    
    ;次の音を鳴らす
    ;フレーム数読み込んでSoundFrameCountに保存
    loda,r0 *SoundDataAddress0
    bctr,eq _sp_stop
    stra,r0 SoundFrameCount
    
    ;ピッチを読み込んでPITCHに保存
    lodi,r1 1
    loda,r0 *SoundDataAddress0,r1
    loda,r1 PITCH
    andi,r1 80h
    addz r1
    stra,r0 PITCH

    ;音データのアドレスを次に進める
    loda,r0 SoundDataAddress1
    addi,r0 2
    comi,r0 2
    bcfr,lt _sp_skip_inc
    ;オーバーフローが起きた. 上位byteをインクリメント
    loda,r1 SoundDataAddress0
    addi,r1 1
    stra,r1 SoundDataAddress0
_sp_skip_inc:
    stra,r0 SoundDataAddress1
    retc,un

    ;音止める
_sp_stop:

    loda,r0 PITCH
    andi,r0 80h
    stra,r0 PITCH

    eorz r0
    stra,r0 SoundPriority
    stra,r0 SoundFrameCount
    retc,un

end ; End of assembly
