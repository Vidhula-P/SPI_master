module tb_top;
	import uvm_pkg::*;
	import spi_pkg::*;

	parameter DATA_LENGTH = 8;
 
	logic clk;

	// SPI interfaces
	spi_host_if hostIF(clk);
	spi_bus_if busIF();

	// Instantiate DUT
	spi_master #(.DATA_LENGTH(DATA_LENGTH)) dut (.hostIF(hostIF),.busIF(busIF));

	// create an object of spi_transaction class
	spi_transaction txn_host;

	// Handle external clock, reset and start chip select by pulling it down
	initial clk = 0;
	always #5 clk = ~clk;

	initial begin
		hostIF.start = 0;
		hostIF.rst_n = 1; // triggger negedge rst_n
		#1
		hostIF.rst_n = 0;
		#10
		hostIF.rst_n = 1;
		hostIF.start = 1; // trigger posedge rst_n
		txn_host = spi_transaction::type_id::create("txn_host");
	end

	always_ff @(negedge busIF.spi_sck) begin
		if(hostIF.start) begin
			//assert(txn_host.randomize());
			//hostIF.data_in = txn_host.tx_data; //data sent by host
			hostIF.data_in = 8'h13;
			txn_host.rx_data = hostIF.data_out; // data received by host
		end
	end

	// Provide interface handle to UVM
	initial begin
		uvm_config_db#(virtual spi_bus_if)::set(null, "*", "vif", busIF);
		uvm_config_db#(virtual spi_host_if)::set(null, "*", "vif_host", hostIF);;
		run_test("spi_test");
	end

endmodule

