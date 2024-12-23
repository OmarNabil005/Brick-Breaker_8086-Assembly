public chat

.MODEL small
.STACK 100h

.DATA
    goodbyeMsg   DB 'Goodbye!', 0AH, 0DH, "$"

    ; Data Buffers
    localChar    DB ?                            ; Stores the local character typed
    receivedChar DB ?                            ; Stores the received character
    localRow     DB 0                            ; Cursor row for local input
    localCol     DB 0                            ; Cursor column for local input
    remoteRow    DB 13                           ; Cursor row for remote input (starts at row 13)
    remoteCol    DB 0                            ; Cursor column for remote input
    exitFlag     DB 0                            ; Flag to indicate program exit

.CODE
Initialize_UART PROC
                          mov  dx, 3FBh                 ; Line Control Register
                          mov  al, 10000000b            ; Set Divisor Latch Access Bit
                          out  dx, al

                          mov  dx, 3F8h                 ; Baud Rate Divisor LSB
                          mov  al, 0Ch                  ; 9600 baud
                          out  dx, al

                          mov  dx, 3F9h                 ; Baud Rate Divisor MSB
                          mov  al, 00h
                          out  dx, al

                          mov  dx, 3FBh                 ; Line Control Register
                          mov  al, 00011011b            ; 8 data bits, no parity, 1 stop bit
                          out  dx, al
                          ret
Initialize_UART ENDP

Set_Cursor PROC
                          mov  ah, 02h                  ; BIOS function to set cursor position
                          mov  bh, 0                    ; Video page number
                          int  10h
                          ret
Set_Cursor ENDP

Display_Char PROC
                          push ax
                          push bx
                          push cx
                          push dx

                          mov  ah, 09h                  ; BIOS function to write character/attribute
                          mov  al, receivedChar         ; Character to display
                          mov  bh, 0                    ; Video page number
                          mov  bl, 0Eh                  ; Attribute: red text on black background
                          mov  cx, 1                    ; Write the character once
                          int  10h                      ; Call BIOS interrupt

                          pop  dx
                          pop  cx
                          pop  bx
                          pop  ax
                          ret
Display_Char ENDP

Display_Char_coloured PROC
                          push ax
                          push bx
                          push cx
                          push dx

                          mov  ah, 09h                  ; BIOS function to write character/attribute
                          mov  al, localChar            ; Character to display
                          mov  bh, 0                    ; Video page number
                          mov  bl, 0Ah                  ; Attribute: red text on black background
                          mov  cx, 1                    ; Write the character once
                          int  10h                      ; Call BIOS interrupt

                          pop  dx
                          pop  cx
                          pop  bx
                          pop  ax
                          ret
Display_Char_coloured ENDP


Wait_UART_Tx PROC
                          mov  dx, 3FDh                 ; Line Status Register
    Wait_UART_Tx_Loop:    in   al, dx                   ; Check Transmitter Holding Register
                          and  al, 00100000b            ; Check if empty
                          jz   Wait_UART_Tx_Loop        ; Wait until ready
                          ret
Wait_UART_Tx ENDP

Send_Exit_Signal PROC
    ; Send ESC character via UART to signal exit to receiver
                          call Wait_UART_Tx             ; Ensure UART is ready

                          mov  dx, 3F8h                 ; Transmit Data Register
                          mov  al, 1Bh                  ; ESC character
                          out  dx, al                   ; Send character
                          ret
Send_Exit_Signal ENDP

Handle_Keyboard_Input PROC
                          mov  ah, 01h                  ; Check if key is in keyboard buffer
                          int  16h
                          jz   No_Key                   ; No key pressed, skip to UART check

                          mov  ah, 00h                  ; Read character
                          int  16h
                          mov  localChar, al            ; Store character
                          cmp  al, 1Bh                  ; Check if ESC (ASCII 27)
                          je   Call_Global_Exit         ; If ESC is pressed, jump to call Global_Exit_Sequence

    ; Display character on screen (local input section)
                          mov  dh, localRow             ; Row for local input
                          mov  dl, localCol             ; Column for local input
                          call Set_Cursor
                          mov  al, localChar            ; Character to display
                          call Display_Char_coloured

    ; Send character via UART
                          call Wait_UART_Tx             ; Ensure UART is ready

                          mov  dx, 3F8h                 ; Transmit Data Register
                          mov  al, localChar            ; Load character
                          out  dx, al                   ; Send character

    ; Update cursor position for local input
                          inc  localCol
                          cmp  localCol, 80             ; If column reaches the end of the row
                          jl   Check_Local_Scroll       ; If less than 80, continue
                          mov  localCol, 0              ; Reset column to 0 for next line
                          inc  localRow                 ; Move to next row

    ; Scroll local section if needed
    Check_Local_Scroll:   cmp  localRow, 12
                          jl   No_Key
                          call Scroll_Screen_Local
                          mov  localRow, 11             ; Reset to the last row of local section

    No_Key:               ret

    Call_Global_Exit:     
                          call Global_Exit_Sequence     ; Call the unified Global_Exit_Sequence procedure
                          ret
