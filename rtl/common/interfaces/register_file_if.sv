///////////////////////////////////////////////////////////////////////////////
// File Name:     register_file_if.sv
// Description:   Interface for RISC-V register file connections between pipeline
//                stages. Supports dual asynchronous read ports and single 
//                synchronous write port.
//
// Parameters:    XLEN - Width of registers (default: 32)
//                ADDR - Width of register address (default: 5 for 32 registers)
//
// Author:        Reece Wayt
///////////////////////////////////////////////////////////////////////////////

interface register_file_if ();
    import riscv_pkg::*;

    // Common Signals
    logic clk;
    logic rst_n; 

    // Read port for RS1 
    logic [ADDR-1:0] rs1_addr;
    logic [XLEN-1:0] data_out_rs1;

    // Read port for RS2
    logic [ADDR-1:0] rs2_addr;
    logic [XLEN-1:0] data_out_rs2;

    // Write port
    logic write_en
    logic [ADDR-1:0] rd_addr;
    logic [XLEN-1:0] rd_data;

    // modport for decode stage
    modport decode_reg(
        output rs1_add, rs2_addr                    //decode outputs these signals  
        input data_out_rs1, data_out_rs2            //decode receives these signals
    );

    //modport for execute stage
    modport writeback_reg(
        input clk,
        output write_en, rd_addr, rd_data
    );

    //mdoport for register file itself
    modport register_file(
        input clk, rst_n, 
              rs1_addr, rs2_addr,
              write_en, rd_addr, rd_data,
        output data_out_rs1, data_out_rs2              
    );

endinterface: register_file_if 
