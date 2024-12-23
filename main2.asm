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
	public live
	public SCORE
	public LIVES
	public LEVEL
	public BRICKS_LEFT

	extrn drawBricks:FAR

	public GAME

	
	.MODEL SMALL
	.STACK 100h

.DATA
	live        db 03h
	LIVES       dw 3
	LEVEL       dw 1
	SCORE       dw 0
	BRICKS_LEFT dw 45

.CODE

GAME proc far

	           clearscreen
	           Call        Bar
	           Call        drawBricks
	           Call        Display_Stats

	Check_time:
	           mov         ah,2ch       	;get system time
	           int         21h          	;ch = hour | cl = min | dh = sec | dl = 1/100 secs

	           cmp         dl,TIME_STORE	;comparing current time with prev one
	           je          Check_time

	           mov         TIME_STORE,dl	;storing current time

	           Call        Draw_B_Ball

	           Call        Move_Ball
		
	           Call        Draw_Ball
	           Call        Display_stats
		
	checkKey:                           	; scan codes *** left arrow -> 4B, right arrow -> 4D , esc -> 1
	           mov         ah, 1        	; peek keyboard buffer
	           int         16h
	           jnz         get_key      	; jump to wherever you want later to keep logic going if no key was pressed
	           jmp         Check_time
	get_key:   mov         ah, 0        	; get key (and clear keyboard buffer)
	           int         16h

	           cmp         ah, 4Bh
	           jne         checkRight   	; if not left arrow, check right arrow
	           call        moveLeft
	           jmp         checkKey

	checkRight:
	           cmp         ah, 4Dh
	           jne         checkEsc     	; if not right arrow, check next key
	           call        moveRight
	           jmp         checkKey


	checkEsc:  
	           cmp         ah, 1
	           jne         moveball     	; if not esc, keep game going
	           jmp         exitt
	moveball:  jmp         checkKey

	exitt:     
	           Ret
	           ENDP        GAME
MAIN PROC
  
	; Initialize data segment
	           MOV         AX, @DATA
	           MOV         DS, AX
	
	           clearscreen


	           mov         ah,00h       	;set video mode
	           mov         al,13h       	;choose vedio mode
	           int         10h

	           Call        menu
	           
		
	           Call        GAME

	; Exit program
	exit:      
	           MOV         AH, 4Ch      	; DOS interrupt to exit
	           INT         21h          	; Call DOS interrupt
	
MAIN ENDP
END MAIN