///////////////////////////////////////////////////////////////////////
// Module: Instruction Fetch
// Description: This module implements the instruction fetch stage
//              of a RISC-V pipeline. It fetches instructions from 
//              instruction memory and updates the program counter (PC).
//
// Interfaces:
//   fetch_decode_if, memory_writeback_if and memory_fetch_if
//
// Features:
//   - Fetches instructions from instruction memory using the PC.
//   - Implements PC update logic based on branching (condpc).
//   - Provides a default instruction (NOP: `0x00000013`) on reset.
//
// Behavior:
//   - On reset:
//       * PC is initialized to 0.
//       * NPC is initialized to 4 (next address).
//       * The fetched instruction is set to NOP (`0x00000013`).
//   - During normal operation:
//       * NPC is updated unconditionally to PC + 4.
//       * PC is updated based on the conditional branch PC (condpc).
//       * Fetched instruction is updated based on read enable.
//
// Notes:
//   - The module instantiates the `instruction_memory` module to 
//     handle instruction storage and retrieval.
//   - Supports aligned memory addressing for 32-bit instructions.
///////////////////////////////////////////////////////////////////////


module instruction_fetch(
  input logic clk,
  input logic rst_n,
  memory_fetch_if.fetch_stage fetch_if,
  fetch_decode_if.fetch_out dec_if,
  memory_writeback_if.memory_stage mem_if
);
  
  instruction_memory IM(.*);                               // Connect instruction_memory module
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dec_if.pc <= 32'h00000000;                            // Reset PC to the starting address
      dec_if.instruction <= 32'h00000013;                          // Clear the current instruction
      mem_if.npc <= 32'h00000004;                           // Initialize NPC to next address
    end else begin
      // Update NPC unconditionally
      mem_if.npc <= dec_if.pc + 4;                         
      
      // Use condpc for updating PC
      dec_if.pc <= fetch_if.condpc;                         
      
      // Update instruction when read is enabled
      if (fetch_if.read_enable) begin
        dec_if.instruction <= fetch_if.instruction;          
      end
    end
  end
  
endmodule
