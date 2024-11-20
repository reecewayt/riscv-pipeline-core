module memory_access(input logic clk,rst_n,memory_writeback_if.memory_stage mem_if);
  
  
  
  data_memory MA(.*);
  
  //assign mem_if.LMD = mem_if.RE?mem_if.read_data:mem_if.LMD;
  
  always_ff@(posedge clk or posedge rst_n) begin
    if(!rst_n)
      mem_if.LMD<=32'hFFFFFFFF;
    else if(mem_if.RE) //Load Instruction
      mem_if.LMD<=mem_if.read_data;
  end
  
  assign mem_if.condpc=mem_if.cond?mem_if.address:mem_if.npc;
  
endmodule