.model small
.stack 100h

SCREEN_W        equ 320
SCREEN_H        equ 200
VIDEO_SEG       equ 0A000h
MODE_13H        equ 0013h
MODE_TEXT       equ 0003h

SHIP_W          equ 20
SHIP_H          equ 20
AST_W           equ 10
AST_H           equ 10
MAX_AST         equ 5
MAX_BULLETS     equ 8

SHIP_MIN_X      equ 4
SHIP_MAX_X      equ 296
SHIP_MIN_Y      equ 20
SHIP_MAX_Y      equ 176
SHIP_STEP       equ 6

COLOR_BLACK     equ 0
COLOR_WHITE     equ 15
COLOR_YELLOW    equ 14
COLOR_RED       equ 12
COLOR_GREEN     equ 10
COLOR_CYAN      equ 11
COLOR_GRAY      equ 8

.data
exit_requested  db 0
game_over       db 0

ship_x          dw 150
ship_y          dw 166

score           dw 0
fuel            dw 100
fuel_tick       db 0
lives           db 3

last_tick       dw 0
rng_seed        dw 1234h
frame_counter   db 0
ast_speed_tick  db 0
invuln_timer    db 0

bullet_active   db MAX_BULLETS dup(0)
bullet_x        dw MAX_BULLETS dup(0)
bullet_y        dw MAX_BULLETS dup(0)

ast_active      db MAX_AST dup(1)
ast_x           dw 20,90,155,220,275
ast_y           dw 0,35,75,115,150
ast_dir         db 1,255,1,255,1

energy_active   db 1
energy_x        dw 145
energy_y        dw 40

explosion_active db 0
explosion_x      dw 0
explosion_y      dw 0
explosion_timer  db 0

msg_menu1       db 'ENTER para iniciar',0
msg_menu2       db 'Flechas: mover   ESPACIO: disparar   ESC: salir',0
msg_menu3       db 'Recoge energia y destruye asteroides',0

msg_title       db 'SPACE RAID - 8086',0
msg_score       db 'Puntos: ',0
msg_fuel        db 'Energia',0
msg_gameover    db 'GAME OVER',0
msg_restart     db 'ESC para salir',0
msg_lives       db 'UMG',0

ship_sprite label byte
    db 0,0,0,0,0,0,0,0,0,15,15,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,15,15,15,15,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,15,15,15,15,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,15,15,15,15,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,15,15,15,15,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,11,11,11,11,11,11,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,11,11,11,11,11,11,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,11,11,11,11,11,11,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,11,11,11,11,11,11,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0,0
    db 0,0,0,0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0,0
    db 0,0,1,1,1,1,9,9,9,9,9,9,9,9,1,1,1,1,0,0
    db 0,0,1,1,1,1,9,9,9,9,9,9,9,9,1,1,1,1,0,0
    db 0,0,1,1,1,1,9,9,9,9,9,9,9,9,1,1,1,1,0,0
    db 0,0,1,1,1,1,9,9,9,9,9,9,9,9,1,1,1,1,0,0
    db 0,0,1,1,1,1,9,9,9,9,9,9,9,9,1,1,1,1,0,0
    db 1,1,1,1,1,1,9,9,9,9,9,9,9,9,1,1,1,1,1,1
    db 1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,1,1,1,1
    db 1,1,1,1,0,0,0,12,12,14,14,12,12,0,0,0,1,1,1,1
    db 0,0,0,0,0,0,0,12,12,14,14,12,12,0,0,0,0,0,0,0

asteroid_sprite label byte
    db 0,0,0,8,8,8,8,0,0,0
    db 0,0,7,8,8,8,8,6,0,0
    db 0,7,0,0,0,8,8,6,6,0
    db 7,7,0,0,0,8,8,6,6,6
    db 8,8,0,0,0,8,8,6,6,6
    db 8,8,8,8,8,0,0,6,6,6
    db 8,8,8,8,8,0,0,6,6,6
    db 0,8,8,8,8,0,0,6,6,0
    db 0,0,6,6,6,6,6,6,0,0
    db 0,0,0,6,6,6,6,0,0,0

