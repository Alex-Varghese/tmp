`ifndef DEFINES_SV  
`define DEFINES_SV  

/* `define no_trans 5000 */ 
`define WIDTH 8
`define CMD_WIDTH 3
`define POW_2_N $clog2(`WIDTH)

//Arithematic Commands
`define ADD				0
`define SUB				1
`define ADD_CIN		2
`define SUB_CIN		3
`define INC_A			4
`define DEC_A			5
`define INC_B			6
`define DEC_B			7
`define CMP				8
`define INC_MULT  9
`define SH_MULT		10

//Logical Commands
`define AND				0
`define NAND			1
`define OR				2
`define NOR				3
`define XOR				4
`define XNOR			5
`define NOT_A			6
`define NOT_B			7
`define SHR1_A		8
`define SHL1_A		9
`define SHR1_B		10
`define SHL1_B		11
`define ROL_A_B		12
`define ROR_A_B		13

`endif 
