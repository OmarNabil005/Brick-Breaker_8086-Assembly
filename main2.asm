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
	extrn TIME_STORE:byte


	
	.MODEL SMALL
	.STACK 100h
	
	.DATA
	
	.CODE
	MAIN PROC
	; Initialize data segment
	MOV AX, @DATA
	MOV DS, AX
	
	clearscreen
	
	mov ah,00h 					;set video mode 
	mov al,13h 					;choose vedio mode
	int 10h   


	Check_time:
		mov ah,2ch 				;get system time 
		int 21h	   				;ch = hour | cl = min | dh = sec | dl = 1/100 secs 

		cmp dl,TIME_STORE		;comparing current time with prev one
		je Check_time			

		mov TIME_STORE,dl		;storing current time
					
		clearscreen

		Call Move_Ball			

		Call Draw_Ball

		jmp Check_time			;go checking time again

	; Exit program
	MOV AH, 4Ch                  ; DOS interrupt to exit
	INT 21h                      ; Call DOS interrupt
	
	
	
	MAIN ENDP
	END MAIN


