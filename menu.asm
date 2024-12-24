initPort MACRO
	;Set Divisor Latch Access Bit
	         MOV DX, 3FBh     	; Line Control Register
	         MOV AL, 10000000b	;Set Divisor Latch Access Bit
	         OUT DX, AL       	;Out it
	
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

clear_screen MACRO
                 mov ah, 06h
                 mov al, 0
                 mov bh, 07h
                 mov cx, 0
                 mov dl, 80
                 mov dh, 25
                 int 10h

                  MOV AH, 0
                MOV AL, 3
                INT 10h
ENDM

moveCursor MACRO row, col
               mov dl, col
               mov dh, row
               mov bh, 0
               mov ah, 02h
               int 10h
ENDM

displayMessage MACRO String
                   lea dx, String
                   mov ah, 09h
                   int 21h
ENDM

extrn GAME:far
extrn chat:far
public menu

.model small
.stack 100h
.data
    menu1 db "1. Start", '$'
    menu2 db "2. Quit", '$'
    menu3 db "3. Chat", '$'
    
.code
menu proc far
                   
                   clear_screen

    ; Center and display "Start"
                   moveCursor     10, 30
                   displayMessage menu1

    ; Center and display "Quit"
                   moveCursor     12, 30
                   displayMessage menu2

    ; Center and display "Chat"
                   moveCursor     14, 30
                   displayMessage menu3

    

    call check_local_menu
    call check_remote_menu
    ; Wait for user input
    ; wait_for_input:
    ;                mov            ah, 00h
    ;                int            16h
    ;                cmp            al, '1'
    ;                je             start_game
    ;                cmp            al, '2'
    ;                je             exit
    ;                cmp            al, '3'
    ;                je             chat_function
    ;                jmp            wait_for_input

    ; start_game:    
    ; ; Load and execute the start program
    ;                call           GAME
    ;                jmp            exit
  

    ; chat_function: 
    ; ; Load and execute the chat program
    ;                call           chat
    ;                int            21h
    ;                jmp            exit

    exit:          
    ; Terminate program
                   mov            ah, 4Ch
                   int            21h

menu endp


check_local_menu proc near
	checkKey:                                      	; scan codes *** left arrow -> 4B, right arrow -> 4D , esc -> 1
	                 mov         ah, 1             	; peek keyboard buffer
	                 int         16h
	                 jnz         get_key           	; jump to wherever you want later to keep logic going if no key was pressed
	                 call        check_remote_menu
	;Key exists
		
	get_key:         
	                 mov         ah, 0             	; get key (and clear keyboard buffer)
	                 int         16h
	;;;;;;;SENDING KEY TO PORT;;;;;;;;;;;;;
		
	                 mov         dx,3FDH           	;Line Status Register
	                 in          al , dx           	;Read Line Status
	                 AND         al , 00100000b
	                 jnz          send         	;Not empty
                    call        check_remote_menu

                     send:
	                 mov         dx, 3F8H          	;Transmit data register
	                 mov         al, ah            	;put the data into al
	                 out         dx, al            	;sending the data
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	                 cmp         ah, 2
	                 jne         check_chat        	; if not left arrow, check right arrow
	;left arrow key
		
	                 call        GAME
	                 jmp         end_local

	check_chat:      
	                 cmp         ah, 4
	                 jne         check_exit          	; if not right arrow, check next key
	;right arrow key
	;send right arrow to port
	                 call        chat
                     int         21h
	                 jmp         end_local
	check_exit:        
	                 cmp         ah, 3
	                 je         end_local         	; if not esc, keep game going
                     call       check_remote_menu
	;jmp         exitt
	end_local:       
	; Terminate program
                   mov            ah, 4Ch
                   int            21h
	                 ret
check_local_menu ENDP

check_remote_menu PROC
	                 MOV         DX, 3FDh          	;line status register
	                 in          AL, DX            	;take from the line register into AL
	                 AND         al, 1             	;check if its not empty
	                 Jnz          cont       	;if it's empty, go recieve mode again (loop)
                     call         check_local_menu
     cont:                
	; status register is not empty, theres data in the recieve com port
	                 MOV         DX, 03F8h
	                 in          al, dx            	;take key from the port, store in al
		
	                 cmp         al, 2
	                 jne         check_chat_remote  	; if not left arrow, check right arrow
	;left arrow key
	;send left arrow to port
		
	                 call        GAME
	                 jmp         exit_remote

	check_chat_remote:
	                 cmp         al, 4
	                 jne         check_exit_remote    	; if not right arrow, check next key
	;right arrow key
	;send right arrow to port
	                 call        chat
                     int         21h
	                 jmp         exit_remote
		
	check_exit_remote:  
	                 cmp         al, 3             	;escape
                     je          exit_remote
                     call        check_local_menu
	
	exit_remote:     
    ; Terminate program
                   mov            ah, 4Ch
                   int            21h
	                 ret
check_remote_menu ENDP

end menu