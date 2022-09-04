    ;--------------------------------------
    ; clear_ram
    ; ram領域を0クリアする
    ; r0,r1を使用
clear_ram:
    eorz r0

    lodi,r1 32 
_clear_ram_ram1:
    stra,r0 18D0h,r1-
    brnr,r1 _clear_ram_ram1

    lodi,r1 4
_clear_ram_ram2:
    stra,r0 18F8h,r1-
    brnr,r1 _clear_ram_ram2
    
    lodi,r1 48
_clear_ram_ram3:
    stra,r0 1AD0h,r1-
    brnr,r1 _clear_ram_ram3

    retc,un ; return

    ;-------------------
    ;wait_vsync
    ;垂直帰線期間に入るまで待機
    ;MEMO:描画領域の最終行のデータをフェッチした時点で書き換え開始して良くない？
wait_vsync:
    tpsu 080h
    bctr,eq wait_vsync    ;非垂直帰線期間に入るのを待つ 7bit目が0になるのを待つ（垂直帰線期間で呼ばれてたらそれが終わるまで待つ
_wait_vsync:
    tpsu 080h
    bcfr,eq _wait_vsync    ;垂直帰線期間に入るのを待つ 7bit目が1になるのを待つ
    retc,un ; return

end
