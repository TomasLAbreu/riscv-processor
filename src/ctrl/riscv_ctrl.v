module riscv_ctrl (
  input             iclk,
  input             irst_n,
  input             iflush_e,

  input wire  [6:0] iop,
  input wire  [2:0] ifunct3,
  input wire        ifunct7b5,

  // ALU flags
  input wire        ialu_zero,
  input wire        ialu_ovfl,
  input wire        ialu_carry,
  input wire        ialu_neg,
  output reg        oalu_src,
  output reg  [3:0] oalu_ctrl,

  output reg  [2:0] ord_wr_data_src_2d,
  output wire       ord_wr_data_srcb0,

  output reg        odmem_wr_en_1d,
  output reg        ord_wr_en_2d,
  output reg        ord_wr_en_1d,
  output wire       opc_src,
  output reg        opc_result_src,
  output wire [2:0] oimm_src
);
//----------------------------------------------------------------------------

  wire [1:0] walu_op;

  // pipeline Decode - Execute
  wire        wrd_wr_en_nxt;
  wire  [2:0] wresult_src_nxt;
  wire        wdmem_wr_en_nxt;
  wire  [3:0] walu_ctrl_nxt;
  wire        walu_src_nxt;
  wire        wpc_result_src_nxt;

  reg [6:0] rop;
  reg [2:0] rfunct3;
  reg       rrd_wr_en;
  reg [2:0] rrd_wr_data_src;
  reg       rdmem_wr_en;

  // pipeline Execute - Memory
  reg  [2:0] rrd_wr_data_src_1d;

  //----------------------------------------------------------------------------
  // pipeline decode-execute
  //----------------------------------------------------------------------------

  riscv_ctrl_maindec u_maindec (
    .iop            (iop),
    .oresult_src    (wresult_src_nxt),
    .odmem_wr_en    (wdmem_wr_en_nxt),
    .oalu_src       (walu_src_nxt),
    .ord_wr_en      (wrd_wr_en_nxt),
    .opc_result_src (wpc_result_src_nxt),
    .oimm_src       (oimm_src),
    .oalu_op        (walu_op)
  );

  riscv_ctrl_aludec u_aludec (
    .ialu_op    (walu_op),
    .iop_b5     (iop[5]),
    .ifunct3    (ifunct3),
    .ifunct7_b5 (ifunct7b5),
    .oalu_ctrl  (walu_ctrl_nxt)
  );

  always @(posedge iclk) begin : sproc_stage_execute
    if ((!irst_n) || iflush_e) begin
      rop             <= {7{1'b0}};
      rfunct3         <= {3{1'b0}};
      rrd_wr_en       <= 1'b0;
      rrd_wr_data_src <= {3{1'b0}};
      rdmem_wr_en     <= 1'b0;
      oalu_ctrl       <= {4{1'b0}};
      oalu_src        <= 1'b0;
      opc_result_src  <= 1'b0;
    end else begin
      rop             <= iop;
      rfunct3         <= ifunct3;
      rrd_wr_en       <= wrd_wr_en_nxt;
      rrd_wr_data_src <= wresult_src_nxt;
      rdmem_wr_en     <= wdmem_wr_en_nxt;
      oalu_ctrl       <= walu_ctrl_nxt;
      oalu_src        <= walu_src_nxt;
      opc_result_src  <= wpc_result_src_nxt;
    end
  end

  assign ord_wr_data_srcb0 = rrd_wr_data_src[0];

  riscv_ctrl_jumpdec u_jumpdec (
    .iop        (rop),
    .ifunct3    (rfunct3),
    .ialu_zero  (ialu_zero),
    .ialu_ovfl  (ialu_ovfl),
    .ialu_carry (ialu_carry),
    .ialu_neg   (ialu_neg),
    .opc_src    (opc_src)
  );

  //----------------------------------------------------------------------------
  // pipeline execute-memory
  //----------------------------------------------------------------------------

  always @(posedge iclk) begin : sproc_stage_memory
    if (!irst_n) begin
      ord_wr_en_1d       <= 1'b0;
      odmem_wr_en_1d     <= 1'b0;
      rrd_wr_data_src_1d <= {3{1'b0}};
    end else begin
      ord_wr_en_1d       <= rrd_wr_en;
      odmem_wr_en_1d     <= rdmem_wr_en;
      rrd_wr_data_src_1d <= rrd_wr_data_src;
    end
  end

  //----------------------------------------------------------------------------
  // pipeline memory-writeback
  //----------------------------------------------------------------------------

  always @(posedge iclk) begin : sproc_stage_writeback
    if (!irst_n) begin
      ord_wr_en_2d       <= 1'b0;
      ord_wr_data_src_2d <= {3{1'b0}};
    end else begin
      ord_wr_en_2d       <= ord_wr_en_1d;
      ord_wr_data_src_2d <= rrd_wr_data_src_1d;
    end
  end

endmodule
