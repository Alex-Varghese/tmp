class alu_base extends uvm_test;

 	`uvm_component_utils(alu_base)

   	alu_environment env;

    function new(string name = "alu_base",uvm_component parent=null);
      	super.new(name,parent);
 	  endfunction:new 

  	virtual function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	env = alu_environment::type_id::create("env", this);
        uvm_config_db#(uvm_active_passive_enum)::set(this,"env.passive_agent" , "is_active" ,UVM_PASSIVE);      		  
        uvm_config_db#(uvm_active_passive_enum)::set(this,"env.active_agent","is_active",UVM_ACTIVE);
  	endfunction : build_phase
  
  	virtual task run_phase(uvm_phase phase);
        alu_sequence seq;
        phase.raise_objection(this);
        seq = alu_sequence::type_id::create("seq");
      	seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
    endtask:run_phase

	  virtual function void end_of_elaboration();
 		    print();
    endfunction:end_of_elaboration

endclass:alu_base


class alu_single_operand_operation_test extends alu_base;

  	`uvm_component_utils(alu_single_operand_operation_test)

   	alu_environment env;

  	function new(string name = "alu_single_operand_operation_test",uvm_component parent=null);
    	  super.new(name,parent);
  	endfunction:new 

	  virtual task run_phase(uvm_phase phase);
        alu_single_operand_operation seq;
        phase.raise_objection(this);
        seq = alu_single_operand_operation::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_single_operand_operation_test


class alu_multiple_operand_arithmetic_test extends alu_base;

  	`uvm_component_utils(alu_multiple_operand_arithmetic_test)


  	  function new(string name = "alu_multiple_operand_arithmetic_test",uvm_component parent=null);
    	    super.new(name,parent);
  	  endfunction:new 

	    virtual task run_phase(uvm_phase phase);
          alu_multiple_operand_arithmetic seq;
          phase.raise_objection(this);
          seq = alu_multiple_operand_arithmetic::type_id::create("seq");
          seq.start(env.active_agent.sequencer);
          phase.drop_objection(this);
  	  endtask:run_phase

endclass:alu_multiple_operand_arithmetic_test

class alu_multiple_operand_logical_test extends alu_base;

  	`uvm_component_utils(alu_multiple_operand_logical_test)


  	function new(string name = "alu_multiple_operand_logical_test",uvm_component parent=null);
    	  super.new(name,parent);
  	endfunction:new 

	  virtual task run_phase(uvm_phase phase);
        alu_multiple_operand_logical seq;
        phase.raise_objection(this);
        seq = alu_multiple_operand_logical::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_multiple_operand_logical_test

class alu_invalid_arithmetic_test extends alu_base;

  	`uvm_component_utils(alu_invalid_arithmetic_test)


  	function new(string name = "alu_invalid_arithmetic_test",uvm_component parent=null);
    	  super.new(name,parent);
  	endfunction:new 

	  virtual task run_phase(uvm_phase phase);
        alu_invalid_arithmetic seq;
        phase.raise_objection(this);
        seq = alu_invalid_arithmetic::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_invalid_arithmetic_test


class alu_invalid_logical_test extends alu_base;

  	`uvm_component_utils(alu_invalid_logical_test)


  	function new(string name = "alu_invalid_logical_test",uvm_component parent=null);
    	  super.new(name,parent);
  	endfunction:new 

	virtual task run_phase(uvm_phase phase);
        alu_invalid_logical seq;
        phase.raise_objection(this);
        seq = alu_invalid_logical::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_invalid_logical_test


class alu_compare_test extends alu_base;

  	`uvm_component_utils(alu_compare_test)


  	function new(string name = "alu_compare_test",uvm_component parent=null);
    	  super.new(name,parent);
  	endfunction:new 

	  virtual task run_phase(uvm_phase phase);
        alu_compare seq;
        phase.raise_objection(this);
        seq = alu_compare::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_compare_test



class alu_16_cycle_normal_logical_test extends alu_base;

  	`uvm_component_utils(alu_16_cycle_normal_logical_test)


    	function new(string name = "alu_16_cycle_normal_logical_test",uvm_component parent=null);
        	super.new(name,parent);
  	  endfunction:new 

	  virtual task run_phase(uvm_phase phase);
        alu_16_cycle_normal_logical seq;
        phase.raise_objection(this);
        seq = alu_16_cycle_normal_logical::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_16_cycle_normal_logical_test



class alu_16_cycle_normal_arithmetic_test extends alu_base;

  	`uvm_component_utils(alu_16_cycle_normal_arithmetic_test)


  	function new(string name = "alu_16_cycle_normal_arithmetic_test",uvm_component parent=null);
      	super.new(name,parent);
  	endfunction:new 

	  virtual task run_phase(uvm_phase phase);
        alu_16_cycle_normal_arithmetic seq;
        phase.raise_objection(this);
        seq = alu_16_cycle_normal_arithmetic::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_16_cycle_normal_arithmetic_test



class alu_inactive_CE_test extends alu_base;

  	`uvm_component_utils(alu_inactive_CE_test)


  	function new(string name = "alu_inactive_CE_test",uvm_component parent=null);
    	  super.new(name,parent);
  	endfunction:new 

	  virtual task run_phase(uvm_phase phase);
        alu_inactive_CE seq;
        phase.raise_objection(this);
        seq = alu_inactive_CE::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_inactive_CE_test


class alu_16_cycle_multiplication_test extends alu_base;

  `uvm_component_utils(alu_16_cycle_multiplication_test)


  	function new(string name = "alu_16_cycle_multiplication_test",uvm_component parent=null);
    	  super.new(name,parent);
  	endfunction:new 

	  virtual task run_phase(uvm_phase phase);
        alu_16_cycle_multiplication seq;
        phase.raise_objection(this);
        seq = alu_16_cycle_multiplication::type_id::create("seq");
      seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_16_cycle_multiplication_test

class alu_multiplication_test extends alu_base;

  	`uvm_component_utils(alu_multiplication_test)

  	function new(string name = "alu_multiplication_test",uvm_component parent=null);
      	super.new(name,parent);
  	endfunction:new 

  	virtual task run_phase(uvm_phase phase);
        alu_multiplication seq;
        phase.raise_objection(this);
        seq = alu_multiplication::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
  	endtask:run_phase

endclass:alu_multiplication_test


class alu_regression_test extends alu_base;

  	`uvm_component_utils(alu_regression_test)

  	function new(string name = "alu_regression_test",uvm_component parent=null);
    	  super.new(name,parent);
  	endfunction :new

	  virtual task run_phase(uvm_phase phase);
        alu_regression seq;
        phase.raise_objection(this);
        seq = alu_regression::type_id::create("seq");
        seq.start(env.active_agent.sequencer);
        phase.drop_objection(this);
    endtask:run_phase
endclass:alu_regression_test
