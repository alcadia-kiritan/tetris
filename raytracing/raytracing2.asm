    name raytracing          ; module name

    include "inc\arcadia.h"  ; v1.01

    org         0000H        ; Start of Arcadia ROM

programentry:
    eorz  r0                 ; Zero-out register 0
    bctr,un     programstart ; Branch to start of program
    retc,un                  ; Called on VSYNC or VBLANK?
                             ; As suggested by Paul Robson

programstart:
    ppsu        00100000b    ; Set Interrupt Inhibit bit
                             ; The Tech doc that Paul
                             ; wrote infers that Inter-
                             ; rupts aren't used
    
    ppsl 00000010b           ; COM=1

    ;lodi,r0 00000000b       ;ノーマルモード&通常解像度
    lodi,r0 01000000b       ;ノーマルモード&高解像度
    stra,r0 RESOLUTION
    ;lodi,r0 000001010b       ;通常解像度&背景白
    lodi,r0 10001010b       ;高解像度&背景白
    stra,r0 BGCOLOUR

    ;lodi,r0 00000000b
    ;stra,r0 PITCH

    ;スクロール位置を画面上端へ
    lodi,r0 0F0h
    stra,r0 CRTCVPR

    ;-------------
    ;RAM1           equ 18D0h   ;$18D0..$18EF are user RAM1 - 32 Byte 

    ScreenOffset    equ 18D0h
    Pixel           equ 18D1h
    LightPosition   equ 18D2h
    RayRotateY      equ 18D3h
    RayRotateX      equ 18D4h

    ;キー関係
    KeyData                     equ RayRotateX+1
    PrevP1LeftKeys              equ KeyData+0           ;1フレーム前のP1LEFTKEYSの値
    CountRepeatedP1LeftKeys     equ KeyData+1           ;押し続けた時のリピート処理用カウンタ, 前フレームと同じ値が来ると減算されて０になると押してる扱いになる
    PrevP1MiddleKeys            equ KeyData+2           ;1フレーム前のP1MIDDLEKEYSの値
    CountRepeatedP1MiddleKeys   equ KeyData+3    
    PrevP1RightKeys             equ KeyData+4           ;1フレーム前のP1RIGHTKEYSの値
    CountRepeatedP1RightKeys    equ KeyData+5

    RayPositionData             equ KeyData+6
    RayRootPositionX0           equ RayPositionData+0
    RayRootPositionX1           equ RayPositionData+1
    RayRootPositionY0           equ RayPositionData+2
    RayRootPositionY1           equ RayPositionData+3
    RayRootPositionZ0           equ RayPositionData+4
    RayRootPositionZ1           equ RayPositionData+5

    RAM1End                     equ RayRootPositionZ1+1
    IF RAM1End > 18EFh
        warning "RAM1がオーバーしてます"
    ENDIF

    ;RAM2           equ 18F8h   ;$18F8..$18FB are user RAM2 -  4 Byte
    Temporary0      equ 18F8h
    Temporary1      equ 18F9h
    Temporary2      equ 18FAh
    Temporary3      equ 18FBh
    Temporary0P1    equ 18F8h + 8*1024
    Temporary1P1    equ 18F9h + 8*1024
    Temporary2P1    equ 18FAh + 8*1024
    Temporary3P1    equ 18FBh + 8*1024

    FStack equ 1AD0h + PAGE1        ;$1AD0..$1AFF are user RAM3 - 48 Byte

    ;-------------

    ;AABBのmin,max
    lodi,r0 80h + EXPONENT_OFFSET   ; -1
    stra,r0 FStack+AabbFStackOffset+0 - PAGE1
    stra,r0 FStack+AabbFStackOffset+4 - PAGE1
    stra,r0 FStack+AabbFStackOffset+8 - PAGE1

    lodi,r0 EXPONENT_OFFSET         ; +1
    stra,r0 FStack+AabbFStackOffset+2 - PAGE1
    stra,r0 FStack+AabbFStackOffset+6 - PAGE1
    stra,r0 FStack+AabbFStackOffset+10 - PAGE1

    eorz r0
    stra,r0 FStack+AabbFStackOffset+1 - PAGE1
    stra,r0 FStack+AabbFStackOffset+3 - PAGE1
    stra,r0 FStack+AabbFStackOffset+5 - PAGE1
    stra,r0 FStack+AabbFStackOffset+7 - PAGE1
    stra,r0 FStack+AabbFStackOffset+9 - PAGE1
    stra,r0 FStack+AabbFStackOffset+11 - PAGE1

    ;レイの原点の初期化
    bsta,un set_ray_position

    bcta,un mainloop

