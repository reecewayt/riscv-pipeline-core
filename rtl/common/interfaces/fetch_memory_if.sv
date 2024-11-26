
interface memory_fetch_if #(parameter DATA_WIDTH = 32) (input logic clk);
    // Interface signals
   logic [DATA_WIDTH-1:0] pc;
   logic [DATA_WIDTH-1:0] npc;                                   // Next PC value
   logic [DATA_WIDTH-1:0] condpc;                               // Conditional PC value
   logic [DATA_WIDTH-1:0] instruction;     
   logic [DATA_WIDTH-1:0] IR;
   logic reset;      
   logic read_enable;                   
   logic valid;                                             // Valid signal for handshaking
   logic [DATA_WIDTH-1:0] write_instruction;               //write instruction
  
  
  modport fetch_stage (
     output pc,                                                 //output of pc stage
     output npc,                                               // Output from npc stage
     output instruction,                                      //output of instruction stage
     input read_enable,
     output reset,                                           
     input valid,
     input condpc,
     input IR,
     input write_instruction
     
   );

  modport memory_stage(
     input pc,                 // Program counter to be used as input
     input npc,                // Next program counter as input
     output instruction,       // Instruction data read from memory
     input read_enable,        // Enable read control from fetch stage
     input reset,              // Reset signal
     output valid,              // Indicates if data is valid
     output condpc
   );
endinterface: memory_fetch_if