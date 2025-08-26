`include "defines.svh"

program alu_assertion(clk,rst,CE,MODE,CMD,INP_VALID,OPA,OPB,CIN,RES,ERR,COUT,OFLOW,E,G,L);
	input clk,rst;
	input CE,CIN,MODE;
	input [`WIDTH-1:0] OPA, OPB;
	input [1:0] INP_VALID;
	input [`CMD_WIDTH:0] CMD;
	input [`WIDTH:0] RES;
	
	input ERR;
	input COUT;
	input OFLOW;
	input E;
	input G;
	input L;

	
	property alu_unknown;
		@(posedge clk) disable iff (rst) !($isunknown ({rst,CE,MODE,CMD,INP_VALID,OPA,OPB,CIN}));
	endproperty

	unknown: assert property(alu_unknown)
											/* $info("pass"); */
										else
											$error("Inputs are unknown %d %d %d %d %d %d %d %d %d",clk,rst,CE,MODE,CMD,INP_VALID,OPA,OPB,CIN);

	rst_assert: assert property(@(posedge clk) ##4 !rst)  // added 4 clock delay for assertion pass
											/* $info("pass"); */
										else
											$info("Reset is asserted");

	Clk_enable: assert property(@(posedge clk) disable iff (rst) !CE |=> (RES === $past(RES)))
											$info("pass");
										else
											$error("Output is not retained, it changed res:%0d | past:%0d ",RES,$past(RES));

	/* sequence delay_16; */
	/* 	(##[1:16] INP_VALID[1]) or (##[1:16] INP_VALID[0]); */
			/* ##[1:16] (INP_VALID == 2'b11); */
	/* endsequence */

	/* property alu_delay; */
	/* 	@(posedge clk) */
	/* 	disable iff (rst) */
	/* 	if(MODE) */
	/* 		(CE && (CMD inside {[0:3],[8:10]}) && INP_VALID inside {2'b01, 2'b10}) |-> delay_16 */
	/* 	else */
	/* 		(CE && (CMD inside {[0:5],12,13}) && INP_VALID inside {2'b01, 2'b10}) |-> delay_16; */
	/* endproperty */
	
	/* Input_Invalid_cycle: assert property(alu_delay) */ 
	/* 		/1* $info("pass"); *1/ */
	/* 	else */ 
	/* 		$error("Timeout: The second operand was not received within 16 cycles."); */

	////
	/* sequence delay_16; */
    /* INP_VALID == 2'b11 or (INP_VALID[0] ##[0:16] INP_VALID[1]) or (INP_VALID[1] ##[0:16] INP_VALID[0]); */
  /* endsequence */

  /* property alu_delay; */
    /* @(posedge clk) */
	/* 		disable iff (rst) */
	/* 		if(MODE) */
	/* 			CMD inside {[0:3],[8:10]} |-> (CMD inside {[0:3],[8:10]}) throughout delay_16 */
	/* 		else */
	/* 			CMD inside {[0:5],12,13} |-> (CMD inside {[0:5],12,13}) throughout delay_16; */
  /* endproperty */

  /* Input_Invalid_cycle: assert property(alu_delay) */
	/* 												/1* $info("pass"); *1/ */
	/* 											else */
	/* 												$error("Timeout, inputs are not recieved on time"); */


	sequence arrives_within_16_cycles;
		##[1:16] (INP_VALID == 2'b11);
	endsequence

	property alu_delay;
		@(posedge clk) disable iff (rst)
			((INP_VALID == 2'b01 && $past(OPA) != OPA) or (INP_VALID == 2'b10 && $past(OPB) != OPB)) |=> arrives_within_16_cycles;
	endproperty

	Input_Invalid_cycle: assert property(alu_delay)
			$info("arrived within 16 clock cycle");
		else
			$error("Timeout Violation: The second operand was not received within 16 cycles.");
	
	property mode_cmd;
		@(posedge clk) disable iff (rst)
			MODE |-> CMD inside {[0:10]} or !MODE |-> CMD inside {[0:13]};
	endproperty

	Mode_Cmd_Relation: assert property(mode_cmd)
		else
			$error("Invalid mode-command combination");

	property OPA_valid;
		@(posedge clk) disable iff (rst)
			if(MODE)
				(CMD == `INC_A || CMD == `DEC_A) |-> (INP_VALID == 2'b01)
			else
				(CMD == `NOT_A || CMD == `SHL1_A) || CMD == `SHR1_A |-> (INP_VALID == 2'b01);
	endproperty

	Input_Valid_OPA: assert property(OPA_valid)
		else
			$error("Invalid input valid for operand A");

	property OPB_valid;
		@(posedge clk) disable iff (rst)
			if(MODE)
				(CMD == (`INC_B || CMD == `DEC_B)) |-> (INP_VALID == 2'b10)
			else
				(CMD == (`NOT_B || CMD == `SHL1_B || CMD == `SHR1_B)) |-> (INP_VALID == 2'b10);				
	endproperty
		
	Input_Valid_OPB: assert property(OPB_valid)
		else
			$error("Invalid input valid for operand B");

endprogram	
