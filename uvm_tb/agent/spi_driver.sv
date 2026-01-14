// the driver (as host) handles start and data_in
// the driver (as slave) handles Chip Select and sampling MISO from slave's tx_data set in sequencer

class spi_driver extends uvm_driver #(spi_transaction);
  	// Register in factory
  	`uvm_component_utils(spi_driver)

  	// Actual interface object is later obtained by doing a get() call on uvm_config_db
  	virtual spi_bus_if vif_bus;
  	virtual spi_host_if vif_host;

  	function new (string name = "spi_driver", uvm_component parent = null);
    	super.new (name, parent);
  	endfunction

  	virtual function void build_phase (uvm_phase phase);
  		super.build_phase (phase);
     	if (! uvm_config_db #(virtual spi_bus_if) :: get (this, "", "vif_bus", vif_bus)) begin
     		`uvm_fatal (get_type_name (), "Didn't get handle to virtual interface vif_bus")
     	end
     	if (! uvm_config_db #(virtual spi_host_if) :: get (this, "", "vif_host", vif_host)) begin
     		`uvm_fatal (get_type_name (), "Didn't get handle to virtual interface vif_host")
     	end
	endfunction
	
	// This is the main piece of driver code which decides how it has to translate
	// transaction level objects into pin wiggles at the DUT interface
	virtual task run_phase (uvm_phase phase);
		spi_transaction txn;
		// initial values
		vif_host.start = 0;
		vif_bus.spi_miso = 0;

		forever begin
			`uvm_info(get_type_name(), "Waiting for transaction...", UVM_MEDIUM)

			// Get next item from the sequencer
			seq_item_port.get_next_item (txn);

			// 1. Assert CS, start and set data from host CPU to master
			vif_bus.spi_cs_n <= 0;
			vif_host.start 	 <= 1;

			// 2. Drive bits
			vif_host.data_in = txn.rx_data; // send data as host to master
			for (int i = DATA_LENGTH-1; i>=0; i--) begin
				@(negedge vif_bus.spi_sck); // under mode 0, data is driven on falling edge
				vif_bus.spi_miso = txn.tx_data[i]; // send data as slave to master
			end

			// 3. Deassert CS, start
			@(negedge vif_bus.spi_sck);
			vif_bus.spi_cs_n <= 1;
			vif_host.start 	 <= 0;

			seq_item_port.item_done();
		end
	endtask
	
endclass
