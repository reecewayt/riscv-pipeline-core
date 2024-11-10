# Test Plan for Register File (register_file.sv)
## Running the Tests
```bash
# From /riscv-pipeline-core/tb/tests/register_file/sim/ run:
 vsim -c -do ../register_file_run.do
``` 


## 1. Overview
### 1.1 DUT Information
- **Module**: `register_file.sv`
- **Interface**: `register_file_if.sv`
- **Key Features**:
  - 32 general-purpose registers (x0-x31)
  - Two read ports (RS1, RS2)
  - One write port
  - Register x0 hardwired to zero

## 2. Test Implementation
### 2.1 Components
1. **Interface** (`register_file_if.sv`)
   - Defines signals and modports for pipeline stages
   - Handles read/write port connections

2. **Test Driver** (`reg_file_test_pkg.sv`)
   - Contains test driver class
   - Maintains reference model
   - Drives interface signals
   - Verifies read/write operations

## 3. Test Cases
### 3.1 Basic Test
- Write sequential values to registers x0-x4
- Read back values using both RS1 and RS2 ports
- Verify x0 remains zero
- Verify other registers contain written values

### 3.2 Concurrent Test
- Write different patterns to x1 and x2
- Read both registers simultaneously
- Verify correct values read from both ports

## 4. Expected Behavior
### 4.1 Write Operations
- Values written on positive clock edge when write_en is high
- Writing to x0 has no effect
- Data persists until next write

### 4.2 Read Operations
- Asynchronous reads from both ports
- x0 always returns zero
- Other registers return last written value

## 5. Success Criteria
1. Reset sets all registers to zero
2. Write operations store correct values
3. Read operations return correct values
4. x0 always reads as zero
5. Concurrent reads work correctly

## 6. Debug Features
- Monitor statements for write operations
- Monitor statements for read operations
- Register file state display
- Error reporting for mismatches

## 7. Verification Process
1. Run basic test sequence
2. Run concurrent test sequence
3. Check error count
4. Display final register state


