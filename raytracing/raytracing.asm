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

    ;キー関係
    KeyData                     equ LightPosition+1
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

    lodi,r0 80h + EXPONENT_OFFSET + 0
    stra,r0 FStack+Plane0FStackOffset+0 - PAGE1

    lodi,r0 EXPONENT_OFFSET + 0
    ;stra,r0 FStack+Plane1FStackOffset+0 - PAGE1

    lodi,r0 0h
    stra,r0 FStack+Plane0FStackOffset+1 - PAGE1
    ;stra,r0 FStack+Plane1FStackOffset+1 - PAGE1

    
    lodi,r0 0
    stra,r0 FStack + Sphere0FStackOffset+0 - PAGE1
    stra,r0 FStack + Sphere0FStackOffset+4 - PAGE1

    lodi,r0 EXPONENT_OFFSET+1
    stra,r0 FStack + Sphere0FStackOffset+2 - PAGE1

    lodi,r0 EXPONENT_OFFSET+1
    stra,r0 FStack + Sphere0FStackOffset+6 - PAGE1

    eorz r0
    stra,r0 FStack + Sphere0FStackOffset+1 - PAGE1
    stra,r0 FStack + Sphere0FStackOffset+3 - PAGE1
    stra,r0 FStack + Sphere0FStackOffset+5 - PAGE1
    stra,r0 FStack + Sphere0FStackOffset+7 - PAGE1

    eorz r0 
    stra,r0 FStack + LightPos0FStackOffset+0 - PAGE1
    stra,r0 FStack + LightPos0FStackOffset+1 - PAGE1
    stra,r0 FStack + LightPos0FStackOffset+4 - PAGE1
    stra,r0 FStack + LightPos0FStackOffset+5 - PAGE1

    lodi,r0 EXPONENT_OFFSET+1 + 80h
    stra,r0 FStack + LightPos0FStackOffset+0 - PAGE1
    stra,r0 FStack + LightPos0FStackOffset+1 - PAGE1

    lodi,r0 EXPONENT_OFFSET+2
    stra,r0 FStack + LightPos0FStackOffset+2 - PAGE1
    lodi,r0 80h
    stra,r0 FStack + LightPos0FStackOffset+3 - PAGE1

    ;レイの原点の初期化
    eorz r0
    stra,r0 RayRootPositionX0
    stra,r0 RayRootPositionX1
    stra,r0 RayRootPositionY0
    stra,r0 RayRootPositionY1
    stra,r0 RayRootPositionZ1

    lodi,r0 EXPONENT_OFFSET + 80h + 2
    stra,r0 RayRootPositionZ0

    lodi,r0 EXPONENT_OFFSET
    stra,r0 RayRootPositionY0

    bcta,un mainloop

get_pixel_color:
    eorz r0
    stra,r0 Pixel

    lodi,r0 MAX_FLOAT0
    stra,r0 FStack+RayTFStackOffset+0-PAGE1
    lodi,r0 MAX_FLOAT1
    stra,r0 FStack+RayTFStackOffset+1-PAGE1

IF 0
    lodi,r1 RayDirFStackOffset
    lodi,r2 Plane1FStackOffset
    bsta,un intersection_ray_and_z_plane
    bctr,lt _no_intersection_plane1

    lodi,r1 0
    lodi,r2 RayTFStackOffset
    bsta,un fcom
    bcfr,lt _no_intersection_plane1

    loda,r0 FStack+0-PAGE1
    stra,r0 FStack+RayTFStackOffset+0-PAGE1
    loda,r0 FStack+1-PAGE1
    stra,r0 FStack+RayTFStackOffset+1-PAGE1
    
    ;lodi,r0 0C3h
    ;stra,r0 Pixel

_no_intersection_plane1:
ENDIF

    lodi,r1 RayDirFStackOffset
    lodi,r2 Sphere0FStackOffset
    bsta,un intersection_ray_and_sphere
    bcta,lt _no_intersection_sphere0

    loda,r0 FStack+0-PAGE1
    stra,r0 FStack+RayTFStackOffset+0-PAGE1
    loda,r0 FStack+1-PAGE1
    stra,r0 FStack+RayTFStackOffset+1-PAGE1

    lodi,r1 RayTFStackOffset
    lodi,r2 RayDirFStackOffset
    lodi,r0 8
    bsta,un vmul3

    lodi,r1 8
    lodi,r2 RayPosFStackOffset
    lodi,r0 8
    bsta,un vadd3

    lodi,r1 8
    lodi,r2 Sphere0FStackOffset
    lodi,r0 8
    bsta,un vsub3

    lodi,r1 LightPos0FStackOffset
    lodi,r2 Sphere0FStackOffset
    lodi,r0 2
    bsta,un vsub3

    lodi,r1 2
    lodi,r2 8
    bsta,un vdot3

    lodi,r1 0
    bsta,un fcom0    

    bcfr,lt _sphere_shadow

    lodi,r0 043h
    stra,r0 Pixel
    bctr,un _no_intersection_sphere0

