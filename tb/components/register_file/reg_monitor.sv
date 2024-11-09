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
            trans.op_type = reg_transaction::WRITE_RD;
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
            trans.op_type = reg_transaction::READ_RS1;
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
            trans.op_type = reg_transaction::READ_RS2;
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
            reg_transaction::WRITE_RD: begin
                $display("[MONITOR] Time=%0t: Write to x%0d with data=%h",
                         $time, trans.addr, trans.data);
            end
            
            reg_transaction::READ_RS1: begin
                $display("[MONITOR] Time=%0t: RS1 Read from x%0d returned data=%h",
                         $time, trans.addr, trans.read_data);
            end
            
            reg_transaction::READ_RS2: begin
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