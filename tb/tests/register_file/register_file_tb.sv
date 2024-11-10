///////////////////////////////////////////////////////////////////////////////
// File: register_file_tb.sv
// Description: Top-level testbench for register file verification
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module register_file_tb;
    import riscv_pkg::*;
    import reg_file_test_pkg::*;
    
    // Clock generation
    logic clk = 0;
    always #5 clk = ~clk;  // 100MHz clock
    
    // Interface instance
    register_file_if rf_if();
    
    // Clock and reset connections
    assign rf_if.clk = clk;
    
    // DUT instantiation
    register_file dut (
        .rf_if(rf_if.register_file)
    );
    
    // Verification environment instance
    reg_env env;
    reg_test_seq test;
    
    // Assertions
    // Check that write enable is never active during reset
    property write_during_reset;
        @(posedge clk) !rf_if.rst_n |-> !rf_if.write_en;
    endproperty
    assert property(write_during_reset) else 
        $error("Write enable active during reset");
    
    // Check that x0 reads always return 0 (RS1)
    property x0_always_zero_rs1;
        @(posedge clk) (rf_if.rs1_addr == 0) |-> (rf_if.data_out_rs1 == 0);
    endproperty
    assert property(x0_always_zero_rs1) else 
        $error("RS1: x0 read returned non-zero value: %h", rf_if.data_out_rs1);
    
    // Check that x0 reads always return 0 (RS2)
    property x0_always_zero_rs2;
        @(posedge clk) (rf_if.rs2_addr == 0) |-> (rf_if.data_out_rs2 == 0);
    endproperty
    assert property(x0_always_zero_rs2) else 
        $error("RS2: x0 read returned non-zero value: %h", rf_if.data_out_rs2);
    
    // Test execution
    initial begin
        // Create verification environment
        env = new(rf_if);
        
        // Create test sequence
        test = new(rf_if, env.drv_mbx);
        
        // Reset sequence
        rf_if.rst_n = 0;
        #100;
        rf_if.rst_n = 1;
        #100;
        
        // Start verification components
        env.run();
        
        // Run test sequences
        $display("\nStarting write-read test...");
        test.write_read_test();
        #100;
        
        $display("\nTesting x0 register...");
        test.test_zero_register();
        #100;
        
        $display("\nTesting concurrent reads...");
        test.test_concurrent_reads();
        #100;
        
        // Wait for completion and check results
        #1000;
        env.scoreboard.report_status();
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #100000;  // Adjust timeout as needed
        $display("TEST TIMEOUT!");
        $finish;
    end
    
    // Optional: Waveform dumping
    initial begin
        $dumpfile("reg_file_tb.vcd");
        $dumpvars(0, register_file_tb);
    end
    
endmodule