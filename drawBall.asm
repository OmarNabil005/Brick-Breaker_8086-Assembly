initPort MACRO
	;Set Divisor Latch Access Bit
	         MOV DX, 3FBh     	; Line Control Register
	         MOV AL, 10000000b	;Set Divisor Latch Access Bit
	         OUT DX, AL       	;Out it
	
	;Set LSB byte of the Baud Rate Divisor Latch register.
	         MOV DX, 3F8h
	         MOV AL, 0Ch
	         OUT DX, AL

	;Set MSB byte of the Baud Rate Divisor Latch register.
	         MOV DX, 3F9h
	         MOV AL, 00h
	         OUT DX, AL

	;Set port configuration
	         MOV DX, 3FBh
	         MOV AL, 00011011b
	         OUT DX, AL
ENDM
clearscreen macro
	            MOV ax, 0600h	; Scroll up intterupt
	            MOV bh, 00h
	            MOV cx, 0    	; top left corner to scroll from
	            MOV dh, 25   	; bottom row
	            MOV dl, 80   	; right column
	            int 10h      	; call the interrupt
endm

	EXTRN bricks_initial_y:word
	EXTRN bricks_initial_x_left:word  
    EXTRN bricks_initial_x_right:word
	EXTRN Brick:FAR
	extrn drawBricksleft:FAR
	extrn drawBricksright:FAR
	extrn vertical_line:FAR
	EXTRN playerOneBarLeft:word
    EXTRN playerTwoBarLeft:word
    EXTRN playerOneBarRight:word
    EXTRN playerTwoBarRight:word
    EXTRN barTop:word
	extrn bar:far
	;extrn GAME:FAR
	;extrn loss:FAR
	;EXTRN SCORE:word
    ;EXTRN LIVES_1:word
	;extrn LIVES_2:word
    ; EXTRN LEVEL_1:word
	; EXTRN LEVEL_2:word
    ; EXTRN BRICKS_LEFT_1:word
	; EXTRN BRICKS_LEFT_2:word
	; EXTRN playerOneBarLeft:word
	; EXTRN playerTwoBarLeft:word
	; EXTRN playerOneBarRight:word
	; EXTRN playerTwoBarRight:word
	; EXTRN barTop:word
	; EXTRN barBottom:word

	; public TIME_STORE
	; public Move_Ball
	; public Draw_Ball
	; public Draw_B_Ball
	; public BALL_X
	; public BALL_Y
	; public BALL_X_SPEED
	; public BALL_Y_SPEED
	public resetBallAndBricks

	public Move_Ball
	public Draw_B_1_Ball
	public Draw_B_2_Ball
	public Draw_Ball_1
	public Draw_Ball_2
	


	.MODEL SMALL
	.STACK 100h
	
.DATA
	
	brick_width EQU 28d					;bricks width
    brick_height EQU 9d					;bricks height

	GAME_WINDOW     dw  14d
	WINDOW_WIDTH    dw  140h                    	;width of the window (320)
	WINDOW_HEIGHT   dw  0c8h                    	;height of the window (200)
	WINDOW_BOUNCE   dw  3h                      	;used to check collision early

	BALL_1_X          dw  79d                    	;x position of the ball
	BALL_1_ORIGINAL_X equ  79d                    	;x original position
	
	BALL_2_X          dw  240d                    	;x position of the ball
	BALL_2_ORIGINAL_X equ  240d                    	;x original position

	BALL_1_Y          dw  64h                     	;y position of the ball

	BALL_2_Y          dw  64h                    	;x position of the ball
	
	BALL_ORIGINAL_Y equ  64h                    	;x original position

	BALL_SIZE       dw  04h                     	;size of the ball

	


	BALL_SPEED_ORIGINAL_X EQU  02h               	;original speed of the ball in x axis
	BALL_SPEED_ORIGINAL_Y EQU  05h               	;original speed of the ball in y axis

	BALL_X_1_SPEED    dw  02h                     	;speed of the ball in x axis
	BALL_Y_1_SPEED    dw  05h                     	;speed of the ball in y axis
	BALL_X_2_SPEED    dw  02h                     	;speed of the ball in x axis
	BALL_Y_2_SPEED    dw  05h                     	;speed of the ball in y axis

	active_bricks_1   	dw  1, 1, 1, 1,1 
	                	dw  1, 1, 1, 1,1 
	                	dw  1, 1, 1, 1,1
	                	dw  1, 1, 1, 1,1
	                	dw  1, 1, 1, 1,1

	active_bricks_2   	dw  1, 1, 1, 1,1 
	                	dw  1, 1, 1, 1,1 
	                	dw  1, 1, 1, 1,1
	                	dw  1, 1, 1, 1,1
	                	dw  1, 1, 1, 1,1
	bar_height EQU 10
					

