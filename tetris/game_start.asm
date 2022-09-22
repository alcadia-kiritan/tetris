;ゲームスタート
    
    ;-------------------
    ;game_start_start
    ;ゲーム開始の開始時に呼ばれる
    ;r0,r1,r2,r3を使用
game_start_start:

    loda,r2 SPRITE0Y
    lodi,r3 SCROLL_Y
    
    ;現画面を下にスクロール
_gss:
    GAME_START_SCROLL equ 3
    subi,r2 GAME_START_SCROLL
    subi,r3 GAME_START_SCROLL

    bsta,un wait_vsync
    
    comi,r3 GAME_START_SCROLL
    bctr,lt _gss_start          ;下までスクロールした

    stra,r2 SPRITE0Y
    stra,r3 CRTCVPR

    bsta,un sound_process
    bctr,un _gss

_gss_start:

    eorz r0
    stra,r0 CRTCVPR

    retc,un

    ;-------------------
    ;game_start
    ;ゲーム開始シーン
    ;r0を使用
game_start:
    retc,un

    ;-------------------
    ;game_start_after_vsync
    ;ゲーム開始シーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_start_after_vsync:
    retc,un
    

end ; End of assembly
