                   extrn       Move_Ball:FAR
                   extrn       Draw_Ball:FAR
                   extrn       Draw_B_Ball:FAR
                   extrn       drawBricks:FAR
                   EXTRN SCORE:word
                   EXTRN LIVES:word
                   EXTRN LEVEL:word
                   EXTRN BRICKS_LEFT:word 
                   
                   public      display_stats


.MODEL SMALL
.STACK 100h

.DATA
    score_msg db "Score: $", 0
    lives_msg db " Lives: $", 0
    level_msg db " Level: $", 0
    buffer    db 6 dup (0)
   

.CODE
                   
display_stats PROC NEAR
    ; Set data segment
                   MOV  AX, @DATA
                   MOV  DS, AX

    ; ; Clear the bottom portion of the screen for stats display (approx. 5% of 200 = 10 pixels)
    ;                MOV  AX, 0A000h        ; Base address of video memory
    ;                MOV  ES, AX
    ;                MOV  DI, 320 * 190     ; Calculate offset for row 190

    ;                MOV  CX, 320 * 10      ; Clear 10 rows (total area for stats)
    ;                XOR  AX, AX            ; Clear the pixels (black color)
    ; clear_bottom:
    ;                MOV  [ES:DI], AX       ; Clear pixel at DI
    ;                ADD  DI, 2             ; Move to next pixel (16-bit)
    ;                LOOP clear_bottom      ; Repeat for all pixels

    ; Display Score
                   lea  dx, score_msg
                   call displayMessage
                   mov  ax, SCORE
                   call print_number

    ; Display Lives
                   lea  dx, lives_msg
                   call displayMessage
                   mov  ax, LIVES
                   call print_number

    ; Display Level
                   lea  dx, level_msg
                   call displayMessage
                   mov  ax, LEVEL
                   call print_number

                   RET
display_stats ENDP

displayMessage PROC
                   push si                ; Save si register

                   mov  si, dx            ; Load string address into si
                   mov  ah, 0Eh           ; BIOS teletype function to display characters

    display_loop:  
                   mov  al, [si]          ; Load character from string
                   cmp  al, '$'           ; Check for string termination
                   je   end_message
                   int  10h               ; Print character
                   inc  si                ; Move to next character in the string
                   jmp  display_loop

    end_message:   
                   pop  si                ; Restore si register
                   ret
displayMessage ENDP

print_number PROC NEAR
                   push ax
                   push bx
                   push dx
                   xor  bx, bx
                   mov  bx, 10            ; Base 10

    convert_digit: 
                   xor  dx, dx
                   div  bx                ; Divide AX by 10
                   add  dl, '0'           ; Convert remainder to ASCII
                   push dx
                   test ax, ax
                   jnz  convert_digit

    print_digits:  
                   pop  dx
                   mov  ah, 0Eh
                   mov  al, dl
                   int  10h
                   cmp  sp, 0
                   jne  print_digits

                   pop  dx
                   pop  bx
                   pop  ax
                   ret
print_number ENDP


END display_stats