.CODE


Move_Ball PROC FAR
	                    MOV  AX,BALL_X_1_SPEED
	                    ADD  BALL_1_X,AX               	;inc ball x pos with velocity

	                    mov  ax,BALL_Y_1_SPEED
	                    ADD  BALL_1_Y,AX               	;inc ball x pos with velocity

						initPort

						call send_all
						call recieve_all


		call check_walls

	

		call check_left_Ball_bar
		call check_right_Ball_bar

		call check_left_Ball_collision
		call check_right_Ball_collision
	

	; neg_speed_x:        
	;                     NEG  BALL_X_SPEED
	;                     RET

	; neg_speed_y:        
    
	;                     NEG  BALL_Y_SPEED
	; ; Correct ball position if stuck
	;                     MOV  AX, BALL_Y
	;                     CMP  AX, 0                   	; Check if ball_y is above the top boundary
	;                     JGE  no_position_fix
	;                     MOV  BALL_Y, 3               	; Reset ball position slightly below top boundary
	;no_position_fix:    
	                   ret 
	

Move_Ball ENDP

send_all PROC
	; Wait until THR is empty
	MOV     DX, 3FDh            ; Line Status Register
	 MOV     DX, 3FDh            ; Line Status Register

    IN      AL, DX
    AND     AL, 00100000b       ; Check if THR is empty
    JZ      cant_send_all              ; Wait if not empty

    ; Send lower byte
    MOV     DX, 3F8h            ; Transmit Holding Register
    MOV     AL, BYTE PTR [BALL_1_X]
    OUT     DX, AL
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV     DX, 3FDh            ; Line Status Register
	 MOV     DX, 3FDh            ; Line Status Register
wait1:
    IN      AL, DX
    AND     AL, 00100000b       ; Check if THR is empty
    JZ      wait1              ; Wait if not empty

    ; Send lower byte
    MOV     DX, 3F8h            ; Transmit Holding Register
    MOV     AL, BYTE PTR [BALL_1_Y]
    OUT     DX, AL
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


cant_send_all:
	RET

endp send_all

recieve_all PROC
	 ; Wait for data in RHR
    MOV     DX, 3FDh

    IN      AL, DX
    AND     AL, 00000001b       ; Check if data is available
    JZ      cant_recieve              ; Wait if no data

    ; Receive lower byte
    MOV     DX, 3F8h
    IN      AL, DX
    MOV     BYTE PTR [BALL_2_Y], AL
	
	MOV     DX, 3FDh
wait2:
    IN      AL, DX
    AND     AL, 00000001b       ; Check if data is available
    JZ      wait2              ; Wait if no data

    ; Receive lower byte
    MOV     DX, 3F8h
    IN      AL, DX
    MOV     BYTE PTR [BALL_2_X], AL
	add     BALL_2_X, 162

  cant_recieve:
    RET

endp recieve_all

; send_ball_1_x PROC
;     ; Wait until THR is empty
;     MOV     DX, 3FDh            ; Line Status Register
; .wait1:
;     IN      AL, DX
;     AND     AL, 00100000b       ; Check if THR is empty
;     JZ      .wait1              ; Wait if not empty

;     ; Send lower byte
;     MOV     DX, 3F8h            ; Transmit Holding Register
;     MOV     AL, BYTE PTR [BALL_1_X]
;     OUT     DX, AL

;     RET
; send_ball_1_x ENDP

; send_ball_1_y PROC
;     ; Wait until THR is empty
;     MOV     DX, 3FDh
; .wait11:
;     IN      AL, DX
;     AND     AL, 00100000b
;     JZ      .wait11

;     ; Send lower byte
;     MOV     DX, 3F8h
;     MOV     AL, BYTE PTR [BALL_1_Y]
;     OUT     DX, AL

;     ; Wait for THR to be empty again
; .wait22:
;     IN      AL, DX
;     AND     AL, 00100000b
;     JZ      .wait22

;     ; Send higher byte
;     MOV     AL, BYTE PTR [BALL_1_Y+1]
;     OUT     DX, AL

;     RET
; send_ball_1_y ENDP

; ;-------------------------------------------------
; ; Receive Ball 2 X Position
; recieve_ball_2_x PROC
;     ; Wait for data in RHR
;     MOV     DX, 3FDh
; .wait3:
;     IN      AL, DX
;     AND     AL, 00000001b       ; Check if data is available
;     JZ      .wait3              ; Wait if no data

;     ; Receive lower byte
;     MOV     DX, 3F8h
;     IN      AL, DX
;     MOV     BYTE PTR [BALL_2_X], AL

;     ; Wait for next data byte
; .wait4:
;     IN      AL, DX
;     AND     AL, 00000001b
;     JZ      .wait4

