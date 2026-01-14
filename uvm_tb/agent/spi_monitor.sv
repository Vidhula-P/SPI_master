class spi_monitor extends uvm_monitor;
	// Add to factory
	`uvm_component_utils (spi_monitor)

	// Actual interface object is later obtained by doing a get() call on uvm_config_db
	virtual spi_bus_if vif_bus;

	uvm_analysis_port  #(spi_transaction) mon_analysis_port;

	// covergroup to capture functional coverage
	int txn_id_cp;
	logic [DATA_LENGTH-1:0] tx_data_cp, rx_data_cp;
	covergroup cg_inst;
		coverpoint tx_data_cp;
		coverpoint rx_data_cp;
		coverpoint txn_id_cp;
	endgroup 

	virtual function void build_phase (uvm_phase phase);
		super.build_phase (phase);

		// Create an instance of the declared analysis port
		mon_analysis_port = new ("mon_analysis_port", this);

		// Get virtual interface handle from the configuration DB
		if (! uvm_config_db #(virtual spi_bus_if) :: get (this, "", "vif_bus", vif_bus)) begin
			`uvm_error (get_type_name (), "DUT interface not found")
		end	
	endfunction

	function new (string name = "spi_monitor", uvm_component parent = null);
		super.new(name, parent);
		 cg_inst = new();
	endfunction

	virtual task run_phase (uvm_phase phase);
		int i, next_id;
		spi_transaction txn;
		next_id = 0;
		forever begin
			@(negedge vif_bus.spi_cs_n); // wait until start (cs_n pulled low)
			txn = spi_transaction::type_id::create("txn", this);
			txn.tx_data = '0;
			txn.rx_data = '0;
			@(posedge vif_bus.spi_sck); // ignore first posedge since driver updates on negedge
			// sample data on rising edge of sck
			for (i = DATA_LENGTH-1; i>=0; i--) begin
				@(posedge vif_bus.spi_sck); // under mode 0, data is sampled on rising edge
				txn.tx_data[i] = vif_bus.spi_miso;
				txn.rx_data[i] = vif_bus.spi_mosi;
			end
			txn.txn_id = next_id;
			next_id = next_id + 1;

			// send to coverage
			txn_id_cp = txn.txn_id;
			tx_data_cp = txn.tx_data;
			rx_data_cp = txn.rx_data;
			cg_inst.sample();

			// Send data object through the analysis port before cs_n pulled high
			mon_analysis_port.write(txn);
			//@(posedge vif_bus.spi_cs_n)
		end
	endtask

	virtual function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(), $sformatf("SPI monitor coverage = %0.2f%%", cg_inst.get_inst_coverage()), UVM_LOW)
	endfunction

endclass
