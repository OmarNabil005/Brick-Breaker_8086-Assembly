clearscreen macro
	            MOV ax, 0600h	; Scroll up intterupt
	            MOV bh, 00h
	            MOV cx, 0    	; top left corner to scroll from
	            MOV dh, 25   	; bottom row
	            MOV dl, 80   	; right column
	            int 10h      	; call the interrupt
endm

	EXTRN bricks_initial_x:word
	EXTRN bricks_initial_y:word
	EXTRN Brick:FAR
	extrn drawBricks:FAR
	extrn loss:FAR
	EXTRN SCORE:word
    EXTRN LIVES:word
    EXTRN LEVEL:word
    EXTRN BRICKS_LEFT:word
	EXTRN barLeft:word
	EXTRN barRight:word
	EXTRN barTop:word
	EXTRN barBottom:word

	public TIME_STORE
	public Move_Ball
	public Draw_Ball
	public Draw_B_Ball
	public BALL_X
	public BALL_Y
	public BALL_X_SPEED
	public BALL_Y_SPEED
	public resetActiveBricks

	.MODEL SMALL
	.STACK 100h
	
.DATA
	
	brick_width     EQU 32d                     	;bricks width
	brick_height    EQU 9d                      	;bricks height

	GAME_WINDOW     dw  10d
	WINDOW_WIDTH    dw  140h                    	;width of the window (320)
	WINDOW_HEIGHT   dw  0c8h                    	;height of the window (200)
	WINDOW_BOUNCE   dw  3h                      	;used to check collision early

	BALL_X          dw  0a0h                    	;x position of the ball
	BALL_ORIGINAL_X dw  0a0h                    	;x original position

	BALL_Y          dw  64h                     	;y position of the ball
	BALL_ORIGINAL_Y dw  64h                     	;y original position

	BALL_SIZE       dw  04h                     	;size of the ball

	TIME_STORE      db  0                       	;variable used for checking time changed

	BALL_X_SPEED    dw  02h                     	;speed of the ball in x axis
	BALL_Y_SPEED    dw  05h                     	;speed of the ball in y axis

	active_bricks   dw  1, 1, 1, 1, 1, 1, 1, 1, 1
	                dw  1, 1, 1, 1, 1, 1, 1, 1, 1
	                dw  1, 1, 1, 1, 1, 1, 1, 1, 1
	                dw  1, 1, 1, 1, 1, 1, 1, 1, 1
	                dw  1, 1, 1, 1, 1, 1, 1, 1, 1

.CODE

