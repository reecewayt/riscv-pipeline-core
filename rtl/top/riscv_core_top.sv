// RISC-V Top Level Module
module riscv_top (
    input logic clk,
    input logic rst_n,
  fetch_decode_if fd_if,
  execute_memory_if em_if,
  memory_writeback_if mw_if,
  memory_fetch_if mf_if,
  decode_execute_if de_if,
  register_file_if rf_if
);


    // Pipeline stage instantiations
    instruction_fetch IF (
        .clk(clk),
        .rst_n(rst_n),
        .fetch_if(mf_if),
        .dec_if(fd_if),
        .mem_if(mw_if)
    );
  
  decode DECODE(.fd_if(fd_if),
                .de_if(de_if),
                .rf_if(rf_if)               
               );
  
  alu EXECUTE (.de_if(de_if),
               .em_if(em_if)
              );
  
  memory_access MEM_ACC(.clk(clk),
                        .rst_n(rst_n),
                        .mem_if(mw_if),
                        .fetch_if(mf_if),
                        .e_m_if(em_if)
                       );
  
  writeback_stage WB(.rf_write_if(rf_if),
                     .mw_if(mw_if)
                    );
  
  
endmodule  