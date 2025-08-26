`define MAX ((1<<`WIDTH)-1)  // For example, if width is defined

`define WIDTH 8
`define CMD_WIDTH 4
`define no_of_transaction 10000


`define ADD              4'b0000
`define SUB              4'b0001
`define ADD_CIN          4'b0010
`define SUB_CIN          4'b0011
`define INC_A            4'b0100
`define DEC_A            4'b0101
`define INC_B            4'b0110
`define DEC_B            4'b0111
`define CMP              4'b1000
`define MUL_INC          4'b1001
`define MUL_SHIFT        4'b1010


`define AND              4'b0000
`define NAND             4'b0001
`define OR               4'b0010
`define NOR              4'b0011
`define XOR              4'b0100
`define XNOR             4'b0101
`define NOT_A            4'b0110
`define NOT_B            4'b0111
`define SHR1_A           4'b1000
`define SHL1_A           4'b1001
`define SHR1_B           4'b1010
`define SHL1_B           4'b1011
`define ROL_A_B          4'b1100
`define ROR_A_B          4'b1101

`define MAX_WAIT_CYCLE 16

`define CLK_PERIOD 10

`define ROR_WIDTH $clog2(`WIDTH)
