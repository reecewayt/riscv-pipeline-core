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
        .de_if(de_if.execute_in),
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
de_if.decoded_instr.funct3 = F3_AND;    // Use F3_AND for ANDI
de_if.decoded_instr.reg_A = 32'hFFFF_FFFF; // Input A with all bits set
de_if.decoded_instr.imm = 12'hFFF;      // Immediate with lower 12 bits set
@(posedge clk);
de_if.valid = 1'b1;
@(posedge clk); 
de_if.valid = 1'b0;

    // Wait for result propagation
    #20;


        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0FFF) 
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
de_if.decoded_instr.imm = 12'hFF0;       // Negative offset (-16)

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


// Test 23: Unsupported opcode
de_if.decoded_instr.opcode = opcode_t'(8'hFF); // Explicit cast
de_if.decoded_instr.funct3 = F3_ADD_SUB;
@(posedge clk);
de_if.valid = 1'b1;
@(posedge clk);
de_if.valid = 1'b0;

#20;
if (em_if.alu_result !== 32'd0)
    $display("Test 23 Unsupported Opcode failed: result = %h", em_if.alu_result);
else
    $display("Test 23 Unsupported Opcode passed");



//Test 24: Zero Operand
de_if.decoded_instr.opcode = OPCODE_REG_REG;
de_if.decoded_instr.funct3 = F3_ADD_SUB;
de_if.decoded_instr.funct7 = F7_ADD_SRL; // ADD
de_if.decoded_instr.reg_A = 32'h0000_0000; 
de_if.decoded_instr.reg_B = 32'h0000_0005;
@(posedge clk);
de_if.valid = 1'b1;
@(posedge clk);
de_if.valid = 1'b0;

#20;
if (em_if.alu_result !== 32'h0000_0005)
    $display("Test 24 Zero Operand failed: result = %h", em_if.alu_result);
else
    $display("Test 24 Zero Operand passed");


//Test 25: JAL
de_if.decoded_instr.opcode = OPCODE_JAL;
de_if.decoded_instr.pc = 32'h0000_1000;
de_if.decoded_instr.imm = 12'h004; // Small forward jump
@(posedge clk);
de_if.valid = 1'b1;
@(posedge clk);
de_if.valid = 1'b0;

#20;
if (em_if.alu_result !== 32'h0000_1004)
    $display("Test 25 JAL Small Jump failed: result = %h", em_if.alu_result);
else
    $display("Test 25 JAL Small Jump passed");



//Test 26: NonAligned JALR
de_if.decoded_instr.opcode = OPCODE_JALR;
de_if.decoded_instr.reg_A = 32'h0000_1001; // Misaligned base
de_if.decoded_instr.imm = 12'h004; // Offset
@(posedge clk);
de_if.valid = 1'b1;
@(posedge clk);
de_if.valid = 1'b0;

#20;
if (em_if.alu_result !== 32'h0000_1004)
    $display("Test 26 JALR Non-Aligned failed: result = %h", em_if.alu_result);
else
    $display("Test 26 JALR Non-Aligned passed");


//Test 27: Boundary Conditions for Shifts
de_if.decoded_instr.opcode = OPCODE_REG_IMM;
de_if.decoded_instr.funct3 = F3_SRL_SRA;
de_if.decoded_instr.funct7 = F7_ADD_SRL; // SRLI
de_if.decoded_instr.reg_A = 32'h8000_0000;
de_if.decoded_instr.imm = 12'h01F; // Maximum shift
@(posedge clk);
de_if.valid = 1'b1;
@(posedge clk);
de_if.valid = 1'b0;

#20;
if (em_if.alu_result !== 32'h0000_0001)
    $display("Test 27 Maximum Shift failed: result = %h", em_if.alu_result);
else
    $display("Test 27 Maximum Shift passed");




        // Test 28: SLTI (Set Less Than Immediate, signed)
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_SLT;
        de_if.decoded_instr.reg_A = 32'h0000_0005; // Positive value
        de_if.decoded_instr.imm = 12'hFF5; // -11 in signed 12-bit immediate
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    #20;

        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0000) 
            $display("Test 28 (SLTI signed, A >= Immediate) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 28 (SLTI signed, A >= Immediate) passed");

        // Test 29: SLTI (Set Less Than Immediate, signed where A < Immediate)
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_SLT;
        de_if.decoded_instr.reg_A = 32'hFFFF_FFF5; // -11 in signed 32-bit
        de_if.decoded_instr.imm = 12'h0005; // 5 in signed 12-bit
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    #20;

        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0001) 
            $display("Test 29 (SLTI signed, A < Immediate) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 29 (SLTI signed, A < Immediate) passed");

        // Test 30: SLTIU (Set Less Than Immediate Unsigned)
        de_if.decoded_instr.opcode = OPCODE_REG_IMM;
        de_if.decoded_instr.funct3 = F3_SLTU;
        de_if.decoded_instr.reg_A = 32'h0000_0003; // Smaller unsigned
        de_if.decoded_instr.imm = 12'h0005; // Larger unsigned immediate
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    #20;

        // Check results
        #10;
        if (em_if.alu_result !== 32'h0000_0001) 
            $display("Test 30 (SLTIU unsigned) failed: result = %h", em_if.alu_result);
        else 
            $display("Test 30 (SLTIU unsigned) passed");

// Test 31: BEQ (Branch if Equal)
de_if.decoded_instr.opcode = OPCODE_BRANCH;
de_if.decoded_instr.funct3 = F3_ADD_SUB; // BEQ
de_if.decoded_instr.reg_A = 32'h0000_0001;
de_if.decoded_instr.reg_B = 32'h0000_0001; // Equal
@(posedge clk);
de_if.valid = 1'b1;
@(posedge clk);  // Allow 1 clock cycle for the ALU to process
de_if.valid = 1'b0;

// Wait for em_if.valid signal
wait (em_if.valid);
#10; // Stabilization time

// Check results
if (em_if.zero !== 1'b1) 
    $display("Test 31 (BEQ) failed: zero = %b", em_if.zero);
else 
    $display("Test 31 (BEQ) passed");

        // Test 32: BNE (Branch if Not Equal)
        de_if.decoded_instr.opcode = OPCODE_BRANCH;
        de_if.decoded_instr.funct3 = F3_OR; // BNE
        de_if.decoded_instr.reg_A = 32'h0000_000A;
        de_if.decoded_instr.reg_B = 32'h0000_000B; // Not equal

    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    #20;

        // Check results
        #10;
        if (em_if.zero !== 1'b1) 
            $display("Test 32 (BNE) failed: zero = %b", em_if.zero);
        else 
            $display("Test 32 (BNE) passed");

        // Test 33: BLT (Branch if Less Than, signed)
        de_if.decoded_instr.opcode = OPCODE_BRANCH;
        de_if.decoded_instr.funct3 = F3_SLT; // BLT
        de_if.decoded_instr.reg_A = 32'hFFFF_FFF5; // -11
        de_if.decoded_instr.reg_B = 32'h0000_0005; // 5
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    #20;

        // Check results
        #10;
        if (em_if.zero !== 1'b1) 
            $display("Test 33 (BLT) failed: zero = %b", em_if.zero);
        else 
            $display("Test 33 (BLT) passed");

        // Test 34: BLTU (Branch if Less Than Unsigned)
        de_if.decoded_instr.opcode = OPCODE_BRANCH;
        de_if.decoded_instr.funct3 = F3_SLTU; // BLTU
        de_if.decoded_instr.reg_A = 32'h0000_0003; // Smaller unsigned
        de_if.decoded_instr.reg_B = 32'h0000_0005; // Larger unsigned
    @(posedge clk);
    de_if.valid = 1'b1;
    @(posedge clk);  // Allow 1 clock cycle for the ALU to process
    de_if.valid = 1'b0;

    #20;

        // Check results
        #10;
        if (em_if.zero !== 1'b1) 
            $display("Test 34 (BLTU) failed: zero = %b", em_if.zero);
        else 
            $display("Test 34 (BLTU) passed");


        // End of tests
        #20;
        $stop;
    end

endmodule