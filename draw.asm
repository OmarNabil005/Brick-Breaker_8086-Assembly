public Drawing
public Drawingloss
public DrawingBricks

.Model Small
.Stack 64
.Data

imagesWidth EQU 320
imagesHeight EQU 110


imagesFilename DB 'win.bin', 0
loseFilename DB 'lose.bin', 0
bricksFilename DB 'bricks.bin', 0

loseFilehandle DW ?
imagesFilehandle DW ?
bricksFilehandle DW ?

imagesData DB imagesWidth*imagesHeight dup(0)

.Code
Drawing PROC FAR
    MOV AX , @DATA
    MOV DS , AX
    
    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
    CALL OpenFile
    CALL ReadData
	
    LEA BX , imagesData ; BL contains index at the current drawn pixel
	
    MOV CX,0
    MOV DX,0
    MOV AH,0ch
	
; Drawing loop
drawLoop:
    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,imagesWidth
JNE drawLoop 
	
    MOV CX , 0
    INC DX
    CMP DX , imagesHeight
JNE drawLoop
	    
    call CloseFile
    
Drawing ENDP




OpenFile PROC 

    ; Open file

    MOV AH, 3Dh
    MOV AL, 0 ; read only
    LEA DX, imagesFilename
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
     
    MOV [imagesFilehandle], AX
    
    RET

OpenFile ENDP

ReadData PROC

    MOV AH,3Fh
    MOV BX, [imagesFilehandle]
    MOV CX,imagesWidth*imagesHeight ; number of bytes to read
    LEA DX, imagesData
    INT 21h
    RET
ReadData ENDP 


CloseFile PROC
	MOV AH, 3Eh
	MOV BX, [imagesFilehandle]

	INT 21h
	RET
CloseFile ENDP




Drawingloss PROC FAR
    
    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
    CALL OpenFileLose
    CALL ReadDataLose
	
    LEA BX , imagesData ; BL contains index at the current drawn pixel
	
    MOV CX,0
    MOV DX,0
    MOV AH,0ch
	
; Drawingloss loop
drawLoop2:
    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,imagesWidth
JNE drawLoop2
    MOV CX , 0
    INC DX
    CMP DX , imagesHeight
JNE drawLoop2
	    
    call CloseFileLose
    
Drawingloss ENDP


OpenFileLose PROC 

    ; Open file

    MOV AH, 3Dh
    MOV AL, 0 ; read only
    LEA DX, loseFilename
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
     
    MOV [loseFilehandle], AX
    
    RET

OpenFileLose ENDP

ReadDataLose PROC

    MOV AH,3Fh
    MOV BX, [loseFilehandle]
    MOV CX,imagesWidth*imagesHeight ; number of bytes to read
    LEA DX, imagesData
    INT 21h
    RET
ReadDataLose ENDP 


CloseFileLose PROC
	MOV AH, 3Eh
	MOV BX, [loseFilehandle]

	INT 21h
	RET
CloseFileLose ENDP


DrawingBricks PROC FAR
    
    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
    CALL OpenFileBricks
    CALL ReadDataBricks
	
    LEA BX , imagesData ; BL contains index at the current drawn pixel
	
    MOV CX,0
    MOV DX,0
    MOV AH,0ch
	
; DrawingBricks loop
drawLoop3:
    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,imagesWidth
JNE drawLoop3
    MOV CX , 0
    INC DX
    CMP DX , imagesHeight
JNE drawLoop3
	    
    call CloseFileBricks
    
DrawingBricks ENDP


OpenFileBricks PROC 

    ; Open file

    MOV AH, 3Dh
    MOV AL, 0 ; read only
    LEA DX, bricksFilename
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
     
    MOV [bricksFilehandle], AX
    
    RET

OpenFileBricks ENDP

ReadDataBricks PROC

    MOV AH,3Fh
    MOV BX, [bricksFilehandle]
    MOV CX,imagesWidth*imagesHeight ; number of bytes to read
    LEA DX, imagesData
    INT 21h
    RET
ReadDataBricks ENDP 


CloseFileBricks PROC
	MOV AH, 3Eh
	MOV BX, [bricksFilehandle]

	INT 21h
	RET
CloseFileBricks ENDP


END Drawing
