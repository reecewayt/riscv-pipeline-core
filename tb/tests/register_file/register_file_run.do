# Clean up and create work directory
if [file exists "work"] {vdel -all}
vlib work

# Compile packages first
vlog +define+DEBUG \
    +incdir+../../../../rtl/common/packages \
    +incdir+../../../../rtl/common/interfaces \
    ../../../../rtl/common/packages/riscv_pkg.sv \
    ../../../../tb/common/reg_file_test_pkg.sv

# Compile interface
vlog +define+DEBUG \
    +incdir+../../../../rtl/common/packages \
    ../../../../rtl/common/interfaces/register_file_if.sv

# Compile RTL
vlog +define+DEBUG \
    +incdir+../../../../rtl/common/packages \
    +incdir+../../../../rtl/common/interfaces \
    ../../../../rtl/core/decode/register_file.sv

# Compile testbench top
vlog +define+DEBUG \
    +incdir+../../../../rtl/common/packages \
    +incdir+../../../../rtl/common/interfaces \
    +incdir+../../../../tb/common \
    ../register_file_tb.sv

# Start simulation
vsim -c -voptargs=+acc work.register_file_tb
run -all
quit -f