energy_sprite label byte
    db 10,10,10,10,10,10,10,10,10,10
    db 10,0,0,0,0,0,0,0,0,10
    db 10,0,0,2,2,2,2,0,0,10
    db 10,0,0,2,14,2,2,0,0,10
    db 10,0,0,2,14,2,2,0,0,10
    db 10,0,0,14,14,14,14,0,0,10
    db 10,0,0,2,14,2,2,0,0,10
    db 10,0,0,2,2,2,2,0,0,10
    db 10,0,0,0,0,0,0,0,0,10
    db 10,10,10,10,10,10,10,10,10,10

star_x          dw 12,31,55,80,112,146,175,205,238,272,305,25,68,121,164,217,260,310,44,98,190,244,288,155
star_y          dw 5,18,31,44,58,72,85,96,109,124,137,151,165,179,193,14,27,39,52,66,81,113,145,174

.code

start:
    mov ax,@data
    mov ds,ax
    cld
    call set_video
    call show_menu
    cmp exit_requested,1
    je quit_game
    call read_tick
    mov last_tick,dx
    mov rng_seed,dx

main_loop:
    call handle_input
    cmp exit_requested,1
    je quit_game

    cmp game_over,1
    je draw_only_gameover

    call update_game
    call check_collisions

draw_only_gameover:
    call render_frame
    call wait_frame
    jmp main_loop

quit_game:
    call set_text
    mov ax,4C00h
    int 21h

set_video proc near
    mov ax,MODE_13H
    int 10h
    ret
set_video endp

set_text proc near
    mov ax,MODE_TEXT
    int 10h
    ret
set_text endp

show_menu proc near
sm_redraw:
    call clear_screen

    mov dh,7
    mov dl,11
    call set_cursor
    mov si,offset msg_title
    mov bl,COLOR_CYAN
    call print_string

    mov dh,10
    mov dl,11
    call set_cursor
    mov si,offset msg_menu1
    mov bl,COLOR_YELLOW
    call print_string

    mov dh,12
    mov dl,2
    call set_cursor
    mov si,offset msg_menu2
    mov bl,COLOR_WHITE
    call print_string

    mov dh,14
    mov dl,3
    call set_cursor
    mov si,offset msg_menu3
    mov bl,COLOR_GREEN
    call print_string

sm_wait:
    mov ah,00h
    int 16h
    cmp al,27
    jne sm_enter
    mov exit_requested,1
    ret
sm_enter:
    cmp al,13
    jne sm_wait
    ret
show_menu endp

read_tick proc near
    push ax
    push cx
    mov ah,00h
    int 1Ah
    pop cx
    pop ax
    ret
read_tick endp

wait_frame proc near
    ; Sincroniza con el refresco vertical de VGA.
    ; Es mucho mas fluido que esperar el tick del BIOS (18.2 FPS).
    push ax
    push dx
    mov dx,03DAh
wf_wait_end:
    in al,dx
    test al,08h
    jnz wf_wait_end
wf_wait_start:
    in al,dx
    test al,08h
    jz wf_wait_start
    pop dx
    pop ax
    ret
wait_frame endp

handle_input proc near
    ; Lee varias teclas por cuadro para que el disparo no se pierda
    ; cuando el jugador tambien esta moviendo la nave.
    push cx
    mov cx,16
hi_poll:
    mov ah,01h
    int 16h
    jnz hi_read_key
    jmp hi_finish

hi_read_key:
    mov ah,00h
    int 16h

    cmp al,27
    jne key_space
    mov exit_requested,1
    jmp hi_finish

key_space:
    cmp game_over,1
    jne hi_check_space
    jmp hi_next

hi_check_space:
    cmp al,32
    jne key_extended
    call fire_bullet
    jmp hi_next

key_extended:
    cmp al,0
    jne hi_next
    cmp ah,48h
    je key_up
    cmp ah,50h
    je key_down
    cmp ah,4Bh
    je key_left
    cmp ah,4Dh
    je key_right
    jmp hi_next

key_up:
    mov ax,ship_y
    cmp ax,SHIP_MIN_Y+SHIP_STEP
    jb set_top
    sub ax,SHIP_STEP
    mov ship_y,ax
    jmp hi_next