_sphere_shadow:
    lodi,r0 003h
    stra,r0 Pixel

_no_intersection_sphere0:


    lodi,r1 RayDirFStackOffset
    lodi,r2 Plane0FStackOffset
    bsta,un intersection_ray_and_y_plane

    bcta,lt _no_intersection_plane0

    lodi,r1 0
    lodi,r2 RayTFStackOffset
    bsta,un fcom
    bcfr,lt _no_intersection_plane0

    loda,r0 FStack+0-PAGE1
    stra,r0 FStack+RayTFStackOffset+0-PAGE1
    loda,r0 FStack+1-PAGE1
    stra,r0 FStack+RayTFStackOffset+1-PAGE1

    ;RayDirFStackOffset = レイの開始地点から当たった場所までのベクトル
    lodi,r1 RayTFStackOffset
    lodi,r2 RayDirFStackOffset
    lodi,r0 RayDirFStackOffset
    bsta,un vmul3

    ;RayPosFStackOffset = ワールド座標系での当たった場所の位置
    lodi,r1 RayDirFStackOffset
    lodi,r2 RayPosFStackOffset
    lodi,r0 RayPosFStackOffset
    bsta,un vadd3

    ;RayDirFStackOffset = 当たった場所からライトへのベクトル
    lodi,r1 LightPos0FStackOffset
    lodi,r2 RayPosFStackOffset
    lodi,r0 RayDirFStackOffset
    bsta,un vsub3

    lodi,r1 RayDirFStackOffset
    lodi,r2 Sphere0FStackOffset
    bsta,un simple_intersection_ray_and_sphere_without_normalized

    bctr,lt _lighting
    
    lodi,r0 0C3h
    stra,r0 Pixel
    bctr,un _no_intersection_plane0

_lighting:
    lodi,r0 083h
    stra,r0 Pixel

_no_intersection_plane0:

    retc,un

rendering:
    eorz r0
    stra,r0 ScreenOffset

    ;ライトの位置(X,Z)を書き込み

    loda,r0 LightPosition
    lodi,r1 LightPos0FStackOffset+0
    bsta,un fcos256
    bsta,un fquadruple


    loda,r0 LightPosition
    lodi,r1 LightPos0FStackOffset+4
    bsta,un fsin256
    bsta,un fquadruple


    ;上画面描画
rendering_upscr:

    bsta,un load_ray_root_position

    loda,r1 ScreenOffset
    bsta,un get_ray_up
    ;bsta,un get_ray        ;低解像度

    bsta,un get_pixel_color

    loda,r0 Pixel
    loda,r3 ScreenOffset
    stra,r0 SCRUPDATA,r3

    loda,r3 ScreenOffset
    addi,r3 1
    stra,r3 ScreenOffset
    comi,r3 16*13
    bcfa,eq rendering_upscr

    ;bcta,un rendering_end  ;低解像度

    eorz r0
    stra,r0 ScreenOffset

    ;下画面描画
rendering_loscr:

    bsta,un load_ray_root_position

    loda,r1 ScreenOffset
    bsta,un get_ray_lo

    bsta,un get_pixel_color

    loda,r0 Pixel
    loda,r3 ScreenOffset
    stra,r0 SCRLODATA,r3

    loda,r3 ScreenOffset
    addi,r3 1
    stra,r3 ScreenOffset
    comi,r3 16*13
    bcfa,eq rendering_loscr

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

    bsta,un load_ray_root_position

    ;キー操作での移動量をFStack+2~3へ書き込み
    lodi,r0 EXPONENT_OFFSET-3
    stra,r0 FStack+2 - PAGE1
    lodi,r0 0
    stra,r0 FStack+3 - PAGE1

    ;1,q,a,zキー判定をr0へ
    loda,r0 P1LEFTKEYS
    lodi,r1 PrevP1LeftKeys - KeyData
    bsta,un button_process

    ;aキー, 視点を左に移動
    stra,r0 Temporary0
    tmi,r0 0010b
    bcfr,eq _skip_a_key

    lodi,r1 RayPosFStackOffset+0
    lodi,r2 2
    bsta,un fsub
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+0 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+1 - PAGE1

