module writeback_stage (
    register_file_if.writeback_reg rf_write_if,  // Register file interface for writeback stage
    memory_writeback_if.writeback_stage mw_if // Memory to Writeback stage interface
);
  import riscv_pkg::*;

    // Select data for writeback
    logic [XLEN-1:0] wb_data;
    assign wb_data = mw_if.mem_to_reg ? mw_if.LMD : mw_if.address; //mem_to_reg is high for load instructions, low for arithmetic or logical operations

    // Directly assign rd_data based on write enable and address validity
    assign rf_write_if.rd_data = (rf_write_if.write_en && rf_write_if.rd_addr != '0) ? wb_data : '0;

endmodule : writeback_stage