initPort MACRO
    ;Set Divisor Latch Access Bit
             MOV DX, 3FBh         ; Line Control Register
             MOV AL, 10000000b    ;Set Divisor Latch Access Bit
             OUT DX, AL           ;Out it
	
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

clearScreen MACRO
                MOV AH, 0
                MOV AL, 3
                INT 10h
                MOV AH, 6      ;function 6
                MOV al, 13     ;scroll lines
                MOV bh, 07h    ;normal video attribute
                MOV ch, 0      ;upper left Y
                MOV cl, 0      ;upper left X
                MOV dh, 12     ;lower right Y
                MOV dl, 79     ;lower right X
                int 10h

	
                MOV AH, 6      ;function 6
                MOV al, 12     ;scroll lines
                MOV bh, 70h    ;normal video attribute
                MOV ch, 13     ;upper left Y
                MOV cl, 0      ;upper left X
                MOV dh, 24     ;lower right Y
                MOV dl, 79     ;lower right X
                int 10h
ENDM

setCursor MACRO x, y
              MOV AH, 2
              MOV BH, 0
              MOV DL, x
              MOV DH, y
              int 10h
ENDM

clearUpperScreen MACRO
                     mov AX, 0601h
                     mov BH, 07h
                     mov CH, 0
                     mov CL, 0
                     mov DH, 12
                     mov DL, 79
                     int 10h
ENDM

clearLowerScreen MACRO
                     mov AX, 0601h    ;int options (al=lines to scroll)
                     mov BH, 70h
                     mov CH, 13       ;top y
                     mov CL, 0        ;left x
                     mov DH, 24       ;bottom y
                     mov DL, 79       ;right x
                     int 10h
ENDM

saveCursorSender MACRO
                     mov ah,3h
                     mov bh,0h
                     int 10h
                     mov x_sender, dl
                     mov y_sender, dh
ENDM

saveCursorReciever MACRO
                       mov ah,3h
                       mov bh,0h
                       int 10h
                       mov x_reciever,	dl
                       mov y_reciever,	dh
ENDM


public chat
.MODEL small
.STACK 100
.data
    value      db ?, "$"
    messsage   DB 'reciever on , press esc to end session', 0AH, 0DH, "$"
    messsage2  DB 'Enter your string', 0AH, 0DH, "$"
    messsage3  DB 'good by then', 0AH, 0DH, "$"

    INPUT      DB ?
    x_sender   DB 0h
    x_reciever DB 0h
    y_sender   DB 0h
    y_reciever DB 0Dh

.code


chat proc FAR
                      MOV                ax, @data
                      MOV                ds, ax
	
                      initPort                                     ;initialize port
	
                      clearScreen                                  ;clear all screen

	
    main_loop:        
                      MOV                AH,1                      ;check if key is pressed
                      INT                16h
                      JNZ                send
                      JMP                recieve                   ;if no key is pressed, go recieve mode
	
    send:             
                      MOV                AH, 0                     ;clear keyboard buffer
                      int                16h
		
                      MOV                INPUT, AL                 ;Store it in AL (ASCII?)
                      CMP                AL, 0Dh                   ;check if enter
                      JNE                cont
	
	
    newline:          
                      CMP                y_sender, 12              ;check if y position is at end, if yes, clear sender screen
                      JNE                continue_new_line         ;if no, continue
		
    ;if y is at the end, clear screen
                      clearUpperScreen
                      MOV                x_sender, 0
    ;MOV y_sender, 0
                      setCursor          x_sender, y_sender
                      JMP                print                     ;now print
		
    continue_new_line:
                      INC                y_sender
                      MOV                x_sender, 0
    cont:             
                      setCursor          x_sender, y_sender
                      CMP                x_sender, 79              ;check if x went to the boundaries
                      JE                 dontprint
                      JMP                print                     ;if not, just print
    dontprint:        
	
    ; if x is at the boundaries
                      CMP                y_sender, 12              ;if y as at the boundaries (and x is also at the boundaries)
                      JNZ                print                     ;if not, just print normally
                      clearUpperScreen                             ;if both at the boundaries, clear the sender screen and reset cursor
                      MOV                x_sender, 0               ;set cursor x
    ;MOV y_sender, 0		;set cursor y (if clear)
                      setCursor          x_sender, y_sender
                      JMP                print                     ;then finally print
		
    print:            
                      mov                ah,2                      ;printing the char
                      mov                dl, INPUT
                      int                21h
		  
                      mov                dx,3FDH                   ;Line Status Register
                      in                 al , dx                   ;Read Line Status
                      AND                al , 00100000b
                      jz                 recieve                   ;Not empty
                      mov                dx, 3F8H                  ;Transmit data register
                      mov                al, INPUT                 ;put the data into al
                      out                dx, al                    ;sending the data
                      CMP                al, 27                    ;if the key was esc terminate the programe and this check must be after the send is done
                      JNE                dontexit2
                      JMP                exit
    dontexit2:        
		
                      saveCursorSender                             ;store current cursor in the variables
                      jmp                main_loop                 ;loop again
		
		
    recieve:          
                      MOV                AH, 1                     ;check if key is pressed
                      INT                16h
                      jz                 notsend
                      JMP                send                      ;if no key pressed, go send mode
    notsend:          
		
    ; no key is pressed, so recieve the data
                      MOV                DX, 3FDh                  ;line status register
                      in                 AL, DX                    ;take from the line register into AL
                      AND                al, 1                     ;check if its not empty
                      JZ                 recieve                   ;if it's empty, go recieve mode again (loop)
		
    ; status register is not empty, theres data in the recieve com port
                      MOV                DX, 03F8h
                      in                 al, dx                    ;take data from the port
                      MOV                INPUT, al
                      CMP                INPUT, 27                 ;check if its esc
                      JNE                dontexit
                      JMP                exit                      ;if esc, exit
    dontexit:         
		
                      CMP                INPUT, 0DH                ;check if enter
                      JNE                continue_recieve
		
                      CMP                y_reciever, 24            ;check if y is at the end
                      JNE                printR                    ;if not, continue print at current
		
    ; if y is at the end
                      clearLowerScreen                             ;clear reciever screen part
                      mov                x_reciever, 0             ;reset x pos
    ;MOV y_reciever, 0Dh	;reset y pos
                      setCursor          x_reciever, y_reciever    ;reset cursor position
                      JMP                print_reciever
	
    ; if key is enter and y is not at the edge
    printR:           
                      INC                y_reciever
                      MOV                x_reciever, 0
	
    continue_recieve: 
                      setCursor          x_reciever, y_reciever
                      CMP                x_reciever, 79            ;check if x as at the edge
                      JNE                print_reciever            ;if no, just print
	
    ; x is at the edge, lets also check y
                      CMP                y_reciever, 24
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;edit? if not, go new line?
                      JNE                print_reciever            ;if not, just print
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;edit?
    ; if y is also at edge, clear reciever screen
                      clearLowerScreen
                      MOV                x_reciever, 0
    ;MOV y_reciever, 0Dh
                      setCursor          x_reciever, y_reciever
	
    print_reciever:   
                      MOV                AH, 2
                      MOV                DL, INPUT
                      INT                21h
		
                      saveCursorReciever
                      JMP                main_loop
    
    exit:             
                      MOV                AH, 4ch
                      INT                21h

chat endp
end chat