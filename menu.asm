clear_screen MACRO
                 mov ah, 06h
                 mov al, 0
                 mov bh, 07h
                 mov cx, 0
                 mov dl, 80
                 mov dh, 25
                 int 10h
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
                   mov            ax, @data
                   mov            ds, ax
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

    ; Wait for user input
    wait_for_input:
                   mov            ah, 00h
                   int            16h
                   cmp            al, '1'
                   je             start_game
                   cmp            al, '2'
                   je             exit
                   cmp            al, '3'
                   je             chat_function
                   jmp            wait_for_input

    start_game:    
    ; Load and execute the start program
                   call           GAME
                   jmp            exit
  

    chat_function: 
    ; Load and execute the chat program
                   call           chat
                   int            21h
                   jmp            exit

    exit:          
    ; Terminate program
                   mov            ah, 4Ch
                   int            21h

menu endp
end menu