Handle_Keyboard_Input ENDP


Handle_UART_Input PROC
    ; Check if data is ready in UART
                          mov  dx, 3FDh                 ; Line Status Register
                          in   al, dx
                          and  al, 1                    ; Check if Data Ready bit is set
                          jz   No_Serial                ; Skip if no data is available

    ; Read received data
                          mov  dx, 3F8h                 ; Receive Data Register
                          in   al, dx
                          mov  receivedChar, al         ; Store received character

    ; Check for exit signal
                          cmp  receivedChar, 1Bh        ; Check for ESC character
                          je   Global_Exit_Sequence

    ; Display received character on screen (remote input section)
                          mov  dh, remoteRow            ; Row for remote input
                          mov  dl, remoteCol            ; Column for remote input
                          call Set_Cursor
                          mov  al, receivedChar         ; Character to display
                          call Display_Char

    ; Update cursor position for remote input
                          inc  remoteCol
                          cmp  remoteCol, 80            ; If column reaches the end of the row
                          jl   Check_Remote_Scroll      ; If less than 80, continue
                          mov  remoteCol, 0             ; Reset to 0 for next line
                          inc  remoteRow                ; Move to next row

    ; Scroll remote section if needed
    Check_Remote_Scroll:  cmp  remoteRow, 24            ; Check if beyond remote section
                          jl   No_Serial
                          call Scroll_Screen_Remote
                          mov  remoteRow, 23            ; Reset to the last row of remote section
    No_Serial:            ret
Handle_UART_Input ENDP

Scroll_Screen_Local PROC
                          push ax
                          push bx
                          push cx
                          push dx

                          mov  ah, 06h                  ; BIOS function to scroll up screen
                          mov  al, 1                    ; Scroll up by 1 line
                          mov  bh, 07h                  ; Attribute (white on black)
                          mov  cx, 0000h                ; Upper left corner (row 0, column 0)
                          mov  dx, 0C4Fh                ; Lower right corner (row 12, column 79)
                          int  10h                      ; Call BIOS interrupt to scroll the local input area

                          pop  dx
                          pop  cx
                          pop  bx
                          pop  ax
                          ret
Scroll_Screen_Local ENDP

Scroll_Screen_Remote PROC
                          push ax
                          push bx
                          push cx
                          push dx

                          mov  ah, 06h                  ; BIOS function to scroll up screen
                          mov  al, 1                    ; Scroll up by 1 line
                          mov  bh, 07h                  ; Attribute (white on black)
                          mov  cx, 0D00h                ; Upper left corner of the bottom region (row 13, column 0)
                          mov  dx, 174Fh                ; Lower right corner of the bottom region (row 25, column 79)
                          int  10h                      ; Call BIOS interrupt to scroll the bottom half of the screen

    
                          pop  dx
                          pop  cx
                          pop  bx
                          pop  ax
                          ret
Scroll_Screen_Remote ENDP

Clear_Screen PROC
                          mov  ah, 06h                  ; BIOS function to scroll up and clear screen
                          mov  al, 0                    ; Clear the screen
                          mov  bh, 07h                  ; Attribute (default)
                          mov  cx, 0                    ; Upper left corner (row 0, column 0)
                          mov  dx, 184Fh                ; Lower right corner (row 25, column 79)
                          int  10h                      ; Call BIOS interrupt to clear the screen
                          ret
Clear_Screen ENDP

Global_Exit_Sequence PROC
                          call Send_Exit_Signal         ; Send exit signal to receiver
                          mov  exitFlag, 1              ; Set exit flag
                          ret
Global_Exit_Sequence ENDP

Exit_Program PROC
                          mov  ah, 09h
                          mov  dx, offset goodbyeMsg
                          int  21h

                          mov  ah, 4Ch                  ; Terminate program
                          int  21h
Exit_Program ENDP

chat PROC FAR
                          mov  ax, @data
                          mov  ds, ax

                          call Clear_Screen
                          call Initialize_UART

    Main_Loop:            
                          call Handle_Keyboard_Input
                          call Handle_UART_Input

                          cmp  exitFlag, 1              ; Check if exit flag is set
                          je   Exit_Program

                          jmp  Main_Loop                ; Near jump to loop
chat ENDP

END chat
