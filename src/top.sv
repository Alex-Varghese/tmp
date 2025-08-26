`include "uvm_pkg.sv"
`include "uvm_macros.svh"
`include "alu_pkg.sv"
`include "alu_interface.sv"
`include "design.v"
module top;
  	import uvm_pkg::*;  
  	import alu_pkg::*;
 
   	bit CLK;
  	bit RESET;
  
  	always #(`CLK_PERIOD/2) CLK = ~CLK;
  
  	initial begin:reset
    	RESET = 1;
    	#5 RESET =0;
  	end:reset
  	alu_interface intrf(CLK,RESET);
  
  	ALU_DESIGN #(.DW(`WIDTH),.CW(`CMD_WIDTH)) DUV(.OPA(intrf.OPA),.OPB(intrf.OPB),.CMD(intrf.CMD),.CE(intrf.CE),.MODE(intrf.MODE),.CIN(intrf.CIN),.INP_VALID(intrf.INP_VALID),.RES(intrf.RES),.COUT(intrf.COUT),.OFLOW(intrf.OFLOW),.G(intrf.G),.L(intrf.L),.E(intrf.E),.ERR(intrf.ERR),.CLK(intrf.CLK),.RST(RESET));
  
  	initial begin:config_db 
    	uvm_config_db#(virtual alu_interface)::set(uvm_root::get(),"*","vif",intrf);
    	$dumpfile("dump.vcd");
		  $dumpvars;
  	end:config_db
  
  	initial begin:run
    	run_test("alu_regression_test");
    	#100 $finish;
  	end:run
endmodule:top
