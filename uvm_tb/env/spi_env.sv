class spi_env extends uvm_env;
	`uvm_component_utils(spi_env)

	function new (string name = "spi_env", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	spi_agent agent;
	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		agent = spi_agent::type_id::create("agent", this);
	endfunction
endclass
