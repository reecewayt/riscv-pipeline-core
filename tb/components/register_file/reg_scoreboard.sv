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
                reg_transaction::READ_RS1: begin
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
                reg_transaction::READ_RS2: begin
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
                reg_transaction::WRITE_RD: begin
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

