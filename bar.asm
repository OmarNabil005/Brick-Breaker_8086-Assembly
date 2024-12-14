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

.MODEL SMALL
.STACK 100h

.DATA
    barX dw 269d
    barY dw 450d
    barLeft dw 270d
    barRight dw 370d
    barTop dw 450d
    barBottom dw 470d
    speed db 02h
    speedCounter db 02h
.CODE
Bar PROC FAR
    
    mov ax, @DATA
    mov ds, ax

    clearScreen

    mov ah, 0h              ; enter video mode
    mov al, 12h             ; 640 * 480 -> 16 colors 
    int 10h

    mov ah, 0Bh             ; set background color to black
    mov bx, 0h
    int 10h

    drawHorizontal:         ; outer loop (draws horizontal lines)
        mov cx, barTop
        mov barY, cx        ; start at Y = 450
        inc barX            ; start at X = 270
        cmp barX, 370d      ; end at X = 370 -> width = 100
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
        cmp barY, 470d      
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
        cmp barY, 470d
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
        cmp barY, 470d
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
    cmp barRight, 640d      ; dont go right if already hitting the edge
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
        cmp barY, 470d
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
        cmp barY, 470
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

END Bar