set_top:
    mov ship_y,SHIP_MIN_Y
    jmp hi_next

key_down:
    mov ax,ship_y
    add ax,SHIP_STEP
    cmp ax,SHIP_MAX_Y
    jbe save_down
    mov ax,SHIP_MAX_Y
save_down:
    mov ship_y,ax
    jmp hi_next

key_left:
    mov ax,ship_x
    cmp ax,SHIP_MIN_X+SHIP_STEP
    jb set_left
    sub ax,SHIP_STEP
    mov ship_x,ax
    jmp hi_next
set_left:
    mov ship_x,SHIP_MIN_X
    jmp hi_next

key_right:
    mov ax,ship_x
    add ax,SHIP_STEP
    cmp ax,SHIP_MAX_X
    jbe save_right
    mov ax,SHIP_MAX_X
save_right:
    mov ship_x,ax
    jmp hi_next

hi_next:
    dec cx
    jz hi_finish
    jmp hi_poll
hi_finish:
    pop cx
    ret
handle_input endp

update_game proc near
    call update_bullets
    call update_invulnerability
    call update_explosion

    ; Dificultad progresiva:
    ; al inicio los asteroides bajan cada 2 cuadros,
    ; luego del puntaje 15 bajan cada cuadro.
    inc ast_speed_tick
    cmp score,15
    jae ug_fast_mode
    cmp ast_speed_tick,2
    jb ug_only_fuel
ug_fast_mode:
    mov ast_speed_tick,0
    call update_asteroids
    call update_energy
ug_only_fuel:
    call consume_fuel
    ret
update_game endp

update_explosion proc near
    cmp explosion_active,1
    jne uex_done
    cmp explosion_timer,0
    je uex_off
    dec explosion_timer
    jmp uex_done
uex_off:
    mov explosion_active,0
uex_done:
    ret
update_explosion endp

update_invulnerability proc near
    cmp invuln_timer,0
    je ui_done
    dec invuln_timer
ui_done:
    ret
update_invulnerability endp

consume_fuel proc near
    inc fuel_tick
    cmp fuel_tick,25
    jb cf_done
    mov fuel_tick,0
    cmp fuel,0
    je fuel_empty
    dec fuel
    jmp cf_done
fuel_empty:
    call lose_life
cf_done:
    ret
consume_fuel endp

fire_bullet proc near
    push ax
    push bx
    push cx
    push si

    mov cx,MAX_BULLETS
    xor si,si
fb_loop:
    cmp bullet_active[si],0
    je fb_found
    inc si
    loop fb_loop
    jmp fb_done

fb_found:
    mov bullet_active[si],1
    mov bx,si
    shl bx,1
    mov ax,ship_x
    add ax,9
    mov bullet_x[bx],ax
    mov ax,ship_y
    sub ax,3
    mov bullet_y[bx],ax
    call sound_shot

fb_done:
    pop si
    pop cx
    pop bx
    pop ax
    ret
fire_bullet endp

clear_bullets proc near
    push cx
    push si
    mov cx,MAX_BULLETS
    xor si,si
cb_loop:
    mov bullet_active[si],0
    inc si
    loop cb_loop
    pop si
    pop cx
    ret
clear_bullets endp

update_bullets proc near
    push ax
    push bx
    push cx
    push si

    mov cx,MAX_BULLETS
    xor si,si
ub_loop:
    cmp bullet_active[si],0
    je ub_next
    mov bx,si
    shl bx,1
    mov ax,bullet_y[bx]
    ; Si la bala esta cerca del borde superior, liberarla antes de restar.
    ; Esto evita underflow (por ejemplo 5 - 7 = 65534) y que el slot
    ; quede ocupado para siempre, bloqueando nuevos disparos.
    cmp ax,8
    jb ub_disable
    sub ax,7
    mov bullet_y[bx],ax
    jmp ub_next
ub_disable:
    mov bullet_active[si],0
    mov word ptr bullet_y[bx],0
    mov word ptr bullet_x[bx],0
ub_next:
    inc si
    loop ub_loop

    pop si
    pop cx
    pop bx
    pop ax
    ret
