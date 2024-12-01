///////////////////////////////////////////////////////////////////////
// Testbench: writeback_stage_tb
//
// Description:
// This testbench verifies the functionality of the `writeback_stage` module, 
// which is responsible for writing data back to the register file in a RISC-V 
// processor. The module handles the writeback of ALU results or Load Memory 
// Data (LMD) depending on the instruction opcode and updates the destination 
// register (`rd`) when write enable is asserted.
//
// Test Scenarios:
// 1. Reset operation
// 
// 2. Write ALU result to a register
//
// 3. Write Load Memory Data to a register
//
// 4. Write to x0 (Zero Register)
//
// 5. Disable write enable
//
//
///////////////////////////////////////////////////////////////////////
module writeback_stage_tb;
    // Import the package to use its types
    import riscv_pkg::*;
  
    // Clock and reset
    logic clk;
    logic rst_n;

    // Interface instances
    register_file_if rf_write_if();
    memory_writeback_if mw_if(clk);
   
    // Instantiate the DUT 
    writeback_stage dut (
        .rf_write_if(rf_write_if),
        .mw_if(mw_if)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        
        // Initialize interface signals
        rf_write_if.write_en = 0;
        
        // Initialize decoded instruction
        mw_if.decoded_instr.opcode = OPCODE_REG_REG;
        mw_if.decoded_instr.rd = register_name_t'(5'd11);
        mw_if.opcode = OPCODE_REG_REG;
        mw_if.alu_result = 32'h12345678;
        mw_if.LMD = 32'h87654321;

        // Apply reset
        #10;
        rst_n = 1;
        
        // Test case 1: ALU result writeback
        rf_write_if.write_en = 1;
        mw_if.decoded_instr.rd = register_name_t'(5'd1);
        mw_if.opcode = OPCODE_REG_REG;
        #10; 
        
        // Check if ALU result is written to rd_data
        if (rf_write_if.rd_data !== mw_if.alu_result) begin
            $display("Test case 1 failed: Expected rd_data = %h, got %h", 
                      mw_if.alu_result, rf_write_if.rd_data);
        end else begin
            $display("Test case 1 passed: rd_data = %h", rf_write_if.rd_data);
        end
      
        // Test case 2: Load memory data writeback
        rf_write_if.write_en = 1;
        mw_if.decoded_instr.rd = register_name_t'(5'd2);
        mw_if.opcode = OPCODE_LOAD;
        #10; 
        
        // Check if load data is written to rd_data
        if (rf_write_if.rd_data !== mw_if.LMD) begin
            $display("Test case 2 failed: Expected rd_data = %h, got %h", 
                      mw_if.LMD, rf_write_if.rd_data);
        end else begin
            $display("Test case 2 passed: rd_data = %h", rf_write_if.rd_data);
        end

        // Test case 3: Write to x0 (should always be zero)
        rf_write_if.write_en = 1;
        mw_if.decoded_instr.rd = register_name_t'(REG_ZERO);
        mw_if.opcode = OPCODE_REG_REG;
        mw_if.alu_result = 32'hDEADBEEF;
        #10;
        
        // Check if rd_data is zero when writing to x0
        if (rf_write_if.rd_data !== '0) begin
            $display("Test case 3 failed: Writing to x0 should result in zero");
        end else begin
            $display("Test case 3 passed: x0 remains zero");
        end

        // Test case 4: Write enable disabled
        rf_write_if.write_en = 0;
        mw_if.decoded_instr.rd = register_name_t'(5'd3);
        #10;
        
        // Check if rd_data is zero when write enable is low
        if (rf_write_if.rd_data !== '0) begin
            $display("Test case 4 failed: rd_data should be zero when write_en is low");
        end else begin
            $display("Test case 4 passed: No write when write_en is low");
        end

        $finish;
    end
endmodule
