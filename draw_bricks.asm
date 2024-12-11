
EXTRN Brick:FAR
EXTRN BALL_X:word
EXTRN BALL_Y:Word
EXTRN BALL_X_SPEED:word
EXTRN BALL_Y_SPEED:word
public drawBricks


.model small
.stack 64
.data
    ;bricks_initial_x dw 4d, 43d, 82d, 121d, 160d, 199d, 238d, 277d		;initial x-values (columns) for bricks (total=8)
    bricks_initial_y dw 6d, 20d, 34d, 48d, 62d							;initial y-values (rows) for bricks (total=5)
	bricks_initial_x dw 4d, 39d, 74d, 109d,144d,179d, 214d, 249d
	;bricks_initial_y dw 6d, 15d, 24d, 33d, 42d
	active_bricks dw 1, 1, 1, 1, 1, 1, 1, 1
				  dw 1, 1, 1, 1, 1, 1, 1, 1
				  dw 1, 1, 1, 1, 1, 1, 1, 1
				  dw 1, 1, 1, 1, 1, 1, 1, 1
				  dw 1, 1, 1, 1, 1, 1, 1, 1
	colors dw 7, 10, 9, 13, 12											;colors for rows (grey, green, blue, pink, red)
	num_columns EQU 8					;number of bricks in each row
	num_rows EQU 5						;number of rows
	brick_width EQU 32d					;bricks width
    brick_height EQU 9d					;bricks height
.code
drawBricks PROC FAR
	;PUSH DS
    mov ax, @data
    mov ds, ax


    MOV CX, num_columns					;counter for number of bricks in each row
	MOV DI, 0							;index for column
	MOV SI, 0							;index for row
	MOV BX, 0							;index for active bricks
	MOV DX, bricks_initial_y			;get first y-value and store in DX
    
	; Draw bricks in current row
	Render_Horizontal:
        PUSH CX							;store CX to keep for counter
		
        ;Store the x-value in CX, and y-value in DX, the PROC Brick expects them that way
		MOV AX, colors[SI]				;set row color according to index (we're only interested in AL)
		MOV CX, bricks_initial_x[DI]	;store in CX and initial x of index DI (0 initially)
		 PUSH DI							;store DI to protect index before calling the PROC
		; PUSH DX
		; PUSH AX
		; PUSH BX
		; PUSH CX
		; CALL check_collision 			; check ball collision and sets active accordingly
		; POP CX
		; POP BX
		; POP AX
		; POP DX
		;Check if brick is active
		;index = row * columns + column

		; MOV AX, SI             ; Move SI into AX (AX is required for MUL)
		; MOV BX, num_columns	   ; Load the value of num_columns into BX
		; PUSH DX		
		; MUL BX                 ; AX = SI * num_columns
		; POP DX
		; ;Result is now in AX
		; ADD AX, DI
		; MOV BX, AX
		
		
		; ; ;check if current index is active
		; MOV AX, [active_bricks + BX]
		; CMP AL, 0
		; JE draw_black
		; MOV AX, colors[SI]
		
		draw:
		CALL Brick						;draw a single brick, of initial X at CX, and initial Y in DX
		POP DI							;restore DI
		ADD DI, 2						;increment index by 2 (because its word)
        POP CX							;restore counter
    loop Render_Horizontal
	
	; When row rendeing loop ends, lets go one new row below it
	Render_Vertical:
		MOV DI, 0						;reset initial x index back to 0
		ADD SI, 2						;increment initial y index
		CMP SI, num_rows * 2			;check if we reached the limit of bricks (10)
		JGE END_PROC					;if we did, return
		MOV DX, Bricks_Initial_y[SI]	;put the current y by its index in DX
		mov cx, 8						;restore CX for the upper loop
		JMP Render_Horizontal			;go back render this row
	
	
	draw_black:
		MOV AL, 0
		JMP draw
	END_PROC:
	;POP DS							;end
	ret
drawBricks ENDP


check_collision PROC near
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	PUSH SI
	
	;|----|
	;|____|	^
	;ball_y > brick[i].y && ball_y < brick[i].y + brick_height
	;ball_x > brick[i].x && ball_x < brick[i].x + brick_width
	MOV SI, num_rows * 2 ;index = cx-3
	MOV BX, num_columns * 2
	
	check_rows:
	;ball_y > brick[i].y && ball_y < brick[i].y + brick_height
	MOV AX, BALL_Y
	push BX
	mov BX, SI
	CMP AX, bricks_initial_y[BX-2]
	pop BX
	JB next_row
	
	PUSH BX
	MOV BX, SI
	MOV DX, bricks_initial_y[BX-2]
	POP BX
	ADD DX, brick_height
	CMP AX, DX
	JB check_columns
	next_row:
	SUB SI, 2
	CMP SI, 0
	JG check_rows
	
	
	check_columns:
	;ball_x, brick x
	;ball_x > brick[i].x && ball_x < brick[i].x + brick_width
	
	MOV AX, BALL_X
	CMP AX, bricks_initial_x[BX-2]
	JB next_col
	
	MOV DX, bricks_initial_x[BX-2]
	ADD DX, brick_width
	CMP AX, DX
	JL set_inactive
	
	next_col:
	SUB BX, 2
	CMP BX, 0
	JG check_columns
	
	JMP main_end
	set_inactive:
		;bx - 1 = x-position
		;cx - 1 = y-position
		;index = row * columns + column
		SUB BX, 2
		SUB SI, 2
		MOV AX, SI             ; Move SI into AX (AX is required for MUL)
		MOV DX, num_columns	   ; Load the value of num_columns into BX
		MUL DX                 ; AX = SI * num_columns
		;Result is now in AX
		ADC AX, BX
		MOV BX, AX				;index in BX
		MOV active_bricks[BX], 0
	main_end:
	POP SI
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
	RET
check_collision ENDP
end drawBricks