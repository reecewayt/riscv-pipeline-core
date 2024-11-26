#####################################################################################
# Fetch Stage Test Makefile
# Author: Reece Wayt
# Date: Fall 2024
#####################################################################################

# Get root directory (3 levels up from test directory)
ROOT_DIR := $(shell pwd)/../../..

# Directory structure
RTL_DIR := $(ROOT_DIR)/rtl
TB_DIR := $(ROOT_DIR)/tb
COMMON_DIR := $(RTL_DIR)/common

# Color codes for pretty printing
YELLOW := \033[1;33m
GREEN := \033[1;32m
RED := \033[1;31m
BLUE := \033[1;34m
NC := \033[0m # No Color

# Files needed for fetch test
PACKAGES := $(COMMON_DIR)/packages/riscv_pkg.sv

INTERFACES := $(COMMON_DIR)/interfaces/fetch_decode_if.sv \
              $(COMMON_DIR)/interfaces/fetch_memory_interface.sv \
              $(COMMON_DIR)/interfaces/memory_writeback_if.sv

RTL_FILES := $(RTL_DIR)/core/fetch/instruction_memory.sv \
             $(RTL_DIR)/core/fetch/fetch_unit.sv

TB_FILES := fetch_tb.sv

# Compilation flags
VLOG_FLAGS := -sv \
              +incdir+$(COMMON_DIR)/packages \
              +incdir+$(COMMON_DIR)/interfaces \
              +incdir+$(TB_DIR)/common \
              -work work \
              +define+DEBUG

# GUI and wave options
GUI ?= 0
WAVES ?= 0

ifeq ($(GUI),1)
    ifeq ($(WAVES),1)
        VSIM_FLAGS := -do "log -r /*; add wave -r /*; run -all"
    else
        VSIM_FLAGS := -do "run -all"
    endif
else
    ifeq ($(WAVES),1)
        VSIM_FLAGS := -c -do "log -r /*; run -all; quit -f"
    else
        VSIM_FLAGS := -c -do "run -all; quit -f"
    endif
endif

.DEFAULT_GOAL := test

# Main targets
test: create_work compile simulate

compile: check_environment
	@printf "$(BLUE)Compiling fetch test...$(NC)\n"
	
	@printf "$(BLUE)Compiling packages...$(NC)\n"
	@vlog $(VLOG_FLAGS) $(PACKAGES) || (printf "$(RED)Package compilation failed!$(NC)\n" && exit 1)
	
	@printf "$(BLUE)Compiling interfaces...$(NC)\n"
	@vlog $(VLOG_FLAGS) $(INTERFACES) || (printf "$(RED)Interface compilation failed!$(NC)\n" && exit 1)
	
	@printf "$(BLUE)Compiling RTL...$(NC)\n"
	@vlog $(VLOG_FLAGS) $(RTL_FILES) || (printf "$(RED)RTL compilation failed!$(NC)\n" && exit 1)
	
	@printf "$(BLUE)Compiling testbench...$(NC)\n"
	@vlog $(VLOG_FLAGS) $(TB_FILES) || (printf "$(RED)Testbench compilation failed!$(NC)\n" && exit 1)
	
	@printf "$(GREEN)Compilation successful!$(NC)\n"

simulate:
	@printf "$(BLUE)Running fetch test...$(NC)\n"
	@printf "$(YELLOW)Running in $(if $(filter 1,$(GUI)),GUI,command-line) mode$(NC)\n"
	@vsim $(VSIM_FLAGS) work.instruction_fetch_tb || (printf "$(RED)Simulation failed!$(NC)\n" && exit 1)
	@printf "$(GREEN)Simulation completed successfully!$(NC)\n"

create_work:
	@if [ ! -d "work" ]; then \
		printf "$(BLUE)Creating work library...$(NC)\n"; \
		vlib work; \
	fi

check_environment:
	@if [ ! -f "$(RTL_DIR)/core/fetch/fetch_unit.sv" ]; then \
		printf "$(RED)ERROR: fetch_unit.sv not found!\n"; \
		printf "Make sure you're running from the correct directory.\n"; \
		printf "Current directory: $(shell pwd)$(NC)\n"; \
		exit 1; \
	fi

clean:
	@printf "$(BLUE)Cleaning up fetch test artifacts...$(NC)\n"
	@rm -rf work transcript vsim.wlf
	@printf "$(GREEN)Clean complete!$(NC)\n"

help:
	@printf "$(YELLOW)Fetch Test Build System$(NC)\n"
	@printf "$(YELLOW)--------------------$(NC)\n"
	@printf "Test Scenarios:\n"
	@printf "  1. Reset Behavior\n"
	@printf "  2. Simple Instruction Fetch\n"
	@printf "  3. Next Instruction\n"
	@printf "  4. Disable Read\n"
	@printf "  5. Re-enable Read\n"
	@printf "\n"
	@printf "Targets:\n"
	@printf "  $(GREEN)test$(NC)      - Run the full test (default)\n"
	@printf "  $(GREEN)compile$(NC)   - Just compile the test\n"
	@printf "  $(GREEN)simulate$(NC)  - Just run the simulation\n"
	@printf "  $(GREEN)clean$(NC)     - Clean build artifacts\n"
	@printf "  $(GREEN)help$(NC)      - Show this help message\n"
	@printf "\n"
	@printf "Options:\n"
	@printf "  $(BLUE)GUI=1$(NC)    - Run in GUI mode\n"
	@printf "  $(BLUE)WAVES=1$(NC)  - Enable waveform logging\n"
	@printf "\n"
	@printf "Example usage:\n"
	@printf "  make test              # Run in command-line mode\n"
	@printf "  make test GUI=1 WAVES=1 # Run with GUI and waveforms\n"

.PHONY: test compile simulate clean help check_environment create_work