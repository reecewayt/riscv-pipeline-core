#####################################################################################
# RISCV Pipeline Core Top-Level Makefile
# Author: Reece Wayt
# Date: Fall 2024
# Sources: 
#   - Anthropic's Claude AI Assistant (claude.ai)
#   - Used for Makefile structure and pretty printing color codes (https://claude.ai)
#####################################################################################

# Force bash as shell and enable interpretation of backslash escapes
SHELL := /bin/bash
.SHELLFLAGS := -e -c

# Color codes for pretty printing
YELLOW := \033[1;33m
GREEN := \033[1;32m
RED := \033[1;31m
BLUE := \033[1;34m
NC := \033[0m # No Color

# Directory structure
RTL_DIR := rtl
TB_DIR := tb
COMMON_DIR := $(RTL_DIR)/common

# Directory structure for RTL
CORE_DIR := $(RTL_DIR)/core
FETCH_DIR := $(CORE_DIR)/fetch
DECODE_DIR := $(CORE_DIR)/decode
EXECUTE_DIR := $(CORE_DIR)/execute
MEMORY_DIR := $(CORE_DIR)/memory
WRITEBACK_DIR := $(CORE_DIR)/writeback

# Find all SystemVerilog files for the core
# ADD MORE DIRECTORIES HERE IF NEEDED
COMMON_FILES := $(shell find $(COMMON_DIR) -type f -name "*.sv" 2>/dev/null)
CORE_FILES := $(shell find $(RTL_DIR)/core $(RTL_DIR)/top -type f -name "*.sv" 2>/dev/null)
TB_COMMON_FILES := $(shell find $(TB_DIR)/common -type f -name "*.sv" 2>/dev/null)

# Top-level testbench file
TOP_TB := $(TB_DIR)/top/tb_top.sv
TB_TOP_MODULE = riscv_top_tb 		# Top-level testbench module

# Unit tests or module level testbenches
UNIT_TESTS := fetch decode alu register_file memory_access

# Compilation flags
VLOG_FLAGS := -sv \
              +incdir+$(COMMON_DIR)/packages \
              +incdir+$(COMMON_DIR)/interfaces \
              +incdir+$(TB_DIR)/common \
              -work work \
              +define+DEBUG

# GUI and wave options for top-level simulation
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

.DEFAULT_GOAL := help

# Main targets
compile: create_work compile_core compile_tb

compile_core:
	@printf "$(BLUE)Compiling RISCV core...$(NC)\n"
	@printf "$(BLUE)Compiling common packages and interfaces...$(NC)\n"
	@printf "Files to be compiled:\n"
	@for file in $(COMMON_FILES); do printf "  $$file\n"; done
	@vlog $(VLOG_FLAGS) $(COMMON_FILES) || (printf "$(RED)Common files compilation failed!$(NC)\n" && exit 1)
	@printf "$(BLUE)Compiling core RTL...$(NC)\n"
	@printf "Files to be compiled:\n"
	@for file in $(CORE_FILES); do printf "  $$file\n"; done
	@vlog $(VLOG_FLAGS) $(CORE_FILES) || (printf "$(RED)Core compilation failed!$(NC)\n" && exit 1)
	@printf "$(GREEN)Core compilation successful!$(NC)\n"

compile_tb:
	@printf "$(BLUE)Compiling testbench files...$(NC)\n"
	@printf "Files to be compiled:\n"
	@for file in $(TB_COMMON_FILES); do printf "  $$file\n"; done
	@printf "  $(TOP_TB)\n"
	@vlog $(VLOG_FLAGS) $(TB_COMMON_FILES) || (printf "$(RED)Testbench common files compilation failed!$(NC)\n" && exit 1)
	@vlog $(VLOG_FLAGS) $(TOP_TB) || (printf "$(RED)Top-level testbench compilation failed!$(NC)\n" && exit 1)
	@printf "$(GREEN)Testbench compilation successful!$(NC)\n"

simulate: compile
	@printf "$(BLUE)Starting top-level simulation...$(NC)\n"
	@printf "$(YELLOW)Running in $(if $(filter 1,$(GUI)),GUI,command-line) mode$(NC)\n"
	@vsim $(VSIM_FLAGS) work.$(TB_TOP_MODULE) || (printf "$(RED)Simulation failed!$(NC)\n" && exit 1)
	@printf "$(GREEN)Simulation completed successfully!$(NC)\n"

regression: compile
	@printf "$(BLUE)Running regression tests...$(NC)\n"
	@printf "$(YELLOW)=====================================\n$(NC)"
	@for d in $(TB_DIR)/tests/*; do \
		if [ -f "$$d/Makefile" ]; then \
			printf "$(BLUE)Running tests in $$d...$(NC)\n"; \
			if $(MAKE) -C $$d test; then \
				printf "$(GREEN)$$d execution complete$(NC)\n"; \
			else \
				printf "$(RED)$$d execution failed$(NC)\n"; \
				exit 1; \
			fi; \
			printf "$(YELLOW)=====================================\n$(NC)"; \
		fi \
	done
	@printf "$(GREEN)All regression tests executed, check output for errors$(NC)\n"

unit_test: 
	@if [ -z "$(TEST)" ]; then \
		printf "$(RED)Error: TEST parameter is required$(NC)\n"; \
		printf "$(BLUE)Usage: make unit_test TEST=<test_name>$(NC)\n"; \
		printf "$(BLUE)Available tests: $(UNIT_TESTS)$(NC)\n"; \
		exit 1; \
	fi
	@if ! echo "$(UNIT_TESTS)" | grep -w -q "$(TEST)"; then \
		printf "$(RED)Error: Invalid test name '$(TEST)'$(NC)\n"; \
		printf "$(BLUE)Available tests: $(UNIT_TESTS)$(NC)\n"; \
		exit 1; \
	fi
	@printf "$(BLUE)Running $(TEST) unit test...$(NC)\n"
	@case "$(TEST)" in \
		"fetch") $(MAKE) -C $(TB_DIR)/tests/fetch_tb test ;; \
		"decode") $(MAKE) -C $(TB_DIR)/tests/decode test ;; \
		"alu") $(MAKE) -C $(TB_DIR)/tests/alu_stage test ;; \
		"register_file") $(MAKE) -C $(TB_DIR)/tests/register_file test ;; \
		"memory_access") $(MAKE) -C $(TB_DIR)/tests/Memory_Access_stage test ;; \
		"writeback") $(MAKE) -C $(TB_DIR)/tests/Writeback_stage test ;; \
	esac

create_work:
	@if [ ! -d "work" ]; then \
		printf "$(BLUE)Creating work library...$(NC)\n"; \
		vlib work; \
	fi

clean:
	@printf "$(BLUE)Cleaning up build artifacts...$(NC)\n"
	@rm -rf work transcript vsim.wlf
	@printf "$(BLUE)Cleaning unit test directories...$(NC)\n"
	@for d in $(TB_DIR)/tests/*; do \
		if [ -f "$$d/Makefile" ]; then \
			printf "Cleaning $$d...\n"; \
			$(MAKE) -C $$d clean; \
		fi \
	done
	@printf "$(GREEN)Clean complete!$(NC)\n"

help:
	@printf "$(YELLOW)RISCV Pipeline Core Build System$(NC)\n"
	@printf "$(YELLOW)--------------------------------$(NC)\n"
	@printf "Main targets:\n"
	@printf "  $(GREEN)compile$(NC)    - Compile the RISCV core and top-level testbench\n"
	@printf "  $(GREEN)simulate$(NC)   - Run the top-level simulation\n"
	@printf "  $(GREEN)regression$(NC) - Run all unit tests\n"
	@printf "  $(GREEN)unit_test$(NC)  - Run a specific unit test (Usage: make unit_test TEST=<test_name>)\n"
	@printf "                Available tests: $(UNIT_TESTS)\n"
	@printf "  $(GREEN)clean$(NC)      - Clean all build artifacts\n"
	@printf "  $(GREEN)help$(NC)       - Show this help message\n"
	@printf "\n"
	@printf "Options:\n"
	@printf "  $(BLUE)GUI=1$(NC)     - Run simulation in GUI mode\n"
	@printf "  $(BLUE)WAVES=1$(NC)   - Enable waveform logging\n"
	@printf "\n"
	@printf "Examples:\n"
	@printf "  make simulate                # Run top-level simulation in command-line mode\n"
	@printf "  make simulate GUI=1 WAVES=1  # Run with GUI and waveforms\n"
	@printf "  make regression              # Run all unit tests\n"
	@printf "\n"

.PHONY: compile compile_core compile_tb simulate regression clean help create_work