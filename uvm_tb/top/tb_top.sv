module tb_top;
	import uvm_pkg::*;
	import spi_pkg::*;

	parameter DATA_LENGTH = 8;

	spi_bus_if spi_if(); // SPI interface
	logic clk, rst_n;
	bit start, busy, done;

	// Instantiate DUT
	spi_master #(.DATA_LENGTH(DATA_LENGTH)) dut (
		.clk(clk),
		.rst_n(rst_n),
		.data_in(8'hAA), // for now, fixed value
		.data_out(), // only check master to slave for now
		.start(start),
		.busy(busy),
		.done(done),
		.spiIF(spi_if)
		);

	// Handle external clock, reset and start chip select by pulling it down
	initial clk = 0;
	always #5 clk = ~clk;

	initial begin
		start = 0;
		rst_n = 1; // triggger negedge rst_n
		#1
		rst_n = 0;
		#10
		rst_n = 1;
		start = 1; // trigger posedge rst_n
	end

	// Provide interface handle to UVM
	initial begin
		uvm_config_db#(virtual spi_bus_if)::set(null, "*", "vif", spi_if);;
		run_test("spi_test");
	end

endmodule