update_bullets endp

update_asteroids proc near
    push ax
    push bx
    push cx
    push si

    mov cx,MAX_AST
    xor si,si
ua_loop:
    mov bx,si
    shl bx,1

    mov ax,ast_y[bx]
    add ax,1
    cmp ax,199
    jbe ua_store_y
    call reset_asteroid
    jmp ua_next
ua_store_y:
    mov ast_y[bx],ax

    mov al,ast_dir[si]
    cmp al,1
    jne ua_left
ua_right:
    mov ax,ast_x[bx]
    inc ax
    cmp ax,305
    jbe ua_save_x
    mov ast_dir[si],255
    jmp ua_next
ua_left:
    mov ax,ast_x[bx]
    cmp ax,4
    ja ua_subx
    mov ast_dir[si],1
    jmp ua_next
ua_subx:
    dec ax
ua_save_x:
    mov ast_x[bx],ax

ua_next:
    inc si
    loop ua_loop

    pop si
    pop cx
    pop bx
    pop ax
    ret
update_asteroids endp

update_energy proc near
    cmp energy_active,1
    jne ue_maybe_spawn
    mov ax,energy_y
    add ax,1
    cmp ax,199
    jbe ue_save
    mov energy_active,0
    ret
ue_save:
    mov energy_y,ax
    ret
ue_maybe_spawn:
    inc frame_counter
    cmp frame_counter,160
    jb ue_done
    mov frame_counter,0
    call random_x
    mov energy_x,ax
    mov energy_y,0
    mov energy_active,1
ue_done:
    ret
update_energy endp

reset_asteroid proc near
    ; Entrada: SI = indice, BX = indice*2
    push ax
    call random_x
    mov ast_x[bx],ax
    mov ast_y[bx],0
    call random_bit
    cmp al,0
    je ra_left
    mov ast_dir[si],1
    jmp ra_done
ra_left:
    mov ast_dir[si],255
ra_done:
    pop ax
    ret
reset_asteroid endp

random_x proc near
    push bx
    push dx
    mov ax,rng_seed
    mov bx,25173
    mul bx
    add ax,13849
    mov rng_seed,ax
    xor dx,dx
    mov bx,300
    div bx
    mov ax,dx
    add ax,5
    pop dx
    pop bx
    ret
random_x endp

random_bit proc near
    mov ax,rng_seed
    and al,1
    ret
random_bit endp

check_collisions proc near
    call bullet_asteroid_collisions
    call ship_asteroid_collisions
    call ship_energy_collision
    ret
check_collisions endp

bullet_asteroid_collisions proc near
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    xor si,si
    mov cx,MAX_BULLETS
bac_bullet_loop:
    cmp bullet_active[si],0
    jne bac_check_asteroids
    jmp bac_next_bullet

bac_check_asteroids:
    mov bp,cx
    xor di,di
    mov cx,MAX_AST
bac_ast_loop:
    mov bx,si
    shl bx,1
    mov ax,bullet_x[bx]
    mov dx,bullet_y[bx]

    mov bx,di
    shl bx,1
    ; X dentro de asteroide
    cmp ax,ast_x[bx]
    jb bac_ast_next
    mov bx,di
    shl bx,1
    mov ax,ast_x[bx]
    add ax,AST_W
    push bx
    mov bx,si
    shl bx,1
    cmp bullet_x[bx],ax
    pop bx
    ja bac_ast_next

    ; Y dentro de asteroide
    mov bx,si
    shl bx,1
    mov ax,bullet_y[bx]
    mov bx,di
    shl bx,1
    cmp ax,ast_y[bx]
    jb bac_ast_next
    mov ax,ast_y[bx]
    add ax,AST_H
    push bx
    mov bx,si
    shl bx,1
    cmp bullet_y[bx],ax
    pop bx
    ja bac_ast_next

    mov bullet_active[si],0
    inc score
    push si
    mov si,di
    mov bx,si
    shl bx,1
    call activate_explosion
    call sound_explosion
    call reset_asteroid
    pop si
    jmp bac_restore_loop

bac_ast_next:
    inc di
    loop bac_ast_loop

bac_restore_loop:
    mov cx,bp
