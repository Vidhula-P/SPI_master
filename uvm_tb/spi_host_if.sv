interface spi_host_if #(int DATA_LENGTH = 8) (input logic clk);
	logic rst_n;
	logic start;
	logic busy;
	logic done;
	logic [DATA_LENGTH-1:0] host_out;
	logic [DATA_LENGTH-1:0] host_in;

	// clocking blocks for the TB
	clocking host_cb @(posedge clk);
        output rst_n, start, host_out;
        input busy, done, host_in;
    endclocking
endinterface
