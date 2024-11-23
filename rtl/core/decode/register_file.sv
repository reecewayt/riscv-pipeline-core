///////////////////////////////////////////////////////////////////////////////
// File Name:     register_file.sv
// Description:   RISC-V Register File implementation providing:
//                - 32 general-purpose registers (x0-x31)
//                - Register x0 hardwired to zero
//                - Dual asynchronous read ports for pipeline decode stage
//                - Single synchronous write port from writeback stage
//                
// Features:      - Asynchronous reads (combinational)
//                - Synchronous writes (posedge clock)
//                - Active low reset
//                - x0 write protection
//
// Interface:     Uses register_file_if with modports:
//                - decode_reg:    RS1/RS2 read ports
//                - writeback_reg: RD write port
//                - register_file: Combined interface for this module
//
// Parameters:    From riscv_pkg:
//                - XLEN: Register width (default: 32)
//                - ADDR: Address width (default: 5 for 32 registers)
//
// Dependencies:  - register_file_if.sv
//                - riscv_pkg.sv
//
// Notes:         - All registers reset to 0x0
//                - Writes to x0 are ignored (hardwired to zero)
//                - Reads and writes are mutually independent
///////////////////////////////////////////////////////////////////////////////

module register_file (
    register_file_if.register_file rf_if         // Modport for register file
);
    import riscv_pkg::*;

    // Register array: 32 registers of XLEN width
    logic [XLEN-1:0] registers [2**ADDR-1:0] = '{default: 32'h0};

    // Debug function to print register contents (not synthesizable)
    // pragma translate_off
    function automatic void print_registers();
        $display("\n=== Register File Contents ===");
        for (int i = 0; i < 2**ADDR; i++) begin
            $display("Register x%0d = %h", i, registers[i]);
        end
        $display("============================\n");
    endfunction
    // pragma translate_on

    // Asynchronous read ports for decode stage
    // x0 reads always return 0 (implemented in hardware)
    assign rf_if.data_out_rs1 = (rf_if.rs1_addr == '0) ? '0 : registers[rf_if.rs1_addr];
    assign rf_if.data_out_rs2 = (rf_if.rs2_addr == '0) ? '0 : registers[rf_if.rs2_addr];
   
    // Synchronous write port from writeback stage
    // Writes to x0 are ignored (hardware implementation)
    always_ff @(posedge rf_if.clk or negedge rf_if.rst_n) begin
        if (!rf_if.rst_n) begin
            // Reset all registers to 0
            for (int i = 0; i < 2**ADDR; i++) begin
                registers[i] <= '0;
            end
        end 
        else if (rf_if.write_en && rf_if.rd_addr != '0) begin
            registers[rf_if.rd_addr] <= rf_if.rd_data;
        end
    end

endmodule: register_file