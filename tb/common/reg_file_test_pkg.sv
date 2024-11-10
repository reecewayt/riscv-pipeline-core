package reg_file_test_pkg;
    typedef enum {READ_RS1, READ_RS2, WRITE_RD} op_type_t;
    
    class reg_test_driver;
        // Specify the writeback_reg modport for the virtual interface
        virtual register_file_if.writeback_reg write_vif;
        virtual register_file_if.decode_reg read_vif;
        logic [31:0] reg_model[32];
        int num_checks = 0;
        int num_errors = 0;
        
        // Modified constructor to accept both modports
        function new(virtual register_file_if.writeback_reg write_vif,
                    virtual register_file_if.decode_reg read_vif);
            this.write_vif = write_vif;
            this.read_vif = read_vif;
            foreach(reg_model[i]) reg_model[i] = 0;
        endfunction
        
        task write_reg(logic [4:0] addr, logic [31:0] data);
            @(negedge write_vif.clk);     // Setup signals on negedge
            write_vif.rd_addr = addr;     // Set up address
            write_vif.rd_data = data;     // Set up data
            write_vif.write_en = 1'b1;    // Enable write
            @(posedge write_vif.clk);     // Wait for posedge where write occurs
            @(negedge write_vif.clk);     // Wait for negedge
            write_vif.write_en = 1'b0;    // Disable write
            if(addr != 0) reg_model[addr] = data;
            $display("[TEST] Write x%0d = %h", addr, data);
        endtask
        
        // Read tasks using decode_reg modport
        task read_rs1(logic [4:0] addr);
            logic [31:0] expected = reg_model[addr];
            read_vif.rs1_addr = addr;
            #1; // Small delay to allow combinational read to settle
            
            num_checks++;
            if(read_vif.data_out_rs1 !== expected) begin
                $error("RS1 Read Error - x%0d: Expected %h, Got %h",
                       addr, expected, read_vif.data_out_rs1);
                num_errors++;
            end else begin
                $display("[TEST] Read RS1 x%0d = %h", addr, read_vif.data_out_rs1);
            end
        endtask
        
        task read_rs2(logic [4:0] addr);
            logic [31:0] expected = reg_model[addr];
            read_vif.rs2_addr = addr;
            #1; // Small delay to allow combinational read to settle
            
            num_checks++;
            if(read_vif.data_out_rs2 !== expected) begin
                $error("RS2 Read Error - x%0d: Expected %h, Got %h",
                       addr, expected, read_vif.data_out_rs2);
                num_errors++;
            end else begin
                $display("[TEST] Read RS2 x%0d = %h", addr, read_vif.data_out_rs2);
            end
        endtask
        
        // Rest of the tasks remain the same
        task run_basic_test();
            // Write some values
            for(int i = 0; i < 5; i++) begin
                write_reg(i, i * 32'h11111111);
                read_rs1(i);
                read_rs2(i);
            end
        endtask
        
        task run_concurrent_test();
            write_reg(1, 32'hAAAAAAAA);
            write_reg(2, 32'h55555555);
            fork
                read_rs1(1);
                read_rs2(2);
            join
        endtask
        
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