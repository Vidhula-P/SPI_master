module tb_top;
	import uvm_pkg::*;
	import spi_pkg::*;
 
	logic clk;

	// SPI interfaces
	spi_host_if #(DATA_LENGTH) hostIF(clk);
	spi_bus_if busIF();

	// Instantiate DUT
	spi_master #(.DATA_LENGTH(DATA_LENGTH)) dut (.hostIF(hostIF),.busIF(busIF));

	// Handle external clock
	initial clk = 0;
	always #5 clk = ~clk;

	// Handle reset
	initial begin
		hostIF.rst_n = 1; // triggger negedge rst_n
		#1
		hostIF.rst_n = 0;
		#10
		hostIF.rst_n = 1;
	end

	// UVM configuration + test start
	initial begin
		uvm_config_db#(virtual spi_bus_if)::set(null, "*", "vif_bus", busIF);
		uvm_config_db#(virtual spi_host_if #(DATA_LENGTH))::set(null, "*", "vif_host", hostIF);;
		run_test("spi_test");
	end

endmodule

