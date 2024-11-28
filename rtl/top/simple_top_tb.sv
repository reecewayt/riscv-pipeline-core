module simple_top_tb;
    // Declare signals
import riscv_pkg::*;
    logic clk;
    logic rst_n;
  
    // Interface instantiations
  fetch_decode_if fd_if(clk); //dec_if
  decode_execute_if de_if(clk); //de_if
  execute_memory_if em_if(clk); //em_if
  memory_writeback_if mw_if(clk); //mem_if
  memory_fetch_if mf_if(clk); //fetch_if
  register_file_if rf_if(); 
    
    // Instantiate the DUT
  riscv_top DUT(.*);
    
    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initial values
        rst_n = 1;
        
        // Simulate register file contents for testing
        // This simulates predefined register values for testing decode stage
        DUT.DECODE.rf_if.data_out_rs1 = 32'h0000000A;  // x2 = 10
        DUT.DECODE.rf_if.data_out_rs2 = 32'h0000000F;  // x3 = 15
        
        // Test 1: Reset and initial state
        $display("------------Test 1: Reset Check------------");
        rst_n = 0;
      #10;
         // Display decoded instruction details
        $display("  Decoded Instruction: ");
        $display("  Opcode: %b", de_if.decoded_instr.opcode);
        $display("  Destination Register (rd): %0d", de_if.decoded_instr.rd);
        $display("  Source Register 1 (rs1): %0d", de_if.decoded_instr.rs1);
        $display("  Source Register 2 (rs2): %0d", de_if.decoded_instr.rs2);
        $display("  Register A value: %h", de_if.decoded_instr.reg_A);
        $display("  Register B value: %h", de_if.decoded_instr.reg_B);
        $display("  ALU result value: %0d", em_if.alu_result);
        $display("  ALU condition flag: %0d", em_if.zero);
        $display("  REG_B Forward: %0d", em_if.rs2_data);
      $display("   LMD Register: %h", mw_if.LMD);
      $display("   CondPC: %h", mw_if.condpc);
      $display("   Written back at %0d (rd): %0d",rf_if.rd_addr ,rf_if.rd_data);
        #10 rst_n = 1;
      mf_if.read_enable = 1;
      em_if.ready=1;
        
        // Test 2: R-type instruction (add)
        $display("------------Test 2: R-type Instruction (ADD)------------");
        mf_if.write_instruction = 32'h00310233;  // add x4, x2, x3
        mf_if.condpc = 32'h0;
        fd_if.valid = 1'b1;
        rf_if.write_en=1'b1;
        
        #50;
        
        // Display decoded instruction details
        $display("  Decoded Instruction: ");
        $display("  Opcode: %b", de_if.decoded_instr.opcode);
        $display("  Destination Register (rd): %0d", de_if.decoded_instr.rd);
        $display("  Source Register 1 (rs1): %0d", de_if.decoded_instr.rs1);
        $display("  Source Register 2 (rs2): %0d", de_if.decoded_instr.rs2);
        $display("  Register A value: %h", de_if.decoded_instr.reg_A);
        $display("  Register B value: %h", de_if.decoded_instr.reg_B);
        $display("  ALU result value: %0d", em_if.alu_result);
        $display("  ALU condition flag: %0d", em_if.zero);
        $display("  REG_B Forward: %0d", em_if.rs2_data);
      $display("   LMD Register: %h", mw_if.LMD);
      $display("   CondPC: %h", mw_if.condpc);
      $display("   Written back at %0d (rd): %0d",rf_if.rd_addr ,rf_if.rd_data);
      
        #10;
        // Test 3: I-type instruction (addi)
        $display("------------Test 3: I-type Instruction (ADDI)------------");
        mf_if.write_instruction = 32'h00510113;  // addi x2, x2, 5
        mf_if.condpc = 32'h4;
        fd_if.valid = 1'b1;
        #50;
        
        // Display decoded instruction details
      $display("   Decoded Instruction: ");
        $display("  Opcode: %b", de_if.decoded_instr.opcode);
        $display("  Destination Register (rd): %0d", de_if.decoded_instr.rd);
        $display("  Source Register 1 (rs1): %0d", de_if.decoded_instr.rs1);
        $display("  Immediate Value: %h", de_if.decoded_instr.imm_extended);
      $display("  ALU result value: %0d", em_if.alu_result);
      $display("  ALU condition flag: %0d", em_if.zero);
      $display("  REG_B Forward: %0d", em_if.rs2_data);
      $display("   LMD Register: %h", mw_if.LMD);
      $display("   CondPC: %h", mw_if.condpc);
      $display("   Written back at %0d (rd): %0d",rf_if.rd_addr ,rf_if.rd_data);
        #10;
        // Test 4: Store instruction
        $display("------------Test 4: Store Instruction------------");
        mw_if.WE = 1'b1; // Store signal
      mf_if.write_instruction = 32'h00A28223;  // Store word from x11 into memory address (x10 + 4)
        mf_if.condpc = 32'h8;
        fd_if.valid = 1'b1;
      rf_if.write_en=1'b0;
        #50;
        
        // Display decoded instruction details
      $display("   Decoded Instruction: ");
        $display("  Opcode: %b", de_if.decoded_instr.opcode);
        $display("  Source Register 1 (rs1): %0d", de_if.decoded_instr.rs1);
        $display("  Source Register 2 (rs2): %0d", de_if.decoded_instr.rs2);
        $display("  Immediate Value: %h", de_if.decoded_instr.imm_extended);
      $display("  ALU result value: %0d", em_if.alu_result);
      $display("  ALU condition flag: %0d", em_if.zero);
      $display("  REG_B Forward: %0d", em_if.rs2_data);
      $display("   LMD Register: %h", mw_if.LMD);
      $display("   CondPC: %h", mw_if.condpc);
      $display("   Data written to Data memory: %h", em_if.rs2_data);
      $display("   Written back at %0d (rd): %0d",rf_if.rd_addr ,rf_if.rd_data);
      #10;
       mw_if.WE = 1'b0;
      
      // Test 5: Load instruction
      $display("------------Test 5: Load Instruction------------");
        mw_if.RE = 1'b1; // Load signal
      mf_if.write_instruction = 32'h0042A283;  // Load word from memory address (x10 + 4) into x11 
        mf_if.condpc = 32'hc;
        fd_if.valid = 1'b1;
      rf_if.write_en=1'b1;
        #50;
      // Display decoded instruction details
      $display("   Decoded Instruction: ");
        $display("  Opcode: %b", de_if.decoded_instr.opcode);
        $display("  Source Register 1 (rs1): %0d", de_if.decoded_instr.rs1);
        $display("  Source Register 2 (rs2): %0d", de_if.decoded_instr.rs2);
        $display("  Immediate Value: %h", de_if.decoded_instr.imm_extended);
      $display("  ALU result value: %0d", em_if.alu_result);
      $display("  ALU condition flag: %0d", em_if.zero);
      $display("  REG_B Forward: %0d", em_if.rs2_data);
      $display("   LMD Register: %h", mw_if.LMD);
      $display("   CondPC: %h", mw_if.condpc);
      $display("   Data written to Data memory: %h", em_if.rs2_data);	
      $display("   Written back at %0d (rd): %0d",rf_if.rd_addr ,rf_if.rd_data);
      #10;
      
      // Test 6: JAL instruction
      $display("------------Test 6: JAL Instruction------------");
        mw_if.RE = 1'b1; // Load signal
      mf_if.write_instruction = 32'h0000346F;  // 
        mf_if.condpc = 32'h10;
        fd_if.valid = 1'b1;
      rf_if.write_en=1'b1;
        #50;
      // Display decoded instruction details
      $display("   Decoded Instruction: ");
        $display("  Opcode: %b", de_if.decoded_instr.opcode);
        $display("  Destination Register (rd): %0d", de_if.decoded_instr.rd);
        $display("  Source Register 1 (rs1): %0d", de_if.decoded_instr.rs1);
        $display("  Source Register 2 (rs2): %0d", de_if.decoded_instr.rs2);
        $display("  Immediate Value: %h", de_if.decoded_instr.imm_extended);
      $display("  ALU result value: %0d", em_if.alu_result);
      $display("  ALU condition flag: %0d", em_if.zero);
      $display("  REG_B Forward: %0d", em_if.rs2_data);
      $display("   LMD Register: %h", mw_if.LMD);
      $display("   CondPC: %0d", mw_if.condpc);
      $display("   NPC: %0d", mw_if.npc);
      $display("   Data written to Data memory: %h", em_if.rs2_data);	
      $display("   Written back at %0d (rd): %0d",rf_if.rd_addr ,rf_if.rd_data);
      #10;
      
      // Test 7: Branch instruction
      $display("------------Test 7: Branch instruction------------");
        mw_if.RE = 1'b0; // Load signal
      mf_if.write_instruction = 32'h00310063;  //Compare x1 and x2 
        mf_if.condpc = 32'd20;
        fd_if.valid = 1'b1;
      rf_if.write_en=1'b0;
        #50;
      // Display decoded instruction details
      $display("   Decoded Instruction: ");
        $display("  Opcode: %b", de_if.decoded_instr.opcode);
        $display("  Destination Register (rd): %0d", de_if.decoded_instr.rd);
        $display("  Source Register 1 (rs1): %0d", de_if.decoded_instr.rs1);
        $display("  Source Register 2 (rs2): %0d", de_if.decoded_instr.rs2);
        $display("  Immediate Value: %h", de_if.decoded_instr.imm_extended);
      $display("  ALU result value: %0d", em_if.alu_result);
      $display("  ALU condition flag: %0d", em_if.zero);
      $display("  REG_B Forward: %0d", em_if.rs2_data);
      $display("   LMD Register: %h", mw_if.LMD);
      $display("   CondPC: %0d", mw_if.condpc);
      $display("   NPC: %0d", mw_if.npc);
      $display("   Data written to Data memory: %h", em_if.rs2_data);	
      $display("   Written back at %0d (rd): %0d",rf_if.rd_addr ,rf_if.rd_data);
      #10;
      
        
        // End simulation
        #40 $finish;
    end
    
endmodule
