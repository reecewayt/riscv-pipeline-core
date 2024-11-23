# Test Plan for Decode Unit (decode_unit.sv)

## Running the Tests
```bash
# From /riscv-pipeline-core
vsim -c -do /tb/tests/decode/decode_tb_run.do
```

## 1. Overview
### 1.1 DUT Information
- **Module**: `decode_unit.sv`
- **Interfaces**: 
  - `fetch_decode_if.sv`
  - `decode_execute_if.sv`
  - `register_file_if.sv`
- **Key Features**:
  - Full RISC-V RV32I instruction decoding
  - Immediate value generation
  - Control signal generation
  - Register address extraction (RS1, RS2, RD)
  - Single-cycle combinational decode

## 2. Test Implementation
### 2.1 Components
1. **Interfaces**
   - `fetch_decode_if.sv`: Handles instruction and PC input from fetch stage
   - `decode_execute_if.sv`: Provides decoded instruction to execute stage
   - `register_file_if.sv`: Manages register file access
2. **Test Driver** (`decode_test_pkg.sv`)
   - Contains test vectors for all instruction types
   - Handles instruction generation
   - Verifies decode outputs

## 3. Test Cases
### 3.1 R-type Instructions
- **Test**: ADD x1, x2, x3
- **Status**: PASSED
- **Verification Points**:
  - Opcode correctly identified (OPCODE_REG_REG)
  - Register fields properly extracted (rd=1, rs1=2, rs2=3)
  - Function fields decoded (funct3=0, funct7=0)

### 3.2 I-type Instructions
- **Test**: ADDI x1, x2, 12
- **Status**: PASSED
- **Verification Points**:
  - Opcode correctly identified (OPCODE_REG_IMM)
  - Register fields properly extracted (rd=1, rs1=2)
  - Immediate value correctly sign-extended (imm=12)

### 3.3 S-type Instructions
- **Test**: SW x2, 16(x3)
- **Status**: PASSED
- **Verification Points**:
  - Opcode correctly identified (OPCODE_STORE)
  - Register fields properly extracted (rs1=3, rs2=2)
  - Store immediate correctly assembled (imm=16)

### 3.4 B-type Instructions
- **Test**: BEQ x1, x2, 8
- **Status**: PASSED
- **Verification Points**:
  - Opcode correctly identified (OPCODE_BRANCH)
  - Register fields properly extracted (rs1=1, rs2=2)
  - Branch immediate correctly assembled (imm=8)

### 3.5 U-type Instructions
- **Test**: LUI x1, 0x12345
- **Status**: PASSED
- **Verification Points**:
  - Opcode correctly identified (OPCODE_LUI)
  - Register fields properly extracted (rd=0)
  - Upper immediate correctly shifted (imm=0x12345000)

### 3.6 J-type Instructions
- **Test**: JAL x1, 16
- **Status**: PASSED
- **Verification Points**:
  - Opcode correctly identified (OPCODE_JAL)
  - Register fields properly extracted (rd=0)
  - Jump immediate correctly assembled (imm=16)

## 4. Expected Behavior
### 4.1 Decode Operations
- Instruction fields properly extracted based on type
- Immediate values correctly sign-extended
- Register addresses properly identified
- Valid signal asserted for valid instructions

## 5. Success Criteria
1. All instruction types correctly decoded
2. Proper immediate value generation
3. Correct register field extraction
4. Valid signal properly managed
5. Ready signal always high (combinational decode)

## 6. Test Results
- **Total Tests Run**: 6
- **Tests Passed**: 6
- **Tests Failed**: 0
- **Code Coverage**: All instruction types covered
- **Time**: 130ns simulation time

## 7. Debug Features
- Waveform generation (`decode_tb.vcd`)
- Detailed error reporting for mismatches
- Test status display for each instruction type

## 8. Verification Process
1. Initialize all interfaces
2. Run test vector sequence
3. Verify outputs against expected values
4. Display test results
5. Generate final status report

## 9. Conclusion
The decode unit successfully passed all test cases, demonstrating correct functionality for all RISC-V RV32I instruction types. The combinational implementation shows proper handling of instruction decoding with no timing issues observed.

**Terminal Output Below**
```bash
 vsim -c "+access" work.decode_tb
# Start time: 14:24:22 on Nov 18,2024
# ** Note: (vsim-3812) Design is being optimized...
# //  Questa Sim-64
# //  Version 2024.2 linux_x86_64 May 20 2024
# //
# // Unpublished work. Copyright 2024 Siemens
# //
# // This material contains trade secrets or otherwise confidential information
# // owned by Siemens Industry Software Inc. or its affiliates (collectively,
# // "SISW"), or its licensors. Access to and use of this information is strictly
# // limited as set forth in the Customer's applicable agreements with SISW.
# //
# // This material may not be copied, distributed, or otherwise disclosed outside
# // of the Customer's facilities without the express written permission of SISW,
# // and may not be used in any way not expressly authorized by SISW.
# //
# Loading sv_std.std
# Loading work.riscv_pkg(fast)
# Loading work.decode_execute_if_sv_unit(fast)
# Loading work.fetch_decode_if_sv_unit(fast)
# Loading work.decode_test_pkg(fast)
# Loading work.decode_tb(fast)
# Starting Decode Stage Tests
# Test R-type ADD PASSED
# Test I-type ADDI PASSED
# Test S-type SW PASSED
# Test B-type BEQ PASSED
# Test U-type LUI PASSED
# Test J-type JAL PASSED
#
# Test Summary:
# Tests run: 6
# Errors: 0
#  86795978311779806840407650927742502212
# ** Note: $finish    : /home/reecwayt/common/Documents/ece571/riscv-pipeline-core/tb/tests/decode/decode_tb.sv(84)
#    Time: 130 ns  Iteration: 1  Instance: /decode_tb
# End time: 14:24:24 on Nov 18,2024, Elapsed time: 0:00:02
# Errors: 0, Warnings: 0
```