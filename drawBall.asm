	clearscreen macro
	MOV ax, 0600h                ; Scroll up intterupt
	MOV bh, 00h
	MOV cx, 0                    ; top left corner to scroll from
	MOV dh, 25                   ; bottom row
	MOV dl, 80                   ; right column
	int 10h                      ; call the interrupt
	endm


	public TIME_STORE
	public Move_Ball
	public Draw_Ball

	.MODEL SMALL
	.STACK 100h
	
	.DATA
	
	WINDOW_WIDTH    dw 140h		;width of the window (320)
	WINDOW_HEIGHT   dw 0c8h		;height of the window (200)
	WINDOW_BOUNCE   dw 5h		;used to check collision early

	BALL_X 			dw 0a0h 		;x position of the ball
	BALL_ORIGINAL_X dw 0a0h		;x original position 

	BALL_Y 			dw 64h 		;y position of the ball
	BALL_ORIGINAL_Y dw 64h		;y original position 

	BALL_SIZE 		dw 04h 		;size of the ball

	TIME_STORE  	db 0		;variable used for checking time changed

	BALL_X_SPEED 	dw 02h		;speed of the ball in x axis 
	BALL_Y_SPEED 	dw 05h		;speed of the ball in y axis 


	.CODE
	

	Move_Ball PROC FAR
		mov ax,BALL_X_SPEED			
		add BALL_X,ax				;inc ball x pos with velocity

		mov ax,WINDOW_BOUNCE
		cmp BALL_X,ax
		jl  neg_speed_X				;if it collides with left wall

		mov ax,WINDOW_WIDTH
		sub ax,BALL_SIZE
		sub ax,WINDOW_BOUNCE
		cmp BALL_X,ax
		jg neg_speed_X				;if it collides with right wall

		mov ax,BALL_Y_SPEED
		add BALL_Y,ax				;inc ball y pos with velocity

		mov ax,WINDOW_BOUNCE
		cmp BALL_Y,ax
		jl  neg_speed_Y				;if it collides with top wall

		mov ax,WINDOW_HEIGHT
		sub ax,BALL_SIZE
		sub ax,WINDOW_BOUNCE
		cmp BALL_Y,ax
		jg neg_speed_Y				;if it collides with bottom wall
		;jg reset_position			;if it collides with bottom wall


		RET

		reset_position:
			Call Reset_Ball_Position
			RET

		neg_speed_X: 
			neg BALL_X_SPEED
			RET

		neg_speed_Y:
			neg BALL_Y_SPEED
			RET

	Move_Ball ENDP

	Clear_Screen PROC FAR
		mov ah,00h 					;set video mode 
		mov al,13h 					;choose vedio mode
		int 10h    

		mov ah,08h 
		mov bh,00h 					;background color
		mov bl,00h 					;choose black
		int 10h    

		RET
	Clear_Screen ENDP


	Draw_Ball PROC FAR
		mov cx, BALL_X  		;set start X
		mov dx, BALL_Y  		;set start Y

		hor_draw_ball:
			mov ah,0ch 			;set writing pixel
			mov al,0fh 			;choose white as color
			mov bh,00h      	;set page number
			int 10h  

			inc cx          	;adding 1 to x
			mov ax,cx			
			sub ax,BALL_X		;seeing the diff between current x and initial x
			cmp ax,BALL_SIZE	;comparing them
			jng hor_draw_ball	;go to draw the next x pos
 
			mov cx,BALL_X       ;if i finished the line, reseting x position
			inc dx				;go to the next line
			
			mov ax,dx			
			sub ax,BALL_Y		;seeing the diff bet current y and iniyial y
			cmp ax,BALL_SIZE    ;comparing it with ball size
			jng hor_draw_ball	;go to draw next line

		RET
	Draw_Ball ENDP

	Reset_Ball_Position PROC NEAR
		mov ax,BALL_ORIGINAL_X
		mov BALL_X,ax

		mov ax,BALL_ORIGINAL_Y
		mov BALL_Y,ax

		RET
	Reset_Ball_Position ENDP

	END Move_Ball


