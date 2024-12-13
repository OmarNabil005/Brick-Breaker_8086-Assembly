.MODEL small
.STACK 100h
.data
char db ?       ; Character from keyboard
value db ?      ; Character from UART
errorMsg db 'Overrun error detected!$'

.code

checkKey proc
    mov ax, @data
    mov ds, ax
    mov ah, 01h         ; Check if key is pressed
    int 16h
    jz checkUART        ; If no key is pressed, check UART again

    mov ah, 0h          ; Read the key
    int 16h
    mov char, al

    ; Check if the character is Enter
    cmp char, 0Dh
    je handleEnterKey

    ; Check if the character is ESC
    cmp char, 1Bh
    je sendEsc

    mov ah, 2           ; Print the character
    mov dl, char
    int 21h

    ; Check that Transmitter Holding Register is Empty
    mov dx, 3FDH        ; Line Status Register
WaitLoop:
    in al, dx           ; Read Line Status
    and al, 00100000b
    jz WaitLoop

    ; Send the character to UART
    mov dx, 3F8H        ; Transmit Data Register
    mov al, char
    out dx, al

    jmp checkUART

handleEnterKey:
    ; Send newline to screen
    mov ah, 2
    mov dl, 0Dh         ; Carriage return
    int 21h
    mov dl, 0Ah         ; Line feed
    int 21h

    ; Send newline to UART
    mov dx, 3FDH        ; Line Status Register
WaitForEmptyCR:
    in al, dx
    and al, 00100000b
    jz WaitForEmptyCR

    mov dx, 3F8H        ; Transmit Data Register
    mov al, 0Dh
    out dx, al

WaitForEmptyLF:
    in al, dx
    and al, 00100000b
    jz WaitForEmptyLF

    mov al, 0Ah
    out dx, al

    jmp checkUART

checkUART:
    ; Check if UART has data ready
    mov dx, 3FDH        ; Line Status Register
    in al, dx

    ; Check for overrun error
    and al, 00000010b
    jz UARTNoError      ; No error, proceed
    call handleError    ; Handle overrun error

UARTNoError:
    mov dx, 3FDH        ; Line Status Register
    in al, dx
    and al, 1
    jz checkKey         ; If no data, check keyboard again

    ; Read received character
    mov dx, 03F8H
    in al, dx
    mov value, al

    ; Check if received character is ESC
    cmp value, 1Bh
    je exit

    ; Print received character
    cmp value, 0Dh      ; Check if received Enter
    je handleEnterUART

    mov ah, 2
    mov dl, value
    int 21h

    jmp checkKey

handleEnterUART:
    ; Print newline for received Enter
    mov ah, 2
    mov dl, 0Dh         ; Carriage return
    int 21h
    mov dl, 0Ah         ; Line feed
    int 21h
    jmp checkKey

sendEsc:
    ; Send ESC character to UART before exiting
    mov dx, 3FDH        ; Line Status Register
WaitForEmptyEsc:
    in al, dx
    and al, 00100000b
    jz WaitForEmptyEsc

    mov dx, 3F8H        ; Transmit Data Register
    mov al, 1Bh
    out dx, al

    jmp exit

handleError:
    ; Display error message
    lea dx, errorMsg
    mov ah, 09h
    int 21h

    ; Clear the overrun error by reading from the UART
    mov dx, 03F8H
    in al, dx
    ret

checkKey endp

Main proc
    mov ax, @data
    mov ds, ax

    ; Initialize COM port
    mov dx, 3FBH        ; Line Control Register
    mov al, 10000000b   ; Enable Divisor Latch Access
    out dx, al

    ; Set Baud Rate Divisor (LSB and MSB)
    mov dx, 3F8H
    mov al, 0Ch         ; LSB (Baud Rate Divisor)
    out dx, al

    mov dx, 3F9H
    mov al, 00h         ; MSB (Baud Rate Divisor)
    out dx, al

    ; Set port configuration
    mov dx, 3FBH
    mov al, 00011011b   ; 8 bits, no parity, 1 stop bit
    out dx, al

sendloop:
    call checkKey

exit:
    mov ah, 4Ch
    int 21h

Main endp
end
