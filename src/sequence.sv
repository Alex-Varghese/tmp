class alu_sequence extends uvm_sequence#(sequence_item);
	`uvm_object_utils(alu_sequence)

	function new(string name = "alu_sequence");
		super.new(name);
	endfunction

	virtual task body();
		req = sequence_item::type_id::create("req");
		wait_for_grant();
		assert(req.randomize());
		send_request(req); 
		wait_for_item_done(); 
		//get_reponse(req);
	endtask	

endclass	

class custom extends uvm_sequence#(sequence_item);
	`uvm_object_utils(custom)

	function new(string name = "custom");
		super.new(name);
	endfunction

	virtual task body();
	  repeat(`no_of_trans) begin
	/* `uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {[0:3]};req.INP_VALID == 3;}) */
	/* `uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {[0:3],8,9,10};req.INP_VALID == 3;}) */
	/* `uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {9,10};req.INP_VALID == 3;req.op_delivery == SINGLE_CYCLE;}) */
	/* `uvm_do_with(req,{req.MODE == 1;req.CE == 0;req.CMD inside {9,10};req.INP_VALID == 3;req.op_delivery == SINGLE_CYCLE;}) */
	`uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {[4:7]};
		if(req.CMD == 4 || req.CMD == 5) 
			req.INP_VALID == 2'b01; 
		else if(req.CMD == 6 || req.CMD ==7) 
			req.INP_VALID == 2; 
		else req.INP_VALID == 3;

		req.op_delivery == SINGLE_CYCLE;})
			end
  endtask 

endclass

class arith extends uvm_sequence#(sequence_item);
	`uvm_object_utils(arith)

	function new(string name = "arith");
		super.new(name);
	endfunction

	virtual task body();
    repeat(`no_of_trans) begin
	`uvm_do_with(req, {
		req.MODE == 1;
		req.CE == 1;
		req.CMD inside {[0:10]};

		if(req.CMD == 4 || req.CMD == 5) 
			req.INP_VALID == 2'b01; 
		else if(req.CMD == 6 || req.CMD ==7) 
			req.INP_VALID == 2; 
		else req.INP_VALID == 3;

		req.op_delivery == SINGLE_CYCLE; 
		})
	 end
/* `uvm_do_with(req,{req.MODE == 1;req.CE == 1;req.CMD inside {[0:3]};req.INP_VALID == 3;req.op_delivery == SINGLE_CYCLE;}) */
  endtask 

endclass	

class logical extends uvm_sequence#(sequence_item);
	`uvm_object_utils(logical)

	function new(string name = "logical");
		super.new(name);
	endfunction

	virtual task body();
    repeat(`no_of_trans) begin
	`uvm_do_with(req, {
		req.MODE == 0;
		req.CE == 1;
		req.CMD inside {[0:13]};

		if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) 
			req.INP_VALID == 2'b01; 
		else if(req.CMD == 7 || req.CMD == 10 || req.CMD == 11) 
			req.INP_VALID == 2; 
		else req.INP_VALID == 3;

		req.op_delivery == SINGLE_CYCLE;
		})
		end
  endtask 

endclass	

class error extends uvm_sequence#(sequence_item);
	`uvm_object_utils(error)

	function new(string name = "error");
		super.new(name);
	endfunction

	virtual task body();
	    repeat(`no_of_trans) begin
		`uvm_do_with(req, {
			req.MODE == 1;
			req.CMD inside {[4:7],[11:15]}; 
			
			if(req.CMD == 4 || req.CMD == 5) 
				req.INP_VALID == 2'b10; 
			else if(req.CMD == 6 || req.CMD == 7) 
				req.INP_VALID == 2'b01; 
			else 
				req.INP_VALID == 2'b00;

			req.CE == 1;
			req.op_delivery == SINGLE_CYCLE;
		})
		`uvm_do_with(req, {
		req.CE == 1;
		req.op_delivery == SINGLE_CYCLE;
		req.MODE == 0;
		req.CMD inside {[6:11],[14:15]};

		if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) 
			req.INP_VALID == 2'b10; 
		else if(req.CMD == 7 || req.CMD == 10 || req.CMD == 11) 
			req.INP_VALID == 2'b01; 
		else 
			req.INP_VALID == 2'b00; 
		})
		end
	endtask	

endclass	

class flag extends uvm_sequence#(sequence_item);
	`uvm_object_utils(flag)
	
	function new(string name = "flag");
		super.new(name);
	endfunction

	virtual task body();
    repeat(`no_of_trans) begin
		`uvm_do_with(req, {
			req.MODE dist {0:=2,1:=8};
			
			if(req.MODE) 
				req.CMD inside {[0:3],8}; 
			else
				req.CMD inside {12,13};    
			
			if(req.MODE)
				if(req.CMD == 4 || req.CMD == 5) 
					req.INP_VALID == 2'b01; 
				else if(req.CMD == 6 || req.CMD == 7) 
					req.INP_VALID == 2'b10; 
				else 
					req.INP_VALID == 2'b11;

			else
				
				if(req.CMD == 6 || req.CMD == 8 || req.CMD == 9) 
					req.INP_VALID == 2'b01; 
				else if(req.CMD == 7 || req.CMD == 10 || req.CMD == 11) 
					req.INP_VALID == 2'b10; 
				else 
					req.INP_VALID == 2'b11; 

			if(req.MODE) {
				if(req.CMD == 0 || req.CMD == 2)
					req.OPA + req.OPB >= 9'b100000000;
				else if(req.CMD == 1 || req.CMD == 3)
					{
						if(req.CIN)
							req.OPA == req.OPB;
						else
							req.OPA < req.OPB;
					}
				else
					req.OPB > 4'b1111;}

		req.CE == 1;
		req.op_delivery == SINGLE_CYCLE;
			})
		end
	endtask	
endclass	

class split_transaction_seq extends uvm_sequence#(sequence_item);
	`uvm_object_utils(split_transaction_seq)

	function new(string name = "split_transaction_seq");
		super.new(name);
	endfunction

	virtual task body();
    repeat(`no_of_trans) begin
			`uvm_do_with(req, {
				req.CE == 1;
				req.op_delivery == SPLIT_OPA_FIRST;  //SINGLE_CYCLE;
				req.CMD inside {[0:3]};
				req.INP_VALID inside {1,2,3};
				/* if(CMD == 4 || CMD == 5) INP_VALID == 2'b01; else if(CMD == 6 || CMD ==7) INP_VALID ==     2;else INP_VALID == 3; */
				req.MODE == 1;
			})
			
			`uvm_do_with(req, {
				req.CE == 1;
				req.op_delivery == SPLIT_OPB_FIRST;  //SINGLE_CYCLE;
				req.CMD inside {[0:3]};
				req.INP_VALID inside {1,2,3};
				req.MODE == 1;
			})
			
			`uvm_do_with(req, {
				req.CE == 1;
				req.op_delivery == SPLIT_TIMEOUT;
				req.CMD inside {[0:3]};
				req.INP_VALID inside {1,2,3};
				req.MODE == 1;
			})
			end
	endtask
endclass

class regress extends uvm_sequence#(sequence_item);
	
	`uvm_object_utils(regress)
	
	arith test1;
	logical test2;
	error test3;
	flag test4;
	split_transaction_seq test5;

	function new(string name = "regress");
		super.new(name);
		test1 = arith::type_id::create("test1");
		test2 = logical::type_id::create("test1");
		test3 = error::type_id::create("test1");
		test4 = flag::type_id::create("test1");
		test5 = split_transaction_seq::type_id::create("test1");
	endfunction

	virtual task body();
		`uvm_do(test1)
		`uvm_do(test2)
		`uvm_do(test3)
		`uvm_do(test4)
		`uvm_do(test5)
	endtask	
endclass	
