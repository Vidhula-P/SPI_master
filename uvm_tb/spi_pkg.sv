package spi_pkg;
	import uvm_pkg::*;
	
	parameter int DATA_LENGTH = 8; // maximum length

	`include "uvm_macros.svh"
	`include "seq/spi_transaction.sv"
	`include "agent/spi_driver.sv"
	`include "env/spi_scoreboard.sv"
	`include "agent/spi_monitor.sv"
	`include "agent/host_monitor.sv"
	`include "agent/spi_sequencer.sv"
	`include "seq/spi_sequence.sv"
	`include "env/spi_agent.sv"
	`include "env/spi_env.sv"
	`include "test/spi_test.sv"
endpackage
