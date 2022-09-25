;上画面を対象にしたテキスト描画

    ;-------------------
    ;draw_text_hiscr
    ;[SCRUPDATA+[game_hiscr_texts+r2]]へ[game_hiscr_texts+r2+1~5]から5文字書き込む
    ;r0,r1,r2,r3使用
draw_text_hiscr:
    lodi,r3 5
    loda,r0 game_hiscr_texts,r2
    strz r1
_dt5h:
    loda,r0 game_hiscr_texts,r2+
    stra,r0 PAGE1+SCRUPDATA-1,r1+
    bdrr,r3 _dt5h
    ;文字の前後１文字を塗りつぶす
    eorz r0
    stra,r0 PAGE1+SCRUPDATA-1,r1+
    stra,r0 PAGE1+SCRUPDATA-7,r1
    retc,un

    GAME_TEXT_X     equ 5
    GAME_TEXT_Y     equ 5

game_hiscr_texts:
text_game:
    db GAME_TEXT_Y*10h+GAME_TEXT_X
    db ASCII_OFFSET+'G'
    db ASCII_OFFSET+'A'
    db ASCII_OFFSET+'M'
    db ASCII_OFFSET+'E'
    db 0

text_clear:
    db (GAME_TEXT_Y+1)*10h+GAME_TEXT_X
    db ASCII_OFFSET+'C'
    db ASCII_OFFSET+'L'
    db ASCII_OFFSET+'E'
    db ASCII_OFFSET+'A'
    db ASCII_OFFSET+'R'

text_time:
    db (GAME_TEXT_Y+3)*10h+GAME_TEXT_X
    db ASCII_OFFSET+'T'
    db ASCII_OFFSET+'I'
    db ASCII_OFFSET+'M'
    db ASCII_OFFSET+'E'
    db 0

text_best:
    db (GAME_TEXT_Y+6)*10h+GAME_TEXT_X
    db ASCII_OFFSET+'B'
    db ASCII_OFFSET+'E'
    db ASCII_OFFSET+'S'
    db ASCII_OFFSET+'T'
    db 0

text_new:
    db (GAME_TEXT_Y+6)*10h+GAME_TEXT_X-5
    db 0
    db ASCII_OFFSET+'N'
    db ASCII_OFFSET+'E'
    db ASCII_OFFSET+'W'
    db 0

text_hold:
    db (SCREEN_CHARA_HEIGHT - HOLD_TETROMINO_Y-3)*10h+HOLD_TETROMINO_X/2-2
    db 0
    db ASCII_OFFSET+'H'
    db ASCII_OFFSET+'O'
    db ASCII_OFFSET+'L'
    db ASCII_OFFSET+'D'
    

text_next:
    db (SCREEN_CHARA_HEIGHT - NEXT_TETROMINO_Y-3)*10h+NEXT_TETROMINO_X/2-1
    db ASCII_OFFSET+'N'
    db ASCII_OFFSET+'E'
    db ASCII_OFFSET+'X'
    db ASCII_OFFSET+'T'
    db 0

end ; End of assembly
