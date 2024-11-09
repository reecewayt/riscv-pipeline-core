// decode.sv
import riscv_pkg::*;

function automatic logic [31:0] decode_instruction(
        input logic [DATA_WIDTH-1:0] instruction,
        input logic [DATA_WIDTH-1:0] pc
    );
    decoded_instr_t decoded_instr;
    // All instructions have opcode in [6:0]
    decoded.opcode = opcode_t'(instruction[6:0]);
    decoded.pc = pc;

    // Access Registers in another procedure
    decoded.reg_A = '0; 
    decoded.reg_B = '0;

    unique case(decoded.opcode)
        // R-Type Instructions
        OPCODE_REG_REG: begin
            decoded.funct3 = funct3_t'(instruction[14:12]);
            decoded.funct7 = funct7_t'(instruction[31:25]);
            decoded.rd = register_name_t'(instruction[11:7]);
            decoded.rs1 = register_name_t'(instruction[19:15]);
            decoded.rs2 = register_name_t'(instruction[24:20]);
            decoded.imm = '0;
        end
        // I-Type Instructions
        OPCODE_REG_IMM, OPCODE_LOAD, OPCODE_JALR: begin
            decoded.rd     = register_name_t'(instruction[11:7]);
            decoded.funct3 = funct3_t'(instruction[14:12]);
            decoded.rs1    = register_name_t'(instruction[19:15]);
            decoded.rs2    = '0;    // I-type doesn't use rs2
            decoded.funct7 = '0;    // I-type doesn't use funct7
            decoded.imm    = {{20{instruction[31]}},instruction[31:20]};  // 12-bit immediate w/ sign ext
        end
        // S-type instructions
        OPCODE_STORE: begin
            decoded.rd     = '0;  // S-type doesn't use rd
            decoded.funct3 = funct3_t'(instruction[14:12]);
            decoded.rs1    = register_name_t'(instruction[19:15]);
            decoded.rs2    = register_name_t'(instruction[24:20]);
            decoded.funct7 = '0;
            // Combine the split immediate fields
            decoded.imm    = {{20{instruction[31]}},instruction[31:25], instruction[11:7]};
        end
        // B-type instructions
        OPCODE_BRANCH: begin
            decoded.rd     = '0;  // B-type doesn't use rd
            decoded.funct3 = funct3_t'(instruction[14:12]);
            decoded.rs1    = register_name_t'(instruction[19:15]);
            decoded.rs2    = register_name_t'(instruction[24:20]);
            decoded.funct7 = '0;
            // Reconstruct the immediate for branch
            decoded.imm    = {{20{instruction[31]}},instruction[31], instruction[7], 
                            instruction[30:25], instruction[11:8]};
        end
        // U-type instructions
        OPCODE_LUI, OPCODE_AUIPC: begin
            decoded.rd     = register_name_t'(instruction[11:7]);
            decoded.funct3 = '0;
            decoded.rs1    = '0;
            decoded.rs2    = '0;
            decoded.funct7 = '0;
            decoded.imm    = {instruction[31:12], 12'b0};  // Upper 20 bits
        end
        // J-type instructions
        OPCODE_JAL: begin
            decoded.rd     = register_name_t'(instruction[11:7]);
            decoded.funct3 = '0;
            decoded.rs1    = '0;
            decoded.rs2    = '0;
            decoded.funct7 = '0;
            // Reconstruct the immediate for JAL
            decoded.imm    = {{12{instruction[31]}},instruction[31], instruction[19:12],
                            instruction[20], instruction[30:21]};
        end
    endcase

    return decoded_instr
endfunction: decode_instruction

module decode (
    fetch_decode_if.decode_in fd_if,        // Fetch-decode interface
    decode_execute_if.decode_out de_if,     // Decode-execute interface
    register_file_if.decode_reg rf_if       // Register file interface   
);
    decoded_instr_t decoded_instr; 
    assign fd_if.ready = 1'b1;
     // Assign addresses to register file
    assign rf_if.rs1_addr = decoded_instr.rs1;
    assign rf_if.rs2_addr = decoded_instr.rs2;


    always_ff @(posedge fd_if.clk) begin
        if(fd_if.valid && fd_if.ready) begin
            decoded_instr <= decode_instruction(fd_if.instruction, fd_if.pc);
            decoded_instr.reg_A = rf_if.data_out_rs1;
            decoded_instr.reg_B = rf_if.data_out_rs2;
            de_if.valid <= 1'b1;
        end 
        else begin
            de_if.valid <= 1'b0;
        end
    end
endmodule