import riscv_pkg::*;

interface memory_writeback_if(input logic clk);


    // Data from memory (for load instructions)
    logic [DATA_WIDTH-1:0] mem_data;         // Data read from memory (LMD)
    logic [DATA_WIDTH-1:0] write_data;       // Data to write to memory
  logic [DATA_WIDTH-1:0] address;          // Address for memory access
  logic [DATA_WIDTH-1:0] read_data;
  logic [DATA_WIDTH-1:0] LMD;
  logic [DATA_WIDTH-1:0] npc;
  logic [DATA_WIDTH-1:0] condpc;

    // Control signals
    logic reg_write;                         // Control signal to enable register write
    logic mem_to_reg;                        // Control signal to select memory data or ALU result
    logic WE;                                // Write Enable
    logic RE;                                // Read Enable
    logic cond;                              //condition flag from execute stage

    // Valid signal (optional for handshaking between stages)
    logic valid;                             // Indicates if data in the interface is valid

    // Modport for memory stage (driver)
    modport memory_stage (
      input write_data,                   // Write data from decode stage(REG B value) for store instruction
      input address,                      // Address from execute stage(ALU output) for LD/ST instructions
        input WE,                           // Write Enable from memory stage
        input RE,                           // Read Enable from memory stage
        output  LMD,                      // Memory data read back to memory stage
        output read_data,
        input npc,
        output condpc,
        input cond
    );

    // Modport for writeback stage (consumer)
    modport writeback_stage (
        input  LMD,                     // Memory data read back for writeback
        output write_data,                   // Data to write if needed in writeback
        input address,                    // Address used in writeback
        input mem_to_reg
    );

endinterface