# Makefile for Xcelium SPI testbench

# Simulator
SIM = xrun

# Source files
RTL_SRC = ../rtl/spi_master.sv
TB_SRC  = ../tb/spi_slave_tb.sv
TOP     = spi_slave_tb

# Default target
all: run

# Default run without GUI
run:
	$(SIM) -svseed random $(RTL_SRC) $(TB_SRC)

# GUI run with full access
run_gui:
	$(SIM) -svseed random $(RTL_SRC) $(TB_SRC) -gui -access rwc

# Run with covergae
run_cover:
	$(SIM) -svseed random -coverage functional $(RTL_SRC) $(TB_SRC)

# Clean simulator files
clean:
	rm -rf xcelium.d xrun.*

.PHONY: all run run_gui clean
