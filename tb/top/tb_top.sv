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
        
            instruction: 32'h00209063,  // // compare x1 and x2 
            pc: 32'h1018,
            expected_opcode: OPCODE_BRANCH,
            expected_rd: 5'h0,      //unused      
            expected_rs1: 5'h2,     // //Unused
            expected_rs2: 5'h3,   // Unused
            reg_a_value: 32'h1, 
            reg_b_value: 32'hA, 
            expected_result: 32'd4, //unused
           register_write: 1'b1
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
            if (rf_if.data_out_rs1 + rf_if.data_out_rs2 != test.expected_result) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, test.expected_result, rf_if.data_out_rs1 + rf_if.data_out_rs2);
                error_count++;
            end
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_REG_IMM) begin
             if (rf_if.data_out_rs1 + de_if.decoded_instr.imm != test.expected_result) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, test.expected_result, rf_if.data_out_rs1 + de_if.decoded_instr.imm);
                error_count++;
            end
          end
          
          else if(de_if.decoded_instr.opcode==OPCODE_STORE) begin
            if (rf_if.data_out_rs1 + de_if.decoded_instr.imm != test.expected_result) begin
                $error("Test %s: Result mismatch. Expected %h, Got %h",
                    test.test_name, test.expected_result, rf_if.data_out_rs1 + de_if.decoded_instr.imm);
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

            $display("Test %s %s", test.test_name, (error_count == 0) ? "PASSED" : "FAILED");
            
            
          
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
        $display("\nTest Summary:");
        $display("Tests run: %0d", test_count);
        $display("Errors: %0d", error_count);

        $finish;
    end

endmodule

