///////////////////////////////////////////////////////////////////////////////
// File Name:     decode_unit.sv
// Description:   RISC-V Instruction Decode Unit implementing:
//                - Full RISC-V RV32I instruction decoding
//                - Immediate value generation for all instruction types
//                - Control signal generation for execution stage
//                - Register address extraction (RS1, RS2, RD)
//                
// Features:      - Single-cycle combinational decode
//                - Support for all RV32I instruction formats:
//                  * R-type (register-register)
//                  * I-type (immediate)
//                  * S-type (store)
//                  * B-type (branch)
//                  * U-type (upper immediate)
//                  * J-type (jump)
//                
// Interface:     Uses decode_if with modports:
//                - fetch_decode:   Input from fetch stage
//                - decode_execute: Output to execute stage
//                - decode_unit:    Combined interface for this module
//
// Parameters:    From riscv_pkg:
//                - XLEN:      Instruction/register width (default: 32)
//                - ILEN:      Instruction length (default: 32)
//                - IMM_WIDTH: Immediate field width (default: 32)
//
// Dependencies:  - decode_if.sv
//                - riscv_pkg.sv
//                - control_pkg.sv
//
// Notes:         - Handles instruction decomposition into fields
//                - Generates properly sign-extended immediates
//                - Extracts and validates operation codes
//                - Provides control signals for ALU and other units
///////////////////////////////////////////////////////////////////////////////
module decode (
    fetch_decode_if.decode_in fd_if,
    decode_execute_if.decode_out de_if,
    register_file_if.decode_reg rf_if
);
    import riscv_pkg::*; // Import RISC-V package
    decoded_instr_t decoded_instr;

    // Helper function for instruction decoding
    function automatic decoded_instr_t decode_instruction(
        input logic [DATA_WIDTH-1:0] instruction,
        input logic [DATA_WIDTH-1:0] pc
    );
        decoded_instr_t decoded;
        
        // Initialize all fields to prevent latches
        decoded = '0;
        decoded.pc = pc;
        decoded.opcode = opcode_t'(instruction[6:0]);

        unique case(decoded.opcode)
            OPCODE_REG_REG: begin
                decoded.funct3 = funct3_t'(instruction[14:12]);
                decoded.funct7 = funct7_t'(instruction[31:25]);
                decoded.rd = register_name_t'(instruction[11:7]);
                decoded.rs1 = register_name_t'(instruction[19:15]);
                decoded.rs2 = register_name_t'(instruction[24:20]);
            end
            
            OPCODE_REG_IMM, OPCODE_LOAD, OPCODE_JALR: begin
                decoded.rd = register_name_t'(instruction[11:7]);
                decoded.funct3 = funct3_t'(instruction[14:12]);
                decoded.rs1 = register_name_t'(instruction[19:15]);
                decoded.imm = {{20{instruction[31]}}, instruction[31:20]};
            end
            
            OPCODE_STORE: begin
                decoded.funct3 = funct3_t'(instruction[14:12]);
                decoded.rs1 = register_name_t'(instruction[19:15]);
                decoded.rs2 = register_name_t'(instruction[24:20]);
                decoded.imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            OPCODE_BRANCH: begin
                decoded.funct3 = funct3_t'(instruction[14:12]);
                decoded.rs1 = register_name_t'(instruction[19:15]);
                decoded.rs2 = register_name_t'(instruction[24:20]);
                decoded.imm = {{19{instruction[31]}}, instruction[31], instruction[7],
                             instruction[30:25], instruction[11:8], 1'b0};
            end
            
            OPCODE_LUI, OPCODE_AUIPC: begin
                decoded.rd = register_name_t'(instruction[11:7]);
                decoded.imm = {instruction[31:12], 12'b0};
            end
            
            OPCODE_JAL: begin
                decoded.rd = register_name_t'(instruction[11:7]);
                decoded.imm = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                             instruction[20], instruction[30:21], 1'b0};
            end
            
            default: decoded = '0;
        endcase
        
        return decoded;
    endfunction

    // Ready signal is always high for non-pipelined version
    assign fd_if.ready = 1'b1;
    
    // Register file address assignment
    assign rf_if.rs1_addr = decoded_instr.rs1;
    assign rf_if.rs2_addr = decoded_instr.rs2;

    // Main decode logic
    always_ff @(posedge fd_if.clk) begin
        if (fd_if.valid && fd_if.ready) begin
            decoded_instr <= decode_instruction(fd_if.instruction, fd_if.pc);
            decoded_instr.reg_A <= rf_if.data_out_rs1;
            decoded_instr.reg_B <= rf_if.data_out_rs2;
            de_if.decoded_instr <= decoded_instr;
            de_if.valid <= 1'b1;
        end else begin
            de_if.valid <= 1'b0;
        end
    end

endmodule