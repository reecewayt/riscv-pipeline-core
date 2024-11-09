// tb/common/reg_pkg.sv
package reg_pkg;
    // Types and constants for register file verification
    typedef enum {
        READ_RS1,
        READ_RS2,
        WRITE_RD
    } reg_op_type_t;

    // Common parameters
    parameter int ADDR_WIDTH = 5;
    parameter int DATA_WIDTH = 32;
    
    // Status and result types
    typedef enum {
        TEST_PASS,
        TEST_FAIL,
        TEST_TIMEOUT
    } test_status_t;
endpackage: reg_pkg

