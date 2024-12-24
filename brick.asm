public brick

.model small

.data
    brick_width EQU 28d					;bricks width
    brick_height EQU 9d					;bricks height
.code
brick PROC FAR
	
    MOV AH, 0Ch                     ;set interrupt variable
	
	PUSH BP							;store BP to save its value
	MOV BP, SP						;make BP the stack pointer, to access original values in stack directly without needing to pop
	
	PUSH CX							;holds initial x-value [BP-2]
	PUSH DX							;holds initial y-value [BP-4]
	
    Draw_Brick_Horizontal:
        INT 10h                     ;plot the pixel
        INC CX                      ;increment column value

;       x-x0 < width?
        MOV BX, CX                  ;move CX to BX to perform subtraction without messing with CX value
        SUB BX, [BP-2]			    ;subtract from BX the initial x (BP-2 in stack)
        CMP BX, brick_width         ;check if the difference equals to the width
        JL Draw_Brick_Horizontal    ;if less, continue drawing horizontally, else go draw vertically

;   If we reached here, that means we've reached the width limit
    MOV CX, [BP-2]         			;reset the column value to its initial
    INC DX                          ;increment row

    Draw_Brick_Vertical:
;       Just check if y-y0<height
        MOV BX, DX                  ;move DX to BX to perform subtraction without messing with DX value (current y)   
        SUB BX, [BP-4]     			;subtract y0 from BX (current y)
        CMP BX, brick_height        ;check if the difference equals to the width
        JL Draw_Brick_Horizontal    ;if less, continue drawing horizontally this row
		
;       Here we've reached the end
;	Clear stack
	POP DX							
	POP CX
	POP BP
	RET

brick ENDP
end brick