bac_next_bullet:
    inc si
    dec cx
    jz bac_finish
    jmp bac_bullet_loop

bac_finish:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
bullet_asteroid_collisions endp

ship_asteroid_collisions proc near
    cmp invuln_timer,0
    je sac_can_check
    ret
sac_can_check:
    push ax
    push bx
    push cx
    push si

    mov cx,MAX_AST
    xor si,si
sac_loop:
    mov bx,si
    shl bx,1

    mov ax,ship_x
    add ax,SHIP_W
    cmp ax,ast_x[bx]
    jb sac_next

    mov ax,ast_x[bx]
    add ax,AST_W
    cmp ax,ship_x
    jb sac_next

    mov ax,ship_y
    add ax,SHIP_H
    cmp ax,ast_y[bx]
    jb sac_next

    mov ax,ast_y[bx]
    add ax,AST_H
    cmp ax,ship_y
    jb sac_next

    call lose_life
    mov bx,si
    shl bx,1
    call reset_asteroid
    jmp sac_done

sac_next:
    inc si
    loop sac_loop

sac_done:
    pop si
    pop cx
    pop bx
    pop ax
    ret
ship_asteroid_collisions endp

ship_energy_collision proc near
    cmp energy_active,1
    jne sec_done
    push ax
    push bx

    mov ax,ship_x
    add ax,SHIP_W
    cmp ax,energy_x
    jb sec_no

    mov ax,energy_x
    add ax,10
    cmp ax,ship_x
    jb sec_no

    mov ax,ship_y
    add ax,SHIP_H
    cmp ax,energy_y
    jb sec_no

    mov ax,energy_y
    add ax,10
    cmp ax,ship_y
    jb sec_no

    mov word ptr fuel,100
    mov energy_active,0
    call sound_fuel

sec_no:
    pop bx
    pop ax
sec_done:
    ret
ship_energy_collision endp

lose_life proc near
    cmp lives,0
    je ll_over
    dec lives
    call sound_life
    cmp lives,0
    jne ll_reset
ll_over:
    mov game_over,1
    ret
ll_reset:
    mov word ptr fuel,100
    mov word ptr ship_x,150
    mov word ptr ship_y,166
    mov invuln_timer,45
    call clear_bullets
    ret
lose_life endp

render_frame proc near
    call clear_screen
    call draw_starfield
    call draw_bullets
    call draw_asteroids
    call draw_explosion
    call draw_energy_pack
    call draw_ship
    call draw_hud
    cmp game_over,1
    jne rf_done
    call draw_game_over
rf_done:
    ret
render_frame endp

clear_screen proc near
    push ax
    push cx
    push di
    push es
    mov ax,VIDEO_SEG
    mov es,ax
    xor di,di
    xor al,al
    mov cx,64000
    rep stosb
    pop es
    pop di
    pop cx
    pop ax
    ret
clear_screen endp

draw_starfield proc near
    push ax
    push bx
    push cx
    push dx
    push si

    mov cx,24
    xor si,si
ds_loop:
    mov bx,star_x[si]
    mov dx,star_y[si]
    add dx,word ptr last_tick
    and dx,199
    mov al,COLOR_WHITE
    call put_pixel
    add si,2
    loop ds_loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_starfield endp

draw_ship proc near
    push bx
    push dx
    push si
    mov bx,ship_x
    mov dx,ship_y
    mov si,offset ship_sprite
    call draw_sprite_20
    pop si
    pop dx
    pop bx
    ret
draw_ship endp

draw_asteroids proc near
    push bx
    push cx
    push dx
    push si
    push di

    mov cx,MAX_AST
    xor di,di
da_loop:
    mov bx,di
    shl bx,1
    mov bx,ast_x[bx]
    mov si,di
    shl si,1
    mov dx,ast_y[si]
    mov si,offset asteroid_sprite
    call draw_sprite_10
    inc di
    loop da_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
draw_asteroids endp

activate_explosion proc near
    ; Entrada: SI = indice de asteroide, BX = indice*2
    push ax
    mov ax,ast_x[bx]
    mov explosion_x,ax
    mov ax,ast_y[bx]
    mov explosion_y,ax
    mov explosion_active,1
    mov explosion_timer,8
    pop ax
    ret
