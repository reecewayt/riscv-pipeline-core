import riscv_pkg::*;

interface execute_memory_if (
    input logic clk       // Shared pipeline clock signal
);
    // ALU result and additional data
    logic [DATA_WIDTH-1:0] alu_result;  // ALU computation result
    logic [DATA_WIDTH-1:0] rs2_data;    // Data from register file (needed for store instructions)
    logic zero;                         // Zero flag for branch decisions
    opcode_t opcode;                    // Opcode to determine the type of operation in memory stage

    // Control Signals
    logic valid;                        // Indicates valid data from the execute stage
    logic ready;                        // Memory stage ready to accept new instruction

    // Modports for communication
    modport execute_out (
        input clk,
        output alu_result,
        output rs2_data,
        output zero,
        output opcode,
        output valid,
        input ready
    );

    modport memory_in (
        input clk,
        input alu_result,
        input rs2_data,
        input zero,
        input opcode,
        input valid,
        output ready
    );

endinterface: execute_memory_if
