`timescale 1ns / 1ps

import riscv_pkg::*;  // Import all constants and types from riscv_pkg

module alu_tb;

    // Parameters
    parameter N = 32;                    // Data width

    // Clock signal
    logic clk;

    // Interface instances
    decode_execute_if decode_ex_if(clk);
    execute_memory_if ex_mem_if(clk);

    // Instantiate the ALU
    alu #(
        .N(N)
    ) alu_inst (
        .de_if(decode_ex_if.decode_out),
        .em_if(ex_mem_if.execute_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 ns period clock
    end

    // Test procedure
    initial begin
        // Initialize signals
        decode_ex_if.valid = 1'b0;
        ex_mem_if.ready = 1'b1;  // Always ready to accept results

        // Wait for a few clock cycles
        #20;

        // Test 1: ADD operation
        decode_ex_if.decoded_instr.opcode = OPCODE_REG_REG;
        decode_ex_if.decoded_instr.funct3 = F3_ADD_SUB;
        decode_ex_if.decoded_instr.funct7 = F7_ADD_SRL; // Use F7_ADD_SRL for ADD
        decode_ex_if.decoded_instr.reg_A = 32'h0000_0005;
        decode_ex_if.decoded_instr.reg_B = 32'h0000_0003;
        decode_ex_if.valid = 1'b1;

        #10;
        decode_ex_if.valid = 1'b0;

        // Check results
        #10;
        if (ex_mem_if.alu_result !== 32'h0000_0008) 
            $display("Test 1 (ADD) failed: result = %h", ex_mem_if.alu_result);
        else 
            $display("Test 1 (ADD) passed");

        // Test 2: SUB operation
        decode_ex_if.decoded_instr.opcode = OPCODE_REG_REG;
        decode_ex_if.decoded_instr.funct3 = F3_ADD_SUB;
        decode_ex_if.decoded_instr.funct7 = F7_SUB_SRA; // Use F7_SUB_SRA for SUB
        decode_ex_if.decoded_instr.reg_A = 32'h0000_0008;
        decode_ex_if.decoded_instr.reg_B = 32'h0000_0003;
        decode_ex_if.valid = 1'b1;

        #10;
        decode_ex_if.valid = 1'b0;

        // Check results
        #10;
        if (ex_mem_if.alu_result !== 32'h0000_0005) 
            $display("Test 2 (SUB) failed: result = %h", ex_mem_if.alu_result);
        else 
            $display("Test 2 (SUB) passed");

        // Test 3: OR operation
        decode_ex_if.decoded_instr.opcode = OPCODE_REG_REG;
        decode_ex_if.decoded_instr.funct3 = F3_OR;      // Use F3_OR for OR
        decode_ex_if.decoded_instr.funct7 = F7_ADD_SRL; // funct7 is irrelevant for OR
        decode_ex_if.decoded_instr.reg_A = 32'h0000_000A;
        decode_ex_if.decoded_instr.reg_B = 32'h0000_0005;
        decode_ex_if.valid = 1'b1;

        #10;
        decode_ex_if.valid = 1'b0;

        // Check results
        #10;
        if (ex_mem_if.alu_result !== 32'h0000_000F) 
            $display("Test 3 (OR) failed: result = %h", ex_mem_if.alu_result);
        else 
            $display("Test 3 (OR) passed");

        // Test 4: AND operation
        decode_ex_if.decoded_instr.opcode = OPCODE_REG_REG;
        decode_ex_if.decoded_instr.funct3 = F3_AND;    // Use F3_AND for AND
        decode_ex_if.decoded_instr.reg_A = 32'h0000_000A;
        decode_ex_if.decoded_instr.reg_B = 32'h0000_0005;
        decode_ex_if.valid = 1'b1;

        #10;
        decode_ex_if.valid = 1'b0;

        // Check results
        #10;
        if (ex_mem_if.alu_result !== 32'h0000_0000) 
            $display("Test 4 (AND) failed: result = %h", ex_mem_if.alu_result);
        else 
            $display("Test 4 (AND) passed");

        // Test 5: XOR operation
        decode_ex_if.decoded_instr.opcode = OPCODE_REG_REG;
        decode_ex_if.decoded_instr.funct3 = F3_XOR;    // Use F3_XOR for XOR
        decode_ex_if.decoded_instr.reg_A = 32'h0000_000A;
        decode_ex_if.decoded_instr.reg_B = 32'h0000_0005;
        decode_ex_if.valid = 1'b1;

        #10;
        decode_ex_if.valid = 1'b0;

        // Check results
        #10;
        if (ex_mem_if.alu_result !== 32'h0000_000F) 
            $display("Test 5 (XOR) failed: result = %h", ex_mem_if.alu_result);
        else 
            $display("Test 5 (XOR) passed");

        // End of tests
        #20;
        $stop;
    end

endmodule

