// tb/common/reg_pkg.sv
package reg_file_test_pkg;
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
    /////////////////// Transaction Types ///////////////////
    // Enumerated type defining possible register operations
    typedef enum {
        READ_RS1,    // Read from RS1 port
        READ_RS2,    // Read from RS2 port
        WRITE_RD     // Write to RD port
    } op_type_t;

    // Forward declarations of all classes
    typedef class reg_transaction;
    typedef class reg_driver;
    typedef class reg_monitor;
    typedef class reg_scoreboard;
    typedef class reg_env;
    
    class reg_transaction #(parameter DATA_WIDTH = 32);
    
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
    /////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////
    // Class: reg_driver
    // Description: Driver class that converts high-level register operations into 
    //              pin-level signals for the register file interface.
    //
    // The driver receives transactions through a mailbox and converts them into
    // actual signal transitions on the register file interface. It handles three
    // types of operations:
    // - Reading from RS1 port
    // - Reading from RS2 port
    // - Writing to RD port
    ///////////////////////////////////////////////////////////////////////////////

    class reg_driver;
        // Virtual interface handle - provides access to DUT pins
        // A virtual interface is a handle to an actual interface instance
        virtual register_file_if vif;
    
        // Mailbox for receiving transactions from the test
        // A mailbox is a thread-safe FIFO queue used for inter-process communication
        mailbox #(reg_transaction) mbx;
    
        /////////////////// Constructor ///////////////////
        // Parameters:
        // - vif: Virtual interface to drive signals to DUT
        // - mbx: Mailbox to receive transactions from test
        function new(virtual register_file_if vif, mailbox #(reg_transaction) mbx);
            this.vif = vif;
            this.mbx = mbx;
        endfunction
    
        /////////////////// Main Driver Task ///////////////////
        // This task runs forever, continuously processing transactions
        task run();
            // Transaction handle to store current transaction
            reg_transaction trans;
        
            // Infinite loop to keep processing transactions
            forever begin
                // Wait for next transaction from mailbox
                mbx.get(trans);
            
                // Synchronize to clock edge before driving signals
                @(posedge vif.clk);
            
                // Handle different operation types
                case(trans.op_type)
                    // Reading from RS1 port
                    READ_RS1: begin
                        // Drive the RS1 address
                        vif.rs1_addr = trans.addr;
                        // Wait for combinational read to complete
                        @(negedge vif.clk);
                        // Capture read data
                        trans.read_data = vif.data_out_rs1;
                    end
                
                    // Reading from RS2 port
                    READ_RS2: begin
                        // Drive the RS2 address
                        vif.rs2_addr = trans.addr;
                        // Wait for combinational read to complete
                        @(negedge vif.clk);
                        // Capture read data
                        trans.read_data = vif.data_out_rs2;
                    end
                
                    // Writing to register file
                    WRITE_RD: begin
                        // Set write enable and drive write data
                        vif.write_en = 1'b1;
                        vif.rd_addr = trans.addr;
                        vif.rd_data = trans.data;
                        // Hold for one clock cycle
                        @(negedge vif.clk);
                        // Clear write enable
                        vif.write_en = 1'b0;
                    end
                endcase
                // Print transaction details for debugging
                trans.print();
            end
        endtask
    endclass

    ///////////////////////////////////////////////////////////////////////////////
    // Class: reg_env
    // Description: Environment class that instantiates and connects all verification
    //              components for the register file testbench. This class serves as
    //              the top-level container for the verification environment.
    //
    // Verification Architecture:
    //                Test
    //                  │
    //                  ▼
    //         ┌─────Environment────┐
    //         │     (this class)   │
    //         │    ┌───────────────┤
    //         │    │    Driver     │◄──┐
    //         │    └───────────────┤   │
    //         │    ┌───────────────┤   │ drv_mbx
    //         │    │   Monitor     │   │
    //         │    └───────────────┤   │
    //         │    ┌───────────────┤   │
    //         │    │  Scoreboard   │   │
    //         │    └───────────────┤   │
    //         └────────────────────┘   │
    //                  │               │
    //                  ▼               │
    //                 DUT              │
    //                  │               │
    //                  └───────────────┘
    ///////////////////////////////////////////////////////////////////////////////

    class reg_env;
        /////////////////// Component Instances ///////////////////
        //  Driver instance - converts transactions to pin-level signals
        reg_driver driver;
    
        // Monitor instance - observes pin-level activity
        reg_monitor monitor;
    
        // Scoreboard instance - checks correctness of operations
        reg_scoreboard scoreboard;
    
        /////////////////// Communication Channels ///////////////////
        // Mailbox for sending transactions to driver
        // Used by test to send stimulus to driver
        mailbox #(reg_transaction) drv_mbx;
    
        // Mailbox for sending observed transactions to scoreboard
        // Used by monitor to send captured activity to scoreboard
        mailbox #(reg_transaction) mon_mbx;
    
        // Virtual interface handle - connection to DUT
        virtual register_file_if vif;
    
        /////////////////// Constructor ///////////////////
        // Function: new
        // Parameters:
        //   vif: Virtual interface handle for DUT connection
        // Description: Creates and connects all components of the environment
        function new(virtual register_file_if vif);
            // Store interface handle
            this.vif = vif;
        
            // Create communication channels
            drv_mbx = new();  // For test → driver communication
            mon_mbx = new();  // For monitor → scoreboard communication
        
            // Create and configure components
            driver = new(vif, drv_mbx);            // Driver needs interface and input mailbox
            monitor = new(vif, mon_mbx);           // Monitor needs interface and output mailbox
            scoreboard = new(mon_mbx);             // Scoreboard needs monitor mailbox for checking
        endfunction
    
        /////////////////// Run Task ///////////////////
        // Task: run
        // Description: Starts all components of the verification environment
        // Uses fork-join_none to start all components in parallel
        task run();
            fork
                // Start driver to process test transactions
                driver.run();
            
                // Start monitor to observe DUT behavior
                monitor.run();
            
                // Start scoreboard to check results
                scoreboard.run();
            join_none  // Allow all processes to run independently
        // Note: join_none allows the environment to return control
        // to the test while the components continue running
        endtask
    
        /////////////////// Optional: Debug Methods ///////////////////
        // Function: print_status
        // Description: Prints current status of all components
        function void print_status();
            $display("Environment Status:");
            $display("  Driver mailbox size: %0d", drv_mbx.num());
            $display("  Monitor mailbox size: %0d", mon_mbx.num());
            // Add more status information as needed
        endfunction
    
        // Task: wait_for_completion
        // Description: Waits for all transactions to complete
        task wait_for_completion();
            wait(drv_mbx.num() == 0);     // Wait for driver to process all transactions
            wait(mon_mbx.num() == 0);     // Wait for scoreboard to check all results
            #100;  // Additional time for any trailing activity
        endtask
    endclass

    ///////////////////////////////////////////////////////////////////////////////
    // Class: reg_monitor
    // Description: Monitor class that observes the register file interface and 
    //              captures both read and write operations. The monitor creates
    //              transactions for all register file activity and sends them to
    //              the scoreboard for verification.
    ///////////////////////////////////////////////////////////////////////////////


    class reg_monitor;
        /////////////////// Class Properties ///////////////////
        // Virtual interface handle
        virtual register_file_if vif;
        
        // Mailbox for sending transactions to scoreboard
        mailbox #(reg_transaction) mbx;
        
        // Statistics counters
        int num_writes = 0;
        int num_rs1_reads = 0;
        int num_rs2_reads = 0;
        
        /////////////////// Constructor ///////////////////
        function new(virtual register_file_if vif, mailbox #(reg_transaction) mbx);
            this.vif = vif;
            this.mbx = mbx;
        endfunction
        
        /////////////////// Main Monitor Task ///////////////////
        task run();
            // Print startup message
            $display("[MONITOR] Starting at time %0t", $time);
            
            // Main monitoring loop
            forever begin
                fork
                    // Monitor write operations
                    monitor_writes();
                    
                    // Monitor RS1 read operations
                    monitor_rs1_reads();
                    
                    // Monitor RS2 read operations
                    monitor_rs2_reads();
                join_none
                
                // Wait for next clock edge
                @(posedge vif.clk);
            end
        endtask
        
        /////////////////// Operation Monitoring Tasks ///////////////////
        // Task: monitor_writes
        // Description: Captures write operations on the interface
        protected task monitor_writes();
            reg_transaction trans;
            
            // Check for write operation
            if(vif.write_en) begin
                trans = new();
                trans.op_type = WRITE_RD;
                trans.addr = vif.rd_addr;
                trans.data = vif.rd_data;
                
                // Update statistics
                num_writes++;
                
                // Send to scoreboard
                mbx.put(trans);
                
                // Debug message
                print_operation(trans);
            end
        endtask
        
        // Task: monitor_rs1_reads
        // Description: Captures RS1 read operations
        protected task monitor_rs1_reads();
            reg_transaction trans;
            logic [4:0] prev_rs1_addr = 0;
            
            // Detect change in RS1 address
            if(vif.rs1_addr != prev_rs1_addr) begin
                trans = new();
                trans.op_type = READ_RS1;
                trans.addr = vif.rs1_addr;
                trans.read_data = vif.data_out_rs1;
                
                // Update statistics
                num_rs1_reads++;
                
                // Send to scoreboard
                mbx.put(trans);
                
                // Debug message
                print_operation(trans);
                
                // Update previous address
                prev_rs1_addr = vif.rs1_addr;
            end
        endtask
        
        // Task: monitor_rs2_reads
        // Description: Captures RS2 read operations
        protected task monitor_rs2_reads();
            reg_transaction trans;
            logic [4:0] prev_rs2_addr = 0;
            
            // Detect change in RS2 address
            if(vif.rs2_addr != prev_rs2_addr) begin
                trans = new();
                trans.op_type = READ_RS2;
                trans.addr = vif.rs2_addr;
                trans.read_data = vif.data_out_rs2;
                
                // Update statistics
                num_rs2_reads++;
                
                // Send to scoreboard
                mbx.put(trans);
                
                // Debug message
                print_operation(trans);
                
                // Update previous address
                prev_rs2_addr = vif.rs2_addr;
            end
        endtask
        
        /////////////////// Utility Functions ///////////////////
        // Function: print_operation
        // Description: Prints debug information for operations
        protected function void print_operation(reg_transaction trans);
            case(trans.op_type)
                WRITE_RD: begin
                    $display("[MONITOR] Time=%0t: Write to x%0d with data=%h",
                            $time, trans.addr, trans.data);
                end
                
                READ_RS1: begin
                    $display("[MONITOR] Time=%0t: RS1 Read from x%0d returned data=%h",
                            $time, trans.addr, trans.read_data);
                end
                
                READ_RS2: begin
                    $display("[MONITOR] Time=%0t: RS2 Read from x%0d returned data=%h",
                            $time, trans.addr, trans.read_data);
                end
            endcase
        endfunction
        
        // Function: get_statistics
        // Description: Reports monitoring statistics
        function void get_statistics();
            $display("[MONITOR] Statistics at time %0t:", $time);
            $display("  Total writes: %0d", num_writes);
            $display("  Total RS1 reads: %0d", num_rs1_reads);
            $display("  Total RS2 reads: %0d", num_rs2_reads);
        endfunction
        
        /////////////////// Coverage Collection ///////////////////
        covergroup reg_monitor_cov @(posedge vif.clk);
            // Write operation coverage
            wr_addr: coverpoint vif.rd_addr {
                bins zero = {0};                // x0 writes
                bins regs[4] = {[1:31]};        // Other registers
            }
            
            // RS1 read operation coverage
            rs1_addr: coverpoint vif.rs1_addr {
                bins zero = {0};
                bins regs[4] = {[1:31]};
            }
            
            // RS2 read operation coverage
            rs2_addr: coverpoint vif.rs2_addr {
                bins zero = {0};
                bins regs[4] = {[1:31]};
            }
            
            // Coverage crosses
            rd_rs1_cross: cross wr_addr, rs1_addr;
            rd_rs2_cross: cross wr_addr, rs2_addr;
            rs1_rs2_cross: cross rs1_addr, rs2_addr;
            
            // Write enable coverage
            write_en: coverpoint vif.write_en;
        endgroup
        
        /////////////////// Reset Handling ///////////////////
        protected task handle_reset();
            @(negedge vif.rst_n);
            
            // Clear statistics on reset
            num_writes = 0;
            num_rs1_reads = 0;
            num_rs2_reads = 0;
            
            $display("[MONITOR] Reset detected - statistics cleared");
            
            @(posedge vif.rst_n);
        endtask
    endclass 

    ///////////////////////////////////////////////////////////////////////////////
    // Class: reg_scoreboard
    // Description: Scoreboard for the register file verification. Maintains a golden
    //              reference model of the register file and checks all operations
    //              against this model. Key responsibilities include:
    //              - Maintaining reference register state
    //              - Checking read operations against expected values
    //              - Tracking writes to update reference model
    //              - Ensuring x0 remains 0
    //              - Collecting and reporting error statistics
    ///////////////////////////////////////////////////////////////////////////////
    class reg_scoreboard;
        /////////////////// Class Properties ///////////////////
        // Mailbox for receiving transactions from monitor
        mailbox #(reg_transaction) mbx;
        
        // Reference model of register file
        logic [31:0] reg_model[32];
        
        // Error tracking
        int num_errors = 0;
        int num_checks = 0;
        
        // Operation counters
        protected int write_count = 0;
        protected int rs1_read_count = 0;
        protected int rs2_read_count = 0;
        
        /////////////////// Constructor ///////////////////
        function new(mailbox #(reg_transaction) mbx);
            this.mbx = mbx;
            
            // Initialize reference model to reset state
            foreach(reg_model[i]) begin
                reg_model[i] = 32'h0;
            end
            
            // Print startup message
            $display("[SCOREBOARD] Created register file scoreboard");
        endfunction
        
        /////////////////// Main Task ///////////////////
        task run();
            reg_transaction trans;
            
            $display("[SCOREBOARD] Starting at time %0t", $time);
            
            forever begin
                // Get next transaction from monitor
                mbx.get(trans);
                
                // Process based on operation type
                case(trans.op_type)
                    /////////////////// RS1 Read Check ///////////////////
                    READ_RS1: begin
                        rs1_read_count++;
                        
                        if(trans.addr == 0) begin
                            // Check x0 reads
                            check_zero_reg(trans.read_data, "RS1");
                        end
                        else begin
                            // Check normal register reads
                            if(trans.read_data !== reg_model[trans.addr]) begin
                                report_error("RS1 Read Mismatch", trans.addr, 
                                        reg_model[trans.addr], trans.read_data);
                            end
                            else begin
                                report_success("RS1 Read", trans.addr, trans.read_data);
                            end
                        end
                    end
                    
                    /////////////////// RS2 Read Check ///////////////////
                    READ_RS2: begin
                        rs2_read_count++;
                        
                        if(trans.addr == 0) begin
                            // Check x0 reads
                            check_zero_reg(trans.read_data, "RS2");
                        end
                        else begin
                            // Check normal register reads
                            if(trans.read_data !== reg_model[trans.addr]) begin
                                report_error("RS2 Read Mismatch", trans.addr, 
                                        reg_model[trans.addr], trans.read_data);
                            end
                            else begin
                                report_success("RS2 Read", trans.addr, trans.read_data);
                            end
                        end
                    end
                    
                    /////////////////// Write Processing ///////////////////
                    WRITE_RD: begin
                        write_count++;
                        
                        // Update reference model (ignore x0 writes)
                        if(trans.addr != 0) begin
                            reg_model[trans.addr] = trans.data;
                            report_write(trans.addr, trans.data);
                        end
                        else begin
                            $info("[SCOREBOARD] Ignored write to x0: data=%h", trans.data);
                        end
                    end
                endcase
                
                // Update check count
                num_checks++;
            end
        endtask
        
        /////////////////// Utility Functions ///////////////////
        // Function: check_zero_reg
        // Description: Verifies x0 always reads as zero
        protected function void check_zero_reg(logic [31:0] data, string port);
            if(data !== 32'h0) begin
                num_errors++;
                $error("[SCOREBOARD] %s: Register x0 is non-zero: %h", port, data);
            end
        endfunction
        
        // Function: report_error
        // Description: Reports read mismatches
        protected function void report_error(string msg, logic [4:0] addr, 
                                        logic [31:0] exp, logic [31:0] got);
            num_errors++;
            $error("[SCOREBOARD] %s - Register x%0d:", msg, addr);
            $error("           Expected: %h", exp);
            $error("           Got:      %h", got);
            $error("           Diff:     %h", exp ^ got);
        endfunction
        
        // Function: report_success
        // Description: Reports successful reads
        protected function void report_success(string op, logic [4:0] addr, 
                                            logic [31:0] data);
            $info("[SCOREBOARD] %s Success - Register x%0d = %h", op, addr, data);
        endfunction
        
        // Function: report_write
        // Description: Reports register updates
        protected function void report_write(logic [4:0] addr, logic [31:0] data);
            $info("[SCOREBOARD] Write to Register x%0d = %h", addr, data);
        endfunction
        
        /////////////////// Status Reporting ///////////////////
        // Function: report_status
        // Description: Prints scoreboard statistics
        function void report_status();
            $display("\n=== Scoreboard Status at time %0t ===", $time);
            $display("Total Checks:     %0d", num_checks);
            $display("Total Errors:     %0d", num_errors);
            $display("Write Operations: %0d", write_count);
            $display("RS1 Reads:        %0d", rs1_read_count);
            $display("RS2 Reads:        %0d", rs2_read_count);
            $display("Error Rate:       %f%%", 
                    (num_errors * 100.0) / (num_checks > 0 ? num_checks : 1));
            print_reg_state();
        endfunction
        
        // Function: print_reg_state
        // Description: Dumps current register file state
        function void print_reg_state();
            $display("\n=== Register File State ===");
            foreach(reg_model[i]) begin
                $display("x%0d = %h", i, reg_model[i]);
            end
        endfunction
        
        /////////////////// TODO: Coverage Collection ///////////////////
        /*
        * Add coverage collection for the scoreboard here, these can be useful
        * in verifying we've covered all possible register file operations.
        */
    endclass

    // Test sequence class
    class reg_test_seq;
        virtual register_file_if vif;
        mailbox #(reg_transaction) drv_mbx;
        
        function new(virtual register_file_if vif, mailbox #(reg_transaction) drv_mbx);
            this.vif = vif;
            this.drv_mbx = drv_mbx;
        endfunction
        
        // Basic write-read sequence
        task write_read_test();
            reg_transaction trans;
            
            // Write to registers 1-5
            for(int i = 1; i <= 5; i++) begin
                trans = new();
                trans.op_type = WRITE_RD;
                trans.addr = i;
                trans.data = i * 32'h11111111;  // Unique pattern for each register
                drv_mbx.put(trans);
                #10;  // Wait for write to complete
                
                // Read back using RS1
                trans = new();
                trans.op_type = READ_RS1;
                trans.addr = i;
                drv_mbx.put(trans);
                #10;
                
                // Read back using RS2
                trans = new();
                trans.op_type = READ_RS2;
                trans.addr = i;
                drv_mbx.put(trans);
                #10;
            end
        endtask
        
        // Test x0 behavior
        task test_zero_register();
            reg_transaction trans;
            
            // Try to write to x0
            trans = new();
            trans.op_type = WRITE_RD;
            trans.addr = 0;
            trans.data = 32'hFFFFFFFF;
            drv_mbx.put(trans);
            #10;
            
            // Read x0 from both ports
            trans = new();
            trans.op_type = READ_RS1;
            trans.addr = 0;
            drv_mbx.put(trans);
            #10;
            
            trans = new();
            trans.op_type = READ_RS2;
            trans.addr = 0;
            drv_mbx.put(trans);
            #10;
        endtask
        
        // Concurrent read test
        task test_concurrent_reads();
            reg_transaction trans;
            
            // Write different values to two registers
            trans = new();
            trans.op_type = WRITE_RD;
            trans.addr = 1;
            trans.data = 32'hAAAAAAAA;
            drv_mbx.put(trans);
            #10;
            
            trans = new();
            trans.op_type = WRITE_RD;
            trans.addr = 2;
            trans.data = 32'h55555555;
            drv_mbx.put(trans);
            #10;
            
            // Read both simultaneously
            fork
                begin
                    trans = new();
                    trans.op_type = READ_RS1;
                    trans.addr = 1;
                    drv_mbx.put(trans);
                end
                begin
                    trans = new();
                    trans.op_type = READ_RS2;
                    trans.addr = 2;
                    drv_mbx.put(trans);
                end
            join
            #10;
        endtask
    endclass

endpackage

