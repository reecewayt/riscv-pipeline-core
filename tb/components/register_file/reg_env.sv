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
    // Driver instance - converts transactions to pin-level signals
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