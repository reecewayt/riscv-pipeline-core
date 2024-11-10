///////////////////////////////////////////////////////////////////////////////
// File Name:     reg_file_test_pkg.sv
// Author:      Reece Wayt
// Course:        ECE 571
// Description:   Test package for RISC-V register file verification. Contains:
//                - Test driver class for register file testing
//                - Reference model for register state tracking
//                - Basic and concurrent test sequences
//                - Error checking and reporting functionality
//
// Features:      - Dual read port verification (RS1, RS2)
//                - Single write port verification
//                - Register x0 hardwired to zero testing
//                - Concurrent read operation testing
//
// Parameters:    Uses parameters from riscv_pkg:
//                - XLEN: Register width (default: 32)
//                - ADDR: Address width (default: 5 for 32 registers)
//
// Dependencies:  - register_file_if.sv
//                - riscv_pkg.sv
//
///////////////////////////////////////////////////////////////////////////////

package reg_file_test_pkg;
    // Transaction type for register operations
    typedef enum {READ_RS1, READ_RS2, WRITE_RD} op_type_t;
   
    class reg_test_driver;
        // Interface handles for write and read operations
        virtual register_file_if.writeback_reg write_vif;
        virtual register_file_if.decode_reg read_vif;
        
        // Reference model and statistics
        logic [31:0] reg_model[32];
        int num_checks = 0;
        int num_errors = 0;
       
        // Constructor: Initialize interfaces and reference model
        function new(virtual register_file_if.writeback_reg write_vif,
                    virtual register_file_if.decode_reg read_vif);
            this.write_vif = write_vif;
            this.read_vif = read_vif;
            foreach(reg_model[i]) reg_model[i] = 0;
        endfunction
       
        // Write to specified register with proper timing
        task write_reg(logic [4:0] addr, logic [31:0] data);
            @(negedge write_vif.clk);
            write_vif.rd_addr = addr;
            write_vif.rd_data = data;
            write_vif.write_en = 1'b1;
            @(posedge write_vif.clk);
            @(negedge write_vif.clk);
            write_vif.write_en = 1'b0;
            if(addr != 0) reg_model[addr] = data;
        endtask
       
        // Read and verify RS1 port
        task read_rs1(logic [4:0] addr);
            logic [31:0] expected = reg_model[addr];
            read_vif.rs1_addr = addr;
            #1; // Allow combinational read to settle
           
            num_checks++;
            if(read_vif.data_out_rs1 !== expected) begin
                $error("RS1 Read Error - x%0d: Expected %h, Got %h",
                       addr, expected, read_vif.data_out_rs1);
                num_errors++;
            end
        endtask
       
        // Read and verify RS2 port
        task read_rs2(logic [4:0] addr);
            logic [31:0] expected = reg_model[addr];
            read_vif.rs2_addr = addr;
            #1; // Allow combinational read to settle
           
            num_checks++;
            if(read_vif.data_out_rs2 !== expected) begin
                $error("RS2 Read Error - x%0d: Expected %h, Got %h",
                       addr, expected, read_vif.data_out_rs2);
                num_errors++;
            end
        endtask
       
        // Basic test: Sequential write/read to registers
        task run_basic_test();
            for(int i = 0; i < 5; i++) begin
                write_reg(i, i * 32'h11111111);
                read_rs1(i);
                read_rs2(i);
            end
        endtask
       
        // Concurrent test: Simultaneous reads from different registers
        task run_concurrent_test();
            write_reg(1, 32'hAAAAAAAA);
            write_reg(2, 32'h55555555);
            fork
                read_rs1(1);
                read_rs2(2);
            join
        endtask
       
        // Report final test results and status
        function void report_status();
            $display("\n=== Test Results ===");
            $display("Checks: %0d", num_checks);
            if (num_errors > 0) begin
                $display("Errors: %0d", num_errors);
                $display("\nReference Model State:");
                foreach(reg_model[i]) begin
                    $display("x%0d = %h", i, reg_model[i]);
                end
            end else begin
                $display("All tests passed successfully!");
            end
        endfunction
    endclass
endpackage