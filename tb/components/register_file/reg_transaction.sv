///////////////////////////////////////////////////////////////////////////////
// Class: reg_transaction
// 
// Description: This class defines a transaction object that represents a single
//              register file operation. It supports three types of operations:
//              - Reading from RS1 port
//              - Reading from RS2 port
//              - Writing to RD port
//
// Parameters:
//   DATA_WIDTH: Width of the data bus (default: 32 bits for RISC-V)
//
// Usage:
//   reg_transaction trans = new();
//   void'(trans.randomize() with {op_type == READ_RS1;});
///////////////////////////////////////////////////////////////////////////////

class reg_transaction #(parameter DATA_WIDTH = 32);
    /////////////////// Transaction Types ///////////////////
    // Enumerated type defining possible register operations
    typedef enum {
        READ_RS1,    // Read from RS1 port
        READ_RS2,    // Read from RS2 port
        WRITE_RD     // Write to RD port
    } op_type_t;
    
    /////////////////// Transaction Fields ///////////////////
    // Operation type - determines what kind of register access to perform
    // This field can be randomized by the test
    rand op_type_t op_type;
    
    // Register address (5 bits for 32 registers)
    // This field can be randomized by the test
    rand logic [4:0] addr;
    
    // Data for write operations
    // This field can be randomized by the test
    rand logic [DATA_WIDTH-1:0] data;
    
    // Data read from register file
    // This field is filled by the driver during read operations
    logic [DATA_WIDTH-1:0] read_data;
    
    /////////////////// Constraints ///////////////////
    // Constraint: addr_c
    // Description: Ensures register addresses are valid (0-31)
    // Note: x0 is included even though it's read-only, as this is checked
    //       by the scoreboard, not constrained away
    constraint addr_c {
        addr inside {[0:31]};
    }
    
    /////////////////// Utility Methods ///////////////////
    // Function: print
    // Description: Displays transaction information for debug purposes
    // Format: "Transaction: op_type=<type> addr=<addr> data=<data>"
    function void print();
        string op_str;
        case(op_type)
            READ_RS1: op_str = "READ_RS1";
            READ_RS2: op_str = "READ_RS2";
            WRITE_RD: op_str = "WRITE_RD";
        endcase
        
        $display("Transaction: op_type=%s addr=%0d data=%0h", op_str, addr, data);
        
        // Print additional read data if this was a read operation
        if(op_type inside {READ_RS1, READ_RS2}) begin
            $display("          read_data=%0h", read_data);
        end
    endfunction
    
    /////////////////// Clone Method ///////////////////
    // Function: clone
    // Description: Creates a deep copy of the transaction
    // Returns: A new transaction object with identical field values
    // Usage: Used when transactions need to be copied between
    //        testbench components or stored for later comparison
    function reg_transaction clone();
        // Create new transaction object
        reg_transaction clone_trans = new();
        
        // Copy all field values
        clone_trans.op_type = this.op_type;
        clone_trans.addr = this.addr;
        clone_trans.data = this.data;
        clone_trans.read_data = this.read_data;
        
        return clone_trans;
    endfunction
    
    /////////////////// Constructor ///////////////////
    // Function: new
    // Description: Constructor for creating new transaction objects
    function new();
        // Constructor is empty as SystemVerilog automatically 
        // initializes all fields to their default values
    endfunction
    
    /////////////////// Optional: Helper Methods ///////////////////
    // Function: is_read
    // Description: Helper to check if this is a read transaction
    function bit is_read();
        return (op_type inside {READ_RS1, READ_RS2});
    endfunction
    
    // Function: is_write
    // Description: Helper to check if this is a write transaction
    function bit is_write();
        return (op_type == WRITE_RD);
    endfunction
    
    // Function: compare
    // Description: Compares this transaction with another
    // Returns: 1 if transactions match, 0 otherwise
    function bit compare(reg_transaction other);
        if(other == null) return 0;
        
        // For write transactions, compare addr and data
        if(this.is_write()) begin
            return (this.addr == other.addr) &&
                   (this.data == other.data) &&
                   (this.op_type == other.op_type);
        end
        // For read transactions, compare addr and read_data
        else begin
            return (this.addr == other.addr) &&
                   (this.read_data == other.read_data) &&
                   (this.op_type == other.op_type);
        end
    endfunction
    
endclass