_skip_a_key:

    ;qキー, 視点を奥に移動
    loda,r0 Temporary0
    tmi,r0 0100b
    bcfr,eq _skip_q_key

    lodi,r1 RayPosFStackOffset+4
    lodi,r2 2
    bsta,un fadd
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+4 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+5 - PAGE1

_skip_q_key:

    ;3,e,d,cキー判定をr0へ
    loda,r0 P1RIGHTKEYS
    lodi,r1 PrevP1RightKeys - KeyData
    bsta,un button_process  

    ;dキー, 視点を右に移動
    stra,r0 Temporary0
    tmi,r0 0010b
    bcfr,eq _skip_d_key

    lodi,r1 RayPosFStackOffset+0
    lodi,r2 2
    bsta,un fadd
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+0 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+1 - PAGE1

_skip_d_key:

    ;eキー, 視点を手前に移動
    loda,r0 Temporary0
    tmi,r0 0100b
    bcfr,eq _skip_e_key

    lodi,r1 RayPosFStackOffset+4
    lodi,r2 2
    bsta,un fsub
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+4 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+5 - PAGE1

_skip_e_key:

    ;2,w,s,xキー判定をr0へ
    loda,r0 P1MIDDLEKEYS
    lodi,r1 PrevP1MiddleKeys - KeyData
    bsta,un button_process

    ;wキー, 視点を上に移動
    stra,r0 Temporary0
    tmi,r0 0100b
    bcfr,eq _skip_w_key

    lodi,r1 RayPosFStackOffset+2
    lodi,r2 2
    bsta,un fadd
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+2 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+3 - PAGE1

_skip_w_key:

    ;sキー, 視点を上に移動
    loda,r0 Temporary0
    tmi,r0 0010b
    bcfr,eq _skip_s_key

    lodi,r1 RayPosFStackOffset+2
    lodi,r2 2
    bsta,un fsub
    loda,r0 FStack+0 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+2 - PAGE1
    loda,r0 FStack+1 - PAGE1
    stra,r0 FStack+RayPosFStackOffset+3 - PAGE1

_skip_s_key:

    bsta,un store_ray_root_position

    bsta,un post_key_process

    bcta,un mainloop
    ;------------------------

    ;FStack上のオフセット
    RayDirFStackOffset      equ 18
    RayPosFStackOffset      equ RayDirFStackOffset+6
    RayTFStackOffset        equ RayPosFStackOffset+6
    Plane0FStackOffset      equ RayTFStackOffset+2
    ;Plane1FStackOffset      equ Plane0FStackOffset+2
    Sphere0FStackOffset     equ Plane0FStackOffset+2
    LightPos0FStackOffset   equ Sphere0FStackOffset+8

    EndDefinedFStack        equ LightPos0FStackOffset+6

    IF EndDefinedFStack > 48
        warning "FStackの端っこ超えてる"
    ENDIF

    ;include "raytracing\get_ray.asm"
    include "raytracing\get_ray_up_lo.asm"

    FIRST_REPEAT_INTERVAL   equ 10-1        ;ボタンおしっぱのときに最初にリピート入力が有効になるまでのフレーム数
    REPEAT_INTERVAL         equ 5-1         ;リピート入力の間隔

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
    ;store_ray_root_position
    ;レイの原点@FStackをRAM1の変数へ書き込む
    ;r0を使用
store_ray_root_position:
    loda,r0 FStack+RayPosFStackOffset+0 - PAGE1
    stra,r0 RayRootPositionX0
    loda,r0 FStack+RayPosFStackOffset+1 - PAGE1
    stra,r0 RayRootPositionX1
    loda,r0 FStack+RayPosFStackOffset+2 - PAGE1
    stra,r0 RayRootPositionY0
    loda,r0 FStack+RayPosFStackOffset+3 - PAGE1
    stra,r0 RayRootPositionY1
    loda,r0 FStack+RayPosFStackOffset+4 - PAGE1
    stra,r0 RayRootPositionZ0
    loda,r0 FStack+RayPosFStackOffset+5 - PAGE1
    stra,r0 RayRootPositionZ1
    retc,un


_page0_last_:
    if _page0_last_ > 4*1024
        warning "page0の末尾が4K超えてるよ"
    endif

    PAGE1 equ   8*1024
    org PAGE1

    include "raytracing\plane.asm"
    include "raytracing\sphere.asm"

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