get_pixel_color:
    eorz r0
    stra,r0 Pixel

    lodi,r0 MAX_FLOAT0
    stra,r0 FStack+RayTFStackOffset+0-PAGE1
    lodi,r0 MAX_FLOAT1
    stra,r0 FStack+RayTFStackOffset+1-PAGE1

    lodi,r1 RayDirFStackOffset
    lodi,r2 AabbFStackOffset
    bsta,un intersection_ray_and_aabb
    retc,lt

    loda,r0 Temporary2
    rrr,r0
    rrr,r0
    addi,r0 3h
    stra,r0 Pixel

    retc,un

rendering:
    eorz r0
    stra,r0 ScreenOffset

    ;上画面描画
rendering_upscr:

    bsta,un load_ray_root_position

    loda,r1 ScreenOffset
    bsta,un get_ray_up
    ;bsta,un get_ray        ;低解像度

    bsta,un rotate_ray_x_axis
    bsta,un rotate_ray_y_axis

    bstr,un get_pixel_color

    loda,r0 Pixel
    loda,r3 ScreenOffset
    stra,r0 SCRUPDATA,r3

    loda,r3 ScreenOffset
    addi,r3 1
    stra,r3 ScreenOffset
    comi,r3 16*13
    bcfr,eq rendering_upscr

    ;bcta,un rendering_end  ;低解像度

    eorz r0
    stra,r0 ScreenOffset

    ;下画面描画
rendering_loscr:

    bsta,un load_ray_root_position

    loda,r1 ScreenOffset
    bsta,un get_ray_lo

    bsta,un rotate_ray_x_axis
    bsta,un rotate_ray_y_axis

    bsta,un get_pixel_color

    loda,r0 Pixel
    loda,r3 ScreenOffset
    stra,r0 SCRLODATA,r3

    loda,r3 ScreenOffset
    addi,r3 1
    stra,r3 ScreenOffset
    comi,r3 16*13
    bcfr,eq rendering_loscr

rendering_end: 

    ;ライトの位置を進める
    loda,r0 LightPosition
    addi,r0 1
    stra,r0 LightPosition

    retc,un

    ;------------------------
mainloop:

    ;画面描画
    bsta,un rendering


    ;------
    ;キー操作

    ;1,q,a,zキー判定をr0へ
    loda,r0 P1LEFTKEYS
    lodi,r1 PrevP1LeftKeys - KeyData
    bsta,un button_process

    ;aキー, 視点を左回転
    stra,r0 Temporary0
    tmi,r0 0010b
    bcfr,eq _skip_a_key
    
    loda,r0 RayRotateY
    addi,r0 1
    stra,r0 RayRotateY

_skip_a_key:

    ;3,e,d,cキー判定をr0へ
    loda,r0 P1RIGHTKEYS
    lodi,r1 PrevP1RightKeys - KeyData
    bsta,un button_process  

    ;dキー, 視点を右回転
    stra,r0 Temporary0
    tmi,r0 0010b
    bcfr,eq _skip_d_key

    loda,r0 RayRotateY
    subi,r0 1
    stra,r0 RayRotateY

_skip_d_key:

    ;2,w,s,xキー判定をr0へ
    loda,r0 P1MIDDLEKEYS
    lodi,r1 PrevP1MiddleKeys - KeyData
    bsta,un button_process

    ;wキー, 視点を上回転
    stra,r0 Temporary0
    tmi,r0 0100b
    bcfr,eq _skip_w_key

    loda,r0 RayRotateX
    addi,r0 1
    stra,r0 RayRotateX

