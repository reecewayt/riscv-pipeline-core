module instruction_memory(input clk,input rst_n,fetch_decode_if.fetch_out dec_if,memory_fetch_if.fetch_stage fetch_if);
  
  int i;
  logic[31:0] instruction_memory[63:0];
  always_ff@(posedge clk) begin
    if(!rst_n)
      begin
        for (i=0;i<64;i++) begin
          instruction_memory[i]=32'b0;               // On reset, clear all entries in the instruction memory to zero
        end
      end
    else if(fetch_if.read_enable)   // If read_enable is active, write the provided instruction to instruction_memory


      instruction_memory[dec_if.pc]<=fetch_if.write_instruction;
  end
  
  // Instruction Fetch and Decode Combined
  assign fetch_if.instruction = fetch_if.read_enable?instruction_memory[dec_if.pc]:32'd0;

endmodule