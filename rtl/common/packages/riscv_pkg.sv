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
    //Base Instruction Opcodes
    typedef enum logic [6:0] {
        OPCODE_REG_IMM    = 7'b0010011,         // Register-Immediate operations (I-type)
        OPCODE_REG_REG    = 7'b0110011,         // Register-Register operations (R-type)
        OPCODE_LOAD       = 7'b0000011,         // Load operations (I-type)
        OPCODE_STORE      = 7'b0100011,         // Store operations (S-type)
        OPCODE_BRANCH     = 7'b1100011         // Branch operations (B-type)
        //TODO: Add more opcodes
        //OPCODE_JAL        = 7'b1101111,         // Jump and Link (J-type)
        //OPCODE_JALR       = 7'b1100111          // Jump and Link Register (I-type)
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
    	F7_DEFAULT = 7'b0000000,   // Default funct7 value for ADD, SRL, etc.
    	F7_SUB_SRA = 7'b0100000    // Alternate funct7 value for SUB, SRA
    } funct7_t;

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
endpackage   
