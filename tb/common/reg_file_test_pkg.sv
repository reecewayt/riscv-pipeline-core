package reg_file_test_pkg;
    // Simple transaction type
    typedef enum {READ_RS1, READ_RS2, WRITE_RD} op_type_t;

    // Combined test driver/monitor
    class reg_test_driver;
        virtual register_file_if vif;
        logic [31:0] reg_model[32];  // Reference model built into driver
        int num_checks = 0;
        int num_errors = 0;

        function new(virtual register_file_if vif);
            this.vif = vif;
            foreach(reg_model[i]) reg_model[i] = 0;
        endfunction

        // Write to a register and verify
        task write_reg(logic [4:0] addr, logic [31:0] data);
            @(posedge vif.clk);
            vif.write_en = 1'b1;
            vif.rd_addr = addr;
            vif.rd_data = data;
            @(negedge vif.clk);
            vif.write_en = 1'b0;

            // Update reference model (except x0)
            if(addr != 0) reg_model[addr] = data;
            $display("[TEST] Write x%0d = %h", addr, data);
        endtask

        // Read from RS1 and verify
        task read_rs1(logic [4:0] addr);
            logic [31:0] expected = reg_model[addr];
            @(posedge vif.clk);
            vif.rs1_addr = addr;
            @(negedge vif.clk);
            
            num_checks++;
            if(vif.data_out_rs1 !== expected) begin
                $error("RS1 Read Error - x%0d: Expected %h, Got %h", 
                       addr, expected, vif.data_out_rs1);
                num_errors++;
            end else begin
                $display("[TEST] Read RS1 x%0d = %h", addr, vif.data_out_rs1);
            end
        endtask

        // Read from RS2 and verify
        task read_rs2(logic [4:0] addr);
            logic [31:0] expected = reg_model[addr];
            @(posedge vif.clk);
            vif.rs2_addr = addr;
            @(negedge vif.clk);
            
            num_checks++;
            if(vif.data_out_rs2 !== expected) begin
                $error("RS2 Read Error - x%0d: Expected %h, Got %h", 
                       addr, expected, vif.data_out_rs2);
                num_errors++;
            end else begin
                $display("[TEST] Read RS2 x%0d = %h", addr, vif.data_out_rs2);
            end
        endtask

        // Basic test sequences
        task run_basic_test();
            // Write some values
            for(int i = 0; i < 5; i++) begin
                write_reg(i, i * 32'h11111111);
                read_rs1(i);
                read_rs2(i);
            end
        endtask

        task run_concurrent_test();
            // Test concurrent reads
            write_reg(1, 32'hAAAAAAAA);
            write_reg(2, 32'h55555555);
            fork
                read_rs1(1);
                read_rs2(2);
            join
        endtask

        // Report results
        function void report_status();
            $display("\n=== Test Results ===");
            $display("Checks: %0d", num_checks);
            $display("Errors: %0d", num_errors);
            $display("Register File State:");
            foreach(reg_model[i]) begin
                $display("x%0d = %h", i, reg_model[i]);
            end
        endfunction
    endclass
endpackage