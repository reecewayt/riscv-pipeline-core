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
                reg_transaction::READ_RS1: begin
                    // Drive the RS1 address
                    vif.rs1_addr = trans.addr;
                    // Wait for combinational read to complete
                    @(negedge vif.clk);
                    // Capture read data
                    trans.read_data = vif.data_out_rs1;
                end
                
                // Reading from RS2 port
                reg_transaction::READ_RS2: begin
                    // Drive the RS2 address
                    vif.rs2_addr = trans.addr;
                    // Wait for combinational read to complete
                    @(negedge vif.clk);
                    // Capture read data
                    trans.read_data = vif.data_out_rs2;
                end
                
                // Writing to register file
                reg_transaction::WRITE_RD: begin
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