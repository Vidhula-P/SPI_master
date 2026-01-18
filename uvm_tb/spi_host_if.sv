interface spi_host_if #(int DATA_LENGTH = 8) (input logic clk);
	logic rst_n;
	logic start;
	logic busy;
	logic done;
	logic [DATA_LENGTH-1:0] host_out;
	logic [DATA_LENGTH-1:0] host_in;
endinterface
