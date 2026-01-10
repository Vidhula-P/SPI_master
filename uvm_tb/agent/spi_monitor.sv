class spi_monitor extends uvm_monitor;
	// Add to factory
	`uvm_component_utils (spi_monitor)

	// Actual interface object is later obtained by doing a get() call on uvm_config_db
	virtual spi_bus_if vif;

	uvm_analysis_port  #(spi_transaction) mon_analysis_port;

	function new (string name = "spi_monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase (uvm_phase phase);
		super.build_phase (phase);

		// Create an instance of the declared analysis port
		mon_analysis_port = new ("mon_analysis_port", this);

		// Get virtual interface handle from the configuration DB
		if (! uvm_config_db #(virtual spi_bus_if) :: get (this, "", "vif", vif)) begin
			`uvm_error (get_type_name (), "DUT interface not found")
		end
	endfunction

	virtual task run_phase (uvm_phase phase);
		int i;
		int data_length;
		spi_transaction txn;
		forever begin
			@(negedge vif.spi_cs_n); // wait until start (cs_n pulled low)
			txn = spi_transaction::type_id::create("txn", this);
			//data_length = $bits(txn.rx_data);
			// sample data on rising edge of sck
			for (i = DATA_LENGTH-1; i>=0; i--) begin
				@(posedge vif.spi_sck); // under mode 0, data is sampled on rising edge
				txn.rx_data[i] = vif.spi_mosi;
			end

			// Send data object through the analysis port when cs_n pulled high
			@(posedge vif.spi_cs_n);
			mon_analysis_port.write(txn);
			//$strobe("Data from master to slave: %0h\nData from slave to master: %h",txn.rx_data, txn.tx_data);
		end
	endtask

endclass
