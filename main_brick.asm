EXTRN Brick:FAR
public brick_width
public brick_height

.model small
.stack 64
.data
    bricks_initial_x dw 4d, 43d, 82d, 121d, 160d, 199d, 238d, 277d		;initial x-values (columns) for bricks (total=8)
    bricks_initial_y dw 6d, 18d, 30d, 42d, 54d							;initial y-values (rows) for bricks (total=5)
    brick_width dw 32d					;bricks width
    brick_height dw 7d					;bricks height
.code
main PROC
    MOV AX, @data
    MOV DS, AX

    MOV CX, bricks_initial_x[0]     ;move the initial x value in CX
    MOV DX, bricks_initial_y[0]     ;move the initial y value in DX
    call brick                      ;draws only 1 brick, expects the initial x and y to be in CX and DX respectively

    MOV AX, 4c00h
    INT 21h
main ENDP
end main