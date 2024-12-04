// File Name:     riscv_top_tb.sv
// Author:        Raghavendra Davarapalli
// Description:   Testbench for RISC-V Top-Level Module (riscv_top).
//                - Validates functionality of the RISC-V pipeline stages
//                - Tests fetch, decode, execute, memory, and writeback stages
//                - Simulates RISC-V instructions using predefined test vectors
//                - Compares results with expected outputs for verification
//
// Features:      - Clock generation (10 ns period)
//                - Instantiates the `riscv_top` design under test (DUT)
//                - Tests multiple instruction types:
//                   - R-type (register-register)
//                   - I-type (immediate)
//                   - Store (S-type)
//                   - Load (L-type)
//                   - Branch (B-type)
//                   - Jump (J-type)
//                - Validates instruction decoding, ALU results, memory access,
//                  and writeback values
//
// Interface:     - Uses pipeline stage interfaces from `riscv_pkg`:
//                   - fetch_decode_if: Fetch to Decode interface
//                   - decode_execute_if: Decode to Execute interface
//                   - execute_memory_if: Execute to Memory interface
//                   - memory_writeback_if: Memory to Writeback interface
//                   - memory_fetch_if: Memory to Fetch interface
//                   - register_file_if: Register file interface
//
// Parameters:    - None (uses interfaces and definitions from `riscv_pkg`)
//
// Testbench Structure:
//                - Defines `test_case_t` struct to represent a single test case
//                - Includes an array of test cases (`test_vectors`) covering
//                  various instruction types and scenarios
//                - Executes tests sequentially:
//                   1. Initializes inputs for DUT
//                   2. Waits for the DUT to process the instruction
//                   3. Compares DUT outputs with expected results
//                   4. Displays detailed information for debugging
//                - Tracks and reports test pass/fail results
//
// Dependencies:  - riscv_top.sv
//                - riscv_pkg.sv
//                - Pipeline stage interfaces 
//
// Notes:         - Extensible test structure: additional test cases can be
//                  added to the `test_vectors` array
//                - Handles clock/reset initialization and propagation
//                - Reports detailed errors when test cases fail
///////////////////////////////////////////////////////////////////////////////



module riscv_top_tb;
    import riscv_pkg::*;

    // Clock and Reset
    logic clk = 0;
    logic rst_n = 0;

    always #5 clk = ~clk;  // 10ns clock period

    // Interfaces
    fetch_decode_if fd_if(clk);
    decode_execute_if de_if(clk);
    execute_memory_if em_if(clk);
    memory_writeback_if mw_if(clk);
    memory_fetch_if mf_if(clk);
  register_file_if rf_if();

    // DUT instantiation
    riscv_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .fd_if(fd_if),
        .de_if(de_if),
        .em_if(em_if),
        .mw_if(mw_if),
        .mf_if(mf_if),
        .rf_if(rf_if)
    );

    // Testbench Variables
    int test_count = 0;
    int error_count = 0;

    // Test Data
    typedef struct {
        string test_name;
        logic [31:0] instruction;
        logic [31:0] pc;
        opcode_t expected_opcode;
        logic [4:0] expected_rd;
        logic [4:0] expected_rs1;
        logic [4:0] expected_rs2;
        logic [31:0] reg_a_value;
        logic [31:0] reg_b_value;
        logic [31:0] expected_result;
        logic register_write;
    } test_case_t;

    // Test Vectors
    test_case_t test,test_vectors[] = '{
        // R-type: ADD x1, x2, x3
        '{
            test_name: "R-type ADD",
            instruction: 32'h003100b3,  // ADD x1, x2, x3
            pc: 32'h1000,
            expected_opcode: OPCODE_REG_REG,
            expected_rd: 5'd1,      // x1
            expected_rs1: 5'd2,     // x2
            expected_rs2: 5'd3,     // x3
            reg_a_value: 32'h5,
            reg_b_value: 32'h3,
            expected_result: 32'h8,
            register_write: 1'b1
        },
        // I-type: ADDI x1, x2, 12
        '{
            test_name: "I-type ADDI",
            instruction: 32'h00c10093,  // ADDI x1, x1, 12
            pc: 32'h1004,
            expected_opcode: OPCODE_REG_IMM,
            expected_rd: 5'h1,      // x1
            expected_rs1: 5'h1,     // x1
            expected_rs2: 32'd12,   // Unused
            reg_a_value: 32'h5,
            reg_b_value: 32'h0,     //Unused
            expected_result: 32'h11,
            register_write: 1'b1
        },
        // Store instruction
      '{
         test_name: "Store-type",
        
            instruction: 32'h00A28223,  // Store word from x11 into memory address (x10 + 4)
            pc: 32'h1008,
            expected_opcode: OPCODE_STORE,
            expected_rd: 5'h0,       // Unused
            expected_rs1: 5'h5,     // Unused
            expected_rs2: 32'd12,   // Unused
            reg_a_value: 32'h0,      // Unused
            reg_b_value: 32'hA, //Store 32'hA
            expected_result: 32'd4,
           register_write: 1'b0
      },
      
      '{ // Load instruction
         test_name: "Load-type",
        
            instruction: 32'h0042A283,  // // Load word from memory address (x10 + 4) into x11  
            pc: 32'h100C,
            expected_opcode: OPCODE_LOAD,
            expected_rd: 5'h5,      
            expected_rs1: 5'hB,     // //Unused
            expected_rs2: 5'hA,   // Unused
            reg_a_value: 32'h0,   // Unused
            reg_b_value: 32'hA, // Unused
            expected_result: 32'd4, // Unused
           register_write: 1'b1
            
      },
      
      '{
        test_name: "Jump-type",
        
            instruction: 32'h0000346F,  // // Jump to 0x1014
            pc: 32'h1010,
            expected_opcode: OPCODE_JAL,
            expected_rd: 5'h8,      
            expected_rs1: 5'hB,     // //Unused
            expected_rs2: 5'hA,   // Unused
            reg_a_value: 32'h0, //unused
            reg_b_value: 32'hA, //unused
            expected_result: 32'd4, //unused
           register_write: 1'b1
      
      },
      
