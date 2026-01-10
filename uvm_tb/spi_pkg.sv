package spi_pkg;
	import uvm_pkg::*;
	
	parameter int DATA_LENGTH = 8; 

	`include "uvm_macros.svh"
	`include "agent/spi_transaction.sv"
	`include "agent/spi_driver.sv"
	`include "agent/spi_monitor.sv"
	`include "agent/spi_sequencer.sv"
	`include "seq/spi_sequence.sv"
	`include "env/spi_agent.sv"
	`include "env/spi_env.sv"
	`include "test/spi_test.sv"
endpackage
