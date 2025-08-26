`include "defines.svh"
typedef enum { SINGLE_CYCLE, SPLIT_OPA_FIRST, SPLIT_OPB_FIRST, SPLIT_TIMEOUT } op_delivery_e;

class sequence_item extends uvm_sequence_item;
	rand logic [`WIDTH-1:0] OPA;
	rand logic [`WIDTH-1:0] OPB;
	rand logic [`CMD_WIDTH:0] CMD;
	rand logic [1:0] INP_VALID;
	rand logic CIN, CE, MODE;

	logic OFLOW, COUT, E, G, L, ERR;
	logic [`WIDTH:0] RES;
	bit SCB_RST;  
	rand op_delivery_e op_delivery;

	`uvm_object_utils_begin(sequence_item)
		`uvm_field_int(OPA,UVM_ALL_ON)
		`uvm_field_int(OPB,UVM_ALL_ON)
		`uvm_field_int(CMD,UVM_ALL_ON)
		`uvm_field_int(INP_VALID,UVM_ALL_ON)
		`uvm_field_int(CIN,UVM_ALL_ON)
		`uvm_field_int(CE,UVM_ALL_ON)
		`uvm_field_int(MODE,UVM_ALL_ON)
		`uvm_field_int(OFLOW,UVM_ALL_ON)
		`uvm_field_int(COUT,UVM_ALL_ON)
		`uvm_field_int(E,UVM_ALL_ON)
		`uvm_field_int(G,UVM_ALL_ON)
		`uvm_field_int(L,UVM_ALL_ON)
		`uvm_field_int(ERR,UVM_ALL_ON)
		`uvm_field_int(RES,UVM_ALL_ON)
		`uvm_field_int(SCB_RST,UVM_ALL_ON)
		`uvm_field_enum(op_delivery_e, op_delivery, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "sequence_item");
		super.new(name);
	endfunction	

endclass	
