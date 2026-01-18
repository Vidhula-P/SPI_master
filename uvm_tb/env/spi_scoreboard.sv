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
		`uvm_info("write", $sformatf("SCOREBOARD: miso_data = %h, mosi_data = %h", trans.miso_data, trans.mosi_data), UVM_MEDIUM)
	endfunction*/

	virtual task run_phase (uvm_phase phase);
		//super.run_phase(phase);
		spi_transaction prev_host_val, prev_slave_val, host_val, slave_val;
		forever begin
			wait (host_q.size() > 0 && slave_q.size() > 0);
			host_val = host_q.pop_front();
			slave_val = slave_q.pop_front();

			if (host_val.txn_id > 0) begin
				if (prev_host_val.miso_data != slave_val.mosi_data || prev_host_val.mosi_data != prev_slave_val.miso_data) begin
					`uvm_error("SPI_MISMACTH", $sformatf("Mismatch between master <-> slave data for transaction number [%0d]", prev_host_val.txn_id))
					`uvm_info("SPI_SB", $sformatf("HOST id=%0d tx=%0h rx=%0h | SLAVE id=%0d tx=%0h rx=%0h",
					      prev_host_val.txn_id, prev_host_val.miso_data, prev_host_val.mosi_data,
					      prev_slave_val.txn_id, prev_slave_val.miso_data, slave_val.mosi_data), UVM_MEDIUM)
					end else begin
					`uvm_info("SPI_MATCH", $sformatf("Transaction [%0d] passed", prev_host_val.txn_id), UVM_MEDIUM)
					`uvm_info("SPI_SB", $sformatf("HOST id=%0d tx=%0h rx=%0h | SLAVE id=%0d tx=%0h rx=%0h",
					      prev_host_val.txn_id, prev_host_val.miso_data, prev_host_val.mosi_data,
					      prev_slave_val.txn_id, prev_slave_val.miso_data, slave_val.mosi_data), UVM_MEDIUM)
					end
			end
			// since data received by slave is only received at the end of the cycle, 
			// it becomes available in time for next cycle

			prev_host_val = host_val;
			prev_slave_val = slave_val;
		end
	endtask
endclass
