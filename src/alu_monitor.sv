

class alu_monitor extends uvm_monitor;

    virtual alu_interface vif;

    uvm_analysis_port #(alu_sequence_item) item_collected_port;

  	alu_sequence_item seq;

    `uvm_component_utils(alu_monitor)

    function new (string name = "alu_monitor", uvm_component parent);
    	  super.new(name, parent);
    	  seq = new();
          item_collected_port = new("item_collected_port", this);
  	endfunction : new

  	function void build_phase(uvm_phase phase);
    	  super.build_phase(phase);
    	  if(!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
       	  	`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  	endfunction : build_phase

  	virtual task run_phase(uvm_phase phase);
    	  forever begin
      		    @(vif.drv_done_e);
		      	seq.INP_VALID = vif.INP_VALID;
		      	seq.OPA = vif.OPA;
		      	seq.OPB = vif.OPB;
		      	seq.CE = vif.CE;
		      	seq.CIN = vif.CIN;
		      	seq.CMD = vif.CMD;
		      	seq.MODE = vif.MODE;
		      	seq.RES = vif.RES;
		      	seq.ERR = vif.ERR;
		      	seq.COUT = vif.COUT;
		      	seq.OFLOW = vif.OFLOW;
		      	seq.G = vif.G;
		      	seq.E = vif.E;
		      	seq.L = vif.L;
    		    item_collected_port.write(seq);
    	  end : forever_loop
  	endtask : run_phase
endclass : alu_monitor
