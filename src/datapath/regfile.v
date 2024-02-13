//------------------------------------------------------------------------------
module regfile
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ADDR_WIDTH = 5
)
(
  input wire                        iclk,
  input wire                        iwen3,

  input wire  [MP_ADDR_WIDTH-1 : 0] ia1,
  input wire  [MP_ADDR_WIDTH-1 : 0] ia2,
  input wire  [MP_ADDR_WIDTH-1 : 0] ia3,
  input wire  [MP_DATA_WIDTH-1 : 0] iwdata3,

  output wire [MP_DATA_WIDTH-1 : 0] ordata1,
  output wire [MP_DATA_WIDTH-1 : 0] ordata2
);
//------------------------------------------------------------------------------

  localparam LP_REG_NUM = 2**MP_ADDR_WIDTH;

  reg [MP_DATA_WIDTH-1 : 0] rram [LP_REG_NUM-1 : 0];

  integer i;
  initial begin : init_regfile_ram
    for(i = 0; i < LP_REG_NUM; i = i + 1)
      rram[i] = 0;
  end

  always @(posedge iclk) begin : sproc_wr_reg3
    if (iwen3) begin
      rram[ia3] <= iwdata3;
    end
  end

  assign ordata1 = (ia1 != 0) ? rram[ia1] : 0;
  assign ordata2 = (ia2 != 0) ? rram[ia2] : 0;

endmodule : regfile
