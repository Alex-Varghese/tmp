`include "uvm_macros.svh"
import uvm_pkg::*;
`include "alu_pkg.sv"
`include "interface.sv"
`include "assertion.sv"
import alu_pkg::*;      
`include "alu.v"

module top;
  bit clk;
  bit reset;

  always #5 clk = ~clk;

  initial begin
    reset = 1;
		repeat(2) @(negedge clk);
		reset = 0;
  end

  alu_intf intf(clk,reset);

	ALU_DESIGN DUT(
		.OPA(intf.OPA),
		.OPB(intf.OPB),
		.CMD(intf.CMD),
		.CE(intf.CE),
		.CIN(intf.CIN),
		.INP_VALID(intf.INP_VALID),
		.MODE(intf.MODE),
		.G(intf.G),
		.L(intf.L),
		.E(intf.E),
		.ERR(intf.ERR),
		.COUT(intf.COUT),
		.OFLOW(intf.OFLOW),
		.RES(intf.RES),
		.CLK(clk),
		.RST(reset));

		bind intf alu_assertion ASSERT(.*);
			/* .clk(clk), */
			/* .rst(reset), */
			/* .CE(intf.CE), */
			/* .OPA(intf.OPA), */
			/* .OPB(intf.OPB), */
			/* .MODE(intf.MODE), */
			/* .INP_VALID(intf.INP_VALID), */
			/* .CMD(intf.CMD), */
			/* .CIN(intf.CIN), */
			/* .RES(intf.RES), */
			/* .COUT(intf.COUT), */
			/* .OFLOW(intf.OFLOW), */
			/* .E(intf.E), */
			/* .G(intf.G), */	
			/* .L(intf.L), */
			/* .ERR(intf.ERR)); */

  initial begin
   uvm_config_db#(virtual alu_intf)::set(uvm_root::get(),"*","vif",intf);
  end

  initial begin
    /* run_test("custom_test"); */
    /* run_test("arith_test"); */
    /* run_test("logical_test"); */
    /* run_test("error_test"); */
    /* run_test("flag_test"); */
    /* run_test("split_test"); */
    run_test("regress_test");
    #100 $finish;
  end
endmodule
