# Makefile for Xcelium SPI testbench

# Simulator
SIM = xrun
SIM_FLAGS = -sv \
            +incdir+../uvm_tb \
            +incdir+../uvm_tb/agent \
            +incdir+../uvm_tb/env \
            +incdir+../uvm_tb/seq \
            +incdir+../uvm_tb/test \
            +incdir+../uvm_tb/top \
            -uvm \
            -timescale 1ns/1ps

# Source files
PKG_SRC    = ../uvm_tb/spi_pkg.sv
INF_SRC	   = ../uvm_tb/spi_bus_if.sv
RTL_SRC    = ../rtl/spi_master.sv
TB_SRC     = ../tb/spi_master_tb.sv
UVM_TB_SRC = ../uvm_tb/top/tb_top.sv
TOP        = spi_slave_tb

# Default target
all: run_uvm

# Default run without GUI
run:
	$(SIM) -svseed random $(INF_SRC) $(RTL_SRC) $(TB_SRC)

# GUI run with full access
run_gui:
	$(SIM) -svseed random $(INF_SRC) $(RTL_SRC) $(TB_SRC) -gui -access rwc

# Run with covergae
run_cover:
	$(SIM) -svseed random -coverage functional $(INF_SRC) $(RTL_SRC) $(TB_SRC)

run_uvm:
	$(SIM) $(SIM_FLAGS) $(INF_SRC) $(PKG_SRC) $(RTL_SRC) $(UVM_TB_SRC)

# Clean simulator files
clean:
	rm -rf xcelium.d xrun.* cov_work waves.shm

.PHONY: all run run_gui clean
