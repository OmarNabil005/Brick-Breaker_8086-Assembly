public Bar

clearScreen macro
    mov bh, 7h
    mov cx, 0h
    mov dh, 24d
    mov dl, 79d
    mov ax, 600h
    int 10h
endm

public Bar
public moveLeft
public moveRight
public speed
public resetBar

.MODEL SMALL
.STACK 100h

public barLeft
public barRight
public barTop
public barBottom

.DATA
    barX dw 129d
    barY dw 170d
    barLeft dw 130d
    barRight dw 189d
    barTop dw 170d
    barBottom dw 180d
    speed db 04h
    speedCounter db 02h
.CODE
Bar PROC FAR
    
    mov ah, 0Bh             ; set background color to black
    mov bx, 0h
    int 10h

    drawHorizontal:         ; outer loop (draws horizontal lines)
        mov cx, barTop
        mov barY, cx        ; start at Y = 450
        inc barX            ; start at X = 270
        cmp barX, 189d      ; end at X = 370 -> width = 100
        jna cont            ; handle jump out of range
        jmp done
        cont:

    drawVertical:           ; inner loop (draws vertical lines)
        mov ah, 0Ch         ; draw pixel interrupt
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, barX        ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d      
        je drawHorizontal   ; jump to outer loop if inner loop ended 

    jmp drawVertical        ; repeat inner loop

    done:
    ret

Bar ENDP

proc moveLeft FAR
    cmp barLeft, 0          ; dont go left if already hitting the edge
    jne eraseRightCol       ; handle jump out of range
    jmp exit

    eraseRightCol:
        mov ah, 0Ch         ; draw black pixels over right column to erase it
        mov al, 0h          ; black
        mov bh, 0h          ; page num
        mov cx, barRight    ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne eraseRightCol
    
    dec barRight            ; move left
    mov cx, barTop
    mov barY, cx            ; reset barY to match top

    drawLeftCol:
        mov ah, 0Ch         ; draw new gray pixels at left column
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, barLeft     ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne drawLeftCol
    
    dec barLeft             ; move left
    mov cx, barTop
    mov barY, cx            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveLeft
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exit:
    ret
endp moveLeft

proc moveRight FAR
    cmp barRight, 320d      ; dont go right if already hitting the edge
    jne drawRightCol
    jmp exitRight

    drawRightCol:           
        mov ah, 0Ch         ; draw new gray pixels at right column
        mov al, 07h         ; light Gray
        mov bh, 0h          ; page num
        mov cx, barRight    ; x
        mov dx, barY        ; y
        int 10h

        inc barY            
        cmp barY, 180d
        jne drawRightCol
    
    inc barRight            ; move right
    mov cx, barTop
    mov barY, cx            ; reset barY to match top

    eraseLeftCol:
        mov ah, 0Ch
        mov al, 0h          ; black
        mov bh, 0h          ; page num
        mov cx, barLeft     ; x
        mov dx, barY        ; y
        int 10h

        inc barY
        cmp barY, 180d
        jne eraseLeftCol
    
    inc barLeft             ; move right
    mov cx, barTop
    mov barY, cx            ; reset barY to match top
    dec speedCounter        ; for (speedCounter = speed; speedCounter > 0; --speedCounter) move left
    jnz moveRight
    mov bl, speed
    mov speedCounter, bl    ; speedCounter = speed
    exitRight:
    ret
endp moveRight

resetBar PROC FAR
    mov barLeft, 130d
    mov barRight, 189d
    mov barTop, 170d
    mov barBottom, 180d
    ret
resetBar ENDP

END Bar