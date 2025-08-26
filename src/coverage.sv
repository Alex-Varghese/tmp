`uvm_analysis_imp_decl(_mon_act_cg)

class alu_coverage extends uvm_subscriber#(sequence_item);
	`uvm_component_utils(alu_coverage)
  
	uvm_analysis_imp_mon_act_cg#(sequence_item, alu_coverage) mon_act_cg_port;

	sequence_item trans_mon, trans_drv;
	real active_cg, passive_cg;

	covergroup driver_cg;
        INPUT_VALID_CP : coverpoint  trans_drv.INP_VALID { 
          	bins valid_opa = {2'b01};
            bins valid_opb = {2'b10};
            bins valid_both = {2'b11};
            bins invalid = {2'b00};
        }
        
        CMD_CP : coverpoint  trans_drv.CMD { 
        	  bins arithmetic[] = {[0:10]};
            bins logical[] = {[0:13]};
            bins arithmetic_invalid[] = {[11:15]};
            bins logical_invalid[] = {14,15};
        }
        
      	MODE_CP : coverpoint  trans_drv.MODE { 
      			bins arithmetic = {1};
      			bins logical = {0};
        }
       
        CE_CP : coverpoint  trans_drv.CE { 
       			 bins clock_enable_valid = {1};
          	 bins clock_enable_invalid = {0};
        }
       
       	OPA_CP : coverpoint  trans_drv.OPA { 
       			 bins opa[] = {[0:(2**`WIDTH)-1]};
       	}
       
       	OPB_CP : coverpoint  trans_drv.OPB { 
       			 bins opb[] = {[0:(2**`WIDTH)-1]};
        }
       
        CIN_CP : coverpoint  trans_drv.CIN { 
       			 bins cin_high = {1};
       			 bins cin_low = {0};
       	}	
       
       	CROSS_MODE_CMD : cross MODE_CP , CMD_CP;
	endgroup

	covergroup monitor_cg;
			  RES_CP : coverpoint trans_mon.RES { 
        		 option.auto_bin_max = 8;
        		 bins result[] = {[0:(2**`WIDTH)]};
        }
        
        COUT_CP : coverpoint trans_mon.COUT {
        		 bins cout_active = {1};
        		 bins cout_inactive = {0};
        }
        
        OFLOW_CP : coverpoint trans_mon.OFLOW { 
        	 	 bins oflow_active = {1};
             bins oflow_inactive = {0};
    		}
    	
        ERR_CP : coverpoint trans_mon.ERR { 
        		 bins error_active = {1};
        }
        
        G_CP : coverpoint trans_mon.G {
        	 	 bins greater_active = {1};
        }
        E_CP : coverpoint trans_mon.E { 
        		 bins equal_active = {1};
        }
        L_CP : coverpoint trans_mon.L { 
        	   bins lesser_active = {1};
    	  } 
	endgroup

	function new(string name = "alu_coverage", uvm_component parent);
		super.new(name, parent);
		driver_cg = new;
		monitor_cg = new;
	endfunction
  
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		/* drv_cg_port = new("drv_cg_port", this); */
		mon_act_cg_port = new("mon_act_cg_port", this);
	endfunction	

	function void write(sequence_item t);
		trans_mon = t;
		monitor_cg.sample();
	endfunction

	function void write_mon_act_cg(sequence_item t);
		trans_drv = t;
		driver_cg.sample();
	endfunction

	function void extract_phase(uvm_phase phase);
		super.extract_phase(phase);
		active_cg = driver_cg.get_coverage();
		passive_cg = monitor_cg.get_coverage();
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name, $sformatf("Input Coverage ------> %0.2f%%,", active_cg), UVM_MEDIUM);
		`uvm_info(get_type_name, $sformatf("Output Coverage ------> %0.2f%%", passive_cg), UVM_MEDIUM);
	endfunction

endclass

