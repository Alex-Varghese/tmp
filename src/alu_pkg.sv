package alu_pkg;
				import std::*;
				import uvm_pkg::*;		
			`include "define.sv"	
  	`include "uvm_macros.svh"
  	`include "alu_sequence_item.sv"
	`include "alu_sequence.sv"
	`include "alu_sequencer.sv"
    `include "alu_driver.sv"
    `include "alu_monitor.sv"
    `include "alu_agent.sv"
    `include "alu_scoreboard.sv"
    `include "alu_coverage.sv"
    `include "alu_environment.sv"
    `include "alu_test.sv"
endpackage : alu_pkg 
