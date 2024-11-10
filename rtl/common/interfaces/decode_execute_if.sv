import riscv_pkg::*; 

interface decode_execute_if (
    input logic clk;      // Shared pipeline clock signal
);
    // Decoded instruction data
    decoded_instr_t decoded_instr;   // Decoded instruction data

    // Control Signals
    logic valid;                    // Indicates valid data in decode stage
    logic ready;                    // Execute stage ready to accept new instruction

    modport decode_out (
        input clk,
        output decoded_instr,
        output valid,
        input ready
    );

    modport execute_in (
        input clk,
        input decoded_instr,
        input valid,
        output ready
    );


endinterface: fetch_decode_if