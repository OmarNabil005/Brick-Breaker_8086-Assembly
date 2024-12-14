
EXTRN Brick:FAR
EXTRN BALL_X:word
EXTRN BALL_Y:Word
EXTRN BALL_X_SPEED:word
EXTRN BALL_Y_SPEED:word
public drawBricks
public bricks_initial_x
public bricks_initial_y


.model small
.stack 64
.data
    
    bricks_initial_y dw 6d, 20d, 34d, 48d, 62d							;initial y-values (rows) for bricks (total=5)
	bricks_initial_x dw 4d, 39d, 74d, 109d,144d,179d, 214d, 249d, 284d
	
	colors dw 7, 10, 9, 13, 12											;colors for rows (grey, green, blue, pink, red)
	num_columns EQU 9					;number of bricks in each row
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
		MOV CX, num_columns						;restore CX for the upper loop
		JMP Render_Horizontal			;go back render this row

	END_PROC:
	;POP DS							;end
	ret
drawBricks ENDP

end drawBricks