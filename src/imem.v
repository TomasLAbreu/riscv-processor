//------------------------------------------------------------------------------
module instr_mem
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ADDR_WIDTH = 8
)
(
  input wire  [MP_DATA_WIDTH-1 : 0]  iaddr,  // memory position to access/index
  output wire [MP_DATA_WIDTH-1 : 0]  ordata // read data reg
);
//------------------------------------------------------------------------------
  localparam LP_DEPTH = 2**MP_ADDR_WIDTH;

  reg [MP_DATA_WIDTH-1 : 0] rram [LP_DEPTH-1 : 0];

  // initial $readmemh("riscvtest.txt", rram);
  initial $readmemh("../sim/riscvtest.txt", rram);

  assign ordata = rram[iaddr[MP_DATA_WIDTH-1 : 2]];

endmodule : instr_mem
