// tb/tests/decode/decode_tb.sv
`timescale 1ns/1ps

module decode_tb;
    import riscv_pkg::*;
    import decode_test_pkg::*;

    // Clock generation
    logic clk = 0;
    always #5 clk = ~clk;

    // Interfaces
    fetch_decode_if fd_if(clk);
    decode_execute_if de_if(clk);
    register_file_if rf_if(clk);

    // DUT instantiation
    decode dut (
        .fd_if(fd_if),  // Connect fetch/decode interface
        .de_if(de_if),  // Connect decode/execute interface
        .rf_if(rf_if)   // Connect register file interface
    );

    // Test variables
    int error_count = 0;
    int test_count = 0;

    // Verification
    initial begin
        $display("Starting Decode Stage Tests");
        
        // Initialize signals
        fd_if.valid = 0;
        de_if.ready = 1;
        #10;

        // Run through test vectors
        foreach(DecodeTests::test_vectors[i]) begin
            test_count++;
            automatic test_instruction_t test = DecodeTests::test_vectors[i];
            
            // Drive test inputs
            @(posedge clk);
            fd_if.instruction = test.instruction;
            fd_if.pc = test.expected_pc;
            fd_if.valid = 1;
            rf_if.data_out_rs1 = test.reg_a_value;
            rf_if.data_out_rs2 = test.reg_b_value;

            // Wait for result
            @(posedge clk);
            @(negedge clk);

            // Verify outputs
            if (de_if.valid !== 1) begin
                $error("Test %s: Valid signal not asserted", test.test_name);
                error_count++;
            end

            if (de_if.decoded_instr.opcode !== test.expected_opcode) begin
                $error("Test %s: Opcode mismatch. Expected %h, Got %h", 
                    test.test_name, test.expected_opcode, de_if.decoded_instr.opcode);
                error_count++;
            end

            if (de_if.decoded_instr.rd !== test.expected_rd) begin
                $error("Test %s: RD mismatch. Expected %h, Got %h",
                    test.test_name, test.expected_rd, de_if.decoded_instr.rd);
                error_count++;
            end

            // Add more checks for other fields...

            $display("Test %s %s", test.test_name, (error_count == 0) ? "PASSED" : "FAILED");
        end

        // Test summary
        $display("\nTest Summary:");
        $display("Tests run: %0d", test_count);
        $display("Errors: %0d", error_count);
        $display(error_count == 0 ? "ALL TESTS PASSED" : "TESTS FAILED");
        
        $finish;
    end

    // Optional: Dump waveforms
    initial begin
        $dumpfile("decode_tb.vcd");
        $dumpvars(0, decode_tb);
    end

endmodule