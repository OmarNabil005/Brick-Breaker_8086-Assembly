initPort MACRO
    ;Set Divisor Latch Access Bit
    MOV DX, 3FBh 				; Line Control Register
    MOV AL, 10000000b			;Set Divisor Latch Access Bit
    OUT DX, AL					;Out it
	
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
	
	extrn display_stats:FAR
	extrn Move_Ball:FAR
	extrn menu:FAR
	extrn Draw_Ball:FAR
	extrn Draw_B_Ball:FAR
	extrn Bar:FAR
	extrn moveLeft:FAR
	extrn moveRight:FAR
	extrn TIME_STORE:byte
	extrn resetBallAndBricks:FAR
	extrn resetBar:FAR
	public SCORE
	public LIVES
	public LEVEL
	public BRICKS_LEFT

	extrn drawBricks:FAR

	public GAME

	
	.MODEL SMALL
	.STACK 100h

.DATA
	LIVES       dw 3
	LEVEL       dw 1
	SCORE       dw 0
	BRICKS_LEFT dw 45

.CODE

GAME proc far

	clearscreen
	Call		   resetAll
	Call        Display_Stats
	Call        drawBricks
	Call        Bar
	initPort

	Check_time:
		mov  ah,2ch       	;get system time
		int  21h          	;ch = hour | cl = min | dh = sec | dl = 1/100 secs

		cmp  dl,TIME_STORE	;comparing current time with prev one
		je   Check_time

		mov  TIME_STORE,dl	;storing current time

		Call Draw_B_Ball

		Call Move_Ball
	
		Call Draw_Ball
		Call Display_stats
		
		CALL check_local
		
		CALL check_remote
		jmp check_time
	;moveball:  jmp         checkKey

	exitt:     
	           Ret
	           ENDP        GAME

check_local proc
	checkKey:; scan codes *** left arrow -> 4B, right arrow -> 4D , esc -> 1
		mov         ah, 1        	; peek keyboard buffer
		int         16h
		jnz         get_key      	; jump to wherever you want later to keep logic going if no key was pressed
		jmp         end_local
		;Key exists
		
	get_key:
		mov         ah, 0        	; get key (and clear keyboard buffer)
		int         16h
		;;;;;;;SENDING KEY TO PORT;;;;;;;;;;;;;
		
		mov dx,3FDH 			;Line Status Register
		in al , dx 				;Read Line Status
		AND al , 00100000b
		jz end_local          	;Not empty
		mov dx, 3F8H			;Transmit data register
		mov al, ah       		;put the data into al
		out dx, al         		;sending the data
		;;;;;;;;;;;;;;;;;;;;;;;;;;
		cmp         ah, 4Bh
		jne         checkRight   	; if not left arrow, check right arrow
		;left arrow key
		
		call        moveLeft
		jmp         end_local

	checkRight:
		cmp         ah, 4Dh
		jne         checkEsc     	; if not right arrow, check next key
		;right arrow key
		;send right arrow to port
		call        moveRight
		jmp         end_local
	checkEsc:  
		cmp         ah, 1
		jne         end_local     	; if not esc, keep game going
		;jmp         exitt
	end_local:
	
	ret
 check_local ENDP
 
 check_remote PROC
		MOV DX, 3FDh		;line status register
		in AL, DX			;take from the line register into AL
		AND al, 1			;check if its not empty
		JZ exit_remote		;if it's empty, go recieve mode again (loop)
	; status register is not empty, theres data in the recieve com port
		MOV DX, 03F8h
		in al, dx		;take key from the port, store in al
		
		cmp         al, 4Bh
		jne         checkRightRemote   	; if not left arrow, check right arrow
		;left arrow key
		;send left arrow to port
		
		call        moveLeft
		jmp         exit_remote

	checkRightRemote:
		cmp         al, 4Dh
		jne         checkEscRemote     	; if not right arrow, check next key
		;right arrow key
		;send right arrow to port
		call        moveRight
		jmp         exit_remote
		
	checkEscRemote:  
		cmp         al, 1	;escape
		je exitt			;if escape, exit
		;jne         moveball     	; if not esc, keep game going
 exit_remote:
	ret
 check_remote ENDP
MAIN PROC
  
	; Initialize data segment
	           MOV         AX, @DATA
	           MOV         DS, AX
	
	           clearscreen


	           mov         ah,00h       	;set video mode
	           mov         al,13h       	;choose video mode
	           int         10h

	           Call        menu
	           
		
	           Call        GAME

	; Exit program
	exit:      
	           MOV         AH, 4Ch      	; DOS interrupt to exit
	           INT         21h          	; Call DOS interrupt
	
MAIN ENDP

resetAll PROC NEAR
	           MOV         LIVES, 3
	           MOV         SCORE, 0
			   MOV         LEVEL, 1
	           MOV         BRICKS_LEFT, 45
			   call 	   resetBallAndBricks
			   call 	   resetBar
	           RET
resetAll ENDP
END MAIN