import riscv_pkg::*;

///////////////////////////////////////////////////////////////////////////////////////////
// Module: Data Cache
// 
// Description:
// This module implements a simple data memory (or data cache) for the RISCV 
// processor. It supports both read(Load) and write(Store) operations, controlled 
// by the read enable (RE) and write enable (WE) signals.
// 
// Interfaces:
// - memory_writeback_if, execute_memory_if
// 
// Outputs:
// - mem_if.read_data: Assign the data from memory to the LMD register for Load instruction
// 
///////////////////////////////////////////////////////////////////////////////////////////
module data_memory(
    memory_writeback_if.memory_stage mem_if,
    execute_memory_if.memory_in e_m_if,
    input logic clk,
    input logic rst_n
);
    import riscv_pkg::*;
    logic [31:0] D_M [1023:0]; // 32x1024 memory array
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 1024; i++) begin
                D_M[i] <= 32'd0;
            end
        end
        else if (mem_if.WE) begin
            // Use ALU result as memory address
          D_M[e_m_if.alu_result] <= e_m_if.rs2_data;
        end
    end
    
    // Assign read_data based on RE (Read Enable)
  assign mem_if.read_data = mem_if.RE ? D_M[e_m_if.alu_result] : mem_if.LMD;
endmodule

