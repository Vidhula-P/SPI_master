class spi_test extends uvm_test;
	`uvm_component_utils(spi_test)

	function new (string name="spi_test", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	spi_env env;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = spi_env::type_id::create("env", this);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction

	virtual task run_phase(uvm_phase phase);
		spi_sequence seq = spi_sequence::type_id::create("seq");
		//super.run_phase(phase);
		`uvm_info(get_type_name(), "Starting run_phase", UVM_LOW)
		phase.raise_objection(this);
		`uvm_info(get_type_name(), "Objection raised, starting sequence", UVM_LOW)
		seq.start(env.agent.sequencer);
		`uvm_info(get_type_name(), "Sequence completed, dropping objection", UVM_LOW)
		phase.drop_objection(this);
	endtask
endclass
