class alu_env extends uvm_env;
	`uvm_component_utils(alu_env);

	alu_agent_active agt_act;
	alu_agent_passive agt_pass;
	alu_scoreboard scb;
	alu_coverage cov;

	function new(string name = "alu_env", uvm_component parent);
		super.new(name,parent);
	endfunction	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agt_act = alu_agent_active::type_id::create("agt_act",this);
		agt_pass = alu_agent_passive::type_id::create("agt_pass",this);
		set_config_int("agt_pass","is_active",UVM_PASSIVE);
		set_config_int("agt_act","is_active",UVM_ACTIVE);
		scb = alu_scoreboard::type_id::create("scb",this);
		cov = alu_coverage::type_id::create("cov",this);
	endfunction	

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agt_act.mon_act.item_collected_port.connect(scb.item_act_port);
		agt_pass.mon_pass.item_collected_port.connect(scb.item_pass_port); 
		
		agt_act.mon_act.item_collected_port.connect(cov.mon_act_cg_port);
		agt_pass.mon_pass.item_collected_port.connect(cov.analysis_export);
	endfunction	
endclass	
