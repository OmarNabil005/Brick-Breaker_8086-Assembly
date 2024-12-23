extrn SCORE: word
extrn LEVEL: word
extrn LIVES: word

public Display_Stats

.MODEL SMALL
.STACK 100h
.DATA
    ScoreText   DB 'Score: $'
    LivesText   DB 'Lives: $'
    LevelText   DB 'Level: $'
    
    ScoreBuffer DB 6 DUP('$')    ; Buffer for score (max 5 digits + '$')
    LivesBuffer DB 6 DUP('$')    ; Buffer for lives
    LevelBuffer DB 6 DUP('$')    ; Buffer for level
.CODE
.STARTUP

    ; Procedure to convert a 16-bit number to decimal string
Convert_Number PROC NEAR
    ; Input: AX = number to convert
    ; Output: Converts number to decimal string at DS:DI
                       push bx
                       push cx
                       push dx

                       mov  bx, 10                    ; Divisor
                       mov  cx, 0                     ; Counter for digits

convert_loop:      
                       xor  dx, dx                    ; Clear high word for division
                       div  bx                        ; Divide AX by 10
                       add  dl, '0'                   ; Convert remainder to ASCII
                       push dx                        ; Store digit on stack
                       inc  cx                        ; Increment digit count
                       test ax, ax                    ; Check if quotient is zero
                       jnz  convert_loop              ; Continue if not zero

store_loop:        
                       pop  dx                        ; Retrieve digit
                       mov  [di], dl                  ; Store in buffer
                       inc  di                        ; Move to next buffer position
                       loop store_loop

                       mov  byte ptr [di], '$'        ; Terminate string with '$'
    
                       pop  dx
                       pop  cx
                       pop  bx
                       ret
Convert_Number ENDP

    ; Procedure to set the cursor position
Set_Cursor PROC NEAR
    ; Input:
    ; DH = row
    ; DL = column
                       push ax
                       push bx

                       mov  ah, 02h
                       mov  bh, 0                     ; Page number
                       int  10h

                       pop  bx
                       pop  ax
                       ret
Set_Cursor ENDP

    ; Procedure to display a string at a specific screen position
Display_String PROC NEAR
    ; Input:
    ; DS:DX = string address
                       push ax
                       push bx

    ; Display string
                       mov  ah, 09h
                       int  21h

                       pop  bx
                       pop  ax
                       ret
Display_String ENDP

    ; Procedure to display game statistics
Display_Stats PROC FAR
                       push ax
                       push bx
                       push cx
                       push dx
                       push di
                       push es

    ; Save current data segment
                       mov  ax, @data
                       mov  ds, ax
                       mov  es, ax

    ; Prepare buffers for converted numbers
                       lea  di, ScoreBuffer
                       mov  ax, SCORE
                       call Convert_Number

                       lea  di, LivesBuffer
                       mov  ax, LIVES
                       call Convert_Number

                       lea  di, LevelBuffer
                       mov  ax, LEVEL
                       call Convert_Number

    ; Display Score Label
                       mov  dh, 23                    ; Row 23 (bottom of screen)
                       mov  dl, 0                     ; Column 5
                       call Set_Cursor
                       lea  dx, ScoreText
                       call Display_String

    ; Display Score Value
                       mov  dh, 23
                       mov  dl, 6                    ; Column right after 'Score:'
                       call Set_Cursor
                       lea  dx, ScoreBuffer
                       call Display_String

    ; Display Lives Label
                       mov  dh, 23
                       mov  dl, 10                    ; Column for lives label
                       call Set_Cursor
                       lea  dx, LivesText
                       call Display_String

    ; Display Lives Value
                       mov  dh, 23
                       mov  dl, 19                    ; Column right after 'Lives:'
                       call Set_Cursor
                       lea  dx, LivesBuffer
                       call Display_String

    ; Display Level Label
                       mov  dh, 23
                       mov  dl, 22                    ; Column for level label
                       call Set_Cursor
                       lea  dx, LevelText
                       call Display_String

    ; Display Level Value
                       mov  dh, 23
                       mov  dl, 28                    ; Column right after 'Level:'
                       call Set_Cursor
                       lea  dx, LevelBuffer
                       call Display_String

                       pop  es
                       pop  di
                       pop  dx
                       pop  cx
                       pop  bx
                       pop  ax
                       ret
Display_Stats ENDP

END Display_Stats
