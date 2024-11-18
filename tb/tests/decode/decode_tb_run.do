# Clean up and create work directory
if [file exists "work"] {vdel -all}
vlib work

# Compile packages first
vlog +define+DEBUG \
    +incdir+../../../../rtl/common/packages \
    +incdir+../../../../rtl/common/interfaces \
    ../../../../rtl/common/packages/riscv_pkg.sv \
    ../../../../tb/common/decode_test_pkg.sv

# Compile interfaces
vlog +define+DEBUG \
    +incdir+../../../../rtl/common/packages \
    ../../../../rtl/common/interfaces/fetch_decode_if.sv \
    ../../../../rtl/common/interfaces/decode_execute_if.sv \
    ../../../../rtl/common/interfaces/register_file_if.sv

# Compile RTL
vlog +define+DEBUG \
    +incdir+../../../../rtl/common/packages \
    +incdir+../../../../rtl/common/interfaces \
    ../../../../rtl/core/decode/decode_unit.sv

# Compile testbench
vlog +define+DEBUG \
    +incdir+../../../../rtl/common/packages \
    +incdir+../../../../rtl/common/interfaces \
    +incdir+../../../../tb/common \
    ../decode_tb.sv

# Start simulation
vsim -c -voptargs=+acc work.decode_tb

# Run simulation
run -all

# Exit simulation
quit -f