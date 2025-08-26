class alu_environment extends uvm_env;
  	alu_agent active_agent;
  	alu_agent passive_agent;
  	alu_scoreboard scoreboard;
  	alu_coverage coverage;
  
  	`uvm_component_utils(alu_environment)
  
  	function new(string name = "alu_environment", uvm_component parent);
    	  super.new(name, parent);
  	endfunction : new

  	function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
        active_agent = alu_agent::type_id::create("active_agent", this);
      	passive_agent = alu_agent::type_id::create("passive_agent", this);
      	scoreboard = alu_scoreboard::type_id::create("scoreboard", this);
      	coverage = alu_coverage::type_id::create("coverage", this);
  	endfunction : build_phase
  
    function void connect_phase(uvm_phase phase);    								   
        active_agent.monitor.item_collected_port.connect(scoreboard.item_collected_export_active);
        passive_agent.monitor.item_collected_port.connect(scoreboard.item_collected_export_passive);    
        active_agent.monitor.item_collected_port.connect(coverage.act_mon);
        passive_agent.monitor.item_collected_port.connect(coverage.pass_mon);
  	endfunction : connect_phase
endclass : alu_environment
