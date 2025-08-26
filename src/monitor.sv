class alu_monitor_passive extends uvm_monitor;
	`uvm_component_utils(alu_monitor_passive)

	virtual alu_intf vif;
	uvm_analysis_port #(sequence_item) item_collected_port;
	
	function new(string name = "alu_monitor_passive", uvm_component parent);
		super.new(name,parent);
	endfunction	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		item_collected_port = new("item_collected_port",this);
		if(!uvm_config_db#(virtual alu_intf)::get(this,"","vif",vif))
      		`uvm_fatal("No_vif in monitor_passive","virtual interface get failed");
	endfunction	
	
	virtual task run_phase(uvm_phase phase);

		repeat(1)@(vif.mon_cb); 
		forever begin
			sequence_item item = sequence_item::type_id::create("item");

			repeat(2)@(vif.mon_cb);

			if((vif.CE && (vif.MODE && (vif.INP_VALID != 2'b11) && (vif.CMD < 4 || vif.CMD == 8 || vif.CMD == 9 || vif.CMD == 10))) || (vif.CE && (!vif.MODE && (vif.INP_VALID != 2'b11) && (vif.CMD < 6 || vif.CMD == 12 || vif.CMD == 13)))) begin

				`uvm_info(get_type_name(), "Partial input detected, waiting for second operand...", UVM_HIGH);
				for (int i = 0; i < 17; i++) begin
					if (vif.INP_VALID == 2'b11) break; 
					if (i == 16) begin
						`uvm_error("MON_TIMEOUT", "Monitor timed out waiting for INP_VALID==2'b11");
						continue;
					end
					@(vif.mon_cb);
				end
			end

			repeat(1) @(vif.mon_cb);
			item.RES   = vif.RES;
			item.OFLOW = vif.OFLOW;
			item.COUT  = vif.COUT;
			item.E     = vif.E;
			item.G     = vif.G;
			item.L     = vif.L;
			item.ERR   = vif.ERR;

			`uvm_info(get_type_name(),$sformatf("\nMonitor passive: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d |CE:%0b |CIN:%0b \n\t   RES:%0d |ERR:%0b |OFLOW:%0b |COUT:%0b |EGL:%0b%0b%0b \n",vif.MODE, vif.CMD, vif.INP_VALID, vif.OPA, vif.OPB,vif.CE,vif.CIN, vif.RES, vif.ERR, vif.OFLOW, vif.COUT, vif.E,vif.G,vif.L),UVM_LOW)
			item_collected_port.write(item);
			repeat(2) @(vif.mon_cb);
		end
	endtask
endclass

////////////////////////////////////////////
class alu_monitor_active extends uvm_monitor;
	`uvm_component_utils(alu_monitor_active)

	virtual alu_intf vif;
	uvm_analysis_port #(sequence_item) item_collected_port;
	
	function new(string name = "alu_monitor_active", uvm_component parent);
		super.new(name,parent);
	endfunction	

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		item_collected_port = new("item_collected_port",this);
		if(!uvm_config_db#(virtual alu_intf)::get(this,"","vif",vif))
      		`uvm_fatal("No_vif in monitor_active","virtual interface get failed");
	endfunction	
	
	virtual task run_phase(uvm_phase phase);

		repeat(1)@(vif.mon_cb); 
		forever begin
			sequence_item item = sequence_item::type_id::create("item");

			item.SCB_RST	 = vif.rst;
			repeat(2)@(vif.mon_cb);	

			if((vif.CE && (vif.MODE && (vif.INP_VALID != 2'b11) && (vif.CMD < 4 || vif.CMD == 8 || vif.CMD == 9 || vif.CMD == 10))) || (vif.CE && (!vif.MODE && (vif.INP_VALID != 2'b11) && (vif.CMD < 6 || vif.CMD == 12 || vif.CMD == 13)))) begin

				`uvm_info(get_type_name(), "Partial input detected, waiting for second operand...", UVM_HIGH);
				for (int i = 0; i < 17; i++) begin
					if (vif.INP_VALID == 2'b11) break; 
					if (i == 16) begin
						`uvm_error("MON_TIMEOUT", "Monitor timed out waiting for INP_VALID==2'b11");
						continue;
					end
					@(vif.mon_cb);
				end
			end

			item.OPA       = vif.OPA;
			item.OPB       = vif.OPB;
			item.CMD       = vif.CMD;
			item.MODE      = vif.MODE;
			item.CIN       = vif.CIN;
			item.CE        = vif.CE;
			item.INP_VALID = vif.INP_VALID;
			/* item.SCB_RST	 = vif.rst; */
			
			`uvm_info(get_type_name(),$sformatf("\nMonitor active: M:%0b |cmd:%0d |valid:%0b |OPA:%0d |OPB:%0d |CE:%0b |CIN:%0b \n",vif.MODE, vif.CMD, vif.INP_VALID, vif.OPA, vif.OPB,vif.CE,vif.CIN),UVM_LOW)
			item_collected_port.write(item);
			repeat(3) @(vif.mon_cb);
		end
	endtask	

endclass	