_skip_w_key:

    ;sキー, 視点を下回転
    loda,r0 Temporary0
    tmi,r0 0010b
    bcfr,eq _skip_s_key

    loda,r0 RayRotateX
    subi,r0 1
    stra,r0 RayRotateX

_skip_s_key:

    bsta,un set_ray_position

    bsta,un post_key_process

    bcta,un mainloop
    ;------------------------

    ;FStack上のオフセット
    RayDirFStackOffset      equ 18
    RayPosFStackOffset      equ RayDirFStackOffset+6
    RayTFStackOffset        equ RayPosFStackOffset+6
    AabbFStackOffset        equ RayTFStackOffset+2

    EndDefinedFStack        equ AabbFStackOffset+12

    IF EndDefinedFStack > 48
        warning "FStackの端っこ超えてる"
    ENDIF

    ;include "raytracing\get_ray.asm"
    include "raytracing\get_ray_up_lo.asm"

    FIRST_REPEAT_INTERVAL   equ 4-1        ;ボタンおしっぱのときに最初にリピート入力が有効になるまでのフレーム数
    REPEAT_INTERVAL         equ 1-1         ;リピート入力の間隔

    ;-------------------
    ;button_process
    ;押されているボタンのビットを立ててr0に格納して返す
    ;押されていると判断される条件は、次の２つ
    ;１．前フレームで押されていないボタンが押されていないとき
    ;２．ボタン押しっぱなしで以前押されたとされた状態から5フレーム経過したとき
    ;引数
    ;- r0: あるキーの状態(ビット単位で押されている押されてないが格納されている値, P1LEFTKEYSを読み取った値とか)
    ;- r1: 前フレームのキー状態のデータへのオフセット(KeyDataからのオフセット、PrevP1LeftKeys-KeyDataとか)
    ;
    ;r0,r1,r2を使用
    ;複数ボタンが押されてるとリピート回りが微妙な気がするけどヨシ！
button_process:

    strz r2                 ;現フレームのキー情報をr2へ退避    
    loda,r0 KeyData,r1      ;前のフレームのキー情報をr0に読み取り

    comz r2
    bctr,eq _button_process_same_button_state        ;前のフレームとキー状態が同じか？

    ;前のフレームとキー状態が異なる
    eori,r0 0ffh        ;前のフレームの情報を反転
    andz r2             ;今のフレームで押されたビット　＝　not 前のフレーム　and 今のフレーム
    retc,eq             ;ボタンが押されてなければ終了

    ;どこかのボタンが押された
    strz r2                 ;押されたボタンの情報をr2へ退避
    lodi,r0 FIRST_REPEAT_INTERVAL
    stra,r0 KeyData+1,r1    ;リピートのカウントを設定, 初回だけちょっと長め
    lodz r2
    retc,un                 ;終了

_button_process_same_button_state:
    ;前のフレームとキー状態が同じ
    comi,r2 0
    retc,eq             ;ボタンが押されてなければ終了

    loda,r0 KeyData+1,r1   ;リピートカウントを読み取り
    bcfr,eq _button_process_not_repeated

    ;リピートカウントが0になった
    lodi,r0 REPEAT_INTERVAL               ;リピートカウントをリセットして保存
    stra,r0 KeyData+1,r1
    lodz r2
    retc,un

_button_process_not_repeated:
    subi,r0 1
    stra,r0 KeyData+1,r1    ;減らしたリピートカウントを保存
    eorz r0                 ;ボタン何も押してない
    retc,un

    ;-------------------
    ;post_key_process
    ;現在の各キーの情報を前フレームの変数へ退避する
    ;r0を使用
