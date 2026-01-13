interface spi_host_if #(int DATA_LENGTH = 8) (input logic clk);
	logic rst_n;
	logic start;
	logic busy;
	logic done;
	logic [DATA_LENGTH-1:0] data_in;
	logic [DATA_LENGTH-1:0] data_out;
endinterface
