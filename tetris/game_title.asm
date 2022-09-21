;タイトル画面
    
    ;-------------------
    ;game_title_start
    ;タイトルシーンの開始時に呼ばれる
    ;r0,r1,r2,r3を使用
game_title_start:

    ;スクロール位置を最下段にリセット
    eorz r0
    stra,r0 CRTCVPR

    ;垂直同期待ち
    bsta,un wait_vsync

    LOGO_X  equ 0
    LOGO_Y  equ 2
    SCRUP   equ SCRUPDATA+LOGO_X+LOGO_Y*10h

    LOGO_COLOR equ 0C0h

    lodi,r0 0Fh
    lodi,r1 8
_gts_set_sprite:
    stra,r0 UDC0DATA,r1-
    brnr,r1 _gts_set_sprite

    lodi,r0 0F0h
    lodi,r1 8
_gts_set_sprite2:
    stra,r0 UDC1DATA,r1-
    brnr,r1 _gts_set_sprite2
    
    lodi,r0 LOGO_COLOR + 03h
    stra,r0 SCRUP+0+10h*0
    stra,r0 SCRUP+1+10h*0
    stra,r0 SCRUP+3+10h*0
    stra,r0 SCRUP+4+10h*0

    lodi,r0 LOGO_COLOR + 03Dh
    stra,r0 SCRUP+2+10h*0
    stra,r0 SCRUP+1+10h*1
    stra,r0 SCRUP+1+10h*2
    stra,r0 SCRUP+1+10h*3
    stra,r0 SCRUP+1+10h*4
    
    retc,un
    

    ;-------------------
    ;game_over
    ;ゲームタイトルシーン
    ;r0を使用
game_title:
    retc,un

    ;-------------------
    ;game_title_after_vsync
    ;ゲームタイトルシーン（垂直同期後
    ;r0,r1,r2,r3を使用
game_title_after_vsync:

    loda,r0 CRTCVPR
    comi,r0 SCROLL_Y
    bctr,lt _gtav_scroll

    retc,un

_gtav_scroll:
    ;画面最下部から規定位置にスクロール
    addi,r0 1
    stra,r0 CRTCVPR
    retc,un

end ; End of assembly
