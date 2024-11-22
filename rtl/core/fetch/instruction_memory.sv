///////////////////////////////////////////////////////////////////////
// Module: Instruction Memory
// Description: This module models the instruction memory for a RISC-V
//              pipeline. It interacts with the `fetch_decode_if` and
//              `memory_fetch_if` interfaces for fetching and writing
//              instructions as part of the instruction fetch stage.
//
// Interfaces:
//   fetch_decode_if and memory_fetch_if
//
// Features:
//   - Supports 64 words of 32-bit instruction memory.
//   - Implements aligned instruction fetching based on the PC value.
//   - Provides a NOP instruction (`0x00000013`) when no instruction 
//     is being read.
//
// Behavior:
//   - On reset: 
//       * Initializes all memory locations to zero.
//       * Sets the output instruction to NOP (`0x00000013`).
//   - During normal operation:
//       * Reads instructions from the memory array when `read_enable`
//         is asserted.
///////////////////////////////////////////////////////////////////////
module instruction_memory(input clk,input rst_n,fetch_decode_if.fetch_out dec_if,memory_fetch_if.fetch_stage fetch_if);
  
  int i;
  logic[31:0] instruction_memory[63:0];
  always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fetch_if.instruction <= 32'h00000013;  // NOP on reset
            for (int i = 0; i < 64; i++) begin
                instruction_memory[i] <= '0;
            end
        end
        else begin
            if (fetch_if.read_enable) begin
                // Read operation
                fetch_if.instruction <= instruction_memory[dec_if.pc[7:2]]; //Ensure memory alignment on 4 byte boundary
                // Write operation (if implementing writeable instruction memory)
                instruction_memory[dec_if.pc[7:2]] <= fetch_if.write_instruction;
            end
            else begin
                fetch_if.instruction <= 32'h00000013;  // NOP when not reading
            end
        end
    end

endmodule