;     ; Receive higher byte
;     IN      AL, DX
;     MOV     BYTE PTR [BALL_2_X+1], AL

;     RET
; recieve_ball_2_x ENDP

; ;-------------------------------------------------
; ; Receive Ball 2 Y Position
; recieve_ball_2_y PROC
;     ; Wait for data in RHR
;     MOV     DX, 3FDh
; .wait5:
;     IN      AL, DX
;     AND     AL, 00000001b
;     JZ      .wait5

;     ; Receive lower byte
;     MOV     DX, 3F8h
;     IN      AL, DX
;     MOV     BYTE PTR [BALL_2_Y], AL

;     ; Wait for next data byte
; .wait6:
;     IN      AL, DX
;     AND     AL, 00000001b
;     JZ      .wait6

;     ; Receive higher byte
;     IN      AL, DX
;     MOV     BYTE PTR [BALL_2_Y+1], AL

;     RET
; recieve_ball_2_y ENDP

check_walls proc 
check_left_wall:    
	; first BAll with left wall
	                    mov  ax,WINDOW_BOUNCE
	                    cmp  BALL_1_X,ax
	                    jge  second_ball_left               	;if it collides with left wall
	                    MOV  BALL_1_X, ax              	;adjustment to avoid getting stuck
	                    NEG  BALL_X_1_SPEED             	;jle
	second_ball_left: 
	;second Ball with left wall         
						mov  ax,WINDOW_BOUNCE
						add  ax, 162
	                    cmp  BALL_2_X,ax
	                    jge  dont_left_jump               	;if it collides with left wall
	                    MOV  BALL_2_X, ax              	;adjustment to avoid getting stuck
	                    NEG  BALL_X_2_SPEED             	;jle
		

	dont_left_jump:
	;first ball with right wall
	; BALL_X > window - ball_size - offset : collided
	                    mov  ax,156
	                    sub  ax,BALL_SIZE
	                    ; sub  ax,WINDOW_BOUNCE
	                    cmp  BALL_1_X,ax
	                    jle  second_ball_right         	;if it collides with right wall
	; =========to avoid gettings tuck========
	                    mov  ax, 156
	                    sub  ax, BALL_SIZE
	                    ; sub  ax, WINDOW_BOUNCE
	                    mov  BALL_1_X, ax
	;========================================
	                    NEG  BALL_X_1_SPEED             	;jge

	second_ball_right:	
	;second ball with right wall
	; BALL_X > window - ball_size - offset : collided
	                    mov  ax,WINDOW_WIDTH
	                    sub  ax,BALL_SIZE
	                    sub  ax,WINDOW_BOUNCE
	                    cmp  BALL_2_X,ax
	                    jle  top_wall         	;if it collides with right wall
	; =========to avoid gettings tuck========
						mov  ax, WINDOW_WIDTH
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
	                    mov  BALL_2_X, ax		
	;========================================
			            NEG  BALL_X_2_SPEED             	;jge												
	
	

	top_wall:    
	;first ball with top wall
	; BALL_Y <= WINDOW_BOUNCE
	                    mov  ax,WINDOW_BOUNCE
	                    cmp  BALL_1_Y,ax
	                    jge  second_ball_top         	;if it collides with top wall
	                    mov  BALL_1_Y, ax              	;to avoid gettings tuck
	                    NEG  BALL_Y_1_SPEED             	;jge
	second_ball_top:
	;second ball with top wall
	; BALL_Y <= WINDOW_BOUNCE
	                    mov  ax,WINDOW_BOUNCE
	                    cmp  BALL_2_Y,ax
	                    jge  dont_jump_neg_y         	;if it collides with top wall
	                    mov  BALL_2_Y, ax              	;to avoid gettings tuck
	                    NEG  BALL_Y_2_SPEED             	;jge


	dont_jump_neg_y:    
	;first ball with bottom wall
	; BALL_Y >= window - ball - offset : collided
	                    mov  ax,WINDOW_HEIGHT
	                    sub  ax,BALL_SIZE
	                    sub  ax,WINDOW_BOUNCE
						sub  ax,GAME_WINDOW
	                    cmp  BALL_1_Y,ax
	                    jle  second_ball_bottom        	;if it collides with bottom wall
						NEG BALL_Y_1_SPEED
						;JMP  Reset_Ball_1_Position             	;jge
	;======to avoid getting stuck======
	                    mov  ax, WINDOW_HEIGHT
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
	                    sub  ax, GAME_WINDOW

	                    ; dec  LIVES_1
						; jnz comp
						; call loss
						comp:
	                    mov  BALL_1_Y, ax              	;to avoid gettings tuck
	;===================================
	                    ;jmp  reset_position

