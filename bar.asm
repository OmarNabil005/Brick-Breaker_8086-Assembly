drawPixel macro color, X, Y
    mov ah, 0Ch         ; draw pixel interrupt
    mov al, color
    mov bh, 0h          ; page num
    mov cx, X           ; x
    mov dx, Y           ; y
    int 10h
endm

public Bar
public movePlayerOneLeft
public movePlayerOneRight
public movePlayerTwoLeft
public movePlayerTwoRight
public playerOneBarLeft
public playerOneBarRight
public playerTwoBarLeft
public playerTwoBarRight
public barTop
public speed
public resetBar

.MODEL SMALL
.STACK 100h

.DATA
    barTop dw 170d
    playerOneBarLeft dw 60d
    playerOneBarRight dw 109d
    playerTwoBarLeft dw 210d
    playerTwoBarRight dw 259d

    ; initial values for the bars
    playerOneBarLeftInitial equ 60d
    playerOneBarRightInitial equ 109d
    playerTwoBarLeftInitial equ 210d
    playerTwoBarRightInitial equ 259d
    barTopInitial equ 170d
    barBottom equ 180d


    ; threshold values for the bars
    playerOneBarLeftThreshold equ 0d
    playerOneBarRightThreshold equ 160d
    playerTwoBarLeftThreshold equ 160d
    playerTwoBarRightThreshold equ 320d

    barX1 dw 60d
    barX2 dw 210d
    barY dw 170d

    speed db 04h
    speedCounter db 04h

    ; colors
    grey equ 07h
    black equ 0h
.CODE
Bar PROC FAR

    drawHorizontal1:                        ; outer loop (draws horizontal lines)
        mov barY, barTopInitial             ; start at Y = 450
        inc barX1                           ; start at X = 270
        cmp barX1, playerOneBarRightInitial      ; end at X = 370 -> width = 100
        jna cont1                           ; handle jump out of range
        jmp drawsecond
        cont1:

    drawVertical1:                          ; inner loop (draws vertical lines)
        drawPixel grey, barX1, barY

        inc barY
        cmp barY, barBottom      
        je drawHorizontal1                  ; jump to outer loop if inner loop ended 

    jmp drawVertical1                       ; repeat inner loop

        drawsecond:
     drawHorizontal2:                       ; outer loop (draws horizontal lines)
        mov barY, barTopInitial 
        inc barX2                          
        cmp barX2, playerTwoBarRightInitial      
        jna cont2                           ; handle jump out of range
        jmp done
        cont2:

    drawVertical2:                          ; inner loop (draws vertical lines)
        drawPixel grey, barX2, barY

        inc barY
        cmp barY, barBottom      
        je drawHorizontal2   ; jump to outer loop if inner loop ended 

    jmp drawVertical2        ; repeat inner loop

    done:
    ret

Bar ENDP

movePlayerOneLeft proc FAR
moveLeftlabel:
    cmp playerOneBarLeft, playerOneBarLeftThreshold          ; dont go left if already hitting the edge
    jne eraseRightCol 
    jmp exit

    eraseRightCol:
        drawPixel black, playerOneBarRight, barY

        inc barY
        cmp barY, barBottom
        jne eraseRightCol
    
    dec playerOneBarRight            ; move left
    mov cx, barTop
    mov barY, cx            ; reset barY to match top

    drawLeftCol:
        drawPixel grey, playerOneBarLeft, barY

        inc barY
        cmp barY, barBottom
        jne drawLeftCol
    
    dec playerOneBarLeft             ; move left
    mov barY, barTopInitial            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveLeftlabel
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exit:
    ret
movePlayerOneLeft endp

movePlayerOneRight proc FAR

moveRightlabel:
    cmp playerOneBarRight, playerOneBarRightThreshold      ; dont go right if already hitting the edge
    jne drawRightCol
    jmp exitRight

    drawRightCol:
        drawPixel grey, playerOneBarRight, barY 

        inc barY            
        cmp barY, barBottom
        jne drawRightCol
    
    inc playerOneBarRight            ; move right
    mov barY, barTopInitial            ; reset barY to match top

    eraseLeftCol:
        drawPixel black, playerOneBarLeft, barY

        inc barY
        cmp barY, barBottom
        jne eraseLeftCol
    
    inc playerOneBarLeft             ; move right
    mov barY, barTopInitial            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveRightlabel
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exitRight:
    ret
movePlayerOneRight endp

movePlayerTwoLeft proc FAR
moveLeftlabel1:
    cmp playerTwoBarLeft, playerTwoBarLeftThreshold        ; dont go left if already hitting the edge
    jne eraseRightCol1       ; handle jump out of range
    jmp exit2

    eraseRightCol1:
        drawPixel black, playerTwoBarRight, barY

        inc barY
        cmp barY, barBottom
        jne eraseRightCol1
    
    dec playerTwoBarRight            ; move left
    mov barY, barTopInitial            ; reset barY to match top

    drawLeftCol1:
        drawPixel grey, playerTwoBarLeft, barY
        inc barY
        cmp barY, barBottom
        jne drawLeftCol1
    
    dec playerTwoBarLeft             ; move left
    mov barY, barTopInitial            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveLeftlabel1
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exit2:
    ret
movePlayerTwoLeft endp

movePlayerTwoRight proc FAR

moveRightlabel2:
    cmp playerTwoBarRight, playerTwoBarRightThreshold      ; dont go right if already hitting the edge
    jne drawRightCol2
    jmp exitRight2

    drawRightCol2:
        drawPixel grey, playerTwoBarRight, barY       
        inc barY            
        cmp barY, barBottom
        jne drawRightCol2
    
    inc playerTwoBarRight            ; move right
    mov barY, barTopInitial            ; reset barY to match top

    eraseLeftCol2:
        drawPixel black, playerTwoBarLeft, barY
        inc barY
        cmp barY, barBottom
        jne eraseLeftCol2
    
    inc playerTwoBarLeft             ; move right
    mov barY, barTopInitial            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveRightlabel2
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exitRight2:
    ret
movePlayerTwoRight endp

resetBar PROC FAR
    mov playerOneBarLeft, playerOneBarLeftInitial
    mov playerOneBarRight, playerOneBarRightInitial
    mov playerTwoBarLeft, playerTwoBarLeftInitial
    mov playerTwoBarRight, playerTwoBarRightInitial
    mov barX1, playerOneBarLeftInitial
    mov barX2, playerTwoBarLeftInitial
    mov barY, barTopInitial
    ret
resetBar ENDP

END Bar