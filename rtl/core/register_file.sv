module register_file (
    input logic clk,
    input logic reset,                  // Asynchronous Reset
    input logic [4:0] rs1,              // Register Source 1
    input logic [4:0] rs2,              // Register Source 2  
    input logic [4:0] rd,               // Register Destination
    input logic [31:0] data_in,
    input logic write_en,
    output logic [31:0] data_out_rs1,   //temp register for rs1
    output logic [31:0] data_out_rs2    //temp register for rs2
);
    // Register File
    logic [31:0] registers [31:0];

    // Read Data
    assign data_out_rs1 = registers[rs1];
    assign data_out_rs2 = registers[rs2];

    // Write Data
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            registers[0] <= 32'h0;
            for (int i=1; i<32; i++) begin
                registers[i] <= 32'h0;
            end
        end else if (write_en) begin
            registers[rd] <= data_in;
        end
    end