activate_explosion endp

draw_explosion proc near
    cmp explosion_active,1
    jne dex_done
    push ax
    push bx
    push cx
    push dx

    mov bx,explosion_x
    mov dx,explosion_y
    add bx,5
    add dx,5
    mov al,COLOR_YELLOW
    call put_pixel

    mov cx,7
    sub bx,3
    mov al,COLOR_RED
    call draw_hline

    mov bx,explosion_x
    add bx,5
    mov dx,explosion_y
    add dx,2
    mov al,COLOR_YELLOW
    call put_pixel
    add dx,1
    call put_pixel
    add dx,1
    call put_pixel
    add dx,1
    call put_pixel
    add dx,1
    call put_pixel
    add dx,1
    call put_pixel
    add dx,1
    call put_pixel

    pop dx
    pop cx
    pop bx
    pop ax
dex_done:
    ret
draw_explosion endp

draw_energy_pack proc near
    cmp energy_active,1
    jne dep_done
    push bx
    push dx
    push si
    mov bx,energy_x
    mov dx,energy_y
    mov si,offset energy_sprite
    call draw_sprite_10
    pop si
    pop dx
    pop bx
dep_done:
    ret
draw_energy_pack endp

draw_bullets proc near
    push ax
    push bx
    push cx
    push dx
    push si

    mov cx,MAX_BULLETS
    xor si,si
db_loop:
    cmp bullet_active[si],0
    je db_next
    mov bx,si
    shl bx,1
    mov dx,bullet_y[bx]
    mov bx,bullet_x[bx]
    mov al,COLOR_YELLOW
    call put_pixel
    dec dx
    call put_pixel
    inc dx
db_next:
    inc si
    loop db_loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_bullets endp

draw_sprite_20 proc near
    ; BX=x, DX=y, SI=sprite 20x20
    push ax
    push bx
    push cx
    push dx
    push di
    push bp

    mov bp,20
ds20_row:
    push bx
    mov cx,20
ds20_col:
    lodsb
    cmp al,0
    je ds20_skip
    call put_pixel
ds20_skip:
    inc bx
    loop ds20_col
    pop bx
    inc dx
    dec bp
    jnz ds20_row

    pop bp
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_sprite_20 endp

draw_sprite_10 proc near
    ; BX=x, DX=y, SI=sprite 10x10
    push ax
    push bx
    push cx
    push dx
    push bp

    mov bp,10
ds10_row:
    push bx
    mov cx,10
ds10_col:
    lodsb
    cmp al,0
    je ds10_skip
    call put_pixel
ds10_skip:
    inc bx
    loop ds10_col
    pop bx
    inc dx
    dec bp
    jnz ds10_row

    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_sprite_10 endp

put_pixel proc near
    ; BX=x, DX=y, AL=color
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    cmp bx,SCREEN_W
    jae pp_done
    cmp dx,SCREEN_H
    jae pp_done

    mov di,dx
    shl di,6
    mov cx,dx
    shl cx,8
    add di,cx
    add di,bx
    mov cx,VIDEO_SEG
    mov es,cx
    mov es:[di],al

pp_done:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
put_pixel endp

draw_hud proc near
    call draw_lives
    call draw_score
    call draw_fuel
    ret
draw_hud endp

draw_lives proc near
    push ax
    push bx
    push cx
    push si
    push bp

    mov dh,23
    mov dl,1
    call set_cursor
    mov si,offset msg_lives
    xor bp,bp
    mov bl,lives
    mov bp,bx
    mov cx,3
dl_loop:
    lodsb
    cmp cx,bp
    ja dl_dead
    mov bl,COLOR_GREEN
    jmp dl_print
dl_dead:
    mov bl,COLOR_GRAY
dl_print:
    call print_char_color
    loop dl_loop

    pop bp
    pop si
    pop cx
    pop bx
    pop ax
    ret
draw_lives endp

draw_score proc near
    mov dh,23
    mov dl,26
    call set_cursor
    mov si,offset msg_score
    mov bl,COLOR_WHITE
    call print_string
    mov ax,score
    call print_number
    ret
