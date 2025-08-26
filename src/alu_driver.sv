class alu_driver extends uvm_driver #(alu_sequence_item);

  	  virtual alu_interface vif;
  	  bit inpvalid_11;
  	  `uvm_component_utils(alu_driver)
    
  	  function new (string name = "alu_driver", uvm_component parent);
    	    super.new(name, parent);
  	  endfunction : new

  	  function void build_phase(uvm_phase phase);
    	    super.build_phase(phase);
    	    if(!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
     		      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  	  endfunction : build_phase

  	  virtual task run_phase(uvm_phase phase);
    	    forever begin
    		      seq_item_port.get_next_item(req);
    		      drive();
    		      seq_item_port.item_done();
    	    end : forever_loop
  	  endtask : run_phase

  	  virtual task drive();
    	@(posedge vif.driver_cb);
      	  if(no_of_inputs(req)) begin
      	  		vif.OPA <= req.OPA;
      		    vif.OPB <= req.OPB;
      		    vif.INP_VALID <= req.INP_VALID;
      		    vif.CE <= req.CE;
      		    vif.CIN <= req.CIN;
      		    vif.MODE <= req.MODE;
      		    vif.CMD <= req.CMD;
      		    `uvm_info("DRIVER","DRIVING TO DUT",UVM_MEDIUM);
     	 	    req.print();
      		    repeat(2) @(vif.driver_cb);
            	    -> vif.drv_done_e;
      		    repeat(4) @(vif.driver_cb);
		      end : single_operand
    
      	  else if (req.INP_VALID == 2'b11 || req.INP_VALID == 2'b00) begin
      		    vif.OPA <= req.OPA;
      		    vif.OPB <= req.OPB;
      		    vif.INP_VALID <= req.INP_VALID;
      		    vif.CE <= req.CE;
      		    vif.CIN <= req.CIN;
      		    vif.MODE <= req.MODE;
      		    vif.CMD <= req.CMD;
        	    `uvm_info("DRIVER","DRIVING TO DUT",UVM_MEDIUM);
      		    req.print();
          	  if(req.CMD inside{`MUL_INC,`MUL_SHIFT})
    			    repeat(3) @(vif.driver_cb);
            		-> vif.drv_done_e;
  			  end:multiplication
  			  else begin:other_operation
    			    repeat(2) @(vif.driver_cb);
            		-> vif.drv_done_e;
  			  end:other_operation
    		  repeat(4) @(vif.driver_cb);
    	 end : multiple_operand
		 else begin
    		  inpvalid_11 = 1'b0;
         for (int count = 0; count < `MAX_WAIT_CYCLE && !inpvalid_11; count++) begin
        		      req.CMD.rand_mode(0);
        		      req.MODE.rand_mode(0);
				      void'(req.randomize());
        		      @(vif.driver_cb);
            	      if (req.INP_VALID == 2'b11) begin
            		      inpvalid_11 = 1'b1;
                  	  	  req.CMD.rand_mode(1);
                 	      req.MODE.rand_mode(1);
            		      $display("FOUND INP_VALID == 11 AT CYCLE %0d", count + 1);
            		      vif.OPA <= req.OPA;
      				      vif.OPB <= req.OPB;
      				      vif.INP_VALID <= req.INP_VALID;
      				      vif.CE <= req.CE;
      				      vif.CIN <= req.CIN;
      				      vif.MODE <= req.MODE;
      				      vif.CMD <= req.CMD;
                	      `uvm_info("DRIVER","DRIVING TO DUT",UVM_MEDIUM);
      				      req.print();
              		      if(req.CMD inside{`MUL_INC,`MUL_SHIFT})
    					         repeat(3) @(vif.driver_cb);
            			         -> vif.drv_done_e;
  					      end : multiplication
  					      else begin:other_operation
    					         repeat(2) @(vif.driver_cb);
            				     -> vif.drv_done_e;
  					      end:other_operation
            		      repeat(4) @(vif.driver_cb);
            		      break;
        		      end : INP_VALID_11
        		      else begin
                  	  	   `uvm_info("DRIVER","INP_VALID NOT 11",UVM_MEDIUM);  
					       `uvm_info("DRIVER",$sformatf("INP_VALID == %0d at cycle = %0d",req.INP_VALID,count+1),UVM_MEDIUM);
        			       req.print();
        		      end : INP_VALID_not_11
    		      end : for_loop

			      if (!inpvalid_11) begin
      			      $display(" INP_VALID NOT 11 WITHIN %0d CLOCK CYCLE", `MAX_WAIT_CYCLE);
            	      vif.OPA <= req.OPA;
      			      vif.OPB <= req.OPB;
      			      vif.INP_VALID <= req.INP_VALID;
      			      vif.CE <= req.CE;
      			      vif.CIN <= req.CIN;
      			      vif.MODE <= req.MODE;
   				      vif.CMD <= req.CMD;
              	      `uvm_info("DRIVER","DRIVING TO DUT",UVM_MEDIUM);
      			      req.print();
           		      repeat(2) @(vif.driver_cb);
            		      ->vif.drv_done_e;
    		      end 
		      end
  	  endtask : drive
  	  
  	  function bit no_of_inputs(alu_sequence_item req);
          if (req.MODE == 1'b1) begin
        	    case (req.CMD)
            	    `INC_A : return 1;
            	    `INC_B : return 1;
            	    `DEC_A : return 1;
            	    `DEC_B : return 1;
            	    default: return 0;
        	    endcase
    	    end : arithmetic
    	    else begin
        	    case (req.CMD)
            	    `NOT_A : return 1;
            	    `NOT_B : return 1;
            	    `SHR1_A: return 1;
            	    `SHL1_A: return 1;
            	    `SHR1_B: return 1;
            	    `SHL1_B: return 1;
				    default: return 0;
        	    endcase
    	    end : logical
	    endfunction : no_of_inputs
	    
  endclass: alu_driver 
