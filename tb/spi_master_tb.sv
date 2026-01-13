// the testbench acts as both slave and host/CPU
// as slave, it reacts to miso and reports mosi
// as CPU, it sends data_in and 

class spi_transaction #(int DATA_LENGTH = 8);
	rand bit [DATA_LENGTH-1:0] tx_data; // data from CPU to send to slave
	rand bit [DATA_LENGTH-1:0] rx_data; // data from slave to CPU

	constraint tx_no_zero {tx_data != 8'h00;}
	constraint rx_no_zero {rx_data != 8'h00;}
endclass

module spi_master_tb;
    parameter DATA_LENGTH = 8;
    parameter CLK_DIV = 4;

	logic clk;
    spi_host_if hostIF(clk);
    spi_bus_if busIF(); // instantiating the bus interface

    bit [DATA_LENGTH-1:0] data_out_tb;
	bit [DATA_LENGTH-1:0] data_from_master;
    spi_transaction #(8) spi_obj;

    spi_master #(.DATA_LENGTH(DATA_LENGTH), .CLK_DIV(CLK_DIV)) s1(.hostIF(hostIF), .busIF(busIF) );

    initial clk = 0;
    always #5 clk = ~hostIF.clk;
    int i;

	// "cg" is a covergroup
	covergroup cg @ (posedge hostIF.clk);
		coverpoint busIF.spi_mosi;
		coverpoint busIF.spi_miso;
	endgroup

	cg  cg_inst;

    initial begin
		cg_inst= new();

    	hostIF.rst_n = 1;
    	hostIF.start = 0;
    	busIF.spi_miso = 0;

    	#1; hostIF.rst_n = 0;
    	#3; hostIF.rst_n = 1;
    	@(posedge hostIF.clk); #2; // avoid race

    	// Generate 5 random transactions
    	for (int t = 0; t < 5; t++) begin
        	spi_obj = new();
        	assert(spi_obj.randomize());
			//data_from_master = '0;

        	hostIF.data_in = spi_obj.tx_data;
        	data_out_tb = spi_obj.rx_data;

        	// Generate single-cycle start pulse
        	@(posedge hostIF.clk);
        	hostIF.start = 1;
        	@(posedge hostIF.clk);
        	hostIF.start = 0;

        	// Send MISO bits as slave, read MOSI bits as CPU 
        	for (int i = DATA_LENGTH-1; i >= 0; i--) begin
            	@(negedge busIF.spi_sck); // in mode 0, data is sent on negative edge
            	busIF.spi_miso = data_out_tb[i];
				@(posedge busIF.spi_sck); // in mode 0, data is sampled on positive edge
				data_from_master[i] = busIF.spi_mosi;
        	end

			$display("\n\nTransaction %0d", t+1);
        	$display("CPU- CPU to master: %0h", hostIF.data_in);
        	$display("SLAVE- master to slave: %0h, slave to master: %0h", data_from_master, data_out_tb);

        	// Wait for master to finish transaction
        	wait(hostIF.done);
        	@(posedge hostIF.clk); // one delay before next transaction
    	end
		$display ("Coverage = %0.2f %%", cg_inst.get_inst_coverage());
    	$finish;
	end
endmodule
