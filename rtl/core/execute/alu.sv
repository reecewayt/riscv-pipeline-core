/*
Project: Pipelined RiscV ALU module
Author: Phil N
Date: 10/27/2024
ECE 571 Group Project

This module is the ALU for the RISCV processor.

*/

import riscv_pkg::*;

// ALU for the RISC-V processor using decode-execute and execute-memory interfaces
module alu #(
    parameter N = 32                // Data width (e.g., 32-bit)
) (
    decode_execute_if.decode_out de_if,     // Decode to Execute interface
    execute_memory_if.execute_out em_if     // Execute to Memory interface
);

    // Temporary result signals for different operations
    logic [N-1:0] add_sub_result, shift_result, logic_result, compare_result;

    // ALU Operation Handling
    always_comb begin
        // Default result and zero flag
        em_if.alu_result = 32'd0;
        em_if.zero = 1'b0;
        em_if.rs2_data = de_if.decoded_instr.reg_B;  // Pass reg_B directly for memory stage use in store instructions
        em_if.opcode = de_if.decoded_instr.opcode;   // Pass opcode to the memory stage

        // Only compute if data is valid and ready signals are asserted
        if (de_if.valid && em_if.ready) begin
            case (de_if.decoded_instr.opcode)
                OPCODE_REG_IMM, OPCODE_REG_REG: begin
                    case (de_if.decoded_instr.funct3)
                        F3_ADD_SUB: begin
                            // Determine ADD/SUB based on funct7 value
                            if (de_if.decoded_instr.funct7 == F7_SUB)
                                add_sub_result = de_if.decoded_instr.reg_A - de_if.decoded_instr.reg_B;
                            else
                                add_sub_result = de_if.decoded_instr.reg_A + de_if.decoded_instr.reg_B;
                            em_if.alu_result = add_sub_result;
                        end
                        
                        F3_SLL: begin
                            // Shift Left Logical
                            shift_result = de_if.decoded_instr.reg_A << de_if.decoded_instr.reg_B[4:0];
                            em_if.alu_result = shift_result;
                        end
                        
                        F3_SLT: begin
                            // Set Less Than (signed comparison)
                            compare_result = (de_if.decoded_instr.reg_A < de_if.decoded_instr.reg_B) ? 32'd1 : 32'd0;
                            em_if.alu_result = compare_result;
                        end
                        
                        F3_SLTU: begin
                            // Set Less Than Unsigned
                            compare_result = ($unsigned(de_if.decoded_instr.reg_A) < $unsigned(de_if.decoded_instr.reg_B)) ? 32'd1 : 32'd0;
                            em_if.alu_result = compare_result;
                        end

                        F3_XOR: begin
                            // XOR
                            logic_result = de_if.decoded_instr.reg_A ^ de_if.decoded_instr.reg_B;
                            em_if.alu_result = logic_result;
                        end

                        F3_SRL_SRA: begin
                            // Shift Right Logical or Arithmetic based on funct7
                            if (de_if.decoded_instr.funct7 == F7_SRA)
                                shift_result = de_if.decoded_instr.reg_A >>> de_if.decoded_instr.reg_B[4:0];
                            else
                                shift_result = de_if.decoded_instr.reg_A >> de_if.decoded_instr.reg_B[4:0];
                            em_if.alu_result = shift_result;
                        end

                        F3_OR: begin
                            // OR
                            logic_result = de_if.decoded_instr.reg_A | de_if.decoded_instr.reg_B;
                            em_if.alu_result = logic_result;
                        end

                        F3_AND: begin
                            // AND
                            logic_result = de_if.decoded_instr.reg_A & de_if.decoded_instr.reg_B;
                            em_if.alu_result = logic_result;
                        end

                        default: em_if.alu_result = 32'd0; // Default case for unsupported operations
                    endcase
                end
                
                // Additional opcodes (optional) can be handled here
                
                default: em_if.alu_result = 32'd0; // Default case for unsupported opcodes
            endcase

            // Set zero flag for conditional branching
            em_if.zero = (em_if.alu_result == 32'd0);
        end

        // Pass valid signal from decode stage to memory stage via execute
        em_if.valid = de_if.valid;
    end

endmodule: alu


/* Missing operation list

Immediate Arithmetic and Logical Operations: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI
Load/Store Operations: LB, LH, LW, LBU, LHU, SB, SH, SW
Branch Operations: BEQ, BNE, BLT, BGE, BLTU, BGEU
Jump Operations: JAL, JALR
Upper Immediate Operations: LUI, AUIPC

*/



