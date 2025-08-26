`include "define.sv"

interface alu_interface(input bit CLK,RESET);
  	logic [`WIDTH-1:0] OPA, OPB;
  	logic [`CMD_WIDTH-1:0] CMD;
  	logic [1:0] INP_VALID;
  	logic CE, CIN, MODE;

  	logic ERR, OFLOW, COUT, G, L, E;
  	logic [`WIDTH+1:0] RES;
	event drv_done_e;
  
  	clocking driver_cb@(posedge CLK);
      	default input #0 output #0;
    	  output OPA;
    	  output OPB;
    	  output CMD;
    	  output INP_VALID;
    	  output CE;
    	  output CIN;
    	  output MODE;
  	endclocking

  	clocking monitor_cb@(posedge CLK);
    	  default input #0 output #0;
    	  input ERR;
    	  input OFLOW;
    	  input COUT;
    	  input G, L, E;
    	  input RES;
      	  input INP_VALID;
      	  input OPA, OPB;
      	  input CMD;
      	  input CE;
      	  input CIN;
      	  input MODE;
  	endclocking
  
   	clocking cb_reference_model @(posedge CLK or posedge RESET);
        default input #0 output #0;
        input INP_VALID,MODE,CMD,CE,OPA,OPB,CIN,RESET;
    endclocking

  	modport DRV (clocking driver_cb);
 	modport MON(clocking monitor_cb);
    modport REF(clocking cb_reference_model);
      
  	property clk_valid_check;
        @(posedge CLK) !$isunknown(CLK);
  	endproperty
  	assert property (clk_valid_check)
    else $error("[ASSERTION] Clock signal is unknown at time %0t", $time);
      
    property Reset_signal_check;
        @(posedge CLK) RESET |=> (RES === 9'bz && ERR === 1'bz && E === 1'bz && G === 1'bz && L === 1'bz && COUT === 1'bz && OFLOW === 1'bz);
    endproperty:Reset_signal_check
    assert property(Reset_signal_check)
        $display("RST assertion PASSED at time %0t", $time);
    else
        $info("RST assertion FAILED @ time %0t", $time);

    //2. 16- cycle TIMEOUT assertion
    property ppt_timeout_arithmetic;
        @(posedge CLK) disable iff(RESET) (CE && (CMD == `ADD || CMD == `SUB || CMD == `ADD_CIN || CMD == `SUB_CIN || CMD == `MUL_SHIFT || CMD == `MUL_INC) && (INP_VALID == 2'b01 || INP_VALID == 2'b10)) |-> ##16 (ERR == 1'b1);
    endproperty:ppt_timeout_arithmetic
    assert property(ppt_timeout_arithmetic)
        $display("TIMEOUT FOR ARITHMETIC assertion PASSED at time %0t", $time);
    else
        $warning("Timeout assertion failed at time %0t", $time);

    property ppt_timeout_logical;
        @(posedge CLK) disable iff(RESET) (CE && (CMD == `AND || CMD == `OR || CMD == `NAND || CMD == `XOR || CMD == `XNOR || CMD == `NOR || CMD == `ROR_A_B  || CMD == `ROL_A_B) && (INP_VALID == 2'b01 || INP_VALID == 2'b10)) |-> ##16 (ERR == 1'b1);
    endproperty:ppt_timeout_logical
    assert property(ppt_timeout_logical)
        $display("TIMEOUT FOR LOGICAL assertion PASSED at time %0t", $time);
    else
        $warning("Timeout assertion failed at time %0t", $time);

    //3. ROR/ROL error
    assert property (@(posedge CLK) disable iff(RESET) (CE && MODE && INP_VALID ==2'b11 && (CMD == `ROR_A_B || CMD == `ROL_A_B) && $countones(OPB) > `ROR_WIDTH + 1) |-> ##1 ERR )
        $display("ROR ERROR assertion PASSED at time %0t", $time);
    else
        $info("NO ERROR FLAG RAISED");

       //4. CMD out of range
    property CMD_validation_arithmetic;
        @(posedge CLK)disable iff(RESET) (MODE && CMD > 10) |-> ##1 ERR;
    endproperty:CMD_validation_arithmetic
    assert property (CMD_validation_arithmetic)
        $display("CMD out of range fr arithmetic assertion PASSED at time %0t", $time);
    else
        $info("CMD INVALID ERR NOT RAISED");

    //5. CMD out of range logical
    property CMD_validation_logical;
        @(posedge CLK) disable iff(RESET)(!MODE && CMD > 13) |-> ##1 ERR;
    endproperty: CMD_validation_logical
    assert property (CMD_validation_logical)
        $info("CMD out of range for logical assertion PASSED at time %0t", $time);
    else
        $info("CMD INVALID ERR NOT RAISED");

    // 7. INP_VALID 00 case
    property Error_detection_in_inp_valid_00;
        @(posedge CLK) disable iff(RESET) (INP_VALID == 2'b00) |-> ##1 ERR;
    endproperty:Error_detection_in_inp_valid_00
    assert property ( Error_detection_in_inp_valid_00)
        $display("INP_VALID 00  assertion PASSED at time %0t", $time);
    else
        $info("ERROR NOT raised");

    //8. CE assertion
    property Clock_enable_functionality;
        @(posedge CLK) disable iff(RESET) !CE |-> ##1 ($stable(RES) && $stable(COUT) && $stable(OFLOW) && $stable(G) && $stable(L) && $stable(E) && $stable(ERR));
    endproperty:Clock_enable_functionality
    assert property(Clock_enable_functionality)
        $display("ENABLE  assertion PASSED at time %0t", $time);
    else
        $info("Clock enable assertion failed at time %0t", $time);
      
    property VALID_INPUTS_CHECK;
        @(posedge CLK) disable iff(RESET) CE |-> not($isunknown({OPA,OPB,INP_VALID,CIN,MODE,CMD}));
    endproperty

    assert property(VALID_INPUTS_CHECK)
        $info("inputs valid");
    else
        $info("inputs not valid");
    
    property rst_valid_check;
         @(posedge CLK) !$isunknown(RESET);
    endproperty
    assert property (rst_valid_check)
    else $error("[ASSERTION] Reset signal is unknown at time %0t", $time);
 endinterface:alu_interface

    
