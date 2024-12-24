clearscreen macro
                MOV ax, 0600h    ; Scroll up intterupt
                MOV bh, 00h
                MOV cx, 0        ; top left corner to scroll from
                MOV dh, 25       ; bottom row
                MOV dl, 80       ; right column
                int 10h          ; call the interrupt
endm

drawPixel macro color, X, Y

    mov ah, 0Ch         ; draw pixel interrupt
    mov al, color       ; light Gray
    mov bh, 0h          ; page num
    mov cx, X           ; x
    mov dx, Y           ; y
    int 10h
endm

extrn brick:far
public drawBricksleft
public drawBricksright
public bricks_initial_y
public bricks_initial_x_left
public bricks_initial_x_right
public vertical_line
.model small
.stack 64
.data
    bricks_initial_y       dw  6d, 20d, 34d, 48d, 62d          ;initial y-values (rows) for bricks (total=5)
    bricks_initial_x_left  dw  3d, 34d, 65d, 96d, 127d         ; 38 pixels between starts (32 + 6)
    bricks_initial_x_right dw  164d, 195d, 226d, 257d, 288d    ; Same spacing
    colors                 dw  7, 10, 9, 13, 12                ;colors for rows (grey, green, blue, pink, red)
    num_columns            EQU 5                               ;number of bricks in each row
    num_rows               EQU 5                               ;number of rows
    brick_width            EQU 28d                             ;bricks width
    brick_height           EQU 9d                              ;bricks height

.code

drawBricksleft PROC FAR
                            PUSH        DS
                            MOV         AX, @data
                            MOV         DS, AX

                            MOV         CX, num_columns
                            MOV         DI, 0
                            MOV         SI, 0
                            MOV         BX, 0
                            MOV         DX, bricks_initial_y
    
    Render_Horizontal_left: 
                            PUSH        CX
		
                            MOV         AX, colors[SI]
                            MOV         CX, bricks_initial_x_left[DI]
                            PUSH        DI
		
    draw_left:              
                            CALL        Brick
                            POP         DI
                            ADD         DI, 2
                            POP         CX
                            loop        Render_Horizontal_left
	
    Render_Vertical_left:   
                            MOV         DI, 0
                            ADD         SI, 2
                            CMP         SI, num_rows * 2
                            JGE         END_PROC_left
                            MOV         DX, Bricks_Initial_y[SI]
                            MOV         CX, num_columns
                            JMP         Render_Horizontal_left

    END_PROC_left:          
                            POP         DS
                            ret
drawBricksleft ENDP

vertical_line proc FAR
	mov si, 0
	mov di, 157
	drawHorizontal1:                        ; outer loop (draws horizontal lines)
        mov si, 0             ; start at Y = 450
        inc di                           ; start at X = 270
        cmp di, 161      ; end at X = 370 -> width = 100
        jna cont1                           ; handle jump out of range
        jmp rett
        cont1:

    drawVertical1:                          ; inner loop (draws vertical lines)
        drawPixel 07h, di, si

        inc si
        cmp si, 180
        je drawHorizontal1                  ; jump to outer loop if inner loop ended 

    jmp drawVertical1

rett:
	ret

endp vertical_line

drawBricksright PROC FAR
                            PUSH        DS
                            MOV         AX, @data
                            MOV         DS, AX

                            MOV         CX, num_columns
                            MOV         DI, 0
                            MOV         SI, 0
                            MOV         BX, 0
                            MOV         DX, bricks_initial_y
    
    Render_Horizontal_right:
                            PUSH        CX
		
                            MOV         AX, colors[SI]
                            MOV         CX, bricks_initial_x_right[DI]
                            PUSH        DI
		
    draw_right:             
                            CALL        Brick
                            POP         DI
                            ADD         DI, 2
                            POP         CX
                            loop        Render_Horizontal_right
	
    Render_Vertical_right:  
                            MOV         DI, 0
                            ADD         SI, 2
                            CMP         SI, num_rows * 2
                            JGE         END_PROC_right
                            MOV         DX, Bricks_Initial_y[SI]
                            MOV         CX, num_columns
                            JMP         Render_Horizontal_right

    END_PROC_right:         
                            POP         DS
                            ret
drawBricksright ENDP
end drawBricksright
; main PROC
;                             MOV         AX, @data                         ; Initialize DS
;                             MOV         DS, AX
                            
;                             MOV         AH, 0                             ; Set video mode
;                             MOV         AL, 13h                           ; 320x200 256 color mode
;                             INT         10h
                            
;                             clearScreen
;                             call        drawBricksleft
;                             call        drawBricksright
                            
;                             MOV         AH, 4Ch                           ; Return to DOS
;                             INT         21h
; main ENDP
; end main