Move_Ball PROC FAR
	                    MOV  AX,BALL_X_SPEED
	                    ADD  BALL_X,AX               	;inc ball x pos with velocity

	                    mov  ax,BALL_Y_SPEED
	                    add  BALL_Y,ax               	;inc ball y pos with velocity

	;Ball_y + ballsize + WINDOW_BOUNCE> bartop && (ball_x < barRight && ball_x + BallSize > barLeft : collided
	                    mov  ax,WINDOW_BOUNCE
	                    add  ax,BALL_Y
	                    add  ax,BALL_SIZE            	;check of y
	                    cmp  ax,barTop
	                    jl   check_left_wall

	                    mov  ax, BALL_X
	                    add  ax,BALL_SIZE            	;first x condition
	                    cmp  ax,barLeft
	                    jl   check_left_wall

	                    mov  ax,BALL_X
	                    cmp  ax,barRight
	                    jg   check_left_wall
						

	; =========to avoid gettings tuck========
	                    mov  ax, barTop
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
	                    mov  ball_y, ax
	                    jmp  neg_speed_y
	;========================================


	check_left_wall:    
	                    mov  ax,WINDOW_BOUNCE
	                    cmp  BALL_X,ax
	                    jge  dont_jump               	;if it collides with left wall
	                    MOV  BALL_X, ax              	;adjustment to avoid getting stuck
	                    jmp  neg_speed_X             	;jle
	dont_jump:          

		


	; BALL_X > window - ball_size - offset : collided
	                    mov  ax,WINDOW_WIDTH
	                    sub  ax,BALL_SIZE
	                    sub  ax,WINDOW_BOUNCE
	                    cmp  BALL_X,ax
	                    jle  dont_jump_neg_x         	;if it collides with right wall
	; =========to avoid gettings tuck========
	                    mov  ax, WINDOW_WIDTH
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
	                    mov  ball_x, ax
	;========================================
	                    jmp  neg_speed_x             	;jge
	dont_jump_neg_x:    

	; BALL_Y <= WINDOW_BOUNCE
	                    mov  ax,WINDOW_BOUNCE
	                    cmp  BALL_Y,ax
	                    jge  dont_jump_neg_y         	;if it collides with top wall
	                    mov  BALL_Y, ax              	;to avoid gettings tuck
	                    jmp  neg_speed_y
	dont_jump_neg_y:    

	; BALL_Y >= window - ball - offset : collided
	                    mov  ax,WINDOW_HEIGHT
	                    sub  ax,BALL_SIZE
	                    sub  ax,WINDOW_BOUNCE
	                    sub  ax,GAME_WINDOW
	                    cmp  BALL_Y,ax
	                    jle  dont_jump_this_y        	;if it collides with bottom wall
	;======to avoid getting stuck======
	                    mov  ax, WINDOW_HEIGHT
	                    sub  ax, BALL_SIZE
	                    sub  ax, WINDOW_BOUNCE
	                    sub  ax,GAME_WINDOW
	                    dec  LIVES
						jnz comp
						call loss
						comp:
	                    mov  ball_y, ax
	;===================================
	                    jmp  reset_position
	dont_jump_this_y:   

	;check_collision:
	; Assuming bx = brick's y index, si = brick's x index
	; Ball properties: BALL_X, BALL_Y, BALL_SIZE
	; Brick properties: bricks_initial_x[si], bricks_initial_y[bx], brick_width, brick_height

	; Get brick boundaries

	                    call check_collision         	;return brick y index in bx and x index in si

		
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
	                    CMP  BALL_Y, AX              	; Is ball_y > brick_y - BALL_SIZE?
	                    JL   check_top               	; If not, check for top collision

	; Ball's bottom-right corner must also be inside horizontally
	                    MOV  AX, bricks_initial_x[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x + brick_width
	                    SUB  AX, ball_size
	                    CMP  BALL_X, AX              	; Is ball_x + BALL_SIZE < brick_x + brick_width?
	                    JGE  check_top               	; If not, check for top collision

	                    JMP  neg_speed_y             	; Bottom collision confirmed

	check_top:          
	; === Check Top Collision ===
	; Top-left corner of the ball touching the bottom of the brick
	                    MOV  AX, bricks_initial_y[bx]	; AX = brick_y + brick_height
	                    ADD  AX, brick_height
	                    CMP  BALL_Y, AX              	; Is ball_y < brick_y + brick_height?
	                    JG   check_left              	; If not, check for side collisions

	; Ball's top-right corner must also be inside horizontally
	                    MOV  AX, bricks_initial_x[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x + brick_width
	                    SUB  AX, BALL_SIZE
	                    CMP  BALL_X, AX              	; Is ball_x + BALL_SIZE < brick_x + brick_size?
	                    JLE  neg_speed_y             	; Top collision confirmed

	                    JMP  check_left

	check_left:         
	; === Check Left Collision ===
	; Left side of the ball touching the right side of the brick
	                    MOV  AX, bricks_initial_x[si]	; AX = brick_x
	                    ADD  AX, brick_width         	; AX = brick_x - BALL_SIZE
	                    CMP  BALL_X, AX              	; Is ball_x < brick_x + brick_width?
	                    JG   check_right             	; If not, check for right collision

	                    JMP  neg_speed_x             	; Left collision confirmed

	check_right:        
	; === Check Right Collision ===
	; Right side of the ball touching the left side of the brick
	                    MOV  AX, bricks_initial_x[si]	; AX = brick_x + brick_width
	                    SUB  AX, BALL_SIZE
	                    CMP  BALL_X, AX              	; Is ball_x + BALL_SIZE > brick_x?
	                    JLE  nn                      	; No collision detected

	                    JMP  neg_speed_x             	; Right collision confirmed

	nn:                 
	                    RET

	reset_position:     
	                    Call Reset_Ball_Position
	                    RET

	neg_speed_x:        
	                    NEG  BALL_X_SPEED
	                    RET

	neg_speed_y:        
    
	                    NEG  BALL_Y_SPEED
	; Correct ball position if stuck
	                    MOV  AX, BALL_Y
	                    CMP  AX, 0                   	; Check if ball_y is above the top boundary
	                    JGE  no_position_fix
	                    MOV  BALL_Y, 3               	; Reset ball position slightly below top boundary
	no_position_fix:    
	                    RET
	

Move_Ball ENDP

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

Draw_B_Ball PROC FAR
	                    mov  cx, BALL_X              	;set start X
	                    mov  dx, BALL_Y              	;set start Y

	hor_b_draw_ball:    
	                    mov  ah,0ch                  	;set writing pixel
	                    mov  al,00h                  	;choose white as color
	                    mov  bh,00h                  	;set page number
	                    int  10h

	                    inc  cx                      	;adding 1 to x
	                    mov  ax,cx
	                    sub  ax,BALL_X               	;seeing the diff between current x and initial x
	                    cmp  ax,BALL_SIZE            	;comparing them
	                    jng  hor_b_draw_ball         	;go to draw the next x pos
 
	                    mov  cx,BALL_X               	;if i finished the line, reseting x position
	                    inc  dx                      	;go to the next line
			
	                    mov  ax,dx
	                    sub  ax,BALL_Y               	;seeing the diff bet current y and iniyial y
	                    cmp  ax,BALL_SIZE            	;comparing it with ball size
	                    jng  hor_b_draw_ball         	;go to draw next line

	                    RET
Draw_B_Ball ENDP

Draw_Ball PROC FAR
	                    mov  cx, BALL_X              	;set start X
	                    mov  dx, BALL_Y              	;set start Y

	hor_draw_ball:      
	                    mov  ah,0ch                  	;set writing pixel
	                    mov  al,0fh                  	;choose white as color
	                    mov  bh,00h                  	;set page number
	                    int  10h

	                    inc  cx                      	;adding 1 to x
	                    mov  ax,cx
	                    sub  ax,BALL_X               	;seeing the diff between current x and initial x
	                    cmp  ax,BALL_SIZE            	;comparing them
	                    jng  hor_draw_ball           	;go to draw the next x pos
 
	                    mov  cx,BALL_X               	;if i finished the line, reseting x position
	                    inc  dx                      	;go to the next line
			
	                    mov  ax,dx
	                    sub  ax,BALL_Y               	;seeing the diff bet current y and iniyial y
	                    cmp  ax,BALL_SIZE            	;comparing it with ball size
	                    jng  hor_draw_ball           	;go to draw next line




	                    RET
Draw_Ball ENDP

Reset_Ball_Position PROC NEAR
	                    mov  ax,BALL_ORIGINAL_X
	                    mov  BALL_X,ax

	                    mov  ax,BALL_ORIGINAL_Y
	                    mov  BALL_Y,ax

	                    RET
Reset_Ball_Position ENDP


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_collision PROC near
	                    push ax
	                    push cx
	                    push dx


	                    mov  bx, 8                   	; Number of rows
	                    mov  si, 16                  	; Number of columns

	; Loop through rows
	check_row:          
	; First, check if collision can happen with this row, if yes, go prove that by checking the column of collision
	;BALL_Y + BALL_SIZE + offset > BRICK_Y (top of brick) with (bottom left of ball)
	                    mov  ax, BALL_Y
	                    add  ax, BALL_SIZE
	                    ADD  AX, WINDOW_BOUNCE
	                    cmp  ax, bricks_initial_y[bx]	; Compare ball's Y with brick's initial Y
	                    jl   finish_row              	; If less, skip this row
		
	;BALL_Y < BRICK_Y + brick_height + offset (top left of ball is above bottom of brick)
	                    MOV  AX, BALL_Y
	                    mov  dx, bricks_initial_y[bx]
	                    add  dx, brick_height
	                    ADD  DX, WINDOW_BOUNCE
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
	                    mov  ax, BALL_X
	                    ADD  AX, BALL_SIZE
	                    ADD  AX, WINDOW_BOUNCE
	                    cmp  ax, bricks_initial_x[SI]	; Compare ball's X + size with brick's initial X (collision of right side of ball)
	                    jl   finish_col              	; If less, skip this column
		
	;compare ball top left with the brick's right side
	;BALL_X < brick_x + brick_width + offset
	                    mov  dx, bricks_initial_x[si]
	                    add  dx, brick_width
	                    ADD  DX, WINDOW_BOUNCE
	                    MOV  AX, BALL_X
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

	finish:             
	                    mov  ax,bx
	                    mov  cx, 9
	                    mul  cx
	                    add  ax,si                   	;index is stored in ax
	                    mov  di,ax

	                    mov  ax,active_bricks[di]
	                    cmp  ax,0                    	;if it is zero means is not active brick
	                    je   no_index                	;no collision happened

	                    mov  active_bricks[di],0     	;if collision happens deactivate brick
	                    dec  BRICKS_LEFT             	; Reduce brick count
	                    inc  SCORE                   	; Increase score by 1
	
	                    cmp  BRICKS_LEFT, 0          	; Check if all bricks are cleared
	                    jne  draw_next_brick
	                    call level_up                	;Level up logic if all bricks are cleared
	draw_next_brick:    
	                    mov  cx,bricks_initial_x[si]
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
check_collision ENDP
level_up PROC NEAR
	                    push AX
	                    push bx
	                    inc  LEVEL                   	; Increase level
	                    mov  BRICKS_LEFT, 45         	; Reset brick count

	
	                    mov  ax, BALL_X_SPEED        	;Increase ball speed for higher difficulty
	                    mov  bx,2
	                    mul  bx                      	; Increment X speed
	                    mov  BALL_X_SPEED, ax

	                    mov  ax, BALL_Y_SPEED
	                    mul  bx                      	; Increment Y speed
	                    mov  BALL_Y_SPEED, ax

	                    pop  bx
	                    pop  ax
	                    
	                    ret
level_up ENDP

resetActiveBricks PROC FAR
	                    mov  cx, 45
	                    mov  si, 0
	resetActiveBricks_loop:
	                    mov  active_bricks[si], 1
	                    add  si, 2
	                    loop resetActiveBricks_loop
	                    ret
resetActiveBricks ENDP

END Move_Ball