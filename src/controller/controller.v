module controller (
  input             iclk,
  input             irst,

  input             FlushE,
  input wire  [6:0] opD,
  input wire  [2:0] funct3D,
  input wire        funct7b5D,

  // ALU flags
  input wire        ZeroE,
  input wire        OverflowE,
  input wire        CarryE,
  input wire        NegativeE,
  output wire [2:0] ResultSrcW,

  output wire       MemWriteM,
  output wire       PCSrcE,
  output wire       ALUSrcE,
  output wire       RegWriteW,
  output wire       RegWriteM,
  output wire       PCResultSrcE,
  output wire [2:0] ImmSrcD,
  output wire [3:0] ALUControlE,
  output wire       ResultSrcb0E
);

  wire [1:0] ALUOpD;

  // ============================================================================
  // pipeline Decode - Execute
  // ============================================================================
  // inputs
  wire RegWriteD;
  wire [2:0] ResultSrcD;
  wire MemWriteD;
  wire [3:0] ALUControlD;
  wire ALUSrcD;
  wire PCResultSrcD;

  // outputs
  wire [6:0] opE;
  wire [2:0] funct3E;
  wire RegWriteE;
  wire [2:0] ResultSrcE;
  wire MemWriteE;

  // ============================================================================
  // pipeline Execute - Memory
  // ============================================================================
  // outputs
  wire [2:0] ResultSrcM;

  // ============================================================================
  // pipelines instantiation
  // ============================================================================

  always @(posedge iclk) begin : sproc_pipeline_dec_exec
    if (irst | FlushE) begin
      opE          <= {7{1'b0}};
      funct3E      <= {{1'b0}};
      RegWriteE    <= {{1'b0}};
      ResultSrcE   <= {{1'b0}};
      MemWriteE    <= {{1'b0}};
      ALUControlE  <= {{1'b0}};
      ALUSrcE      <= {{1'b0}};
      PCResultSrcE <= {{1'b0}};
    end else begin
      opE          <= opD;
      funct3E      <= funct3D;
      RegWriteE    <= RegWriteD;
      ResultSrcE   <= ResultSrcD;
      MemWriteE    <= MemWriteD;
      ALUControlE  <= ALUControlD;
      ALUSrcE      <= ALUSrcD;
      PCResultSrcE <= PCResultSrcD;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_exec_mem
    if (irst) begin
      RegWriteM  <= {{1'b0}};
      ResultSrcM <= {{1'b0}};
      MemWriteM  <= {{1'b0}};
    end else begin
      RegWriteM  <= RegWriteE;
      ResultSrcM <= ResultSrcE;
      MemWriteM  <= MemWriteE;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_mem_wr
    if (irst) begin
      RegWriteW  <= {{1'b0}};
      ResultSrcW <= {{1'b0}};
    end else begin
      RegWriteW  <= RegWriteM;
      ResultSrcW <= ResultSrcM;
    end
  end

  // ============================================================================
  // controller
  // ============================================================================

  assign ResultSrcb0E = ResultSrcE[0];

  jumpdec jd(
    .op(opE),
    .funct3(funct3E),
    .Zero(ZeroE),
    .Overflow(OverflowE),
    .Carry(CarryE),
    .Negative(NegativeE),
    .PCSrc(PCSrcE)
  );

  maindec md(
    .op(opD),
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .ALUSrc(ALUSrcD),
    .RegWrite(RegWriteD),
    .PCResultSrc(PCResultSrcD),
    .ImmSrc(ImmSrcD),
    .ALUOp(ALUOpD)
  );

  aludec ad(
    .opb5(opD[5]),
    .funct3(funct3D),
    .funct7b5(funct7b5D),
    .ALUOp(ALUOpD),
    .ALUControl(ALUControlD)
  );

endmodule
