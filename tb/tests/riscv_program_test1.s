# Simple RISC-V program demonstrating different instruction types
.text
.global main

main:
    # Initialize registers with immediate values
    addi x2, x0, 10       # x2 = 10
    addi x3, x0, 20       # x3 = 20
    addi x5, x0, 50       # x5 = 50
    addi x6, x0, 30       # x6 = 30
    addi x8, x0, 15       # x8 = 15
    addi x9, x0, 25       # x9 = 25

    # R-type instructions
    add  x1, x2, x3       # x1 = x2 + x3 (10 + 20 = 30)
    sub  x4, x5, x6       # x4 = x5 - x6 (50 - 30 = 20)
    and  x7, x8, x9       # x7 = x8 & x9 (15 & 25)

    # Rest of the program remains the same
    addi x10, x11, 42     # x10 = x11 + 42
    lw   x12, 8(x13)      # Load word from memory
    sw   x14, 12(x15)     # Store x14 to memory
    beq  x16, x17, label1 # Branch if equal
    blt  x18, x19, label2 # Branch if less than
    jal  x1, function     # Jump and link

label1:
    nop

label2:
    nop

function:
    ret