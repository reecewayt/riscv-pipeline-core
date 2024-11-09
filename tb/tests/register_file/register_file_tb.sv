///////////////////////////////////////////////////////////////////////////////
// File: register_file_tb.sv
// Description: Top-level testbench for register file verification
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module register_file_tb;
    import riscv_pkg::*;
    
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
    
    // Test sequence class
    class reg_test_seq;
        virtual register_file_if vif;
        mailbox #(reg_transaction) drv_mbx;
        
        function new(virtual register_file_if vif, mailbox #(reg_transaction) drv_mbx);
            this.vif = vif;
            this.drv_mbx = drv_mbx;
        endfunction
        
        // Basic write-read sequence
        task write_read_test();
            reg_transaction trans;
            
            // Write to registers 1-5
            for(int i = 1; i <= 5; i++) begin
                trans = new();
                trans.op_type = reg_transaction::WRITE_RD;
                trans.addr = i;
                trans.data = i * 32'h11111111;  // Unique pattern for each register
                drv_mbx.put(trans);
                #10;  // Wait for write to complete
                
                // Read back using RS1
                trans = new();
                trans.op_type = reg_transaction::READ_RS1;
                trans.addr = i;
                drv_mbx.put(trans);
                #10;
                
                // Read back using RS2
                trans = new();
                trans.op_type = reg_transaction::READ_RS2;
                trans.addr = i;
                drv_mbx.put(trans);
                #10;
            end
        endtask
        
        // Test x0 behavior
        task test_zero_register();
            reg_transaction trans;
            
            // Try to write to x0
            trans = new();
            trans.op_type = reg_transaction::WRITE_RD;
            trans.addr = 0;
            trans.data = 32'hFFFFFFFF;
            drv_mbx.put(trans);
            #10;
            
            // Read x0 from both ports
            trans = new();
            trans.op_type = reg_transaction::READ_RS1;
            trans.addr = 0;
            drv_mbx.put(trans);
            #10;
            
            trans = new();
            trans.op_type = reg_transaction::READ_RS2;
            trans.addr = 0;
            drv_mbx.put(trans);
            #10;
        endtask
        
        // Concurrent read test
        task test_concurrent_reads();
            reg_transaction trans;
            
            // Write different values to two registers
            trans = new();
            trans.op_type = reg_transaction::WRITE_RD;
            trans.addr = 1;
            trans.data = 32'hAAAAAAAA;
            drv_mbx.put(trans);
            #10;
            
            trans = new();
            trans.op_type = reg_transaction::WRITE_RD;
            trans.addr = 2;
            trans.data = 32'h55555555;
            drv_mbx.put(trans);
            #10;
            
            // Read both simultaneously
            fork
                begin
                    trans = new();
                    trans.op_type = reg_transaction::READ_RS1;
                    trans.addr = 1;
                    drv_mbx.put(trans);
                end
                begin
                    trans = new();
                    trans.op_type = reg_transaction::READ_RS2;
                    trans.addr = 2;
                    drv_mbx.put(trans);
                end
            join
            #10;
        endtask
    endclass
    
    // Test execution
    initial begin
        // Create verification environment
        env = new(rf_if);
        
        // Create test sequence
        reg_test_seq test = new(rf_if, env.drv_mbx);
        
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
    
    // Assertions
    // Check that write enable is never active during reset
    property write_during_reset;
        @(posedge clk) !rf_if.rst_n |-> !rf_if.write_en;
    endproperty
    assert property(write_during_reset);
    
    // Check that x0 reads always return 0
    property x0_always_zero;
        @(posedge clk)
        ((rf_if.rs1_addr == 0) |-> (rf_if.data_out_rs1 == 0)) &&
        ((rf_if.rs2_addr == 0) |-> (rf_if.data_out_rs2 == 0));
    endproperty
    assert property(x0_always_zero);
    
endmodule