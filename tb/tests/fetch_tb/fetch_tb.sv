module tb;
  logic clk;
  logic reset;
  logic[31:0]IR;
  memory_fetch_if fetch_if();
  fetch_decode_if dec_if();
  instruction_fetch DUT(.*);
  
  always #5 clk=~clk;
  
  initial begin
    clk=0;
  end
  initial begin
    reset=1;
    #10;
    reset=0;
    fetch_if.read_enable=1;
    fetch_if.condpc=32'd10;
    fetch_if.write_instruction=32'd15;
    #30;
    $display("Time: %0t | clk: %b | reset: %b | pc: %h | npc: %h | IR: %h | condpc:%h", $time, clk, reset, dec_if.pc, fetch_if.npc, dec_if.instruction,fetch_if.condpc);
    $finish;
  end
    
    
endmodule

