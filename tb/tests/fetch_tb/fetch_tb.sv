///////////////////////////////////////////////////////////////////////
// Testbench: Instruction Fetch Testbench
// Description: 
//   This testbench verifies the functionality of the `instruction_fetch`
//   module by simulating various scenarios such as reset, instruction
//   fetching, PC updates, and read enable behavior.
//
// Test Scenarios:
//   1. Reset Behavior: Verify that the PC, NPC, and instruction are 
//      initialized correctly on reset.
//   2. Instruction Fetch: Check if the module fetches the correct 
//      instruction from memory.
//   3. PC Update: Validate the PC update logic with different conditional PCs.
//   4. Read Enable Behavior: Ensure that instruction updates occur 
//      only when `read_enable` is asserted.
//
// Notes:
//   - Instruction memory write behavior is simulated using 
//     `write_instruction`.
//   - Testbench operates at a clock period of 10 time units.
//   - Each test scenario includes a display task to print relevant signals.
///////////////////////////////////////////////////////////////////////

module instruction_fetch_tb;
    // Declare signals
    logic clk;
    logic rst_n;
    
    // Interface instantiations
    memory_fetch_if fetch_if();
    fetch_decode_if dec_if();
    memory_writeback_if mem_if();
    
    // Instantiate the DUT
    instruction_fetch DUT (
        .clk(clk),
        .rst_n(rst_n),
        .fetch_if(fetch_if),
        .dec_if(dec_if),
        .mem_if(mem_if)
    );
    
    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initial values
        rst_n = 1;
        fetch_if.read_enable = 0;
        fetch_if.condpc = 32'h0;
        fetch_if.write_instruction = 32'h0;
        
        // Test 1: Reset check
      $display("------------Test 1: Reset Check------------");
        #10 rst_n = 0;
      display();
        #10 rst_n = 1;
        display();
        
        // Test 2: Simple instruction fetch
        $display("------------Test 2: Simple Instruction Fetch------------");
        fetch_if.read_enable = 1;
        fetch_if.condpc = 32'h0;
        fetch_if.write_instruction = 32'h00000093;
        display();
  
        
        // Test 3: Next instruction
        $display("------------Test 3: Next Instruction------------");
        fetch_if.condpc = 32'h4;
        fetch_if.write_instruction = 32'h00500113;  // addi x2, x0, 5
        display();
        #10;
        
        // Test 4: Disable read
        $display("------------Test 4: Disable Read------------");
        fetch_if.read_enable = 0;
        display();
        #10;
        
        // Test 5: Re-enable read
        $display("------------Test 5: Re-enable Read------------");
        fetch_if.read_enable = 1;
        fetch_if.condpc = 32'h8;
        fetch_if.write_instruction = 32'h00310233;  // add x4, x2, x3
        display();
        #10;
        
        // End simulation
        #40;
      $display("------------------------------------------Tests completed-----------------------------------------------------------------");
        $finish;
    end
    
    // Task block to display important signals

  task display();
    #40;
    $display("Time=%0t rst_n=%0b read_enable=%0b pc=%h npc=%h instruction=%h",
                 $time, rst_n, fetch_if.read_enable, dec_if.pc,mem_if.npc, dec_if.instruction);
  endtask
    
    
endmodule