post_key_process:
    loda,r0 P1LEFTKEYS
    stra,r0 PrevP1LeftKeys
    loda,r0 P1MIDDLEKEYS
    stra,r0 PrevP1MiddleKeys
    loda,r0 P1RIGHTKEYS
    stra,r0 PrevP1RightKeys
    retc,un

    ;-------------------
    ;load_ray_root_position
    ;RAM1にあるレイの原点をFStackへロードする
    ;r0を使用
load_ray_root_position:
    loda,r0 RayRootPositionX0
    stra,r0 FStack+RayPosFStackOffset+0 - PAGE1
    loda,r0 RayRootPositionX1
    stra,r0 FStack+RayPosFStackOffset+1 - PAGE1
    loda,r0 RayRootPositionY0
    stra,r0 FStack+RayPosFStackOffset+2 - PAGE1
    loda,r0 RayRootPositionY1
    stra,r0 FStack+RayPosFStackOffset+3 - PAGE1
    loda,r0 RayRootPositionZ0
    stra,r0 FStack+RayPosFStackOffset+4 - PAGE1
    loda,r0 RayRootPositionZ1
    stra,r0 FStack+RayPosFStackOffset+5 - PAGE1
    retc,un

    ;-------------------
    ;set_ray_position
    ;RayRotateY,RayRotateXからレイの原点を設定する
    ;r0,r1,r2,r3,Temporary0,Temporary1,Temporary2,Temporary3,FStack+0~7を使用
set_ray_position:

    ;レイの方向に-Zを書き込む（回転する前のレイの位置, 方向に書き込んでるのは回転ルーチンを使いまわす為
    eorz r0
    stra,r0 FStack+0+RayDirFStackOffset - PAGE1
    stra,r0 FStack+1+RayDirFStackOffset - PAGE1
    stra,r0 FStack+2+RayDirFStackOffset - PAGE1
    stra,r0 FStack+3+RayDirFStackOffset - PAGE1

    lodi,r0 EXPONENT_OFFSET+80h+1
    stra,r0 FStack+4+RayDirFStackOffset - PAGE1
    lodi,r0 40h
    stra,r0 FStack+5+RayDirFStackOffset - PAGE1

    bsta,un rotate_ray_x_axis
    bstr,un rotate_ray_y_axis

    loda,r0 RayRotateY
    addi,r0 64*3            ;-Zの位置がレイのデフォなのでRayRotateY=0のときに-Zになるようにずらす
    stra,r0 RayRotateY

    loda,r0 RayRotateY
    subi,r0 64*3
    stra,r0 RayRotateY
        
    loda,r0 FStack+0+RayDirFStackOffset - PAGE1
    stra,r0 RayRootPositionX0
    loda,r0 FStack+1+RayDirFStackOffset - PAGE1
    stra,r0 RayRootPositionX1
    loda,r0 FStack+2+RayDirFStackOffset - PAGE1
    stra,r0 RayRootPositionY0
    loda,r0 FStack+3+RayDirFStackOffset - PAGE1
    stra,r0 RayRootPositionY1
    loda,r0 FStack+4+RayDirFStackOffset - PAGE1
    stra,r0 RayRootPositionZ0
    loda,r0 FStack+5+RayDirFStackOffset - PAGE1
    stra,r0 RayRootPositionZ1

    retc,un

    ;-------------------
    ;rotate_ray_y_axis
    ;レイの方向をY軸でRayRotateY/256*2pi回転させる
    ;r0,r1,r2,r3,FStack+0~7を使用
