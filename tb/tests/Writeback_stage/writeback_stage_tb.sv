module writeback_stage_tb;

 import riscv_pkg::*;
  
   // Clock and reset
    logic clk;
    logic rst_n;

    // Interface instance
    register_file_if rf_if();
  memory_writeback_if mw_if(clk);

   

    // Instantiate the DUT and connect the writeback modport
    writeback_stage dut (
        .rf_write_if(rf_if.writeback_reg), // Connect to the writeback modport
      .mw_if(mw_if.writeback_stage)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        rf_if.write_en = 0;
        rf_if.rd_addr = '0;
        mw_if.address = 32'h12345678;
        mw_if.LMD = 32'h87654321;
        mw_if.mem_to_reg = 0;

        // Apply reset
        rst_n = 1;
        #10;
        rst_n = 0;

        // Test case 1: ALU result to be written
        rf_if.write_en = 1;
        rf_if.rd_addr = 5'd1;
        mw_if.mem_to_reg = 0;  // Select ALU output
        #10; // Wait for a clock cycle

        // Check if ALU output is written to rd_data
      if (rf_if.rd_data !== mw_if.address) begin
        $display("Test case 1 failed: Expected rd_data = %h, got %h", mw_if.address, rf_if.rd_data);
        end else begin
          $display("Test case 1 passed, Expected rd_data = %h, got %h", mw_if.address, rf_if.rd_data);
        end
      
      

        // Test case 2: Load memory data to be written
        rf_if.write_en = 1;
        rf_if.rd_addr = 5'd2;
        mw_if.mem_to_reg = 1;  // Select memory load data
        #10; // Wait for a clock cycle

        // Check if load data is written to rd_data
        if (rf_if.rd_data !== mw_if.LMD) begin
            $display("Test case 2 failed: Expected rd_data = %h, got %h", mw_if.LMD, rf_if.rd_data);
        end else begin
          $display("Test case 2 passed, Expected rd_data = %h, got %h", mw_if.LMD, rf_if.rd_data);
        end

        // Test case 3: Write enable is disabled
        rf_if.write_en = 0;
        rf_if.rd_addr = 5'd3;
        mw_if.address = 32'hDEADBEEF;
        #10;

        // Check if rd_data is unchanged
        if (rf_if.rd_data === mw_if.address) begin
            $display("Test case 3 failed: rd_data should not have been updated");
        end else begin
            $display("Test case 3 passed");
        end


        $finish;
    end

endmodule

