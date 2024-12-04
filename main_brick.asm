
EXTRN Brick:FAR
public brick_width
public brick_height

.model small
.stack 64
.data
    bricks_initial_x dw 4d, 43d, 82d, 121d, 160d, 199d, 238d, 277d		;initial x-values (columns) for bricks (total=8)
    bricks_initial_y dw 6d, 20d, 34d, 48d, 62d							;initial y-values (rows) for bricks (total=5)
	colors dw 12, 7, 9, 10, 11											;colors for rows (red, grey, blue, green, cyan)
    brick_width dw 32d					;bricks width
    brick_height dw 9d					;bricks height
.code
main PROC FAR
    mov ax, @data
    mov ds, ax
	
    MOV AL, 13h
    MOV AH, 0
    INT 10h								;set video mode

    MOV CX, 8							;counter for number of bricks in each row
	MOV DI, 0							;index for column
	MOV SI, 0							;index for row
	MOV DX, bricks_initial_y			;get first y-value and store in DX
    
	; Draw bricks in current row
	Render_Horizontal:
        PUSH CX							;store CX to keep for counter
        ;Store the x-value in CX, and y-value in DX, the PROC Brick expects them that way
		MOV AX, colors[SI]				;set row color according to index (we're only interested in AL)
		MOV CX, bricks_initial_x[DI]	;store in CX and initial x of index DI (0 initially)
		PUSH DI							;store DI to protect index before calling the PROC
		CALL Brick						;draw a single brick, of initial X at CX, and initial Y in DX, and color in AL (we set AX)
		POP DI							;restore DI
		ADD DI, 2						;increment index by 2 (because its word)
        POP CX							;restore counter
    loop Render_Horizontal
	
	; When row rendeing loop ends, lets go one new row below it
	Render_Vertical:
		MOV DI, 0						;reset initial x index back to 0
		ADD SI, 2						;increment initial y index
		CMP SI, 10						;check if we reached the limit of bricks (10)
		JGE END_PROC					;if we did, return
		MOV DX, Bricks_Initial_y[SI]	;put the current y by its index in DX
		mov cx, 8						;restore CX for the upper loop
		JMP Render_Horizontal			;go back render this row
	
	END_PROC:							;end
	ret
main ENDP
end main