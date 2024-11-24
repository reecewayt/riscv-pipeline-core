///////////////////////////////////////////////////////////////////////////////
// File Name:     register_file_scoreboard.sv
// Description:   Scoreboard class for RISC-V Register File verification
//                Provides tracking, comparison, and display functionality for
//                register file testing in the top-level testbench.
//                
// Features:      - Expected value prediction and tracking
//                - Register value comparison and mismatch detection
//                - Multiple display formats for register contents
//                - Support for x0 register write protection
//                - Mismatch counting and tracking
//
// Usage Guide:   In top-level testbench (tb_top.sv):
//
//                // 1. Create interface and DUT instances
//                register_file_if rf_if();
//                register_file dut(.rf_if(rf_if));
//                
//                // 2. Create and initialize scoreboard
//                register_file_scoreboard scb;
//                initial begin
//                    scb = new();
//                    
//                    // 3. Before register write operations
//                    rf_if.rd_addr = 5'd5;         // Example write to x5
//                    rf_if.rd_data = 32'hAABBCCDD;
//                    rf_if.write_en = 1'b1;
//                    scb.update_expected(rf_if.rd_addr, rf_if.rd_data);
//                    
//                    // 4. After write operation completes
//                    @(posedge rf_if.clk);
//                    rf_if.write_en = 1'b0;
//                    scb.check_registers(dut.registers);
//                    
//                    // 5. Display options
//                    scb.dump_registers(dut.registers);     // Simple dump
//                    scb.display_expected();               // Show expected values
//                    scb.display_comparison(dut.registers); // Detailed comparison
//                    
//                    // 6. Check for mismatches
//                    if (scb.get_mismatch_count() > 0) begin
//                        $error("Test failed with %0d mismatches", 
//                               scb.get_mismatch_count());
//                    end
//                end
//
// Methods:       - new():              Constructor, initializes scoreboard
//                - reset():            Resets all expected values to 0
//                - update_expected():    Updates expected value for a register
//                - dump_registers():   Simple display of current register values
//                - check_registers():  Compares expected vs actual values
//                - display_expected(): Shows all expected register values
//                - display_comparison(): Detailed expected vs actual comparison
//                - get_mismatch_count(): Returns total number of mismatches
//
// Dependencies:  - register_file.sv
//                - register_file_if.sv
//                - riscv_pkg.sv
//
// Notes:         - All display methods use hex format for register values
//                - x0 register writes are ignored in update_expected()
//                - Mismatches are counted and tracked for test status
//                - Use reset() to clear scoreboard state between tests
///////////////////////////////////////////////////////////////////////////////

class register_file_scoreboard;
    // Storage for expected register values
    logic [31:0] expected_registers[32];
    string       last_operation;
    int          mismatch_count;
    
    // Constructor
    function new();
        reset();
    endfunction
    
    // Reset the scoreboard state
    function void reset();
        foreach(expected_registers[i]) begin
            expected_registers[i] = 32'h0;
        end
        last_operation = "RESET";
        mismatch_count = 0;
    endfunction
    
    // Update expected value for a register
    function void update_expected(logic [4:0] rd_addr, logic [31:0] rd_data);
        if(rd_addr != 0) begin  // x0 is read-only
            expected_registers[rd_addr] = rd_data;
            last_operation = $sformatf("WRITE x%0d = 0x%8h", rd_addr, rd_data);
        end
    endfunction

     // Simple, dump of register file contents
    function void dump_registers(ref logic [31:0] actual_registers[32]);
        $display("\n=== Register File Contents ===");
        $display("Register  |    Value    ");
        $display("-----------------------");
        
        for(int i = 0; i < 32; i += 2) begin
            //print two registers per line for compact view
            $display("x%-2d: %8h    x%-2d: %8h", 
                    i, actual_registers[i],
                    i+1, actual_registers[i+1]);
        end
        
        $display("======================\n");
    endfunction

    
    // Check actual register file against expected values
    function void check_registers(ref logic [31:0] actual_registers[32]);
        bit mismatch = 0;
        $display("\n=== Register File Check after %s ===", last_operation);
        
        foreach(expected_registers[i]) begin
            if(actual_registers[i] !== expected_registers[i]) begin
                $error("Register x%0d Mismatch: Expected = 0x%8h, Actual = 0x%8h",
                       i, expected_registers[i], actual_registers[i]);
                mismatch = 1;
                mismatch_count++;
            end
        end
        
        if(!mismatch) begin
            $display("✓ All registers match expected values");
        end
        $display("=====================================\n");
    endfunction
    
    // Display current expected register values
    function void display_expected();
        $display("\n=== Expected Register File Contents ===");
        foreach(expected_registers[i]) begin
            $display("Register x%0d = 0x%8h", i, expected_registers[i]);
        end
        $display("====================================\n");
    endfunction
    
    // Display comparison between expected and actual
    function void display_comparison(ref logic [31:0] actual_registers[32]);
        $display("\n=== Register File Comparison ===");
        $display("%-10s %-12s %-12s %-7s", "Register", "Expected", "Actual", "Match?");
        $display("----------------------------------------");
        
        foreach(expected_registers[i]) begin
            string match_status;
            match_status = (actual_registers[i] === expected_registers[i]) ? "PASS" : "FAIL";
            
            $display("x%-9d 0x%8h   0x%8h   %s", 
                    i, expected_registers[i], actual_registers[i], match_status);
        end
        $display("----------------------------------------");
        $display("Total Mismatches: %0d\n", mismatch_count);
    endfunction
    
    // Get the number of mismatches found
    function int get_mismatch_count();
        return mismatch_count;
    endfunction
endclass