draw_score endp

draw_fuel proc near
    push ax
    push bx
    push cx
    push dx

    mov dh,0
    mov dl,1
    call set_cursor
    mov si,offset msg_fuel
    mov bl,COLOR_CYAN
    call print_string

    ; Fondo fijo de la barra para que no desaparezca visualmente.
    mov bx,65
    mov dx,4
    mov cx,200
    mov al,COLOR_GRAY
    call draw_hline

    ; Barra de energia: largo = fuel * 2 pixeles.
    mov bx,65
    mov dx,4
    mov ax,fuel
    shl ax,1
    mov cx,ax
    mov al,COLOR_GREEN
    call draw_hline

    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw_fuel endp

draw_game_over proc near
    mov dh,11
    mov dl,15
    call set_cursor
    mov si,offset msg_gameover
    mov bl,COLOR_RED
    call print_string
    mov dh,13
    mov dl,13
    call set_cursor
    mov si,offset msg_restart
    mov bl,COLOR_WHITE
    call print_string
    ret
draw_game_over endp

draw_hline proc near
    ; BX=x, DX=y, CX=length, AL=color
    push ax
    push bx
    push cx
dh_loop:
    jcxz dh_done
    call put_pixel
    inc bx
    loop dh_loop
dh_done:
    pop cx
    pop bx
    pop ax
    ret
draw_hline endp

set_cursor proc near
    push ax
    push bx
    mov ah,02h
    mov bh,0
    int 10h
    pop bx
    pop ax
    ret
set_cursor endp

print_string proc near
    ; SI -> cadena 0, BL=color
    push ax
ps_loop:
    lodsb
    cmp al,0
    je ps_done
    call print_char_color
    jmp ps_loop
ps_done:
    pop ax
    ret
print_string endp

print_char_color proc near
    ; Imprime AL en la posicion actual sin usar scroll de BIOS.
    ; Esto reduce los flashazos raros en modo grafico 13h.
    push ax
    push bx
    push cx
    push dx

    push ax
    mov ah,03h
    mov bh,0
    int 10h
    pop ax

    mov ah,09h
    mov bh,0
    mov cx,1
    int 10h

    inc dl
    cmp dl,40
    jb pcc_set
    mov dl,0
    inc dh
pcc_set:
    mov ah,02h
    mov bh,0
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_char_color endp

print_number proc near
    push ax
    push bx
    push cx
    push dx

    xor cx,cx
    mov bx,10
    cmp ax,0
    jne pn_divide
    mov al,'0'
    call print_char_color
    jmp pn_done

pn_divide:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jne pn_divide

pn_print:
    pop dx
    add dl,'0'
    mov al,dl
    call print_char_color
    loop pn_print

pn_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_number endp

tone proc near
    ; AX = divisor de frecuencia, CX = duracion corta
    push ax
    push bx
    push cx
    push dx

    mov bx,ax
    mov al,0B6h
    out 43h,al
    mov ax,bx
    out 42h,al
    mov al,ah
    out 42h,al

    in al,61h
    or al,03h
    out 61h,al

tone_delay:
    dec cx
    jnz tone_delay

    in al,61h
    and al,0FCh
    out 61h,al

    pop dx
    pop cx
    pop bx
    pop ax
    ret
tone endp

sound_shot proc near
    push ax
    push cx
    mov ax,0450h
    mov cx,0800h
    call tone
    pop cx
    pop ax
    ret
sound_shot endp

sound_explosion proc near
    push ax
    push cx
    mov ax,0900h
    mov cx,0C00h
    call tone
    mov ax,0B00h
    mov cx,0900h
    call tone
    pop cx
    pop ax
    ret
sound_explosion endp

sound_fuel proc near
    push ax
    push cx
    mov ax,0350h
    mov cx,0700h
    call tone
    mov ax,0250h
    mov cx,0700h
    call tone
    pop cx
    pop ax
    ret
sound_fuel endp

sound_life proc near
    push ax
    push cx
    mov ax,0D00h
    mov cx,0A00h
    call tone
    pop cx
    pop ax
    ret
sound_life endp


end start
