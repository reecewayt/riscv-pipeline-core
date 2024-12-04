 ALU Test Implementation with Interfaces

 1. Overview
 1.1 DUT Information
Module: alu.sv  
Testbench: alu_tb.sv  
Key Interfaces:
- decode_execute_if.sv: Handles instruction decoding and control signals for the ALU.
- execute_memory_if.sv: Transfers ALU results and associated data to the memory stage.

Key Features:
- Arithmetic, logical, and shift operations for RISC-V instructions.
- Immediate and register-to-register operation support.
- Zero flag generation for branch decisions.
- Opcode-based operation execution.



 2. Test Implementation
 2.1 Components
Testbench (alu_tb.sv):
- Stimulates decode_execute_if interface inputs and verifies execute_memory_if outputs.
- Monitors and logs results for validation.

Interfaces:
1. decode_execute_if:
   - Inputs: decoded_instr (struct containing operands and opcode), valid, ready.
   - Outputs: Signals to ALU for operation execution.
   - Key Fields in decoded_instr:
     - rs1_data: First operand.
     - rs2_data: Second operand.
     - imm: Immediate value.
     - opcode: Specifies the ALU operation.

2. execute_memory_if:
   - Inputs: ALU computation results, zero flag, and opcode for memory stage decisions.
   - Outputs: Results and flags for further processing.
   - Key Signals:
     - alu_result: Final ALU computation result.
     - zero: Flag for branch decisions.

RISC-V Package (riscv_pkg.sv):
- Defines data types (opcode_t, decoded_instr_t) and constants (e.g., ADD, SUB, OR).



 3. Test Cases
 3.1 Register-to-Register Operations
Test 1: ADD Operation  
- Inputs:  
  - decoded_instr.rs1_data = 5  
  - decoded_instr.rs2_data = 3  
  - decoded_instr.opcode = ADD  
  - decode_execute_if.valid = 1  
- Expected Outputs:  
  - execute_memory_if.alu_result = 8  
  - execute_memory_if.zero = 0  
- Purpose: Verifies addition functionality.

Test 2: SUB Operation  
- Inputs:  
  - decoded_instr.rs1_data = 8  
  - decoded_instr.rs2_data = 3  
  - decoded_instr.opcode = SUB  
  - decode_execute_if.valid = 1  
- Expected Outputs:  
  - execute_memory_if.alu_result = 5  
  - execute_memory_if.zero = 0  
- Purpose: Verifies subtraction functionality.

Test 3: OR Operation  
- Inputs:  
  - decoded_instr.rs1_data = 0xA  
  - decoded_instr.rs2_data = 0x5  
  - decoded_instr.opcode = OR  
  - decode_execute_if.valid = 1  
- Expected Outputs:  
  - execute_memory_if.alu_result = 0xF  
  - execute_memory_if.zero = 0  
- Purpose: Verifies bitwise OR operation.

Test 4: AND Operation  
- Inputs:  
  - decoded_instr.rs1_data = 0xA  
  - decoded_instr.rs2_data = 0x5  
  - decoded_instr.opcode = AND  
  - decode_execute_if.valid = 1  
- Expected Outputs:  
  - execute_memory_if.alu_result = 0x0  
  - execute_memory_if.zero = 1  
- Purpose: Validates bitwise AND.

Test 5: SLT (Signed Comparison)  
- Inputs:  
  - decoded_instr.rs1_data = -11  
  - decoded_instr.rs2_data = 5  
  - decoded_instr.opcode = SLT  
  - decode_execute_if.valid = 1  
- Expected Outputs:  
  - execute_memory_if.alu_result = 1  
  - execute_memory_if.zero = 0  
- Purpose: Verifies signed less-than comparison.



 3.2 Register-to-Immediate Operations
Test 6: ADDI Operation  
- Inputs:  
  - decoded_instr.rs1_data = 5  
  - decoded_instr.imm = 3  
  - decoded_instr.opcode = ADDI  
  - decode_execute_if.valid = 1  
- Expected Outputs:  
  - execute_memory_if.alu_result = 8  
  - execute_memory_if.zero = 0  
- Purpose: Tests addition with immediate value.

Test 7: ORI Operation  
- Inputs:  
  - decoded_instr.rs1_data = 0xA  
  - decoded_instr.imm = 0x5  
  - decoded_instr.opcode = ORI  
  - decode_execute_if.valid = 1  
- Expected Outputs:  
  - execute_memory_if.alu_result = 0xF  
  - execute_memory_if.zero = 0  
- Purpose: Verifies OR with immediate value.



 4. Debug and Verification Process
1. Stimulus Application:
   - Generate test cases for all supported operations.
   - Apply stimuli using decode_execute_if.

2. Monitoring Outputs:
   - Capture results and flags from execute_memory_if.
   - Compare with expected results.

3. Success Criteria:
   - ALU outputs match expected values for all tests.
   - Zero flag is set correctly.
   - Interface handshaking (valid and ready signals) functions as expected.
