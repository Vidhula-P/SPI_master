class spi_agent extends uvm_agent;
	`uvm_component_utils(spi_agent)

	spi_sequencer sequencer;
	spi_driver	  driver;
	spi_monitor	  monitor;

	virtual spi_bus_if vif;

	function new(string name = "spi_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get interface
		if (!uvm_config_db#(virtual spi_bus_if)::get(this, "", "vif", vif))
			`uvm_fatal(get_type_name(), "spi_bus_if not found")

		// Monitor is always created
		monitor = spi_monitor::type_id::create("monitor", this);

		// Sequencer and driver are created in active agent
		if(is_active == UVM_ACTIVE) begin //active by deafault so no need to change
			sequencer = spi_sequencer::type_id::create("sequencer", this);
			driver	  = spi_driver::type_id::create("driver", this);
		end
	endfunction

	//connect driver to sequencer in the connect phase
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(is_active == UVM_ACTIVE)
			driver.seq_item_port.connect(sequencer.seq_item_export);
	endfunction
endclass
