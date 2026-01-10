class spi_host_transaction #(int DATA_LENGTH);
	rand bit [DATA_LENGTH-1:0] data_host_to_master;
endclass


module tb_top;
	import uvm_pkg::*;
	import spi_pkg::*;

	parameter DATA_LENGTH = 8;

	spi_bus_if spi_if(); // SPI interface
	logic clk, rst_n;
	bit start, busy, done;

	bit [DATA_LENGTH-1:0] data_in;
	bit [DATA_LENGTH-1:0] data_out;

	// Instantiate DUT
	spi_master #(.DATA_LENGTH(DATA_LENGTH)) dut (
		.clk(clk),
		.rst_n(rst_n),
		.data_in(data_in), 
		.data_out(data_out),
		.start(start),
		.busy(busy),
		.done(done),
		.spiIF(spi_if)
		);

	// create an object of spi_host_transaction class
	spi_host_transaction #(DATA_LENGTH) txn;

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
		txn = new();
	end

	always_ff @(negedge spi_if.spi_sck) begin
		if(start) begin
			assert(txn.randomize());
			data_in = txn.data_host_to_master;
		end
	end

	// Provide interface handle to UVM
	initial begin
		uvm_config_db#(virtual spi_bus_if)::set(null, "*", "vif", spi_if);;
		run_test("spi_test");
		if (done)
			$display("TOP- host to master: %0h, master to host: %h", data_in, data_out);
	end

endmodule

