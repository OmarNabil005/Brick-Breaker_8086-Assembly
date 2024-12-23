extrn menu:far
extrn LEVEL:word
extrn resetActiveBricks:far
public loss

.MODEL SMALL
.STACK 100h
.DATA
    GameOverText DB 'Game Over$', 0
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

                   mov    ax, 0600h           ; Scroll up window
                   mov    bh, 07h             ; Fill entire window with this attribute
                   mov    cx, 0               ; Upper left corner (row 0, col 0)
                   mov    dx, 184fh           ; Lower right corner (row 24, col 79)
                   int    10h                 ; BIOS interrupt

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

    ; Set up data segment
                   mov    ax, @data
                   mov    ds, ax

    ; Clear the screen
                   call   Clear_Screen
                   call   resetActiveBricks

    ; Display 'Game Over' in the middle of the screen
                   mov    dh, 12              ; Middle row (approx.)
                   mov    dl, 15              ; Center column (approx.)
                   call   Set_Cursor
                   lea    dx, GameOverText
                   call   Display_String

    ; Display Exit option
                   mov    dh, 14              ; Below 'Game Over'
                   mov    dl, 15              ; Center column (approx.)
                   call   Set_Cursor
                   lea    dx, ExitOption
                   call   Display_String

    ; Display Menu option
                   mov    dh, 15              ; Below Exit option
                   mov    dl, 15              ; Center column (approx.)
                   call   Set_Cursor
                   lea    dx, MenuOption
                   call   Display_String

    ; Wait for valid user input
    WaitForInput:  

                   mov  ah, 01h                  ; Check if key is in keyboard buffer
                   int  16h
                   jz   WaitForInput

                   mov    ah, 0h             ; BIOS function to read key
                   int    16h                 ; Get key press

                   cmp    al, '1'             ; Check if '1' was pressed
                   je     ExitProgram         ; Jump to exit if '1'

                   cmp    al, '2'             ; Check if '2' was pressed
                   je     BackToMenu          ; Jump to menu if '2'

    ; If invalid input, wait for another key press
                   jmp    WaitForInput

    ExitProgram:   
    ; Exit the program (INT 20h - Terminate Program)
                   mov    ah, 4Ch
                   int    21h

    BackToMenu:    
                   call   menu
                   ret                        ; Return to caller

loss ENDP

END loss
