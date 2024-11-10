///////////////////////////////////////////////////////////////////////////////
// File: register_file_tb.sv
// Description: Top-level testbench for register file verification
///////////////////////////////////////////////////////////////////////////////

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
    
    initial begin
        test = new(rf_if.writeback_reg, rf_if.decode_reg);
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
endmodule