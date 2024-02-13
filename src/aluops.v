`ifndef __ALUOPS_V__
`define __ALUOPS_V__

`define ADD_OP 	4'b0000
`define SUB_OP 	4'b0001
`define AND_OP 	4'b0010
`define OR_OP 	4'b0011
`define SLT_OP 	4'b0101
`define SLTU_OP	4'b1101

`define XOR_OP  4'b0110
`define SL_OP   4'b0111
`define SR_OP   4'b1000
`define SRA_OP  4'b1001

`define NOP_OP  4'bxxxx

`endif // __ALUOPS_V__