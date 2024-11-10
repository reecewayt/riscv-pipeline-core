module register_file(
    register_file_if.register_file rf_if         // Modport for register file
);
    import riscv_pkg::*;
    // Register File
    logic [XLEN-1:0] registers [2**ADDR-1:0] = '{default: 32'h0}; // Register File

    // Debug function to print register contents
    function automatic void print_registers();
        $display("\n=== Register File Contents ===");
        for (int i = 0; i < 2**ADDR; i++) begin
            $display("Register x%0d = %h", i, registers[i]);
        end
        $display("============================\n");
    endfunction

    // Monitor write enable and related signals
    initial begin
        $monitor("[REG FILE]Time=%0t write_en=%b rd_addr=%0d rd_data=%h", 
                 $time, rf_if.write_en, rf_if.rd_addr, rf_if.rd_data);
    end

    // Feed Register Data to Decode Stage
    assign rf_if.data_out_rs1 = registers[rf_if.rs1_addr];
    assign rf_if.data_out_rs2 = registers[rf_if.rs2_addr];
    

    // Sequential Write to Register File from Writeback Stage
    always_ff @(posedge rf_if.clk or negedge rf_if.rst_n) begin
        if (!rf_if.rst_n) begin
            // Reset all registers to 0
            for (int i=0; i < (2**ADDR); i++) begin
                registers[i] <= 32'h0;
            end
            //$display("[REG FILE]Register File Reset");
            //print_registers();
        end else if (rf_if.write_en && rf_if.rd_addr != '0) begin // Skip writing to rx0, nothing happens 
            registers[rf_if.rd_addr] <= rf_if.rd_data;
            $display("[WRITE REG FILE] Write x%0d = %h", rf_if.rd_addr, rf_if.rd_data);
        end
    end

endmodule: register_file