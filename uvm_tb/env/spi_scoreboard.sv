// Host 	── spi_host_if	 ──▶ Scoreboard
// Monitor  ── analysis_port ──▶ Scoreboard

class spi_scoreboard extends uvm_scoreboard;
	`uvm_component_utils (spi_scoreboard)

	// Since we have two sources/ monitors
	`uvm_analysis_imp_decl(_host)
	`uvm_analysis_imp_decl(_slave)

	// Analysis import from monitor
	uvm_analysis_imp_host #(spi_transaction, spi_scoreboard) host_imp;
	uvm_analysis_imp_slave #(spi_transaction, spi_scoreboard) slave_imp;

	// FIFO queues
	spi_transaction host_q[$];
	spi_transaction slave_q[$];

	function new (string name = "spi_scoreboard", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	function void write_host(spi_transaction trans);
		host_q.push_back(trans);
	endfunction

	function void write_slave(spi_transaction trans);
		slave_q.push_back(trans);
	endfunction

	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		host_imp  = new("host_imp", this);
		slave_imp = new("slave_imp",   this);
	endfunction

	/*virtual function void write (spi_transaction trans);
		`uvm_info("write", $sformatf("SCOREBOARD: tx_data = %h, rx_data = %h", trans.tx_data, trans.rx_data), UVM_MEDIUM)
	endfunction*/

	virtual task run_phase (uvm_phase phase);
		//super.run_phase(phase);
		spi_transaction host_val, slave_val;
		forever begin
			wait (host_q.size() > 0 && slave_q.size() > 0);
			host_val = host_q.pop_front();
			slave_val = slave_q.pop_front();

			`uvm_info("SPI_SB", $sformatf("HOST id=%0d tx=%0h rx=%0h | SLAVE id=%0d tx=%0h rx=%0h", 
	host_val.txn_id, host_val.tx_data, host_val.rx_data, slave_val.txn_id, slave_val.tx_data, slave_val.rx_data), UVM_MEDIUM)

			/*if (host_val.tx_data !== slave_val.tx_data)
				`uvm_error("SPI_SB", "TX mismatch")

			if (host_val.rx_data !== slave_val.rx_data)
				`uvm_error("SPI_SB", "RX mismatch")*/
		end
	endtask
endclass
