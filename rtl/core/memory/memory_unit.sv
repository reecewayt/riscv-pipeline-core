///////////////////////////////////////////////////////////////////////
// Module: Memory Access Unit
//
// Description:
// This module implements the memory access stage of the RISCV processor. It
// handles data memory operations Load/Store(read/write) and updates the Load 
// Memory Data (LMD) and conditional program counter (condpc) signals.
//
// Interfaces:
// - memory_writeback_if, execute_memory_if, memory_fetch_if
//
// Outputs:
// - Updates `mem_if.LMD` with data read from memory during load operations.
// - Updates `mem_if.condpc` for conditional branching based on ALU results.
//
///////////////////////////////////////////////////////////////////////
module memory_access(
    input logic clk,
    input logic rst_n,
    memory_writeback_if.memory_stage mem_if,
    memory_fetch_if.memory_stage fetch_if,
    execute_memory_if.memory_in e_m_if
);
    // Instantiate data_memory with the new interface
    data_memory MA(
        .mem_if(mem_if),
        .e_m_if(e_m_if),
        .clk(clk),
        .rst_n(rst_n)
    );
  
    // Explicit LMD update logic
    always_ff@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            mem_if.LMD <= 32'h00000000;
        else if(mem_if.RE)
            // Directly capture read_data when RE is high
            mem_if.LMD <= mem_if.read_data;
    end
  
    // Use zero signal from execute_memory interface to drive condpc
    assign mem_if.condpc = e_m_if.zero ? e_m_if.alu_result : mem_if.npc;
endmodule
