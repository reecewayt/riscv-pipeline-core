module tb;

    // Clock and reset signals
    logic clk, rst_n;
    // Instantiate the memory_writeback_if interface
    memory_writeback_if mem_if(.clk(clk));

    
    
    // Signal to monitor the LMD output from the memory_access module
    logic [31:0] LMD;

    // Instantiate the memory_access module (which includes data_memory) with the interface
    memory_access mem_access_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mem_if(mem_if)
    );

    // Initialize clock and reset signals
    initial begin
        clk = 0;
        rst_n = 0;
        mem_if.WE = 0;
        mem_if.RE = 0;
        mem_if.write_data = 32'd0;
        mem_if.address = 32'd0;
        mem_if.npc=32'd0;
       
    end

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Reset sequence
        #10;
        rst_n = 1;

        // Write operation to memory
        mem_if.WE = 1;
        mem_if.RE = 0;
        mem_if.write_data = 32'hF0000000;
        mem_if.address = 32'd0;
        #10; // Wait one clock cycle
      $display("Data written at address %b is %h, LMD output: %h", mem_if.address, mem_if.write_data, mem_if.LMD);

        // Read operation to test LMD output
        mem_if.WE = 0;
        mem_if.RE = 1;
        mem_if.address = 32'd0;
        #10; // Wait one clock cycle for read_data to update
        $display("Data stored at address %b is %h, LMD output: %h", mem_if.address, mem_if.read_data, mem_if.LMD);

        #10;
        mem_if.WE = 0;
        mem_if.RE = 1;
        mem_if.address = 32'd40;
        mem_if.npc=32'd4;
        mem_if.cond=0;
        #10;
      if(mem_if.cond)begin
        $display("NPC Selector has ALU output and it is %0d",mem_if.condpc);
      end
      else begin
        $display("NPC Selector has NPC and it is %0d",mem_if.condpc);
      end
        
        $finish;
    end

endmodule

