#####################################################################################
# Register File Test Makefile
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

# Files needed for Register File test
PACKAGES := $(COMMON_DIR)/packages/riscv_pkg.sv \
            $(TB_DIR)/common/reg_file_test_pkg.sv

INTERFACES := $(COMMON_DIR)/interfaces/register_file_if.sv

RTL_FILES := $(RTL_DIR)/core/decode/register_file.sv

TB_FILES := register_file_tb.sv \
            $(TB_DIR)/common/register_file_scoreboard.sv

# Compilation flags with reduced verbosity
VLOG_FLAGS := -sv \
              -quiet \
              +incdir+$(COMMON_DIR)/packages \
              +incdir+$(COMMON_DIR)/interfaces \
              +incdir+$(TB_DIR)/common \
              -work work

# GUI and wave options
GUI ?= 0
WAVES ?= 0

ifeq ($(GUI),1)
    ifeq ($(WAVES),1)
        VSIM_FLAGS := -quiet -suppress 12110,8233,3829 -do "log -r /*; add wave -r /*; run -all"
    else
        VSIM_FLAGS := -quiet -suppress 12110,8233,3829 -do "run -all"
    endif
else
    ifeq ($(WAVES),1)
        VSIM_FLAGS := -c -quiet -suppress 12110,8233,3829 -do "log -r /*; run -all; quit -f"
    else
        VSIM_FLAGS := -c -quiet -suppress 12110,8233,3829 -do "run -all; quit -f"
    endif
endif

.DEFAULT_GOAL := test

# Main targets
test: create_work compile simulate

compile: check_environment
	@printf "$(BLUE)Compiling Register File test...$(NC)\n"
	@if ! vlog $(VLOG_FLAGS) $(PACKAGES) $(INTERFACES) $(RTL_FILES) $(TB_FILES); then \
		printf "$(RED)Compilation failed!$(NC)\n"; \
		exit 1; \
	fi
	@printf "$(GREEN)Compilation successful!$(NC)\n"

simulate:
	@printf "$(BLUE)Running Register File test...$(NC)\n"
	@printf "$(YELLOW)Running in $(if $(filter 1,$(GUI)),GUI,command-line) mode$(NC)\n"
	@if ! vsim $(VSIM_FLAGS) work.register_file_tb; then \
		printf "$(RED)Simulation failed!$(NC)\n"; \
		exit 1; \
	fi
	@printf "$(GREEN)Simulation completed successfully!$(NC)\n"

create_work:
	@if [ ! -d "work" ]; then \
		printf "$(BLUE)Creating work library...$(NC)\n"; \
		vlib work; \
	fi

check_environment:
	@if [ ! -f "$(RTL_DIR)/core/decode/register_file.sv" ]; then \
		printf "$(RED)ERROR: register_file.sv not found!\n"; \
		printf "Make sure you're running from the correct directory.\n"; \
		printf "Current directory: $(shell pwd)$(NC)\n"; \
		exit 1; \
	fi

clean:
	@printf "$(BLUE)Cleaning up Register File test artifacts...$(NC)\n"
	@rm -rf work transcript vsim.wlf
	@printf "$(GREEN)Clean complete!$(NC)\n"

help:
	@printf "$(YELLOW)Register File Test Build System$(NC)\n"
	@printf "$(YELLOW)---------------------------$(NC)\n"
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