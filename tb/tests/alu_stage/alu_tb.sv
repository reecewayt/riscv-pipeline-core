`timescale 1ns / 1ps

import riscv_pkg::*;  // Import all constants and types from riscv_pkg

module alu_tb;

    // Parameters
    parameter N = 32;                    // Data width

    // Clock signal
    logic clk;

    // Interface instances
    decode_execute_if de_if(clk);
    execute_memory_if em_if(clk);

    // Instantiate the ALU
    alu #(
        .N(N)
    ) alu_inst (
        .de_if(de_if.decode_out),
        .em_if(em_if.execute_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10 ns period clock
    end

    // Test procedure
    initial begin
        // Initialize signals
        de_if.valid = 1'b0;
        em_if.ready = 1'b1;  // Always ready to accept results

        // Wait for a few clock cycles
        #50;


//TESTING REG_REG

        // Test 1: ADD operation
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_ADD_SUB;
        de_if.decoded_instr.funct7 = F7_ADD_SRL; // Use F7_ADD_SRL for ADD
        de_if.decoded_instr.reg_A = 32'h0000_0005;
        de_if.decoded_instr.reg_B = 32'h0000_0003;

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;

        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0008) 
            $display("Test 1 (ADD) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 1 (ADD) passed");

        // Test 2: SUB operation
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_ADD_SUB;
        de_if.decoded_instr.funct7 = F7_SUB_SRA; // Use F7_SUB_SRA for SUB
        de_if.decoded_instr.reg_A = 32'h0000_0008;
        de_if.decoded_instr.reg_B = 32'h0000_0003;

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0005) 
            $display("Test 2 (SUB) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 2 (SUB) passed");

        // Test 3: OR operation
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_OR;      // Use F3_OR for OR
        de_if.decoded_instr.funct7 = F7_ADD_SRL; // funct7 is irrelevant for OR
        de_if.decoded_instr.reg_A = 32'h0000_000A;
        de_if.decoded_instr.reg_B = 32'h0000_0005;

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_000F) 
            $display("Test 3 (OR) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 3 (OR) passed");

        // Test 4: AND operation
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_AND;    // Use F3_AND for AND
        de_if.decoded_instr.reg_A = 32'h0000_000A;
        de_if.decoded_instr.reg_B = 32'h0000_0005;

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0000) 
            $display("Test 4 (AND) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 4 (AND) passed");

        // Test 5: XOR operation
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_XOR;    // Use F3_XOR for XOR
        de_if.decoded_instr.reg_A = 32'h0000_000A;
        de_if.decoded_instr.reg_B = 32'h0000_0005;

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_000F) 
            $display("Test 5 (XOR) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 5 (XOR) passed");
			
        // Test 6: SLT operation (signed comparison)
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_SLT;
        de_if.decoded_instr.reg_A = 32'hFFFF_FFF5; // -11 (signed)
        de_if.decoded_instr.reg_B = 32'h0000_0005; // 5 (signed)

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0001) 
            $display("Test 6 (SLT signed) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 6 (SLT signed) passed");

        // Test 7: SLT operation (signed comparison where A >= B)
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_SLT;
        de_if.decoded_instr.reg_A = 32'h0000_0005; // 5 (signed)
        de_if.decoded_instr.reg_B = 32'hFFFF_FFF5; // -11 (signed)

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0000) 
            $display("Test 7 (SLT signed) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 7 (SLT signed) passed");

        // Test 8: SLTU operation (unsigned comparison)
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_SLTU;
        de_if.decoded_instr.reg_A = 32'h0000_0003; // 3 (unsigned)
        de_if.decoded_instr.reg_B = 32'h0000_0005; // 5 (unsigned)

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0001) 
            $display("Test 8 (SLTU unsigned) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 8 (SLTU unsigned) passed");

        // Test 9: SLTU operation (unsigned comparison where A >= B)
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_SLTU;
        de_if.decoded_instr.reg_A = 32'hFFFF_FFFF; // 4,294,967,295 (unsigned max)
        de_if.decoded_instr.reg_B = 32'h0000_0001; // 1 (unsigned)

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0000) 
            $display("Test 9 (SLTU unsigned) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 9 (SLTU unsigned) passed");

//TESTING REG_IMM

		// Test 10: ADD IMMEDIATE
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_ADD_SUB;
		de_if.decoded_instr.funct7 = F7_ADD_SRL;
        de_if.decoded_instr.reg_A = 32'h0000_0000; //
        de_if.decoded_instr.imm = 32'h0000_0005; //

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0005) 
            $display("Test 10 (ADDI) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 10 (ADDI) passed");

		// Test 11: OR IMMEDIATE
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_OR;
        de_if.decoded_instr.reg_A = 32'h0000_1010; //
        de_if.decoded_instr.imm = 32'h0000_0101; //

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_1111) 
            $display("Test 11 (ORI) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 11 (ORI) passed");

		// Test 12: AND IMMEDIATE
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_AND;
        de_if.decoded_instr.reg_A = 32'h0000_1010; //
        de_if.decoded_instr.imm = 32'h0000_1000; //

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_1000) 
            $display("Test 12 (ANDI) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 12 (ANDI) passed");

		// Test 13: XOR IMMEDIATE
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_XOR;
        de_if.decoded_instr.reg_A = 32'h0000_1010; //
        de_if.decoded_instr.imm = 32'h0000_0110; //

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_1100) 
            $display("Test 13 (XORI) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 13 (XORI) passed");
			
			
        // Test 14: Shift Left Logical IMMEDIATE (SLLI)
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_SLL; // SLLI operation
        de_if.decoded_instr.reg_A = 32'h0000_1111; // Source value
        de_if.decoded_instr.imm = 32'h0000_0002; // Shift amount (2 bits)

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_4444)  // Expected: 0x0000_1111 << 2 = 0x0000_4444
            $display("Test 14 (SLLI) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 14 (SLLI) passed");
			
		// Test 15: Shift Right Logical IMMEDIATE (SRLI)
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_SRL_SRA;
        de_if.decoded_instr.funct7 = F7_ADD_SRL;		
        de_if.decoded_instr.reg_A = 32'h0000_1111; //
        de_if.decoded_instr.imm = 32'h0000_0002; //

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0444)  
		// Expected: 0x0000_1111 >> 2 = 0x0000_0444
            $display("Test 15 (SRLI) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 15 (SRLI) passed");
		
        // Test 16: Shift Right Arithmetic IMMEDIATE (SRAI)
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_SRL_SRA; // SRAI operation
        de_if.decoded_instr.funct7 = F7_SUB_SRA; // Indicates SRA (arithmetic shift)
        de_if.decoded_instr.reg_A = 32'hFFFF_FFF0; // Negative number (-16 in 2's complement)
        de_if.decoded_instr.imm = 32'h0000_0002; // Shift by 2 bits

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'hFFFF_FFFC)  
		// Expected result: 32'hFFFF_FFF0 >>> 2 = 32'hFFFF_FFFC
            $display("Test 16 (SRAI) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 16 (SRAI) passed");

//SPECIAL CASE
        // Test 17: ADD Operation with Overflow
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_ADD_SUB;
        de_if.decoded_instr.funct7 = F7_ADD_SRL;
        de_if.decoded_instr.reg_A = 32'h7FFFFFFF; // Maximum positive value
        de_if.decoded_instr.reg_B = 32'h00000001; // Small positive value

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h80000000) // Expected: overflow wraps around in 2's complement
            $display("Test 17 (ADD with Overflow) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 17 (ADD with Overflow) passed");

        // Test 18: SUB Operation with Underflow
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_ADD_SUB;
        de_if.decoded_instr.funct7 = F7_SUB_SRA;
        de_if.decoded_instr.reg_A = 32'h80000000; // Minimum negative value
        de_if.decoded_instr.reg_B = 32'h00000001; // Small positive value

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h7FFFFFFF) // Expected: underflow wraps around in 2's complement
            $display("Test 18 (SUB with Underflow) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 18 (SUB with Underflow) passed");

        // Test 19: AND Operation with Zero
        de_if.decoded_instr.opcode = OPCODE_REG_REG;
        de_if.decoded_instr.funct3 = F3_AND;
        de_if.decoded_instr.reg_A = 32'hFFFFFFFF; // All bits set
        de_if.decoded_instr.reg_B = 32'h00000000; // All bits cleared

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h00000000) 
            $display("Test 19 (AND with Zero) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 19 (AND with Zero) passed");

        // Test 20: Load Effective Address Calculation
        de_if.decoded_instr.opcode = OPCODE_LOAD;
        de_if.decoded_instr.reg_A = 32'h00001000; // Base address
        de_if.decoded_instr.imm = 32'h00000010; // Offset

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h00001010) 
            $display("Test 20 (Load Effective Address) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 20 (Load Effective Address) passed");

        // Test 21: Store Effective Address Calculation
        de_if.decoded_instr.opcode = OPCODE_STORE;
        de_if.decoded_instr.reg_A = 32'h00002000; // Base address
        de_if.decoded_instr.imm = 32'hFFFFFFF0; // Negative offset (-16)

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h00001FF0) 
            $display("Test 21 (Store Effective Address) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 21 (Store Effective Address) passed");

//Missed Tests from above
		// Test 22: SUB IMMEDIATE
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_ADD_SUB;
		de_if.decoded_instr.funct7 = F7_SUB_SRA;
        de_if.decoded_instr.reg_A = 32'h0000_0005; //
        de_if.decoded_instr.imm = 32'h0000_0002; //

    // Assert valid and wait for computation
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0003) 
            $display("Test 22 (SUBI) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 22 (SUBI) passed");



//BRANCH


        // End of tests
        #20;
        $stop;
    end

endmodule