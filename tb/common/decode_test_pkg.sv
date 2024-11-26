
package decode_test_pkg;
    import riscv_pkg::*;

    // Test instruction structure
    typedef struct {
        string test_name;
        logic [31:0] instruction;
        logic [31:0] expected_pc;
        opcode_t expected_opcode;
        logic [4:0] expected_rd;
        logic [4:0] expected_rs1;
        logic [4:0] expected_rs2;
        logic [2:0] expected_funct3;
        logic [6:0] expected_funct7;
        logic [31:0] expected_imm;
        logic [31:0] reg_a_value;
        logic [31:0] reg_b_value;
    } test_instruction_t;

    // Test vectors
    class DecodeTests;
        static test_instruction_t test_vectors[] = '{
            // R-type: ADD x1, x2, x3
            '{
                test_name: "R-type ADD",
                instruction: 32'h003100b3,  // ADD x1, x2, x3
                expected_pc: 32'h1000,
                expected_opcode: OPCODE_REG_REG,
                expected_rd: 5'h1,
                expected_rs1: 5'h2,
                expected_rs2: 5'h3,
                expected_funct3: 3'h0,
                expected_funct7: 7'h00,
                expected_imm: 32'h0,
                reg_a_value: 32'h5,
                reg_b_value: 32'h3
            },
            // I-type: ADDI x1, x2, 12
            '{
                test_name: "I-type ADDI",
                instruction: 32'h00c10093,
                expected_pc: 32'h1004,
                expected_opcode: OPCODE_REG_IMM,
                expected_rd: 5'h1,
                expected_rs1: 5'h2,
                expected_rs2: 5'h0,
                expected_funct3: 3'h0,
                expected_funct7: 7'h0,
                expected_imm: 32'hC,
                reg_a_value: 32'h5,
                reg_b_value: 32'h0
            },
            // S-type: SW x2, 16(x3)
            '{
                test_name: "S-type SW",
                instruction: 32'h0021a023,
                expected_pc: 32'h1008,
                expected_opcode: OPCODE_STORE,
                expected_rd: 5'h0,
                expected_rs1: 5'h3,
                expected_rs2: 5'h2,
                expected_funct3: 3'h2,
                expected_funct7: 7'h0,
                expected_imm: 32'h10,
                reg_a_value: 32'h100,
                reg_b_value: 32'h42
            },
            // B-type: BEQ x1, x2, 8
            '{
                test_name: "B-type BEQ",
                instruction: 32'h00208463,
                expected_pc: 32'h100C,
                expected_opcode: OPCODE_BRANCH,
                expected_rd: 5'h0,
                expected_rs1: 5'h1,
                expected_rs2: 5'h2,
                expected_funct3: 3'h0,
                expected_funct7: 7'h0,
                expected_imm: 32'h8,
                reg_a_value: 32'h42,
                reg_b_value: 32'h42
            },
            // U-type: LUI x1, 0x12345
            '{
                test_name: "U-type LUI",
                instruction: 32'h12345037,
                expected_pc: 32'h1010,
                expected_opcode: OPCODE_LUI,
                expected_rd: 5'h0,
                expected_rs1: 5'h0,
                expected_rs2: 5'h0,
                expected_funct3: 3'h0,
                expected_funct7: 7'h0,
                expected_imm: 32'h12345000,
                reg_a_value: 32'h0,
                reg_b_value: 32'h0
            },
            // J-type: JAL x1, 16
            '{
                test_name: "J-type JAL",
                instruction: 32'h0100006f,
                expected_pc: 32'h1014,
                expected_opcode: OPCODE_JAL,
                expected_rd: 5'h0,
                expected_rs1: 5'h0,
                expected_rs2: 5'h0,
                expected_funct3: 3'h0,
                expected_funct7: 7'h0,
                expected_imm: 32'h10,
                reg_a_value: 32'h0,
                reg_b_value: 32'h0
            }
        };
    endclass
endpackage