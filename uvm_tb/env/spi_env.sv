class spi_env extends uvm_env;
	`uvm_component_utils(spi_env)

	function new (string name = "spi_env", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	spi_agent agent;
	spi_scoreboard sb;

	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		agent = spi_agent::type_id::create("agent", this);
		sb = spi_scoreboard::type_id::create("sb", this);
	endfunction

	// connect analysis port of scoreboard with monitor
	virtual function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		agent.monitor.mon_analysis_port.connect(sb.slave_imp);
		agent.host_mon.host_analysis_port.connect(sb.host_imp);
	endfunction
endclass
