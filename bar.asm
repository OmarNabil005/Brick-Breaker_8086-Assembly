
clearScreen macro
    mov bh, 7h
    mov cx, 0h
    mov dh, 24d
    mov dl, 79d
    mov ax, 600h
    int 10h
endm

public Bar
public movePlayerOneLeft
public movePlayerOneRight
public movePlayerTwoLeft
public movePlayerTwoRight
public speed
public resetBar

.MODEL SMALL
.STACK 100h

public playerOneBarLeft
public playerOneBarRight
public playerTwoBarLeft
public playerTwoBarRight
public barTop
public barBottom

.DATA
    barX1 dw 60d
    barX2 dw 210d
    barY dw 170d
    playerOneBarLeft dw 60d
    playerOneBarRight dw 109d
    playerTwoBarLeft dw 210d
    playerTwoBarRight dw 259d
    barTop dw 170d
    barBottom dw 180d
    speed db 04h
    speedCounter db 02h
.CODE
Bar PROC FAR

    drawHorizontal1:         ; outer loop (draws horizontal lines)
        mov cx, barTop
        mov barY, cx        ; start at Y = 450
        inc barX1            ; start at X = 270
        cmp barX1, 109d      ; end at X = 370 -> width = 100
        jna cont1            ; handle jump out of range
        jmp drawsecond
        cont1:

    drawVertical1:           ; inner loop (draws vertical lines)
        mov ah, 0Ch         ; draw pixel interrupt
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, barX1        ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d      
        je drawHorizontal1   ; jump to outer loop if inner loop ended 

    jmp drawVertical1        ; repeat inner loop
        drawsecond:
     drawHorizontal2:         ; outer loop (draws horizontal lines)
        mov cx, barTop
        mov barY, cx        ; start at Y = 450
        inc barX2            ; start at X = 270
        cmp barX2, 259d      ; end at X = 370 -> width = 100
        jna cont2            ; handle jump out of range
        jmp done
        cont2:

    drawVertical2:           ; inner loop (draws vertical lines)
        mov ah, 0Ch         ; draw pixel interrupt
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, barX2        ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d      
        je drawHorizontal2   ; jump to outer loop if inner loop ended 

    jmp drawVertical2        ; repeat inner loop

    done:
    ret

Bar ENDP

movePlayerOneLeft proc FAR
moveLeftlabel:
    cmp playerOneBarLeft, 0          ; dont go left if already hitting the edge
    jne eraseRightCol       ; handle jump out of range
    jmp exit

    eraseRightCol:
        mov ah, 0Ch         ; draw black pixels over right column to erase it
        mov al, 0h          ; black
        mov bh, 0h          ; page num
        mov cx, playerOneBarRight    ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne eraseRightCol
    
    dec playerOneBarRight            ; move left
    mov cx, barTop
    mov barY, cx            ; reset barY to match top

    drawLeftCol:
        mov ah, 0Ch         ; draw new gray pixels at left column
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, playerOneBarLeft     ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne drawLeftCol
    
    dec playerOneBarLeft             ; move left
    mov cx, barTop
    mov barY, cx            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveLeftlabel
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exit:
    ret
movePlayerOneLeft endp

movePlayerOneRight proc FAR

moveRightlabel:
    mov cx, playerTwoBarLeft
    cmp playerOneBarRight, cx      ; dont go right if already hitting the edge
    jne drawRightCol
    jmp exitRight

    drawRightCol:           
        mov ah, 0Ch         ; draw new gray pixels at right column
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, playerOneBarRight    ; x
        mov dx, barY        ; y
        int 10h

        inc barY            
        cmp barY, 180d
        jne drawRightCol
    
    inc playerOneBarRight            ; move right
    mov cx, barTop
    mov barY, cx            ; reset barY to match top

    eraseLeftCol:
        mov ah, 0Ch
        mov al, 0h          ; black
        mov bh, 0h          ; page num
        mov cx, playerOneBarLeft     ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne eraseLeftCol
    
    inc playerOneBarLeft             ; move right
    mov cx, barTop
    mov barY, cx            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveRightlabel
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exitRight:
    ret
movePlayerOneRight endp

movePlayerTwoLeft proc FAR
moveLeftlabel1:
    mov cx, playerOneBarRight
    cmp playerTwoBarLeft, cx        ; dont go left if already hitting the edge
    jne eraseRightCol1       ; handle jump out of range
    jmp exit2

    eraseRightCol1:
        mov ah, 0Ch         ; draw black pixels over right column to erase it
        mov al, 0h          ; black
        mov bh, 0h          ; page num
        mov cx, playerTwoBarRight    ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne eraseRightCol1
    
    dec playerTwoBarRight            ; move left
    mov cx, barTop
    mov barY, cx            ; reset barY to match top

    drawLeftCol1:
        mov ah, 0Ch         ; draw new gray pixels at left column
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, playerTwoBarLeft     ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne drawLeftCol1
    
    dec playerTwoBarLeft             ; move left
    mov cx, barTop
    mov barY, cx            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveLeftlabel1
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exit2:
    ret
movePlayerTwoLeft endp

movePlayerTwoRight proc FAR

moveRightlabel2:
    cmp playerTwoBarRight, 320d      ; dont go right if already hitting the edge
    jne drawRightCol2
    jmp exitRight2

    drawRightCol2:           
        mov ah, 0Ch         ; draw new gray pixels at right column
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, playerTwoBarRight    ; x
        mov dx, barY        ; y
        int 10h

        inc barY            
        cmp barY, 180d
        jne drawRightCol2
    
    inc playerTwoBarRight            ; move right
    mov cx, barTop
    mov barY, cx            ; reset barY to match top

    eraseLeftCol2:
        mov ah, 0Ch
        mov al, 0h          ; black
        mov bh, 0h          ; page num
        mov cx, playerTwoBarLeft     ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne eraseLeftCol2
    
    inc playerTwoBarLeft             ; move right
    mov cx, barTop
    mov barY, cx            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveRightlabel2
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exitRight2:
    ret
movePlayerTwoRight endp

resetBar PROC FAR
    mov playerOneBarLeft, 60d
    mov playerOneBarRight, 109d
    mov playerTwoBarLeft, 210d
    mov playerTwoBarRight, 259d
    mov barX1, 60d
    mov barX2, 210d
    mov barY, 170d
    ret
resetBar ENDP

END Bar