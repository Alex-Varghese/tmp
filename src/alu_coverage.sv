`uvm_analysis_imp_decl(_active_mon)
`uvm_analysis_imp_decl(_passive_mon)

class alu_coverage extends uvm_component;
	real driver_coverage, monitor_coverage;
    `uvm_component_utils(alu_coverage)

    uvm_analysis_imp_active_mon #(alu_sequence_item, alu_coverage) active_mon;
    uvm_analysis_imp_passive_mon #(alu_sequence_item, alu_coverage) passive_mon;

	  alu_sequence_item trans_drv, trans_mon;

	  covergroup driver_cov;
  
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

  	endgroup : driver_cov

 	covergroup monitor_cov;
 	
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
    
  	endgroup : monitor_cov

	function new(string name = "", uvm_component parent);
  	  	super.new(name, parent);
  		driver_cov = new;
        monitor_cov = new;
        active_mon = new("active_mon", this);
        passive_mon = new("passive_mon", this);
	endfunction:new
  

  	function void write_active_mon(alu_sequence_item t);
      	trans_drv = t;
        driver_cov.sample();
	endfunction : write_active_mon
  
	function void write_passive_mon(alu_sequence_item t);
        trans_mon = t;
        monitor_cov.sample();
	endfunction : write_passive_mon
  
	function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);
        driver_coverage = driver_cov.get_coverage();
        monitor_coverage = monitor_cov.get_coverage();
  	endfunction : extract_phase

	function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info(get_type_name, $sformatf("[INPUT] Coverage ------> %0.2f%%,", driver_coverage), UVM_MEDIUM);
      `uvm_info(get_type_name, $sformatf("[OUTPUT] Coverage ------> %0.2f%%", monitor_coverage), UVM_MEDIUM);
  	endfunction:report_phase

endclass : alu_coverage
