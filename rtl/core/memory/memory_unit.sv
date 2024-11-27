///////////////////////////////////////////////////////////////////////
// Module: Memory Access Unit
//
// Description:
// This module implements the memory access stage of the RISC-V processor.
// It handles the following operations:
// - **Load**: Reads data from memory and updates the `Load Memory Data (LMD)` signal.
// - **Store**: Writes data to memory through the `data_memory` module.
// - **Conditional Branching**: Computes the conditional program counter (`condpc`) based on
//   branch conditions or jump instructions (JAL, JALR).
//
// Interfaces:
// - memory_writeback_if, execute_memory_if, memory_fetch_if
//
// Outputs:
// - Updates `mem_if.LMD` with data read from memory during load operations.
// - Updates `mem_if.condpc` to reflect the correct program counter based on branch or jump decisions.
// - Integrates the `data_memory` module to perform memory read/write operations.
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
  import riscv_pkg::*;
  
  always_ff@(posedge clk or negedge rst_n) begin
    if(!rst_n)
       mem_if.LMD <= 32'h00000000;
    else begin
      case (e_m_if.opcode)
        OPCODE_LOAD: mem_if.LMD <= mem_if.read_data;
        OPCODE_JAL: mem_if.LMD <= mem_if.npc;
        OPCODE_JALR: mem_if.LMD <= mem_if.npc;
        default:mem_if.LMD <= mem_if.LMD;
      endcase
    end
  end
  
    // Use zero signal from execute_memory interface to drive condpc
    always_comb begin
      case(e_m_if.opcode)
        OPCODE_BRANCH: mem_if.condpc = e_m_if.zero ? e_m_if.alu_result : mem_if.npc;
        OPCODE_JAL: mem_if.condpc = e_m_if.alu_result;
        OPCODE_JALR: mem_if.condpc = e_m_if.alu_result;
        default:mem_if.condpc = mem_if.npc;
      endcase
    end
  
endmodule

