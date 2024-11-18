module instruction_fetch(
  input logic clk,
  input logic rst_n,
  memory_fetch_if.fetch_stage fetch_if,
  fetch_decode_if.fetch_out dec_if,
  memory_writeback_if.memory_stage mem_if
);
  
  instruction_memory IM(.*);                               // Connect instruction_memory module
  
  always_ff @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
      dec_if.pc <= 32'h00000000;                            // Reset PC to the starting address
      dec_if.instruction <= 32'd0;                          // Clear the current instruction
    end else if (fetch_if.read_enable) begin
      mem_if.npc <= dec_if.pc + 4;                         // Calculate the next PC (increment by 4)
      dec_if.pc <= fetch_if.condpc;                         // Update PC with the provided PC
      dec_if.instruction <= fetch_if.instruction;          
    end
  end
  
endmodule