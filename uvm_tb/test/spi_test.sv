class spi_test extends uvm_test;
	`uvm_component_utils(spi_test)

	virtual spi_host_if #(DATA_LENGTH) vif_host;

	function new (string name="spi_test", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	spi_env env;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// override base sequence
		uvm_factory::get().set_type_override_by_type(spi_sequence::get_type(), example_seq::get_type());
		env = spi_env::type_id::create("env", this);
		if (!uvm_config_db#(virtual spi_host_if #(DATA_LENGTH))::get(this, "", "vif_host", vif_host))
			`uvm_fatal(get_type_name(), "vif_host not found")
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology();
	endfunction

	task wait_for_done();
		// Wait for last DONE pulse to be over before ending simulation
		@(posedge vif_host.done);
		@(posedge vif_host.clk);
	endtask


	virtual task run_phase(uvm_phase phase);
		// need to explicitly create sequence since we need to wait_for_done()
		spi_sequence seq = spi_sequence::type_id::create("seq");

		phase.raise_objection(this);
		`uvm_info(get_type_name(), "Objection raised, starting sequence", UVM_LOW)
		seq.start(env.agent.sequencer);
		`uvm_info(get_type_name(), "Sequence completed, dropping objection", UVM_LOW)

		wait_for_done();
		phase.drop_objection(this);
	endtask
endclass
