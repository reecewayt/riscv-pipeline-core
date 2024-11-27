///////////////////////////////////////////////////////////////////////
// Module: Writeback Stage
//
// Description:
// This module implements the writeback stage of the RISC-V processor. 
// It is responsible for selecting the appropriate data (either ALU result 
// or Load Memory Data) and writing it back to the register file. The 
// writeback operation occurs only if the `write_en` signal is enabled and 
// the destination register address is valid (non-zero).
//
// Interfaces: register_file_if, memory_writeback_if
//
//
// Functionality:
// - For load instructions (`OPCODE_LOAD`), the `LMD` is written back.
// - For non-load instructions, the `alu_result` is written back.
// - If `write_en` is enabled and `rd_addr` is non-zero, the computed 
//   writeback data is assigned to `rd_data`.
//
///////////////////////////////////////////////////////////////////////
module writeback_stage (
    register_file_if.writeback_reg rf_write_if,  // Register file interface for writeback stage
    memory_writeback_if.writeback_stage mw_if // Memory to Writeback stage interface  
);
    import riscv_pkg::*;
   
    // Select data for writeback
    logic [XLEN-1:0] wb_data;
  always_comb begin
    if(mw_if.opcode == OPCODE_LOAD)
      wb_data = mw_if.LMD;
    else
      wb_data = mw_if.alu_result;
  end
  
    assign rf_write_if.rd_addr = mw_if.decoded_instr.rd;

    // Directly assign rd_data based on write enable and address validity
    assign rf_write_if.rd_data = (rf_write_if.write_en && rf_write_if.rd_addr != '0) ? wb_data : '0;

endmodule : writeback_stage

