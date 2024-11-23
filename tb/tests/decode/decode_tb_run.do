# Immediately check if we're in the correct directory
set CURRENT_DIR [file tail [pwd]]
puts "Current directory: [pwd]"

if {$CURRENT_DIR ne "riscv-pipeline-core"} {
    puts "\nERROR: This script must be run from the riscv-pipeline-core root directory!"
    puts "You are currently in: $CURRENT_DIR"
    puts "Please change to the riscv-pipeline-core directory and run this script again"
    puts "Example: cd /path/to/riscv-pipeline-core && vsim -c -do tb/tests/decode/decode_tb_run.do\n"
    quit -code 1
}

# Additional check for required directories
if {![file exists "rtl"] || ![file exists "tb"]} {
    puts "\nERROR: Required directories 'rtl' and 'tb' not found!"
    puts "Current directory contents: [glob -nocomplain *]"
    puts "Please make sure you're in the correct riscv-pipeline-core directory\n"
    quit -code 1
}


# Define base paths relative to the current directory
set PROJECT_ROOT [pwd]
set RTL_ROOT "$PROJECT_ROOT/rtl"
set TB_ROOT "$PROJECT_ROOT/tb"

puts "Using project root: $PROJECT_ROOT"
puts "RTL path: $RTL_ROOT"
puts "TB path: $TB_ROOT"

# Clean up and create work directory
if [file exists "work"] {vdel -all}
vlib work

# Compile packages first
vlog +define+DEBUG \
    +incdir+${RTL_ROOT}/common/packages \
    +incdir+${RTL_ROOT}/common/interfaces \
    ${RTL_ROOT}/common/packages/riscv_pkg.sv \
    ${TB_ROOT}/common/decode_test_pkg.sv

# Compile interfaces
vlog +define+DEBUG \
    +incdir+${RTL_ROOT}/common/packages \
    ${RTL_ROOT}/common/interfaces/fetch_decode_if.sv \
    ${RTL_ROOT}/common/interfaces/decode_execute_if.sv \
    ${RTL_ROOT}/common/interfaces/register_file_if.sv

# Compile RTL
vlog +define+DEBUG \
    +incdir+${RTL_ROOT}/common/packages \
    +incdir+${RTL_ROOT}/common/interfaces \
    ${RTL_ROOT}/core/decode/decode_unit.sv

# Compile testbench
vlog +define+DEBUG \
    +incdir+${RTL_ROOT}/common/packages \
    +incdir+${RTL_ROOT}/common/interfaces \
    +incdir+${TB_ROOT}/common \
    ${TB_ROOT}/tests/decode/decode_tb.sv

# Start simulation
vsim -c +access work.decode_tb
# Run simulation
run -all
# Exit simulation
quit -f
