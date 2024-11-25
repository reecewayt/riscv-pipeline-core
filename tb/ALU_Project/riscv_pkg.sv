//*****************************************************************************************
    // RV32I Base Instruction Formats:
    // R-type (Register): Used for register-to-register arithmetic/logical operations
    // Format: | funct7 | rs2 | rs1 | funct3 | rd | opcode |
    // Bits:   |    7   |  5  |  5  |    3   |  5 |    7   |
    
    // I-type (Immediate): Used for immediate arithmetic/logical operations and loads
    // Format: | immediate[11:0] | rs1 | funct3 | rd | opcode |
    // Bits:   |       12        |  5  |    3   |  5 |    7   |
    
    // S-type (Store): Used for store operations
    // Format: | imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode |
    // Bits:   |     7     |  5  |  5  |    3   |     5    |    7   |
    //
    // B-type (Branch): Used for branch operations
    // Format: | imm[12] | imm[10:5] | rs2 | rs1 | funct3 | imm[4:1] | imm[11] | opcode |
    // Bits:   |    1    |     6     |  5  |  5  |    3   |     4    |    1    |    7   |
    //
    // // J-type (Jump): Used for unconditional jumps (JAL)
    // Format: | imm[20] | imm[10:1] | imm[11] | imm[19:12] | rd | opcode |
    // Bits:   |    1    |     10    |    1    |     8      |  5 |    7   |
//*****************************************************************************************
package riscv_pkg;
    // Architecture Parameters
    parameter DATA_WIDTH = 32;
    parameter XLEN = 32; 
    parameter ADDR = 5;

    // Register Names
    typedef enum logic [4:0] {
        REG_ZERO = 5'b00000,        // x0   // Zero Register
        REG_RA   = 5'b00001,        // x1   //Return Address
        REG_SP   = 5'b00010,        // x2   //Stack Pointer
        REG_GP   = 5'b00011,        // x3   //Global Pointer
        REG_TP   = 5'b00100,        // x4   //Thread Pointer
        REG_T0   = 5'b00101,        // x5   //Temporary Register 0
        REG_T1   = 5'b00110,        // x6   //Temporary Register 1
        REG_T2   = 5'b00111,        // x7   //Temporary Register 2
        REG_S0   = 5'b01000,        // x8   //Saved register / frame pointer
        REG_S1   = 5'b01001,        // x9   //Saved register
        REG_A0   = 5'b01010,        // x10  //Function Argument / Returns
        REG_A1   = 5'b01011,        // x11  
        REG_A2   = 5'b01100,        // x12  
        REG_A3   = 5'b01101,        // x13 
        REG_A4   = 5'b01110,        // x14
        REG_A5   = 5'b01111,        // x15
        REG_A6   = 5'b10000,        // x16
        REG_A7   = 5'b10001,        // x17
        REG_S2   = 5'b10010,        // x18 //Saved registers
        REG_S3   = 5'b10011,        // x19 
        REG_S4   = 5'b10100,        // x20 
        REG_S5   = 5'b10101,        // x21
        REG_S6   = 5'b10110,        // x22
        REG_S7   = 5'b10111,        // x23
        REG_S8   = 5'b11000,        // x24
        REG_S9   = 5'b11001,        // x25
        REG_S10  = 5'b11010,        // x26
        REG_S11  = 5'b11011,        // x27
        REG_T3   = 5'b11100,        // x28 //Temporary registers
        REG_T4   = 5'b11101,        // x29
        REG_T5   = 5'b11110,        // x30
        REG_T6   = 5'b11111         // x31
    } register_name_t;



    typedef enum logic [6:0] {
        // I-type instructions
        OPCODE_REG_IMM    = 7'b0010011,  // Register-Immediate operations (addi, slti, etc.)
        OPCODE_LOAD       = 7'b0000011,  // Load operations (lw, lh, lb)
        OPCODE_JALR       = 7'b1100111,  // Jump and Link Register
        // R-type instructions
        OPCODE_REG_REG    = 7'b0110011,  // Register-Register operations (add, sub, etc.)
        // S-type instructions
        OPCODE_STORE      = 7'b0100011,  // Store operations (sw, sh, sb)
        // B-type instructions
        OPCODE_BRANCH     = 7'b1100011,  // Branch operations (beq, bne, etc.)
        // U-type instructions
        OPCODE_LUI        = 7'b0110111,  // Load Upper Immediate
        OPCODE_AUIPC      = 7'b0010111,  // Add Upper Immediate to PC
        // J-type instruction
        OPCODE_JAL        = 7'b1101111   // Jump and Link
    } opcode_t;

    // ALU functions Codes (funct3)
     typedef enum logic [2:0] {
        F3_ADD_SUB  = 3'b000,  // ADD/SUB based on funct7
        F3_SLL      = 3'b001,  // Shift Left Logical
        F3_SLT      = 3'b010,  // Set Less Than
        F3_SLTU     = 3'b011,  // Set Less Than Unsigned
        F3_XOR      = 3'b100,  // XOR
        F3_SRL_SRA  = 3'b101,  // Shift Right Logical/Arithmetic
        F3_OR       = 3'b110,  // OR
        F3_AND      = 3'b111   // AND
    } funct3_t;

    // ALU functions Codes (funct7)
    typedef enum logic [6:0] {
        F7_ADD_SRL  = 7'b0000000,   // ADD or SRL Operation
        F7_SUB_SRA  = 7'b0100000    // SUB or SRA Operation
    } funct7_t;

    // Decoded Instruction Structure, plus immediate value and operands Regs[rs1] and Regs[rs2]
    typedef struct packed {
        opcode_t opcode;            // Instruction opcode
        register_name_t rd;         // Destination register
        register_name_t rs1;        // Source register 1
        register_name_t rs2;        // Source register 2
        funct3_t funct3;            // ALU function code
        funct7_t funct7;            // ALU function code
        logic [DATA_WIDTH-1:0] pc;  // Program Counter
        logic [XLEN-1:0] reg_A;     // Regs[rs1]
        logic [XLEN-1:0] reg_B;     // Regs[rs2]
        logic [11:0] imm;           // Immediate value
	logic [31:0] imm_extended;     // Sign-extended immediate
    } decoded_instr_t;


    // Instruction encoding functions 
    function automatic logic [31:0] encode_r_type(
        input logic [6:0] opcode,
        input logic [2:0] funct3,
        input logic [6:0] funct7,
        input logic [4:0] rd,
        input logic [4:0] rs1,
        input logic [4:0] rs2
    );
        return {funct7, rs2, rs1, funct3, rd, opcode};
    endfunction

    function automatic logic [31:0] encode_i_type(
        input logic [6:0] opcode,
        input logic [2:0] funct3,
        input logic [4:0] rd,
        input logic [4:0] rs1,
        input logic [11:0] imm
    );
        return {imm, rs1, funct3, rd, opcode};
    endfunction

    function automatic logic [31:0] encode_s_type(
        input logic [6:0] opcode,
        input logic [2:0] funct3,
        input logic [4:0] rs1,
        input logic [4:0] rs2,
        input logic [11:0] imm
    );
        return {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
    endfunction

    function automatic logic [31:0] encode_b_type(
        input logic [6:0] opcode,
        input logic [2:0] funct3,
        input logic [4:0] rs1,
        input logic [4:0] rs2,
        input logic [11:0] imm
    );
        return {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
    endfunction

    function automatic logic [31:0] encode_j_type(
        input logic [6:0] opcode,
        input logic [4:0] rd,
        input logic [20:0] imm
    );
        return {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
    endfunction 
endpackage: riscv_pkg