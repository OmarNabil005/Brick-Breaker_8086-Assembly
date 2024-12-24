extrn menu:far
extrn LEVEL:word
extrn resetActiveBricks:far
extrn Convert_Number:far
public loss
EXTRN LIVES:word
EXTRN LIVES_2:word
EXTRN BRICKS_LEFT_1:word
EXTRN BRICKS_LEFT_2:word
EXTRN SCORE:word

.MODEL SMALL
.STACK 100h
.DATA
    GameOverText DB 'Game Over$', 0
    YouWinText   DB 'You won$', 0
    ScoreText    DB 'Your Score:$',0
    CurScore     DB 4 dup("$")
    ExitOption   DB '1. Exit$', 0
    MenuOption   DB '2. Back to Menu$', 0

.CODE
                   PUBLIC loss

    ; Procedure to display a string at a specific screen position
Display_String PROC NEAR
    ; Input:
    ; DS:DX = string address
                   push   ax
                   push   bx

    ; Display string using DOS interrupt
                   mov    ah, 09h
                   int    21h

                   pop    bx
                   pop    ax
                   ret
Display_String ENDP

    ; Procedure to set the cursor position
Set_Cursor PROC NEAR
    ; Input:
    ; DH = row
    ; DL = column
                   push   ax
                   push   bx

                   mov    ah, 02h
                   mov    bh, 0               ; Page number
                   int    10h

                   pop    bx
                   pop    ax
                   ret
Set_Cursor ENDP

    ; Procedure to clear the screen
Clear_Screen PROC NEAR
                   push   ax
                   push   bx
                   push   cx
                   push   dx

                   mov    ah, 06h           ; Scroll up window
                   mov al, 0
                   mov    bh, 07h             ; Fill entire window with this attribute
                   mov    cx, 0               ; Upper left corner (row 0, col 0)
                   mov    dx, 184fh           ; Lower right corner (row 24, col 79)
                   int    10h                 ; BIOS interrupt

                   mov ah, 0
                   mov al, 3
                   int 10h
                   pop    dx
                   pop    cx
                   pop    bx
                   pop    ax
                   ret
Clear_Screen ENDP

    ; Main procedure
loss PROC FAR
                   push   ax
                   push   ds
                   push   dx


    ; Clear the screen
                   call   Clear_Screen
                   
                   cmp LIVES, 0
                je losee

;;; COMPARE TWO BRICKS LEFT
                    mov ax, bricks_left_2
                    cmp bricks_left_1, ax
                    jg losee
                    jle win
;;;;;;;;;;;;;;;;;;;;

                losee:
    ; Display 'Game Over' in the middle of the screen
                   mov    dh, 12              ; Middle row (approx.)
                   mov    dl, 15              ; Center column (approx.)
                   call   Set_Cursor
                   lea    dx, GameOverText
                   call   Display_String
                   jmp display_label
                   win:
                   mov    dh, 12              ; Middle row (approx.)
                   mov    dl, 15              ; Center column (approx.)
                   call   Set_Cursor
                   lea    dx, YouWinText
                   call   Display_String

                    
display_label:
                    mov dh, 14
                    mov dl, 15
                    call Set_Cursor
                    lea dx, ScoreText
                    call Display_String
                    mov dh, 14
                    mov dl, 28
                    call Set_cursor
                    lea di, CurScore
                    mov AX, SCORE
                    call Convert_Number
                    lea dx, CurScore
                    call Display_String
    ; Display Exit option
                   mov    dh, 16              ; Below 'Game Over'
                   mov    dl, 15              ; Center column (approx.)
                   call   Set_Cursor
                   lea    dx, ExitOption
                   call   Display_String

    ; Display Menu option
                   mov    dh, 17              ; Below Exit option
                   mov    dl, 15              ; Center column (approx.)
                   call   Set_Cursor
                   lea    dx, MenuOption
                   call   Display_String

    ; Wait for valid user input
    call check_local_loss
    call check_remote_loss

    ExitProgram:   
    ; Exit the program (INT 20h - Terminate Program)
                   mov    ah, 4Ch
                   int    21h

    BackToMenu:    
                   call   menu
                   ret                        ; Return to caller

loss ENDP

check_local_loss proc
    checkKey:                                      	; scan codes *** left arrow -> 4B, right arrow -> 4D , esc -> 1
	                 mov         ah, 1             	; peek keyboard buffer
	                 int         16h
	                 jnz         get_key           	; jump to wherever you want later to keep logic going if no key was pressed
	                 call        check_remote_loss
	;Key exists
		
	get_key:         
	                 mov         ah, 0             	; get key (and clear keyboard buffer)
	                 int         16h
	;;;;;;;SENDING KEY TO PORT;;;;;;;;;;;;;
		
	                 mov         dx,3FDH           	;Line Status Register
	                 in          al , dx           	;Read Line Status
	                 AND         al , 00100000b
	                 jnz          send         	;Not empty
                    call        check_remote_loss

                     send:
	                 mov         dx, 3F8H          	;Transmit data register
	                 mov         al, ah            	;put the data into al
	                 out         dx, al            	;sending the data
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	                 cmp         ah, 2 ;exit
	                 je         end_local        	; if not left arrow, check right arrow
	;left arrow key
	                 cmp         ah, 3;continue
	                 jne         check_remote_2          	; if not right arrow, check next key
	;right arrow key
	;send right arrow to port
	                 CALL         menu
                     ret
	;jmp         exitt
	end_local:       
	; Terminate program
                   mov            ah, 4Ch
                   int            21h
	                ret
    check_remote_2:
        call check_remote_loss
        ret
check_local_loss ENDP
check_remote_loss PROC
	                 MOV         DX, 3FDh          	;line status register
	                 in          AL, DX            	;take from the line register into AL
	                 AND         al, 1             	;check if its not empty
	                 Jnz          cont       	;if it's empty, go recieve mode again (loop)
                     call check_local_loss
     cont:                
	; status register is not empty, theres data in the recieve com port
	                 MOV         DX, 03F8h
	                 in          al, dx            	;take key from the port, store in al
		;;;;;;;;;;;;;;;

	                 cmp         al, 2;exit
	                 je         exit_remote  	; if not left arrow, check right arrow

                    cmp al, 3;menu
                    jne return
	                 call        menu

	exit_remote:     
    ; Terminate program
                   mov            ah, 4Ch
                   int            21h
                   ret
    return:
	                 call check_local_loss
                     ret
check_remote_loss ENDP

END loss
