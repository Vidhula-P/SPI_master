// the driver models an SPI slave
class spi_driver extends uvm_driver #(spi_transaction);
  	// Register in factory
  	`uvm_component_utils(spi_driver)

  	// Actual interface object is later obtained by doing a get() call on uvm_config_db
  	virtual spi_bus_if vif;

  	function new (string name = "spi_driver", uvm_component parent = null);
    	super.new (name, parent);
  	endfunction

  	virtual function void build_phase (uvm_phase phase);
  		super.build_phase (phase);
     	if (! uvm_config_db #(virtual spi_bus_if) :: get (this, "", "vif", vif)) begin
     		`uvm_fatal (get_type_name (), "Didn't get handle to virtual interface if_name")
     	end
	endfunction
	
	// This is the main piece of driver code which decides how it has to translate
	// transaction level objects into pin wiggles at the DUT interface
	virtual task run_phase (uvm_phase phase);
		spi_transaction txn;
		//int data_length;

		vif.spi_miso = 1'b0;

		forever begin
			`uvm_info(get_type_name(), "Waiting for transaction...", UVM_MEDIUM)

			// Get next item from the sequencer
			seq_item_port.get_next_item (txn);

			@(negedge vif.spi_cs_n); // wait until start (cs_n pulled low)
			`uvm_info(get_type_name(), "CS asserted, starting transfer", UVM_HIGH)

			// Actively drive on MISO
			for (int i = DATA_LENGTH-1; i>=0; i--) begin
				@(negedge vif.spi_sck); // under mode 0, data is driven on falling edge
				vif.spi_miso = txn.tx_data[i];
			end

		seq_item_port.item_done();
		end
	endtask
	
endclass