'{ 
    test_name: "Branch-type",
    instruction: 32'h00209063,  // Assume BEQ
    pc: 32'h1018,
    expected_opcode: OPCODE_BRANCH,
    expected_rd: 5'h0,         // Unused
    expected_rs1: 5'h2,        // Register 2
    expected_rs2: 5'h3,        // Register 3
    reg_a_value: 32'h1, 
    reg_b_value: 32'hA,        // Values compared
    expected_result: 32'h101C, // Branch taken (PC + offset)
    register_write: 1'b0
}
        // Add more test cases in case of future implementations...
    };

    // Test Logic
    initial begin
        $display("Starting RISC-V Pipeline Tests...");

        // Initialize Reset
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        // Run Test Cases
        foreach (test_vectors[i]) begin
            test_count++;
            //test_case_t test;
            test = test_vectors[i];

            $display("Running Test: %s", test.test_name);

            // Initialize Inputs
      
            mf_if.read_enable=1;
          em_if.ready=1;
            fd_if.valid = 1;
          rf_if.write_en=1;
            mf_if.write_instruction = test.instruction;
            mf_if.condpc = test.pc;
            rf_if.data_out_rs1 = test.reg_a_value;
            rf_if.data_out_rs2 = test.reg_b_value;
          #40;
              if(de_if.decoded_instr.opcode==OPCODE_LOAD) begin
            mw_if.RE=1'b1;
            mw_if.WE=1'b0;
           
          end
          else if(de_if.decoded_instr.opcode==OPCODE_STORE) begin
            mw_if.RE=1'b0;
            mw_if.WE=1'b1;
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_JAL || OPCODE_JALR) begin
            mw_if.RE=1'b1;
            mw_if.WE=1'b0;
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_BRANCH) begin
            mw_if.RE=1'b1;
            mw_if.WE=1'b1;
          end
          
          
      
          
        



            // Wait for Execution
          #10;

            // Verify Outputs
          if (fd_if.valid && de_if.decoded_instr.opcode != test.expected_opcode) begin
                $error("Test %s: Opcode mismatch. Expected %h, Got %h",
                    test.test_name, test.expected_opcode, de_if.decoded_instr.opcode);
                error_count++;
            end

          if(de_if.decoded_instr.opcode==OPCODE_REG_REG) begin
            if (em_if.alu_result != test.expected_result) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, test.expected_result, em_if.alu_result);
                error_count++;
            end
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_REG_IMM) begin
             if (em_if.alu_result != test.expected_result) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, test.expected_result, em_if.alu_result);
                error_count++;
            end
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_STORE) begin
            if (em_if.alu_result != test.expected_result) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, test.expected_result, em_if.alu_result);
                error_count++;
            end
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_LOAD) begin
            if (mw_if.LMD != mw_if.read_data) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, mw_if.read_data, mw_if.LMD);
                error_count++;
            end
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_JAL) begin
            if (mw_if.LMD != mw_if.npc) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, mw_if.npc, mw_if.LMD);
                error_count++;
            end
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_BRANCH) begin
            if (mw_if.condpc != em_if.alu_result) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, em_if.alu_result, mw_if.condpc);
                error_count++;
            end
          end

            
            
            
          
        //By Default: commented out, remove comments to display decoded instruction details for debug if needed.
  /*
        $display("  Decoded Instruction: ");
        $display("  Opcode: %b", de_if.decoded_instr.opcode);
        $display("  Destination Register (rd): %0d", de_if.decoded_instr.rd);
        $display("  Source Register 1 (rs1): %0d", de_if.decoded_instr.rs1);
        $display("  Source Register 2 (rs2): %0d", de_if.decoded_instr.rs2);
        $display("  Register A value: %h", de_if.decoded_instr.reg_A);
        $display("  Register B value: %h", de_if.decoded_instr.reg_B);
          $display("  Immediate value: %h", de_if.decoded_instr.imm);  
          $display("  ALU result value: %h", em_if.alu_result);
        $display("  ALU condition flag: %0d", em_if.zero);
        $display("  REG_B Forward: %0d", em_if.rs2_data);
          $display("   LMD Register: %h", mw_if.LMD);
      $display("   CondPC: %h", mw_if.condpc);
          $display("   Data written to Data memory: %h", em_if.rs2_data);
          $display("   Written back at %0d (rd): %h",rf_if.rd_addr ,rf_if.rd_data);
   */
  
          
        end

        // Test Summary
        $display("Tests Completed!");
        $display("\nTest Summary:");
        $display("Tests run: %0d", test_count);
        $display("Errors: %0d", error_count);

        $finish;
    end

endmodule

