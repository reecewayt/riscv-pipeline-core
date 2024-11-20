module data_memory(memory_writeback_if.memory_stage mem_if,input logic clk,input logic rst_n);

    logic [31:0] D_M [1023:0]; // 32x1024 memory array

    always_ff @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 1024; i++) begin
                D_M[i] <= 32'd0;
            end
        end
        else if (mem_if.WE) begin //Store instructions have WE high
            D_M[mem_if.address] <= mem_if.write_data;
        end
    end

    // Assign read_data based on RE (Read Enable)
    assign mem_if.read_data = mem_if.RE ? D_M[mem_if.address] : 32'd0; //Load instrutions have RE high

endmodule