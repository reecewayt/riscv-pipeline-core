import riscv_pkg::*;

interface fetch_decode_if (
    input logic clk       // Shared pipeline clock signal
);
    // Instruction data
    logic [DATA_WIDTH-1:0] instruction;   // Fetched instruction data
    logic [DATA_WIDTH-1:0] pc;       // Next program counter value

    // Control Signals
    logic valid;               // Indicates valid instruction data
    logic ready;               // Decode stage ready to accept new instruction

    // Future pipelining signals (not used in this implementation)
    //TODO: Add future pipelining signals here
    // logic stall;
    // logic flush;

    modport fetch_out (
        input clk,
        output instruction,
        output pc,
        output valid,
        input ready
    );

    modport decode_in(
        input clk,
        input instruction,
        input pc,
        input valid,
        output ready
    );


endinterface: fetch_decode_if