class host_monitor extends uvm_monitor;

	`uvm_component_utils (host_monitor)

	// Actual interface object is later obtained by doing a get() call on uvm_config_db
	virtual spi_host_if #(DATA_LENGTH) vif_host;

	uvm_analysis_port  #(spi_transaction) host_analysis_port;

	function new (string name = "host_monitor", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase (uvm_phase phase);
		super.build_phase (phase);

		// Create an instance of the declared analysis port
		host_analysis_port = new ("host_analysis_port", this);

		// Get virtual interface handle from the configuration DB
		if (! uvm_config_db #(virtual spi_host_if #(DATA_LENGTH)) :: get (this, "", "vif_host", vif_host)) begin
			`uvm_error (get_type_name (), "DUT interface not found")
		end
	endfunction

	virtual task run_phase (uvm_phase phase);
		int next_id;
		spi_transaction txn;
		next_id = 0;
		forever begin
			@(posedge vif_host.done); // wait for rising edge
			txn = spi_transaction::type_id::create("txn", this);
			txn.tx_data = vif_host.data_in;
			txn.rx_data = vif_host.data_out;
			txn.txn_id  = next_id;
			host_analysis_port.write(txn);
			next_id = next_id + 1;
		end
	endtask

endclass
