`uvm_analysis_imp_decl(_mon_pass)
`uvm_analysis_imp_decl(_mon_act)

class alu_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(alu_scoreboard)

	int no = 1;  // no of transactions 
	int MATCH, MISMATCH;
	int mismatch_file;

	virtual alu_intf vif;
	sequence_item mon_act_packet_q[$];
	sequence_item mon_pass_packet_q[$];

	uvm_analysis_imp_mon_act #(sequence_item, alu_scoreboard) item_act_port;
	uvm_analysis_imp_mon_pass #(sequence_item, alu_scoreboard) item_pass_port;
	
	function new (string name = "alu_scoreboard", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		mismatch_file = $fopen("mismatch_report.log", "w");

		if(!uvm_config_db#(virtual alu_intf)::get(this," ","vif",vif)) 
			`uvm_fatal("No_vif in scoreboard","virtual interface get failed from config db"); 

		item_act_port = new("item_act_port", this);
		item_pass_port = new("item_pass_port", this);
	endfunction

	virtual function void write_mon_act(sequence_item pkt);
		`uvm_info(get_type_name(), "Received input packet ", UVM_DEBUG)
		mon_act_packet_q.push_back(pkt);
	endfunction

	virtual function void write_mon_pass(sequence_item pkt);
		`uvm_info(get_type_name(), "Received output packet ", UVM_DEBUG)
		mon_pass_packet_q.push_back(pkt);
	endfunction


	function sequence_item predict_model(sequence_item drv_pkt, sequence_item previous_val);
    
		sequence_item expected;
    logic [`POW_2_N - 1:0] SH_AMT;
    expected = new();
    expected.copy(drv_pkt);
		
		if (get_report_verbosity_level() >= UVM_HIGH)  
			$display("\n---------------------------Before reference execution-----------------------------------");
		`uvm_info(get_type_name(),$sformatf("\nOPA:	 %0d \nOPB:   %0d \nMODE:  %0d \nCMD:   %0d \nRES:   %0d \n------------------------------------------------------------------", expected.OPA, expected.OPB, expected.MODE, expected.CMD, expected.RES),UVM_HIGH) 

		if (drv_pkt.SCB_RST == 1) begin
        expected.RES   = 'bz;
        expected.COUT  = 1'bz;
        expected.OFLOW = 1'bz;
        expected.E     = 1'bz;
        expected.G     = 1'bz;
        expected.L     = 1'bz;
        expected.ERR   = 1'bz;
    end 
		else if(expected.CE == 0)
      expected = previous_val;
    else begin
      expected.RES   = 'bz;
      expected.COUT  = 1'bz;
      expected.OFLOW = 1'bz;
      expected.E     = 1'bz;
			expected.G     = 1'bz;
      expected.L     = 1'bz;
      expected.ERR   = 1'bz;	

		if(expected.CE == 1) begin
			if(expected.MODE) begin // Arithmetic Mode
				case(expected.INP_VALID)
					2'b11: begin
						case(expected.CMD)
							`ADD:
								begin
									expected.RES = drv_pkt.OPA + drv_pkt.OPB;
									expected.COUT = expected.RES[`WIDTH];
								end
							`SUB:
								begin
									expected.RES = drv_pkt.OPA - drv_pkt.OPB;
									expected.OFLOW = drv_pkt.OPA < drv_pkt.OPB;
								end
							`ADD_CIN:
								begin
									expected.RES = drv_pkt.OPA + drv_pkt.OPB + drv_pkt.CIN;
									expected.COUT = expected.RES[`WIDTH];
								end
							`SUB_CIN:
								begin
									expected.RES = drv_pkt.OPA - drv_pkt.OPB - drv_pkt.CIN;
									expected.OFLOW = (drv_pkt.OPA < drv_pkt.OPB) || ((drv_pkt.OPA == drv_pkt.OPB) && drv_pkt.CIN);
								end
							`CMP:
								begin
									if(drv_pkt.OPA == drv_pkt.OPB)
										expected.E = drv_pkt.OPA == drv_pkt.OPB;
									else if(drv_pkt.OPA > drv_pkt.OPB)
										expected.G = drv_pkt.OPA > drv_pkt.OPB;
									else
										expected.L = drv_pkt.OPA < drv_pkt.OPB;
								end
							`INC_MULT: expected.RES = (drv_pkt.OPA + 1) * (drv_pkt.OPB + 1);
							`SH_MULT:   expected.RES = (drv_pkt.OPA << 1) * drv_pkt.OPB;
							default:    expected.ERR = 1;
						endcase
					end
					// Cases for other INP_VALID values
					2'b01: begin
						if(expected.CMD == `INC_A) expected.RES = drv_pkt.OPA + 1;
						else if (expected.CMD == `DEC_A) expected.RES = drv_pkt.OPA - 1;
						else expected.ERR = 1;
					end
					2'b10: begin
						if(expected.CMD == `INC_B) 
							expected.RES = drv_pkt.OPB + 1;
						else if (expected.CMD == `DEC_B) 
							expected.RES = drv_pkt.OPB - 1;
						else expected.ERR = 1;
					end
					default: expected.ERR = 1;
				endcase
			end
			else begin // Logical Mode
				case(expected.INP_VALID)
					2'b11: begin
						case(expected.CMD)
							`AND:   expected.RES = {1'b0, drv_pkt.OPA & drv_pkt.OPB};
							`NAND:  expected.RES = {1'b0, ~(drv_pkt.OPA & drv_pkt.OPB)};
							`OR:    expected.RES = {1'b0, drv_pkt.OPA | drv_pkt.OPB};
							`NOR:   expected.RES = {1'b0, ~(drv_pkt.OPA | drv_pkt.OPB)};
							`XOR:   expected.RES = {1'b0, drv_pkt.OPA ^ drv_pkt.OPB};
							`XNOR:  expected.RES = {1'b0, ~(drv_pkt.OPA ^ drv_pkt.OPB)};
							`ROL_A_B:
								begin
									SH_AMT = drv_pkt.OPB[`POW_2_N - 1:0];
									expected.RES = {1'b0, drv_pkt.OPA << SH_AMT | drv_pkt.OPA >> (`WIDTH - SH_AMT)};
									expected.ERR = |drv_pkt.OPB[`WIDTH - 1 : `POW_2_N +1];
								end
							`ROR_A_B:
								begin
								  SH_AMT = drv_pkt.OPB[`POW_2_N - 1:0];
								  expected.RES = {1'b0, drv_pkt.OPA << (`WIDTH - SH_AMT) | drv_pkt.OPA >> SH_AMT};
								  expected.ERR = |drv_pkt.OPB[`WIDTH - 1 : `POW_2_N +1];
								end
							default: expected.ERR = 1;
						endcase
					end
					// Cases for other INP_VALID values
					2'b01: begin
						case(expected.CMD)
							`NOT_A:  expected.RES = {1'b0, ~drv_pkt.OPA};
							`SHR1_A: expected.RES = drv_pkt.OPA >> 1;
							`SHL1_A: expected.RES = drv_pkt.OPA << 1;
							default: expected.ERR = 1;
						endcase
					end
					2'b10: begin
						case(expected.CMD)
							`NOT_B:  expected.RES = {1'b0, ~drv_pkt.OPB};
							`SHR1_B: expected.RES = drv_pkt.OPB >> 1;
							`SHL1_B: expected.RES = drv_pkt.OPB << 1; 
							default: expected.ERR = 1;
						endcase
					end
					default: expected.ERR = 1;
				endcase
			end
		end
		end

		if (get_report_verbosity_level() >= UVM_HIGH)  
		`uvm_info(get_type_name(),$sformatf("\nRES:	 %0d \nERR:   %0d \nCOUT:  %0d \nOFLOW: %0d \nEGL:   %0b%0b%0b \n------------------------------------------------------------------", expected.RES, expected.ERR, expected.COUT, expected.OFLOW, expected.E, expected.G, expected.L),UVM_HIGH) 

		return expected;
	endfunction	


	task compare_and_report(sequence_item actual, sequence_item expected, sequence_item drv_input);
		bit mismatch_found = 0;
		string report_message;
		if (actual.RES !== expected.RES) begin
			`uvm_error(get_type_name(), $sformatf("FAIL: RES Mismatch! | Expected: %0d (%0h) | Actual: %0d (%0h)", 
			           expected.RES, expected.RES, actual.RES, actual.RES))
			mismatch_found = 1;
		end
		if (actual.COUT !== expected.COUT) begin
			`uvm_error(get_type_name(), $sformatf("FAIL: COUT Mismatch! | Expected: %b | Actual: %b", 
			           expected.COUT, actual.COUT))
			mismatch_found = 1;
		end
		if (actual.OFLOW !== expected.OFLOW) begin
			`uvm_error(get_type_name(), $sformatf("FAIL: OFLOW Mismatch! | Expected: %b | Actual: %b", 
			           expected.OFLOW, actual.OFLOW))
			mismatch_found = 1;
		end
		if (actual.ERR !== expected.ERR) begin
			`uvm_error(get_type_name(), $sformatf("FAIL: ERR Mismatch! | Expected: %b | Actual: %b", 
			           expected.ERR, actual.ERR))
			mismatch_found = 1;
		end
		if(expected.CMD == `CMP) begin
			if (actual.E !== expected.E) begin `uvm_error(get_type_name(), "FAIL: E Flag Mismatch!") mismatch_found = 1; end
			if (actual.G !== expected.G) begin `uvm_error(get_type_name(), "FAIL: G Flag Mismatch!") mismatch_found = 1; end
			if (actual.L !== expected.L) begin `uvm_error(get_type_name(), "FAIL: L Flag Mismatch!") mismatch_found = 1; end
		end
	if (mismatch_found) begin
		`uvm_info(get_type_name(), "FAILED", UVM_LOW)
		MISMATCH++;
		$fdisplay(mismatch_file, "------------------- MISMATCH FOUND @ %0t -------------------", $time);
		$fdisplay(mismatch_file, "DRIVER Transaction (Input):\n%s", drv_input.sprint());
		$fdisplay(mismatch_file, "\nPREDICTED Transaction (Expected Output):\n%s", expected.sprint());
		$fdisplay(mismatch_file, "\nMONITOR Transaction (Actual Output):\n%s", actual.sprint());
		$fdisplay(mismatch_file, "------------------------------------------------------------------\n");
		mismatch_found = 0;
	end else begin
		MATCH++;
		`uvm_info(get_type_name(), "-------------------------------------- PASS -------------------------------------------------------", UVM_HIGH)
	end

	endtask

	virtual task run_phase(uvm_phase phase);
					sequence_item monitor_active;
					sequence_item monitor_passive;  
					sequence_item expected;  
					sequence_item previous_val; 
					previous_val = new();	

		forever begin
			wait(mon_act_packet_q.size() > 0 && mon_pass_packet_q.size() > 0);
			
			monitor_active = mon_act_packet_q.pop_front();
			monitor_passive = mon_pass_packet_q.pop_front();
		


			if (get_report_verbosity_level() >= UVM_HIGH) 
				$display("\n-------------------------------inputs -----------------------------------");
			`uvm_info(get_type_name(),$sformatf("\nOPA:	 %0d \nOPB:   %0d \nMODE:  %0d \nCMD:   %0d \nCE:   %0b \nValid:    %0b \nCIN:    %0b",monitor_active.OPA, monitor_active.OPB, monitor_active.MODE, monitor_active.CMD, monitor_active.CE, monitor_active.INP_VALID, monitor_active.CIN),UVM_HIGH) 

			if (get_report_verbosity_level() >= UVM_HIGH)
			`uvm_info(get_type_name(),$sformatf("\nRES:   %0d \nERR:    %0b\nCOUT:    %0b\nOFLOW:    %0b\nEGL:    %0b%0b%0b\n",monitor_passive.RES, monitor_passive.ERR, monitor_passive.COUT, monitor_passive.OFLOW, monitor_passive.E, monitor_passive.G, monitor_passive.L),UVM_HIGH)
		
			expected = predict_model(monitor_active,previous_val);
			previous_val = expected;

			compare_and_report(monitor_passive, expected, monitor_active);
			$display("---------------------------------------------- Pass = %0d | Fail = %0d -------------------------------------------------\n\n",MATCH,MISMATCH);
		end
	endtask

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		$fclose(mismatch_file);
	endfunction

endclass
