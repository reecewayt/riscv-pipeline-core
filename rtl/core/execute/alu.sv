/*
Project: RISC-V ALU module
Author: Phil N
Date: 11/20/2024
ECE 571 Group Project
V2.0

This module is the ALU for the RISCV processor.
*/

import riscv_pkg::*;

module alu #(
    parameter N = 32  // Data width (e.g., 32-bit)
) (
    decode_execute_if.execute_in de_if,     // Decode to Execute interface
    execute_memory_if.execute_out em_if     // Execute to Memory interface
);




    // Temporary result signals for different operations
    logic [N-1:0] add_sub_result, shift_result, logic_result, compare_result, imm_result;
    logic [N-1:0] imm_extended;  // Sign-extended immediate for I-type instructions


    // ALU Operation Handling
    always_comb begin
        // Default result and flags
        // Initialize signals
        add_sub_result = 32'd0;
        shift_result = 32'd0;
        logic_result = 32'd0;
	      compare_result = 32'd0;
	      imm_result = 32'd0;
        em_if.zero = 1'b0;
        em_if.rs2_data = de_if.decoded_instr.reg_B;  // Pass reg_B directly for memory stage use in store instructions
        em_if.opcode = de_if.decoded_instr.opcode;   // Pass opcode to the memory stage
        em_if.decoded_instr.rd=de_if.decoded_instr.rd;//Pass destination register to Memory access Stage to be passed to Write_back Stage

        // Immediate sign extension for I-type instructions
        imm_extended = {{20{de_if.decoded_instr.imm[11]}}, de_if.decoded_instr.imm};

        // Only compute if valid signal is asserted
        if (de_if.valid && em_if.ready) begin
            case (de_if.decoded_instr.opcode)

				//REG_REG
                OPCODE_REG_REG: begin
                    case (de_if.decoded_instr.funct3)
                        F3_ADD_SUB: begin
                            // ADD or SUB based on funct7
                            if (de_if.decoded_instr.funct7 == F7_ADD_SRL)
                                add_sub_result = de_if.decoded_instr.reg_A + de_if.decoded_instr.reg_B;
                            else if (de_if.decoded_instr.funct7 == F7_SUB_SRA)
                                add_sub_result = de_if.decoded_instr.reg_A - de_if.decoded_instr.reg_B;
                            em_if.alu_result = add_sub_result;
                        end
                        F3_SRL_SRA: begin
                            // SRL or SRA based on funct7
                            if (de_if.decoded_instr.funct7 == F7_ADD_SRL)
                                shift_result = de_if.decoded_instr.reg_A >> de_if.decoded_instr.reg_B[4:0];
                            else if (de_if.decoded_instr.funct7 == F7_SUB_SRA)
                                shift_result = de_if.decoded_instr.reg_A >>> de_if.decoded_instr.reg_B[4:0];
                            em_if.alu_result = shift_result;
                        end
                        F3_OR: em_if.alu_result = de_if.decoded_instr.reg_A | de_if.decoded_instr.reg_B;
                        F3_AND: em_if.alu_result = de_if.decoded_instr.reg_A & de_if.decoded_instr.reg_B;
                        F3_XOR: em_if.alu_result = de_if.decoded_instr.reg_A ^ de_if.decoded_instr.reg_B;
                        F3_SLT: em_if.alu_result = ($signed(de_if.decoded_instr.reg_A) < $signed(de_if.decoded_instr.reg_B)) ? 1 : 0;
                        F3_SLTU: em_if.alu_result = (de_if.decoded_instr.reg_A < de_if.decoded_instr.reg_B) ? 1 : 0;
                        default: em_if.alu_result = 32'd0; // Unsupported operation
                    endcase
                end

				//REG_IMM
                OPCODE_REG_IMM: begin
                    case (de_if.decoded_instr.funct3)
                            F3_ADD_SUB: begin
								if (de_if.decoded_instr.funct7 == F7_ADD_SRL) 
										em_if.alu_result = de_if.decoded_instr.reg_A + imm_extended; // ADDI
								else if (de_if.decoded_instr.funct7 == F7_SUB_SRA) 
										em_if.alu_result = de_if.decoded_instr.reg_A - imm_extended; // SUBI
							end
                        F3_OR: em_if.alu_result = de_if.decoded_instr.reg_A | imm_extended;      // ORI
                        F3_AND: em_if.alu_result = de_if.decoded_instr.reg_A & imm_extended;     // ANDI
                        F3_XOR: em_if.alu_result = de_if.decoded_instr.reg_A ^ imm_extended;     // XORI
                        F3_SLL: em_if.alu_result = de_if.decoded_instr.reg_A << imm_extended[4:0]; // SLLI
                        F3_SRL_SRA: begin
                            if (de_if.decoded_instr.funct7 == F7_ADD_SRL)
                                em_if.alu_result = de_if.decoded_instr.reg_A >> imm_extended[4:0]; // SRLI
                            else if (de_if.decoded_instr.funct7 == F7_SUB_SRA)
                                em_if.alu_result = de_if.decoded_instr.reg_A >>> imm_extended[4:0]; // SRAI
                        end
                      
                        default: em_if.alu_result = 32'd0; // Unsupported operation
                    endcase
                end


				//BRANCH
                OPCODE_BRANCH: begin
                    case (de_if.decoded_instr.funct3)
                        F3_ADD_SUB: em_if.zero = (de_if.decoded_instr.reg_A == de_if.decoded_instr.reg_B); // BEQ
                        F3_OR: em_if.zero = (de_if.decoded_instr.reg_A != de_if.decoded_instr.reg_B); // BNE
                        F3_SLT: em_if.zero = ($signed(de_if.decoded_instr.reg_A) < $signed(de_if.decoded_instr.reg_B)); // BLT
                        F3_SLTU: em_if.zero = (de_if.decoded_instr.reg_A < de_if.decoded_instr.reg_B); // BLTU
                        default: em_if.zero = 1'b0; // Default to false for unsupported branches
                    endcase
                end

        //LOAD/STORE
                OPCODE_LOAD: em_if.alu_result = de_if.decoded_instr.reg_A + imm_extended; // Compute load address
                OPCODE_STORE: em_if.alu_result = de_if.decoded_instr.reg_A + imm_extended; // Compute store address

       //JUMP
                OPCODE_JAL: em_if.alu_result = de_if.decoded_instr.pc + {{11{imm_extended[20]}}, imm_extended}; // JAL
                OPCODE_JALR: em_if.alu_result = (de_if.decoded_instr.reg_A + imm_extended) & ~32'b1; // JALR

       //DEFAULT
                default: em_if.alu_result = 32'd0; // Unsupported opcode
            endcase

            // Set zero flag for conditional branching
            em_if.zero = (em_if.alu_result == 32'd0);
        end

        // Pass valid signal to the next stage
        em_if.valid = de_if.valid;
    end

 
endmodule