second_ball_bottom:
	;second ball with bottom wall
	; BALL_Y >= window - ball - offset : collided
						mov  ax, WINDOW_HEIGHT
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
						sub  ax, GAME_WINDOW

	                    cmp  BALL_2_Y,ax
	                    jle  dont_jump_this_y         	;if it collides with bottom wall
						NEG BALL_Y_2_SPEED
						;JMP  Reset_Ball_2_Position             	;jge	
	;======to avoid getting stuck======
						mov  ax, WINDOW_HEIGHT
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
	                    sub  ax, GAME_WINDOW
	                    ; dec  LIVES_2
						; jnz comp2
						; call loss
						comp2:
	                    mov  BALL_2_Y, ax              	;to avoid gettings tuck								

	dont_jump_this_y:   
	ret
endp check_walls

check_left_ball_bar proc 
;Ball_y + ballsize + WINDOW_BOUNCE> bartop && (ball_x < barRight && ball_x + BallSize > barLeft : collided
	                    mov  ax,WINDOW_BOUNCE
	                    add  ax,BALL_1_Y
	                    add  ax,BALL_SIZE            	;check of y
	                    cmp  ax,barTop
	                    jl   noo

	                    mov  ax, BALL_1_X
	                    add  ax,BALL_SIZE            	;first x condition
	                    cmp  ax,playerOneBarLeft
	                    jl   noo

	                    mov  ax,BALL_1_X
	                    cmp  ax,playerOneBarRight
	                    jg   noo
						

	; =========to avoid gettings tuck========
	                    mov  ax, barTop
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
	                    mov  ball_1_y, ax
	                    neg  BALL_Y_1_SPEED
	;========================================

	noo: 
	ret
endp check_left_ball_bar

check_right_ball_bar proc 
;Ball_y + ballsize + WINDOW_BOUNCE> bartop && (ball_x < barRight && ball_x + BallSize > barLeft : collided
	                    mov  ax,WINDOW_BOUNCE
	                    add  ax,BALL_2_Y
	                    add  ax,BALL_SIZE            	;check of y
	                    cmp  ax,barTop
	                    jl   nooo

	                    mov  ax, BALL_2_X
	                    add  ax,BALL_SIZE            	;first x condition
	                    cmp  ax,playerTwoBarLeft
	                    jl   nooo

	                    mov  ax,BALL_2_X
	                    cmp  ax,playerTwoBarRight
	                    jg   nooo
						

	; =========to avoid gettings tuck========
	                    mov  ax, barTop
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
	                    mov  ball_2_y, ax
	                    neg  BALL_Y_2_SPEED
	;========================================

	nooo: 
	ret
endp check_right_ball_bar

check_left_Ball_collision PROC NEAR
	           ;check_collision:
	; Assuming bx = brick's y index, si = brick's x index
	; Ball properties: BALL_X, BALL_Y, BALL_SIZE
	; Brick properties: bricks_initial_x[si], bricks_initial_y[bx], brick_width, brick_height

	; Get brick boundaries

	                    call check_collision_left         	;return brick y index in bx and x index in si

		
	;if didn't jump to nn, therefore collision occured (part of ball is inside) with brick[si][bx]
	;let's figure out where did that occur
	                    cmp  bx, 30
	                    je   nn
	                    cmp  si,30
	                    je   nn

	; === Check Bottom Collision ===
	; Bottom-left corner of the ball touching the top of the brick
	                    MOV  AX, bricks_initial_y[bx]	; AX = brick_y
	                    SUB  AX, BALL_SIZE           	; AX = brick_y - BALL_SIZE
	                    CMP  BALL_1_Y, AX              	; Is ball_y > brick_y - BALL_SIZE?
	                    JL   check_top               	; If not, check for top collision

	; Ball's bottom-right corner must also be inside horizontally
	                    MOV  AX, bricks_initial_x_left[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x + brick_width
	                    SUB  AX, ball_size
	                    CMP  BALL_1_X, AX              	; Is ball_x + BALL_SIZE < brick_x + brick_width?
	                    JGE  check_top               	; If not, check for top collision

	                    NEG  BALL_Y_1_SPEED             	; Bottom collision confirmed
						ret
	check_top:          
	; === Check Top Collision ===
	; Top-left corner of the ball touching the bottom of the brick
	                    MOV  AX, bricks_initial_y[bx]	; AX = brick_y + brick_height
	                    ADD  AX, brick_height
	                    CMP  BALL_1_Y, AX              	; Is ball_y < brick_y + brick_height?
	                    JG   check_left              	; If not, check for side collisions

	; Ball's top-right corner must also be inside horizontally
	                    MOV  AX, bricks_initial_x_left[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x + brick_width
	                    SUB  AX, BALL_SIZE
	                    CMP  BALL_1_X, AX              	; Is ball_x + BALL_SIZE < brick_x + brick_size?
	                    JG  check_left
	                    NEG BALL_Y_1_SPEED            	; Top collision confirmed
						Ret

	check_left:         
	; === Check Left Collision ===
	; Left side of the ball touching the right side of the brick
	                    MOV  AX, bricks_initial_x_left[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x - BALL_SIZE
	                    CMP  BALL_1_X, AX              	; Is ball_x < brick_x + brick_width?
	                    JG   check_right             	; If not, check for right collision

	                    NEG  BALL_X_1_SPEED             	; Left collision confirmed
						Ret
	check_right:        
	; === Check Right Collision ===
	; Right side of the ball touching the left side of the brick
	                    MOV  AX, bricks_initial_x_left[si]	; AX = brick_x + brick_width
	                    SUB  AX, BALL_SIZE
	                    CMP  BALL_1_X, AX              	; Is ball_x + BALL_SIZE > brick_x?
	                    JLE  nn                      	; No collision detected

	                    NEG  BALL_X_1_SPEED        	; Right collision confirmed

	nn:                 
	                    RET

	reset_position:     
	                    Call Reset_Ball_1_Position
	                    RET         
endp check_left_Ball_collision

check_right_Ball_collision PROC NEAR
	           ;check_collision:
	; Assuming bx = brick's y index, si = brick's x index
	; Ball properties: BALL_X, BALL_Y, BALL_SIZE
	; Brick properties: bricks_initial_x[si], bricks_initial_y[bx], brick_width, brick_height

	; Get brick boundaries

	                    call check_collision_right         	;return brick y index in bx and x index in si

		
	;if didn't jump to nn, therefore collision occured (part of ball is inside) with brick[si][bx]
	;let's figure out where did that occur
	                    cmp  bx, 30
	                    je   nnn
	                    cmp  si,30
	                    je   nnn

	; === Check Bottom Collision ===
	; Bottom-left corner of the ball touching the top of the brick
	                    MOV  AX, bricks_initial_y[bx]	; AX = brick_y
	                    SUB  AX, BALL_SIZE           	; AX = brick_y - BALL_SIZE
	                    CMP  BALL_2_Y, AX              	; Is ball_y > brick_y - BALL_SIZE?
	                    JL   check_topp               	; If not, check for top collision

	; Ball's bottom-right corner must also be inside horizontally
	                    MOV  AX, bricks_initial_x_right[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x + brick_width
	                    SUB  AX, ball_size
	                    CMP  BALL_2_X, AX              	; Is ball_x + BALL_SIZE < brick_x + brick_width?
	                    JGE  check_topp               	; If not, check for top collision

	                    NEG  BALL_Y_2_SPEED             	; Bottom collision confirmed
						ret
	check_topp:          
	; === Check Top Collision ===
	; Top-left corner of the ball touching the bottom of the brick
	                    MOV  AX, bricks_initial_y[bx]	; AX = brick_y + brick_height
	                    ADD  AX, brick_height
	                    CMP  BALL_2_Y, AX              	; Is ball_y < brick_y + brick_height?
	                    JG   check_leftt              	; If not, check for side collisions

	; Ball's top-right corner must also be inside horizontally
	                    MOV  AX, bricks_initial_x_right[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x + brick_width
	                    SUB  AX, BALL_SIZE
	                    CMP  BALL_2_X, AX              	; Is ball_x + BALL_SIZE < brick_x + brick_size?
	                    JG  check_leftt
	                    NEG BALL_Y_2_SPEED            	; Top collision confirmed
						Ret

	check_leftt:         
	; === Check Left Collision ===
	; Left side of the ball touching the right side of the brick
	                    MOV  AX, bricks_initial_x_right[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x - BALL_SIZE
	                    CMP  BALL_2_X, AX              	; Is ball_x < brick_x + brick_width?
	                    JG   check_rightt             	; If not, check for right collision

	                    NEG  BALL_X_2_SPEED             	; Left collision confirmed
						Ret
	check_rightt:        
	; === Check Right Collision ===
	; Right side of the ball touching the left side of the brick
	                    MOV  AX, bricks_initial_x_right[si]	; AX = brick_x + brick_width
	                    SUB  AX, BALL_SIZE
	                    CMP  BALL_2_X, AX              	; Is ball_x + BALL_SIZE > brick_x?
	                    JLE  nnn                      	; No collision detected

	                    NEG  BALL_X_2_SPEED        	; Right collision confirmed

	nnn:                 
	                    RET

	reset_positionn:     
	                    Call Reset_Ball_2_Position
	                    RET         
endp check_right_Ball_collision

Clear_Screen PROC FAR
	                    mov  ah,00h                  	;set video mode
	                    mov  al,13h                  	;choose vedio mode
	                    int  10h

	                    mov  ah,08h
	                    mov  bh,00h                  	;background color
	                    mov  bl,00h                  	;choose black
	                    int  10h

	                    RET
Clear_Screen ENDP

Draw_B_1_Ball PROC FAR
	                    mov  cx, BALL_1_X              	;set start X
	                    mov  dx, BALL_1_Y              	;set start Y

	hor_b_draw_ball:    
	                    mov  ah,0ch                  	;set writing pixel
	                    mov  al,00h                  	;choose white as color
	                    mov  bh,00h                  	;set page number
	                    int  10h

	                    inc  cx                      	;adding 1 to x
	                    mov  ax,cx
	                    sub  ax,BALL_1_X               	;seeing the diff between current x and initial x
	                    cmp  ax,BALL_SIZE            	;comparing them
	                    jng  hor_b_draw_ball         	;go to draw the next x pos
 
	                    mov  cx,BALL_1_X               	;if i finished the line, reseting x position
	                    inc  dx                      	;go to the next line
			
	                    mov  ax,dx
	                    sub  ax,BALL_1_Y               	;seeing the diff bet current y and iniyial y
	                    cmp  ax,BALL_SIZE            	;comparing it with ball size
	                    jng  hor_b_draw_ball         	;go to draw next line

	                    RET
Draw_B_1_Ball ENDP

Draw_B_2_Ball PROC FAR
	                    mov  cx, BALL_2_X              	;set start X
	                    mov  dx, BALL_2_Y              	;set start Y

	hor_b_draw_ball_2:    
	                    mov  ah,0ch                  	;set writing pixel
	                    mov  al,00h                  	;choose white as color
	                    mov  bh,00h                  	;set page number
	                    int  10h

	                    inc  cx                      	;adding 1 to x
	                    mov  ax,cx
	                    sub  ax,BALL_2_X               	;seeing the diff between current x and initial x
	                    cmp  ax,BALL_SIZE            	;comparing them
	                    jng  hor_b_draw_ball_2         	;go to draw the next x pos
 
	                    mov  cx,BALL_2_X               	;if i finished the line, reseting x position
	                    inc  dx                      	;go to the next line
			
	                    mov  ax,dx
	                    sub  ax,BALL_2_Y               	;seeing the diff bet current y and iniyial y
	                    cmp  ax,BALL_SIZE            	;comparing it with ball size
	                    jng  hor_b_draw_ball_2         	;go to draw next line

	                    RET
Draw_B_2_Ball ENDP

Draw_Ball_1 PROC FAR
	                    mov  cx, BALL_1_X              	;set start X
	                    mov  dx, BALL_1_Y              	;set start Y

	hor_draw_ball:      
	                    mov  ah,0ch                  	;set writing pixel
	                    mov  al,0fh                  	;choose white as color
	                    mov  bh,00h                  	;set page number
	                    int  10h

	                    inc  cx                      	;adding 1 to x
	                    mov  ax,cx
	                    sub  ax,BALL_1_X               	;seeing the diff between current x and initial x
	                    cmp  ax,BALL_SIZE            	;comparing them
	                    jng  hor_draw_ball           	;go to draw the next x pos
 
	                    mov  cx,BALL_1_X               	;if i finished the line, reseting x position
	                    inc  dx                      	;go to the next line
			
	                    mov  ax,dx
	                    sub  ax,BALL_1_Y               	;seeing the diff bet current y and iniyial y
	                    cmp  ax,BALL_SIZE            	;comparing it with ball size
	                    jng  hor_draw_ball           	;go to draw next line

	                    RET
Draw_Ball_1 ENDP



Draw_Ball_2 PROC FAR
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	                    mov  cx, BALL_2_X              	;set start X
	                    mov  dx, BALL_2_Y              	;set start Y

	hor_draw_ball_2:      
	                    mov  ah,0ch                  	;set writing pixel
	                    mov  al,0fh                  	;choose white as color
	                    mov  bh,00h                  	;set page number
	                    int  10h

	                    inc  cx                      	;adding 1 to x
	                    mov  ax,cx
	                    sub  ax,BALL_2_X               	;seeing the diff between current x and initial x
	                    cmp  ax,BALL_SIZE            	;comparing them
	                    jng  hor_draw_ball_2           	;go to draw the next x pos
 
	                    mov  cx,BALL_2_X               	;if i finished the line, reseting x position
	                    inc  dx                      	;go to the next line
			
	                    mov  ax,dx
	                    sub  ax,BALL_2_Y               	;seeing the diff bet current y and iniyial y
	                    cmp  ax,BALL_SIZE            	;comparing it with ball size
	                    jng  hor_draw_ball_2           	;go to draw next line
exit_remote:
	                    RET
Draw_Ball_2 ENDP


Reset_Ball_1_Position PROC NEAR
	                    mov  ax,BALL_1_ORIGINAL_X
	                    mov  BALL_1_X,ax

	                    mov  ax,BALL_ORIGINAL_Y
	                    mov  BALL_1_Y,ax

	                    RET
Reset_Ball_1_Position ENDP

Reset_Ball_2_Position PROC NEAR
	                    mov  ax,BALL_2_ORIGINAL_X
	                    mov  BALL_2_X,ax

	                    mov  ax,BALL_ORIGINAL_Y
	                    mov  BALL_2_Y,ax

	                    RET
Reset_Ball_2_Position ENDP


; 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


check_collision_left PROC near
	                    push ax
	                    push cx
	                    push dx


	                    mov  bx, 8                   	; Number of rows
	                    mov  si, 8                  	; Number of columns

	; Loop through rows
	check_row:          
	; First, check if collision can happen with this row, if yes, go prove that by checking the column of collision
	;BALL_Y + BALL_SIZE + offset > BRICK_Y (top of brick) with (bottom left of ball)
	                    mov  ax, BALL_1_Y
	                    add  ax, BALL_SIZE
	                    cmp  ax, bricks_initial_y[bx]	; Compare ball's Y with brick's initial Y
	                    jl   finish_row              	; If less, skip this row
		
	;BALL_Y < BRICK_Y + brick_height + offset (top left of ball is above bottom of brick)
	                    MOV  AX, BALL_1_Y
	                    mov  dx, bricks_initial_y[bx]
	                    add  dx, brick_height
	                    cmp  ax, dx                  	; Check if within row vertically
	                    jl   check_col               	; If yes, check columns to know which x value

	                    cmp  bx, 0
	                    je   no_index

	finish_row:         
	                    sub  bx, 2
	                    jmp  check_row

	; Loop through columns
	; the ball is in the y-range of the current brick row
	
	check_col:          
	;compare ball top right with brick's left side
	; BALL_X + BALL_SIZE + offset > brick_x
	                    mov  ax, BALL_1_X
	                    ADD  AX, BALL_SIZE
	                    cmp  ax, bricks_initial_x_left[SI]	; Compare ball's X + size with brick's initial X (collision of right side of ball)
	                    jl   finish_col              	; If less, skip this column
		
	;compare ball top left with the brick's right side
	;BALL_X < brick_x + brick_width + offset
	                    mov  dx, bricks_initial_x_left[si]
	                    add  dx, brick_width
	                    MOV  AX, BALL_1_X
	                    cmp  ax, dx                  	; Check if within column horizontally
	                    jl   finish                  	; If yes, verify corners
		
	                    cmp  si, 0
	                    je   no_index

	finish_col:         
	                    sub  si, 2
	                    jmp  check_col


	no_index:           
	                    mov  bx, 30
	                    mov  si, 30
	                    pop  dx
	                    pop  cx
	                    pop  ax
	                    ret

;(curr_y * cols) + curr_x
	finish:             
	                    mov  ax,bx
	                    mov  cx, 5
	                    mul  cx
	                    add  ax,si                   	;index is stored in ax
	                    mov  di,ax

	                    mov  ax,active_bricks_1[di]
	                    cmp  ax,0                    	;if it is zero means is not active brick
	                    je   no_index                	;no collision happened

	                    mov  active_bricks_1[di],0     	;if collision happens deactivate brick
	                    ;dec  BRICKS_LEFT             	; Reduce brick count
	                    ;inc  SCORE                   	; Increase score by 1
	
	                    ;cmp  BRICKS_LEFT, 30          	; Check if all bricks are cleared
	                    ;jne  draw_next_brick
	                    ;call level_up                	;Level up logic if all bricks are cleared
						;jmp  no_index
   
	                    mov  cx,bricks_initial_x_left[si]
	                    mov  dx,bricks_initial_y[bx]
	                    mov  al,0
	                    push bx
	                    push si
	                    call Brick                   	;and draw black brick
	                    pop  si
	                    pop  bx

	rett:
	                    pop  dx
	                    pop  cx
	                    pop  ax
	                    ret
check_collision_left ENDP

check_collision_right PROC near
	                    push ax
	                    push cx
	                    push dx


	                    mov  bx, 8                   	; Number of rows
	                    mov  si, 8                  	; Number of columns

	; Loop through rows
	check_roww:          
	; First, check if collision can happen with this row, if yes, go prove that by checking the column of collision
	;BALL_Y + BALL_SIZE + offset > BRICK_Y (top of brick) with (bottom left of ball)
	                    mov  ax, BALL_2_Y
	                    add  ax, BALL_SIZE
	                    cmp  ax, bricks_initial_y[bx]	; Compare ball's Y with brick's initial Y
	                    jl   finish_roww              	; If less, skip this row
		
	;BALL_Y < BRICK_Y + brick_height + offset (top left of ball is above bottom of brick)
	                    MOV  AX, BALL_2_Y
	                    mov  dx, bricks_initial_y[bx]
	                    add  dx, brick_height
	                    cmp  ax, dx                  	; Check if within row vertically
	                    jl   check_coll               	; If yes, check columns to know which x value

	                    cmp  bx, 0
	                    je   no_indexx

	finish_roww:         
	                    sub  bx, 2
	                    jmp  check_roww

	; Loop through columns
	; the ball is in the y-range of the current brick row
	
	check_coll:          
	;compare ball top right with brick's left side
	; BALL_X + BALL_SIZE + offset > brick_x
	                    mov  ax, BALL_2_X
	                    ADD  AX, BALL_SIZE
	                    cmp  ax, bricks_initial_x_right[SI]	; Compare ball's X + size with brick's initial X (collision of right side of ball)
	                    jl   finish_coll              	; If less, skip this column
		
	;compare ball top left with the brick's right side
	;BALL_X < brick_x + brick_width + offset
	                    mov  dx, bricks_initial_x_right[si]
	                    add  dx, brick_width
	                    MOV  AX, BALL_2_X
	                    cmp  ax, dx                  	; Check if within column horizontally
	                    jl   finishh                  	; If yes, verify corners
		
	                    cmp  si, 0
	                    je   no_indexx

	finish_coll:         
	                    sub  si, 2
	                    jmp  check_coll


	no_indexx:           
	                    mov  bx, 30
	                    mov  si, 30
	                    pop  dx
	                    pop  cx
	                    pop  ax
	                    ret

;(curr_y * cols) + curr_x
	finishh:             
	                    mov  ax,bx
	                    mov  cx, 5
	                    mul  cx
	                    add  ax,si                   	;index is stored in ax
	                    mov  di,ax

	                    mov  ax,active_bricks_2[di]
	                    cmp  ax,0                    	;if it is zero means is not active brick
	                    je   no_indexx                	;no collision happened

	                    mov  active_bricks_2[di],0     	;if collision happens deactivate brick
	                    ;dec  BRICKS_LEFT             	; Reduce brick count
	                    ;inc  SCORE                   	; Increase score by 1
	
	                    ;cmp  BRICKS_LEFT, 30          	; Check if all bricks are cleared
	                    ;jne  draw_next_brick
	                    ;call level_up                	;Level up logic if all bricks are cleared
						;jmp  no_index
   
	                    mov  cx,bricks_initial_x_right[si]
	                    mov  dx,bricks_initial_y[bx]
	                    mov  al,0
	                    push bx
	                    push si
	                    call Brick                   	;and draw black brick
	                    pop  si
	                    pop  bx

	                    pop  dx
	                    pop  cx
	                    pop  ax
	                    ret
check_collision_right ENDP

; level_up PROC NEAR
;     inc  LEVEL                   ; Increase level
;     mov  BRICKS_LEFT, 45         ; Reset brick count
    
;     ; Ensure clean state for next level
;     call resetBallSpeed
;     call resetActiveBricks

;     ; Increase difficulty
;     mov  ax, LEVEL              ; Load current level
;     add  BALL_X_SPEED, ax       ; Proportional speed increase
;     add  BALL_Y_SPEED, ax
    
;     call drawBricks
;     ret
; level_up ENDP

resetBallAndBricks PROC FAR
						call resetBallSpeed
						call resetActiveBricks
						ret
resetBallAndBricks ENDP

resetActiveBricks PROC NEAR
						push si
						mov  cx, 25
	                    mov  si, 0
	resetActiveBricks_1_loop:
	                    mov  active_bricks_1[si], 1
	                    add  si, 2
	                    loop resetActiveBricks_1_loop

						mov  cx, 25
	                    mov  si, 0
	resetActiveBricks_2_loop:
	                    mov  active_bricks_2[si], 1
	                    add  si, 2
	                    loop resetActiveBricks_2_loop

						pop si
	                    ret
resetActiveBricks ENDP

resetBallSpeed PROC NEAR
						call Reset_Ball_1_Position
						call Reset_Ball_2_Position
	                    mov  BALL_X_1_SPEED, BALL_SPEED_ORIGINAL_X
	                    mov  BALL_Y_1_SPEED, BALL_SPEED_ORIGINAL_Y
						mov  BALL_X_2_SPEED, BALL_SPEED_ORIGINAL_X
	                    mov  BALL_Y_2_SPEED, BALL_SPEED_ORIGINAL_Y
	                    ret
resetBallSpeed ENDP


END Move_Ball