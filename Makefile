#####################################################################################
# RISCV Pipeline Core Makefile
# Author: Reece Wayt
# Date: Fall 2024
#####################################################################################
# Directory Structure
RTL_DIR = rtl
TB_DIR = tb
COMMON_DIR = $(RTL_DIR)/common
CORE_DIR = $(RTL_DIR)/core

# Pipeline Stages
FETCH_DIR = $(CORE_DIR)/fetch
DECODE_DIR = $(CORE_DIR)/decode
EXECUTE_DIR = $(CORE_DIR)/execute
MEMORY_DIR = $(CORE_DIR)/memory
WRITEBACK_DIR = $(CORE_DIR)/writeback

# Find all SystemVerilog files
COMMON_FILES = $(wildcard $(COMMON_DIR)/**/*.sv)
FETCH_FILES = $(wildcard $(FETCH_DIR)/*.sv)
DECODE_FILES = $(wildcard $(DECODE_DIR)/*.sv)
EXECUTE_FILES = $(wildcard $(EXECUTE_DIR)/*.sv)
MEMORY_FILES = $(wildcard $(MEMORY_DIR)/*.sv)
WRITEBACK_FILES = $(wildcard $(WRITEBACK_DIR)/*.sv)
TB_FILES = $(wildcard $(TB_DIR)/**/*.sv)

# Default to 'none' for TOP_MODULE
TOP_MODULE ?= none

# Compilation and simulation flags
VLOG_FLAGS = -sv +incdir+$(COMMON_DIR) -work work
VSIM_FLAGS = -c -do "run -all; quit"

# Determine files to compile based on STAGE
ifeq ($(STAGE),fetch)
    STAGE_FILES = $(COMMON_FILES) $(FETCH_FILES)
else ifeq ($(STAGE),decode)
    STAGE_FILES = $(COMMON_FILES) $(DECODE_FILES)
else ifeq ($(STAGE),execute)
    STAGE_FILES = $(COMMON_FILES) $(EXECUTE_FILES)
else ifeq ($(STAGE),memory)
    STAGE_FILES = $(COMMON_FILES) $(MEMORY_FILES)
else ifeq ($(STAGE),writeback)
    STAGE_FILES = $(COMMON_FILES) $(WRITEBACK_FILES)
else ifeq ($(STAGE),all)
    STAGE_FILES = $(COMMON_FILES) $(FETCH_FILES) $(DECODE_FILES) $(EXECUTE_FILES) $(MEMORY_FILES) $(WRITEBACK_FILES)
endif

# Add testbench files if TOP_MODULE is specified and not 'none'
ifneq ($(TOP_MODULE),none)
    STAGE_FILES += $(TB_FILES)
endif

# Default to help
.DEFAULT_GOAL := help

# Main targets
compile:
	@if [ -z "$(STAGE)" ]; then \
		echo "Error: STAGE parameter is required"; \
		echo "Run 'make help' for usage information"; \
		exit 1; \
	fi
	@$(MAKE) check_stage
	@echo "Compiling $(STAGE) stage..."
	vlog $(VLOG_FLAGS) $(STAGE_FILES)

simulate: compile
	@if [ "$(TOP_MODULE)" = "none" ]; then \
		echo "Skipping simulation (no TOP_MODULE specified)"; \
	else \
		echo "Simulating $(TOP_MODULE)..."; \
		vsim $(VSIM_FLAGS) work.$(TOP_MODULE); \
	fi

# Validation
check_stage:
	@if ! echo "fetch decode execute memory writeback all" | grep -w "$(STAGE)" > /dev/null; then \
		echo "Error: Invalid stage '$(STAGE)'"; \
		echo "Valid stages are: fetch, decode, execute, memory, writeback, all"; \
		exit 1; \
	fi

clean:
	rm -rf work
	rm -f transcript
	rm -f vsim.wlf

help:
	@echo "RISCV Pipeline Core Build System"
	@echo "--------------------------------"
	@echo "Usage:"
	@echo "  make STAGE=<stage> TOP_MODULE=<module> [target]"
	@echo ""
	@echo "Required Parameters:"
	@echo "  STAGE=<stage>     - Pipeline stage to build (fetch|decode|execute|memory|writeback|all)"
	@echo "  TOP_MODULE=<mod>  - Top-level module for simulation (optional)"
	@echo ""
	@echo "Targets:"
	@echo "  compile     - Only compile the specified stage"
	@echo "  simulate    - Compile and simulate the specified stage"
	@echo "  clean       - Remove generated files"
	@echo "  help       - Display this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make STAGE=fetch compile                        # Just compile fetch stage"
	@echo "  make STAGE=fetch TOP_MODULE=tb_fetch simulate   # Compile and simulate fetch"
	@echo "  make STAGE=all TOP_MODULE=tb_top simulate       # Full pipeline simulation"

.PHONY: compile simulate clean help check_stage