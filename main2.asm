	clearscreen macro
	MOV ax, 0600h                ; Scroll up intterupt
	MOV bh, 00h
	MOV cx, 0                    ; top left corner to scroll from
	MOV dh, 25                   ; bottom row
	MOV dl, 80                   ; right column
	int 10h                      ; call the interrupt
	endm
	
	extrn Move_Ball:FAR
	extrn Draw_Ball:FAR
	extrn Draw_B_Ball:FAR
	extrn Bar:FAR
	extrn moveLeft:FAR
	extrn moveRight:FAR
	extrn TIME_STORE:byte
	public lives

	extrn drawBricks:FAR

	
	.MODEL SMALL
	.STACK 100h
	
	.DATA
	lives db 03h
	.CODE
	MAIN PROC
	; Initialize data segment
	MOV AX, @DATA
	MOV DS, AX
	
	clearscreen
	
	mov ah,00h 					;set video mode 
	mov al,12h 					;choose video mode
	int 10h						;call video interrupt


	Call Bar
	Call drawBricks
		
	Check_time:
		mov ah,2ch 				;get system time 
		int 21h	   				;ch = hour | cl = min | dh = sec | dl = 1/100 secs 

		cmp dl,TIME_STORE		;comparing current time with prev one
		je Check_time			

		mov TIME_STORE,dl		;storing current time

		Call Draw_B_Ball

		Call Move_Ball			
		
		Call Draw_Ball
		
	checkKey:               ; scan codes *** left arrow -> 4B, right arrow -> 4D , esc -> 1 
		mov ah, 1               ; peek keyboard buffer
		int 16h
		jnz get_key            ; jump to wherever you want later to keep logic going if no key was pressed
		jmp Check_time
		get_key: mov ah, 0               ; get key (and clear keyboard buffer)
		int 16h

		cmp ah, 4Bh
		jne checkRight          ; if not left arrow, check right arrow
		call moveLeft
		jmp Check_time

		checkRight:
		cmp ah, 4Dh
		jne checkKey            ; if not right arrow, check next key
		call moveRight
		jmp Check_time

		checkEsc:
		cmp ah, 1
		jne moveball            ; if not esc, check next key
		mov ah, 4Ch             ; exit program
		moveball: jmp Check_time

	; Exit program
	MOV AH, 4Ch                  ; DOS interrupt to exit
	INT 21h                      ; Call DOS interrupt
	
	MAIN ENDP
	END MAIN


