module register_file #(
   
)(
    register_file_if.register_file rf_if         // Modport for register file
);
    import riscv_pkg::*;
    // Register File
    logic [XLEN-1:0] registers [ADDR**2-1:0] = '{default: 32'h0}; // Register File


    // Feed Register Data to Decode Stage
    assign rf_if.data_out_rs1 = registers[rf_if.rs1_addr];
    assign rf_if.data_out_rs2 = registers[rf_if.rs2_addr];
    

    // Sequential Write to Register File from Writeback Stage
    always_ff @(posedge rf_if.clk or posedge rf_if.rst_n) begin
        if (!rf_if.rst_n) begin
            // Reset all registers to 0
            for (int i=0; i < (2**ADDR); i++) begin
                registers[i] <= 32'h0;
            end
        end else if (rf_if.write_en && rf_if.rd_addr != '0) begin // Skip writing to rx0, nothing happens 
            registers[rf_if.rd_addr] <= rf_if.rd_data;
        end
    end

endmodule: register_file