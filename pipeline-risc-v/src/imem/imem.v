//------------------------------------------------------------------------------
module instr_mem
//------------------------------------------------------------------------------
#(
  parameter MP_WIDTH = 32,
  parameter MP_DEPTH = 256
)
(
  input wire  [MP_WIDTH-1 : 0]  ipos,  // memory position to access/index
  output wire [MP_WIDTH-1 : 0]  ordata // read data reg
);
//------------------------------------------------------------------------------

  reg [MP_WIDTH-1 : 0] rram [MP_DEPTH-1 : 0];

  initial $readmemh("riscvtest.txt", rram);

  assign ordata = rram[ipos[MP_WIDTH-1 : 2]];

endmodule : instr_mem
