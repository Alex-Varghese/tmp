`include "define.sv"

`uvm_analysis_imp_decl(_active_mon)
`uvm_analysis_imp_decl(_passive_mon)


class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)
      virtual alu_interface vif;
      uvm_analysis_imp_active_mon #(alu_sequence_item, alu_scoreboard) item_collected_export_active;
      uvm_analysis_imp_passive_mon #(alu_sequence_item, alu_scoreboard) item_collected_export_passive;    

      int match, mismatch;
      
      alu_sequence_item active_monitor_queue[$];  
      alu_sequence_item passive_monitor_queue[$];  
  
  	  logic [`WIDTH:0] prev_RES;
      logic prev_COUT;
      logic prev_OFLOW;
      logic prev_ERR;
      logic prev_G;
      logic prev_E;
      logic prev_L;
      bit first_transaction;
    
      function new (string name = "alu_scoreboard", uvm_component parent);
          super.new(name, parent);
      	  first_transaction = 1'b1;
      endfunction:new
    
      function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          uvm_config_db#(virtual alu_interface)::get(this,"","vif",vif);
          item_collected_export_active = new("item_collected_export_active", this);
          item_collected_export_passive = new("item_collected_export_passive", this);
      endfunction:build_phase
    
      virtual function void write_active_mon(alu_sequence_item pack);
          alu_sequence_item act_mon_item;
        	$display("Scoreboard received from active monitor:: Packet");
        
          act_mon_item = alu_sequence_item::type_id::create("act_mon_item");
          act_mon_item.copy(pack);
          active_monitor_queue.push_back(act_mon_item);
      endfunction:write_active_mon
  
  	  virtual function void write_passive_mon(alu_sequence_item pack);
        	alu_sequence_item pass_mon_item;
     	    $display("Scoreboard received from passive monitor:: Packet");
        
     	    pass_mon_item = alu_sequence_item::type_id::create("pass_mon_item");
          pass_mon_item.copy(pack);
      	  passive_monitor_queue.push_back(pass_mon_item);
      endfunction:write_passive_mon
  	
  	  task store_output(alu_sequence_item expected);
          prev_RES = expected.RES;
          prev_COUT = expected.COUT;
          prev_OFLOW = expected.OFLOW;
          prev_ERR = expected.ERR;
          prev_G = expected.G;
          prev_E = expected.E;
          prev_L = expected.L;
          first_transaction = 1'b0;
      endtask:store_output

 	   task previous_output(alu_sequence_item expected);
         if(first_transaction) begin
              expected.RES = {`WIDTH+1{1'bz}};
              expected.COUT = 1'bz;
              expected.OFLOW = 1'bz;
              expected.ERR = 1'bz;
              expected.G = 1'bz;
              expected.E = 1'bz;
              expected.L = 1'bz;
        end  
        else begin
            expected.RES = prev_RES;
            expected.COUT = prev_COUT;
            expected.OFLOW = prev_OFLOW;
            expected.ERR = prev_ERR;
            expected.G = prev_G;
            expected.E = prev_E;
            expected.L = prev_L;
        end
    endtask:previous_output
    
    function alu_sequence_item reference_model(alu_sequence_item trans);
        alu_sequence_item expected;
       
        expected = alu_sequence_item::type_id::create("expected");
        expected.copy(trans); 
        
        if(vif.cb_reference_model.RESET == 1'b1) begin
            expected.RES = {`WIDTH+1{1'bz}};
            expected.COUT = 1'bz;
            expected.ERR = 1'bz;
            expected.OFLOW = 1'bz;
            expected.G = 1'bz;
            expected.E = 1'bz;
            expected.L = 1'bz;
        end
        else if(expected.CE == 1'b0) begin
            previous_output(expected);
        end
        else if(expected.CE == 1'b1) begin
            expected.RES = {`WIDTH+1{1'bz}};
            expected.COUT = 1'bz;
            expected.ERR = 1'bz;
            expected.OFLOW = 1'bz;
            expected.G = 1'bz;
            expected.E = 1'bz;
            expected.L = 1'bz;
            if(expected.MODE == 1'b1)begin
                if(expected.INP_VALID == 2'b00)begin
                    expected.ERR = 1'b1;
                end

                else if(expected.INP_VALID == 2'b01)begin:INP_VALID_01
                    case(expected.CMD)
                        `INC_A : begin
                                    expected.RES = expected.OPA + 1;
                                 end
                        `DEC_A : begin
                                    expected.RES = expected.OPA - 1;
                                 end
                        default : expected.ERR = 1'b1;
                    endcase
                end:INP_VALID_01
                else if(expected.INP_VALID == 2'b10)begin:INP_VALID_10
                    case(expected.CMD)
                        `INC_B : begin
                                    expected.RES = expected.OPB + 1;
                                 end
                        `DEC_B : begin
                                    expected.RES = expected.OPB - 1;
                                 end
                        default : expected.ERR = 1'b1;
                    endcase
                end:INP_VALID_10

                else if(expected.INP_VALID == 2'b11)begin:INP_valid_11
                    case(expected.CMD)
                        `ADD : begin
                                  expected.RES = expected.OPA + expected.OPB;
                                  expected.COUT = (expected.RES[`WIDTH]) ? 1'b1 : 1'b0;
                               end
                        `SUB : begin
                                  expected.RES = expected.OPA - expected.OPB;
                                  expected.OFLOW = (expected.OPA < expected.OPB) ? 1'b1 : 1'b0;
                               end
                    `ADD_CIN : begin
                                  expected.RES  = expected.OPA + expected.OPB + expected.CIN;
                                  expected.COUT = (expected.RES[`WIDTH]) ? 1'b1 : 1'b0;
                               end
                    `SUB_CIN : begin
                                  expected.RES = expected.OPA - expected.OPB - expected.CIN;
                                  expected.OFLOW = (expected.OPA < expected.OPB || (expected.OPA == expected.OPB && expected.CIN)) ? 1'b1 : 1'b0;
                               end
                      `INC_A : begin
                                  expected.RES = expected.OPA + 1;
                               end
                      `DEC_A : begin
                                  expected.RES = expected.OPA - 1;
                               end
                      `INC_B : begin
                                  expected.RES = expected.OPB + 1;
                               end
                      `DEC_A : begin
                                  expected.RES = expected.OPB - 1;
                               end
                        `CMP : begin:CMP
                                    if(expected.OPA == expected.OPB)begin:eqaul
                                          expected.E = 1'b1;
                                    end:eqaul
                                    else if(expected.OPA > expected.OPB)begin:greater
                                          expected.G = 1'b1;
                                    end:greater
                                    else begin:lesser
                                          expected.L = 1'b1;
                                    end:lesser
                               end:CMP

                    `MUL_INC : begin:mul_increment
                                  expected.OPA = expected.OPA + 1;
                                  expected.OPB = expected.OPB + 1;
                                  expected.RES = expected.OPA * expected.OPB;
                               end:mul_increment
                  `MUL_SHIFT : begin:mul_shift
                                  expected.OPA = expected.OPA << 1;
                                  expected.RES = expected.OPA * expected.OPB;
                               end:mul_shift
                     default : expected.ERR = 1'b1;
                    endcase
                end
            end
            else begin:logical
                if(expected.INP_VALID == 2'b00)begin:INP_VALID_00
                    expected.ERR = 1'b1;
                end:INP_VALID_00
                else if(expected.INP_VALID == 2'b01)begin:INP_VALID_01
                   case(expected.CMD)
                         `NOT_A : begin
                                    expected.RES = {1'b0,~(expected.OPA)};
                                  end
                        `SHR1_A : begin
                                    expected.RES = {1'b0,expected.OPA >> 1};
                                  end
                        `SHL1_A : begin
                                    expected.RES = {1'b0,expected.OPA << 1};
                                  end
                        default : expected.ERR = 1'b1;
                    endcase
                end:INP_VALID_01
                else if(expected.INP_VALID == 2'b10)begin:INP_VALID_10
                    case(expected.CMD)
                         `NOT_B : begin
                                     expected.RES = {1'b0,~(expected.OPB)};
                                  end
                        `SHR1_B : begin
                                     expected.RES = {1'b0,expected.OPB >> 1};
                                  end
                        `SHL1_B : begin
                                     expected.RES = {1'b0,expected.OPB << 1};
                                  end
                        default : expected.ERR = 1'b1;
                    endcase
                end:INP_VALID_10

                else if(expected.INP_VALID == 2'b11)begin:INP_valid_11
                    case(expected.CMD)
                         `AND : begin
                                   expected.RES = {1'b0,expected.OPA & expected.OPB};
                                end
                        `NAND : begin
                                   expected.RES = {1'b0,~(expected.OPA & expected.OPB)};
                                end
                          `OR : begin
                                   expected.RES = {1'b0,expected.OPA | expected.OPB};
                                end
                         `NOR : begin
                                   expected.RES = {1'b0,~(expected.OPA | expected.OPB)};
                                end
                         `XOR : begin
                                   expected.RES = {1'b0,expected.OPA ^ expected.OPB};
                                end
                        `XNOR : begin
                                   expected.RES = {1'b0,~(expected.OPA ^ expected.OPB)};
                                end
                       `NOT_A : begin
                                   expected.RES = {1'b0,~(expected.OPA)};
                                end
                      `SHR1_A : begin
                                   expected.RES = {1'b0,expected.OPA >> 1};
                                end
                      `SHL1_A : begin
                                   expected.RES = {1'b0,expected.OPA << 1};
                                end
                       `NOT_B : begin
                                   expected.RES = {1'b0,~(expected.OPB)};
                                end
                      `SHR1_B : begin
                                   expected.RES = {1'b0,expected.OPB >> 1};
                                end
                      `SHL1_B : begin
                                   expected.RES = {1'b0,expected.OPB << 1};
                                end
                     `ROL_A_B : begin
                                   int value1 =  expected.OPB[`ROR_WIDTH-1:0];
                                   expected.RES = {1'b0,(expected.OPA << value1 | expected.OPA >> (`WIDTH - value1))};
                                   expected.ERR = (expected.OPB > {`ROR_WIDTH + 1{1'b1}});
                                end
                     `ROR_A_B : begin
                                   int value1 =  expected.OPB[`ROR_WIDTH-1:0];
                                   expected.RES = {1'b0,(expected.OPA >> value1 | expected.OPA << (`WIDTH - value1))};
                                   expected.ERR = (expected.OPB > {`ROR_WIDTH + 1{1'b1}});
                                end
                      default : expected.ERR = 1'b1;
                    endcase
                end : INP_valid_11
            end : logical

            store_output(expected);
        end
        return expected;
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        alu_sequence_item actual_result;    // From monitor
        alu_sequence_item input_stimulus;   // From driver  
        alu_sequence_item expected;  // From reference model
        
        forever begin:forever_loop
            // Wait for both queues to have data
            wait(active_monitor_queue.size() > 0 && passive_monitor_queue.size() > 0);
            
            `uvm_info(get_type_name(), $sformatf("-------------------------------------"), UVM_LOW)
            
            // Get actual results and input stimulus
            actual_result = passive_monitor_queue.pop_front();
            input_stimulus = active_monitor_queue.pop_front();


            `uvm_info(get_type_name(), $sformatf("Processing: opa=%0d opb=%0d cmd=%0d mode=%0d,inp_valid = %0d,ce = %0d,cin = %0d",input_stimulus.OPA, input_stimulus.OPB, input_stimulus.CMD, input_stimulus.MODE,input_stimulus.INP_VALID,input_stimulus.CE,input_stimulus.CIN), UVM_LOW)
            
            // Generate expected results using reference model
             expected = reference_model(input_stimulus);
            
            // Compare actual vs expected
            if ({actual_result.RES, actual_result.ERR, actual_result.OFLOW, actual_result.COUT,actual_result.G, actual_result.E, actual_result.L} === {expected.RES, expected.ERR, expected.OFLOW, expected.COUT, expected.G, expected.E, expected.L}) begin:comparing_match
                match++;
                `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
                `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
                `uvm_info(get_type_name(), $sformatf("Expected: res=%0d err=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d",
                 expected.RES, expected.ERR, expected.OFLOW, expected.COUT, 
                 expected.G, expected.E, expected.L), UVM_LOW)
                 `uvm_info(get_type_name(), $sformatf("Actual  : res=%0d err=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d",
                  actual_result.RES, actual_result.ERR, actual_result.OFLOW, actual_result.COUT, 
                  actual_result.G, actual_result.E, actual_result.L), UVM_LOW)
                  `uvm_info(get_type_name(),$sformatf("MATCH = %0d ,MISMATCH = %0d",match,mismatch),UVM_MEDIUM);  
              end:comparing_match
          	  else begin:compare_mismatch
                  mismatch++;
                  `uvm_error(get_type_name(), "----           TEST FAIL           ----")
                  `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
                  `uvm_info(get_type_name(), $sformatf("Expected: res=%0d err=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d",
                  expected.RES, expected.ERR, expected.OFLOW, expected.COUT, 
                  expected.G, expected.E, expected.L), UVM_LOW)
                  `uvm_info(get_type_name(), $sformatf("Actual  : res=%0d err=%0d oflow=%0d cout=%0d g=%0d e=%0d l=%0d",
                  actual_result.RES, actual_result.ERR, actual_result.OFLOW, actual_result.COUT, 
                  actual_result.G, actual_result.E, actual_result.L), UVM_LOW)
              end:compare_mismatch
              `uvm_info(get_type_name(),$sformatf("MATCH = %0d ,MISMATCH = %0d",match,mismatch),UVM_MEDIUM);
              `uvm_info(get_type_name(), "------------------------------------", UVM_LOW)
          end:forever_loop
    endtask:run_phase
endclass:alu_scoreboard