rotate_ray_y_axis:

    ;x' = cos * x - sin * z
    ;z' = sin * x + cos * z

    ;FStack+2-3にcosをロード
    loda,r0 RayRotateY
    lodi,r1 2
    bsta,un fcos256

    ;cos * x をFStack+4-5へ
    lodi,r2 RayDirFStackOffset
    bsta,un fmul
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+4 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+5 - PAGE1

    ;cos * z をFStack+6-7へ
    lodi,r1 2
    lodi,r2 RayDirFStackOffset+4
    bsta,un fmul
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+6 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+7 - PAGE1

    ;FStack+2-3にsinをロード
    loda,r0 RayRotateY
    lodi,r1 2
    bsta,un fsin256
    
    ;sin * zをFStack+0へ
    lodi,r2 RayDirFStackOffset+4
    bsta,un fmul

    ;cos*x - sin*zをFStack+0へ
    lodi,r1 4
    lodi,r2 0
    bsta,un fsub

    ;FStack+0-1をFStack+4-5へ移動
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+4 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+5 - PAGE1

    ;sin * xをFStack+0へ
    lodi,r1 2
    lodi,r2 RayDirFStackOffset
    bsta,un fmul

    ;cos*z + sin*xをFStack+0へ
    lodi,r1 0
    lodi,r2 6
    bsta,un fadd

    ;z'を書き込み
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+RayDirFStackOffset+4 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+RayDirFStackOffset+5 - PAGE1

    ;x'を書き込み
    loda,r0 FStack+4 - PAGE1
    stra,r0 FStack+RayDirFStackOffset+0 - PAGE1
    loda,r0 FStack+5 - PAGE1
    stra,r0 FStack+RayDirFStackOffset+1 - PAGE1

    retc,un


    ;-------------------
    ;rotate_ray_x_axis
    ;レイの方向をX軸でRayRotateX/256*2pi回転させる
    ;r0,r1,r2,r3,FStack+0~7を使用
rotate_ray_x_axis:

    ;y' = cos * y - sin * z
    ;z' = sin * y + cos * z

    ;FStack+2-3にcosをロード
    loda,r0 RayRotateX
    lodi,r1 2
    bsta,un fcos256

    ;cos * y をFStack+4-5へ
    lodi,r2 RayDirFStackOffset+2
    bsta,un fmul
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+4 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+5 - PAGE1

    ;cos * z をFStack+6-7へ
    lodi,r1 2
    lodi,r2 RayDirFStackOffset+4
    bsta,un fmul
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+6 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+7 - PAGE1

    ;FStack+2-3にsinをロード
    loda,r0 RayRotateX
    lodi,r1 2
    bsta,un fsin256
    
    ;sin * zをFStack+0へ
    lodi,r2 RayDirFStackOffset+4
    bsta,un fmul

    ;cos*y - sin*zをFStack+0へ
    lodi,r1 4
    lodi,r2 0
    bsta,un fsub

    ;FStack+0-1をFStack+4-5へ移動
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+4 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+5 - PAGE1

    ;sin * yをFStack+0へ
    lodi,r1 2
    lodi,r2 RayDirFStackOffset+2
    bsta,un fmul

    ;cos*z + sin*xをFStack+0へ
    lodi,r1 0
    lodi,r2 6
    bsta,un fadd

    ;z'を書き込み
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+RayDirFStackOffset+4 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+RayDirFStackOffset+5 - PAGE1

    ;y'を書き込み
    loda,r0 FStack+4 - PAGE1
    stra,r0 FStack+RayDirFStackOffset+2 - PAGE1
    loda,r0 FStack+5 - PAGE1
    stra,r0 FStack+RayDirFStackOffset+3 - PAGE1

    retc,un

_page0_last_:
    if _page0_last_ > 4*1024
        warning "page0の末尾が4K超えてるよ"
    endif

    PAGE1 equ   8*1024
    org PAGE1

    include "raytracing\aabb.asm"


    include "flib\floating_point_number.asm"
    include "flib\fcom.asm"
    include "flib\fdiv.asm"
    include "flib\fadd.asm"
    include "flib\mantissa_rshift.asm"
    include "flib\fneg.asm"
    ;include "flib\fminmax.asm"
    include "flib\vec3.asm"
    include "flib\fmul.asm"
    include "flib\fsq.asm"
    include "flib\fsqrt.asm"
    include "flib\futil.asm"
    include "flib\fsincos256.asm"
    
_page1_last_:
    if _page1_last_ > 12*1024
        warning "page1の末尾が12K超えてるよ"
    endif

end ; End of assembly
