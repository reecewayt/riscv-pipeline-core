///////////////////////////////////////////////////////////////////////
// Module: Memory Access Testbench
//
// Description:
// This testbench verifies the functionality of the `memory_access` module,
// which implements memory read/write operations and conditional PC updates.
//
//
// Test Scenarios:
// 1. Reset operation to initialize memory and LMD.
// 2. Write data to memory at a specific address.
// 3. Read data from memory to verify the previous write.
// 4. Write data to a different memory location.
// 5. Read data from the new memory location.
// 6. Test conditional PC updates based on ALU zero flag.
//
//
///////////////////////////////////////////////////////////////////////
module memory_access_tb;
    // Declare signals
    logic clk;
    logic rst_n;
    import riscv_pkg::*;
    // Interface instantiations
  memory_writeback_if mem_if(clk);
  memory_fetch_if fetch_if(clk);
  execute_memory_if e_m_if(clk);
  
    
    // Instantiate the DUT (Device Under Test)
    memory_access DUT (
        .clk(clk),
        .rst_n(rst_n),
        .mem_if(mem_if),
        .fetch_if(fetch_if),
        .e_m_if(e_m_if)
    );
    
  
  	always #5 clk = ~clk;  // 10ns clock period
    // Clock generation
    initial begin
        clk = 0;
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst_n = 1;
        mem_if.WE = 0;
        mem_if.RE = 0;
        mem_if.REG_B = 32'h0;
        e_m_if.alu_result = 32'h0;
        e_m_if.zero = 0;
        mem_if.npc = 32'h0;
        
        // Test 1: Reset
        $display("Test 1: Reset Check");
        #10 rst_n = 0;
        display();
        #10 rst_n = 1;
        
        // Test 2: Write to memory
        $display("Test 2: Memory Write");
        #10;
        mem_if.WE = 1;
        mem_if.RE = 0;
        e_m_if.alu_result = 32'h4;  // Memory address
        mem_if.REG_B = 32'hABCD1234;  // Data to write
        display();
        #10;
        mem_if.WE = 0;
        
        // Test 3: Read from memory
        $display("Test 3: Memory Read");
        #10;
      e_m_if.opcode = OPCODE_LOAD;
        mem_if.RE = 1;
        mem_if.WE = 0;
        e_m_if.alu_result = 32'h4;  // Same address to read
        display();
        #10;
        
        // Test 4: Write different location
        $display("Test 4: Write Different Location");
        mem_if.RE = 0;
        mem_if.WE = 1;
        e_m_if.alu_result = 32'h8;  // Different memory address
        mem_if.REG_B = 32'h87654321;  // Different data
        display();
        #10;
        mem_if.WE = 0;
        
        // Test 5: Read different location
        $display("Test 5: Read Different Location");
      e_m_if.opcode = OPCODE_LOAD;
        mem_if.RE = 1;
        e_m_if.alu_result = 32'h8;
        display();
        #10;
        
        // Test 6: Test Branch conditional PC
        $display("Test 6: Conditional PC Test");
        e_m_if.opcode = OPCODE_BRANCH;
        e_m_if.zero = 1;
        e_m_if.alu_result = 32'h100;  // Branch target
        mem_if.npc = 32'h200;         // Next PC
        display();
        #10;
        e_m_if.zero = 0;
        display();
        #10;
      
       // Test 7: Test JAL conditional PC
      $display("Test 6: JAL PC Test");
        e_m_if.opcode = OPCODE_JAL;
        e_m_if.alu_result = 32'h300;  // Branch target
        mem_if.npc = 32'h200;         // Next PC
        display();
        #10;
        e_m_if.zero = 0;
        display();
        #10;
        
        // End simulation
        #100;
        $display("Tests completed");
        $finish;
    end
    
    // Task block to display output
  task display();
        #40;
        $display("Time=%0t rst_n=%0b WE=%0b RE=%0b Addr=%h Data=%h ReadData=%h LMD=%h condpc=%h",
                 $time,
                 rst_n,
                 mem_if.WE,
                 mem_if.RE,
                 e_m_if.alu_result,
                 mem_if.REG_B,
                 mem_if.read_data,
                 mem_if.LMD,
                 mem_if.condpc);
  endtask
    
endmodule
