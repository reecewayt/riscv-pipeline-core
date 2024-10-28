/*
Project: Pipelined RiscV ALU module
Author: Phil N
Date: 10/27/2024
ECE 571 Group Project

This module is the ALU for the RISCV processor.

*/

module alu #(
    parameter N = 32                // Data width (e.g., 32-bit)
) (
    input logic [N-1:0] operand_a,   // First operand
    input logic [N-1:0] operand_b,   // Second operand
    input funct3_t funct3,           // Function code from instruction (funct3)
    input funct7_t funct7,           // Extended function code (funct7)
    input opcode_t opcode,           // Opcode for instruction type
    output logic [N-1:0] result,     // ALU result
    output logic zero                // Zero flag for conditional branches
);

    // Importing all symbols from riscv_pkg
    import riscv_pkg::*;

    // Temporary result signals for different operations
    logic [N-1:0] add_sub_result, shift_result, logic_result, compare_result;

    // ALU Operation Handling
    always_comb begin
        case (opcode)
            OPCODE_REG_IMM, OPCODE_REG_REG: begin
                case (funct3)
                    F3_ADD_SUB: begin
                        // Determine ADD/SUB based on funct7 value
                        if (funct7 == F7_SUB)
                            add_sub_result = operand_a - operand_b;
                        else
                            add_sub_result = operand_a + operand_b;
                        result = add_sub_result;
                    end
                    
                    F3_SLL: begin
                        // Shift Left Logical
                        shift_result = operand_a << operand_b[4:0];
                        result = shift_result;
                    end
                    
                    F3_SLT: begin
                        // Set Less Than (signed comparison)
                        compare_result = (operand_a < operand_b) ? 32'd1 : 32'd0;
                        result = compare_result;
                    end
                    
                    F3_SLTU: begin
                        // Set Less Than Unsigned
                        compare_result = ($unsigned(operand_a) < $unsigned(operand_b)) ? 32'd1 : 32'd0;
                        result = compare_result;
                    end

                    F3_XOR: begin
                        // XOR
                        logic_result = operand_a ^ operand_b;
                        result = logic_result;
                    end

                    F3_SRL_SRA: begin
                        // Shift Right Logical or Arithmetic based on funct7
                        if (funct7 == F7_SRA)
                            shift_result = operand_a >>> operand_b[4:0];
                        else
                            shift_result = operand_a >> operand_b[4:0];
                        result = shift_result;
                    end

                    F3_OR: begin
                        // OR
                        logic_result = operand_a | operand_b;
                        result = logic_result;
                    end

                    F3_AND: begin
                        // AND
                        logic_result = operand_a & operand_b;
                        result = logic_result;
                    end

                    default: result = 32'd0; // Default case for unsupported operations
                endcase
            end
            
            // Optional handling for other opcodes as needed, e.g., load/store, branches
            
            default: result = 32'd0; // Default case for unsupported opcodes
        endcase

        // Set zero flag for conditional branching
        zero = (result == 32'd0);
    end

endmodule: alu

/*

Missing operation list

Immediate Arithmetic and Logical Operations: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI
Load/Store Operations: LB, LH, LW, LBU, LHU, SB, SH, SW
Branch Operations: BEQ, BNE, BLT, BGE, BLTU, BGEU
Jump Operations: JAL, JALR
Upper Immediate Operations: LUI, AUIPC

*/



