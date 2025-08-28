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

  property rst_check;
		@(posedge clk) disable iff(!rst)
				rst |-> ( RES == 'bz && OFLOW == 'bz && COUT == 'bz && ERR == 'bz && G == 'bz && L == 'bz && E == 'bz);
  endproperty
  assert property(rst_check)
	  else $error("Wrong output for rst");

  property alu_not_known;
    @(posedge clk) !($isunknown({rst,CE,MODE,CMD,INP_VALID,OPA,OPB,CIN}));
  endproperty
  assert property(alu_not_known)
	    else $error("Inputs are x and z type");

	assert property(@(posedge clk) disable iff(CE) !CE |=> RES == $past(RES))
	    else $error("Output changed on clock when clock enable is 0");

  property both_operands_required_arithmetic;
    @(posedge clk) disable iff(rst || (!MODE && !((CMD < 4 || CMD > 8) && CMD < 11)))
    (CE && MODE && ((CMD < 4 || CMD > 8) && (CMD < 11))) |-> (INP_VALID == 2'b11);
	endproperty
  assert property(both_operands_required_arithmetic)
	    else $error("Arithmetic operations requiring two operands are missing input valid 11");

	property both_operands_required_logical;
    @(posedge clk) disable iff(rst || (!MODE && !((CMD < 6 || CMD > 11) && CMD <14)))
    (CE && !MODE && ((CMD < 6 || CMD > 11) && (CMD < 14))) |-> (INP_VALID == 2'b11);
	endproperty
  assert property(both_operands_required_logical)
	    else $error("Logical operations requiring two operands are missing input valid 11");

	property check_inp_valid_for_01_arithmetic;
    @(posedge clk) disable iff(rst || (MODE && !(CMD == 5 || CMD == 4)))
    (CE && MODE && ((CMD == 4) || (CMD == 5))) |-> (INP_VALID == 2'b01 || INP_VALID == 2'b11);
  endproperty
  assert property(check_inp_valid_for_01_arithmetic)
	      else $error("Arithmetic operations requiring operand A only are missing input valid");

  property check_inp_valid_for_10_arithmetic;
    @(posedge clk) disable iff(rst || (MODE && !(CMD == 6 || CMD == 7)))
    (CE && MODE && ((CMD == 6) || (CMD == 7))) |-> (INP_VALID == 2'b10 || INP_VALID == 2'b11);
  endproperty
	assert property(check_inp_valid_for_10_arithmetic)
	    else $error("Arithmetic operations requiring operand B only are missing input valid");


  property check_inp_valid_for_01_logical;
    @(posedge clk) disable iff(rst || (!MODE && !(CMD == 6 || CMD == 8 || CMD == 9)))
    (CE && !MODE && ((CMD == 6) || (CMD == 8) || (CMD == 9))) |-> (INP_VALID == 2'b01 || INP_VALID == 2'b11);
  endproperty
  assert property(check_inp_valid_for_01_logical)
	    else $error("Logical operations requiring operand A only are missing input valid");

  property check_inp_valid_for_10_logical;
    @(posedge clk) disable iff(rst || (!MODE && !(CMD == 7 || CMD == 10 || CMD == 11)))
    (CE && !MODE && ((CMD == 7) || (CMD == 10) || (CMD == 11))) |-> (INP_VALID == 2'b10 || INP_VALID == 2'b11);
  endproperty
  assert property(check_inp_valid_for_10_logical)
	    else $error("Logical operations requiring operand B only are missing input valid");

  property rol_ror_err_check;
    @(posedge clk) disable iff(rst || (!MODE && !(CMD == 12 || CMD == 13)) && (OPB[7:4] == 0))
    (CE && MODE == 0 && (CMD == 12 || CMD == 13)) |-> ERR == 1;
  endproperty
  assert property(rol_ror_err_check)
	    else $error("ROL/ROR did not raise ERR");

  property cmp_output_check;
    @(posedge clk) disable iff(rst || !(MODE && CMD == 8))
    (CE && MODE && CMD == 8 && INP_VALID == 2'b11) |-> (
        (OPA > OPB && G == 1 && L == 0 && E == 0) ||
        (OPA < OPB && G == 0 && L == 1 && E == 0) ||
        (OPA == OPB && G == 0 && L == 0 && E == 1)
    );
  endproperty
  assert property(cmp_output_check)
	    else $error("Comparator output incorrect for CMP");


endprogram	
