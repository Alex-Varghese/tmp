class alu_sequence extends uvm_sequence#(alu_sequence_item);
  
    `uvm_object_utils(alu_sequence)
    function new(string name = "alu_sequence");
   	  	 super.new(name);
 	  endfunction:new


  	virtual task body();
        repeat(20)begin
            req = alu_sequence_item::type_id::create("req");
            wait_for_grant();
            req.randomize();
            send_request(req);
            wait_for_item_done();
        end
  	endtask
endclass:alu_sequence

class alu_single_operand_operation extends uvm_sequence#(alu_sequence_item);
  
  	`uvm_object_utils(alu_single_operand_operation)
   
  	function new(string name = "alu_single_operand_operation");
      	super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction)begin:repeat_loop
            `uvm_do_with(req,{req.CE == 1;req.INP_VALID dist{3:=5,2:=2,1:=2};req.CMD inside{`INC_A,`INC_B,`SHR1_A,`SHR1_B,`SHL1_A,`SHR1_B,`NOT_A,`NOT_B};})
        end
  	endtask
endclass

class alu_multiple_operand_arithmetic extends uvm_sequence#(alu_sequence_item);
  
    `uvm_object_utils(alu_multiple_operand_arithmetic)
   
    function new(string name = "alu_multiple_operand_arithmetic");
      	super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction) begin:repeat_loop
            `uvm_do_with(req,{req.INP_VALID==3;req.MODE == 1;req.CMD inside{[0:8]};})
    	  end:repeat_loop
  	endtask:body
endclass:alu_multiple_operand_arithmetic


class alu_multiple_operand_logical extends uvm_sequence#(alu_sequence_item);
  
    `uvm_object_utils(alu_multiple_operand_logical)
   
    function new(string name = "alu_multiple_operand_logical");
    	  super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction) begin:repeat_loop
            `uvm_do_with(req,{req.INP_VALID==3;req.MODE == 0;req.CMD inside{[0:13]};})
    	  end:repeat_loop
  	endtask:body
endclass:alu_multiple_operand_logical


class alu_invalid_logical extends uvm_sequence#(alu_sequence_item);
  
    `uvm_object_utils(alu_invalid_logical)
   
    function new(string name = "alu_invalid_logical");
      	super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction)begin:repeat_loop
            `uvm_do_with(req,{req.INP_VALID==3;req.MODE == 0;req.CE == 1;req.CMD inside{[14:15]};})
        end:repeat_loop
  	endtask:body
endclass:alu_invalid_logical
                                                                                     
                                                           
                                                                                     
class alu_invalid_arithmetic extends uvm_sequence#(alu_sequence_item);
  
  	  `uvm_object_utils(alu_invalid_arithmetic)
   
  	  function new(string name = "alu_invalid_arithmetic");
    	    super.new(name);
  	  endfunction:new
  
  	  virtual task body();
          repeat(`no_of_transaction)begin:repeat_loop
              `uvm_do_with(req,{req.INP_VALID==3;req.MODE == 1;req.CE == 1;req.CMD inside{[11:15]};})
          end:repeat_loop
  	endtask:body
endclass:alu_invalid_arithmetic         
                                                                                     
                                                                                     
class alu_compare extends uvm_sequence#(alu_sequence_item);
  
  	`uvm_object_utils(alu_compare)
   
  	function new(string name = "alu_compare");
    	  super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction)begin:repeat_loop
            `uvm_do_with(req,{req.INP_VALID==3;req.MODE == 1;req.CE == 1;req.CMD ==8;req.OPA inside{[10:13]};req.OPB inside{[10:13]};})
        end:repeat_loop
  	endtask:body
endclass:alu_compare
                                                                                     
                                                                                     
class alu_16_cycle_normal_logical extends uvm_sequence#(alu_sequence_item);
  
    `uvm_object_utils(alu_16_cycle_normal_logical)
   
    function new(string name = "alu_16_cycle_normal_logical");
      	super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction)begin:repeat_loop
            `uvm_do_with(req,{req.MODE == 0;req.CE == 1;req.CMD inside{[0:13]};})
        end:repeat_loop
  	endtask:body
endclass:alu_16_cycle_normal_logical
                          
class alu_16_cycle_normal_arithmetic extends uvm_sequence#(alu_sequence_item);
  
    `uvm_object_utils(alu_16_cycle_normal_arithmetic)
   
    function new(string name = "alu_16_cycle_normal_arithemtic");
      	super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction)begin:repeat_loop
              `uvm_do_with(req,{req.MODE ==1 ;req.CE == 1;req.CMD inside{[0:8]};})
        end:repeat_loop
  	endtask:body
endclass:alu_16_cycle_normal_arithmetic
                          
class alu_inactive_CE extends uvm_sequence#(alu_sequence_item);
  
    `uvm_object_utils(alu_inactive_CE)
   
    function new(string name = "alu_inactive_CE");
      	super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction)begin:repeat_loop
            `uvm_do_with(req,{req.CE == 0;req.INP_VALID ==3;})
        end:repeat_loop
  	endtask:body
endclass:alu_inactive_CE
                                                                                     
class alu_16_cycle_multiplication extends uvm_sequence#(alu_sequence_item);
  
  	`uvm_object_utils(alu_16_cycle_multiplication)
   
  	function new(string name = "alu_16_cycle_multiplication");
      	super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction)begin:repeat_loop
            `uvm_do_with(req,{req.INP_VALID==3;req.MODE == 1;req.CE == 1;req.CMD ==8;})
        end:repeat_loop
  	endtask:body
endclass:alu_16_cycle_multiplication                                                                                 
                                                                                    

class alu_multiplication extends uvm_sequence#(alu_sequence_item);
  
  	`uvm_object_utils(alu_multiplication)
   
  	function new(string name = "alu_multiplication");
    	  super.new(name);
  	endfunction:new
  
  	virtual task body();
        repeat(`no_of_transaction)begin:repeat_loop
    		    `uvm_do_with(req,{req.INP_VALID==3;req.MODE == 1;req.CE == 1;req.CMD inside{`MUL_INC,`MUL_SHIFT};})
        end:repeat_loop
  	endtask:body
endclass:alu_multiplication

class alu_regression extends uvm_sequence#(alu_sequence_item);
  
    alu_single_operand_operation  single;
  	alu_multiple_operand_arithmetic multiple_arithmetic;
  	alu_multiple_operand_logical multiple_logical;
  	alu_invalid_arithmetic invalid_arithmetic;
  	alu_invalid_logical invalid_logical;
  	alu_compare cmp;
	  alu_16_cycle_normal_logical waiting_logical;
	  alu_16_cycle_normal_arithmetic waiting_arithemtic;
	  alu_inactive_CE inactive_ce;
	  alu_16_cycle_multiplication waiting_multiplication;
    alu_multiplication  mul;

    `uvm_object_utils(alu_regression)
   
  	function new(string name = "alu_regression");
      	super.new(name);
  	endfunction:new
  
  	virtual task body();
    	  `uvm_do(single)
      	`uvm_do(multiple_arithmetic)
      	`uvm_do(multiple_logical)
      	`uvm_do(invalid_arithmetic)
       	`uvm_do(invalid_logical)
      	`uvm_do(cmp)
      	`uvm_do(waiting_logical)
      	`uvm_do(waiting_arithemtic)
      	`uvm_do(inactive_ce)
     	  `uvm_do(waiting_multiplication)
     	  `uvm_do(mul)
  	endtask:body
endclass:alu_regression
