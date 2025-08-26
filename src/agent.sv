class  alu_agent_passive extends uvm_agent;
	`uvm_component_utils(alu_agent_passive)

	alu_driver drv;
	alu_monitor_passive mon_pass;
	alu_sequencer seqr;

	function new(string name = "alu_agent_passive",uvm_component parent);
    super.new(name,parent);
  endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(get_is_active == UVM_ACTIVE) begin
			drv = alu_driver::type_id::create("drv",this);
			seqr = alu_sequencer::type_id::create("seqr",this);
		end
		mon_pass = alu_monitor_passive::type_id::create("mon_pass",this);
	endfunction	

endclass	

//////////////////////////////////////////////////////////
class  alu_agent_active extends uvm_agent;
	`uvm_component_utils(alu_agent_active)

	alu_monitor_active mon_act;
	alu_sequencer seqr;
	alu_driver drv;

	function new(string name = "alu_agent_active",uvm_component parent);
    super.new(name,parent);
  endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(get_is_active == UVM_ACTIVE) begin
			drv = alu_driver::type_id::create("drv",this);
			seqr = alu_sequencer::type_id::create("seqr",this);
		end
		mon_act = alu_monitor_active::type_id::create("mon_act",this);
	endfunction	

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction	
endclass	
