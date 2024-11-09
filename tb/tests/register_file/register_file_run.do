# register_file_run.do
# Clean up the work directory
if [file exists "work"] {vdel -all}
vlib work

# Compile packages first
vlog +define+DEBUG \
    +incdir+../../rtl/common/packages \
    +incdir+../../rtl/common/interfaces \
    ../../rtl/common/packages/riscv_pkg.sv \
    ../../tb/common/reg_pkg.sv \
    ../../tb/common/test_pkg.sv

# Compile interfaces
vlog +define+DEBUG \
    +incdir+../../rtl/common/packages \
    ../../rtl/common/interfaces/register_file_if.sv

# Compile RTL
vlog +define+DEBUG \
    +incdir+../../rtl/common/packages \
    +incdir+../../rtl/common/interfaces \
    ../../rtl/core/decode/register_file.sv

# Compile testbench components
vlog +define+DEBUG \
    +incdir+../../rtl/common/packages \
    +incdir+../../rtl/common/interfaces \
    +incdir+../../tb/components/register_file \
    ../../tb/components/register_file/reg_transaction.sv \
    ../../tb/components/register_file/reg_driver.sv \
    ../../tb/components/register_file/reg_monitor.sv \
    ../../tb/components/register_file/reg_scoreboard.sv \
    ../../tb/components/register_file/reg_env.sv

# Compile testbench top
vlog +define+DEBUG \
    +incdir+../../rtl/common/packages \
    +incdir+../../rtl/common/interfaces \
    +incdir+../../tb/components/register_file \
    ../../tb/tests/register_file/register_file_tb.sv

# Start simulation in headless mode
vsim -c -voptargs=+acc work.register_file_tb

# Run simulation
run -all

# Report coverage and check results
coverage save register_file_coverage.ucdb
coverage report -output register_file_coverage.rpt

# Exit
quit -f