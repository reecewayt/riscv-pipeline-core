///////////////////////////////////////////////////////////////////////////////
// File: register_file_tb.sv
// Description: Top-level testbench for register file verification
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module register_file_tb;
    import riscv_pkg::*;
    import reg_file_test_pkg::*;
   
    logic clk = 0;
    always #5 clk = ~clk;
   
    register_file_if rf_if();
    assign rf_if.clk = clk;
   
    register_file dut (
        .rf_if(rf_if.register_file)
    );
   
    reg_test_driver test;

    // Simple test sequence
    initial begin
        test = new(rf_if);

        // Reset
        rf_if.write_en = 0;
        rf_if.rst_n = 0;
        #100 rf_if.rst_n = 1;
        #100;

        // Run tests
        test.run_basic_test();
        #100;
        test.run_concurrent_test();
        #100;

        // Report results
        test.report_status();
        $finish;
    end

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
    
    // Optional: Waveform dumping
    initial begin
        $dumpfile("reg_file_tb.vcd");
        $dumpvars(0, register_file_tb);
    end
    
endmodule