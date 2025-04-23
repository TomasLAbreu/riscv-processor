//------------------------------------------------------------------------------
module riscv_dp_regfile
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32,
  parameter MP_ADDR_WIDTH = 5
)
(
  input wire                        iclk,

  input wire  [MP_ADDR_WIDTH-1 : 0] iaddr1,
  output wire [MP_DATA_WIDTH-1 : 0] ord_data1,

  input wire  [MP_ADDR_WIDTH-1 : 0] iaddr2,
  output wire [MP_DATA_WIDTH-1 : 0] ord_data2,

  input wire  [MP_ADDR_WIDTH-1 : 0] iaddr3,
  input wire                        iwr_en3,
  input wire  [MP_DATA_WIDTH-1 : 0] iwr_data3

);
//------------------------------------------------------------------------------

  localparam LP_REG_NUM = 2**MP_ADDR_WIDTH;

  reg [MP_DATA_WIDTH-1 : 0] rram [LP_REG_NUM-1 : 0];

  integer i;
  initial begin : init_riscv_dp_regfile_ram // TODO: check this
    for(i = 0; i < LP_REG_NUM; i = i + 1)
      rram[i] = 0;
  end

  always @(posedge iclk) begin : sproc_wr_reg3
    if (iwr_en3) begin
      rram[iaddr3] <= iwr_data3;
    end
  end

  assign ord_data1 = (iaddr1 != 0) ? rram[iaddr1] : 0;
  assign ord_data2 = (iaddr2 != 0) ? rram[iaddr2] : 0;

endmodule : riscv_dp_regfile
