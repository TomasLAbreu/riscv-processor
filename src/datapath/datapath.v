module datapath (
  clk,
  reset,

  ResultSrcW,
  PCSrcE,
  ALUSrcE,
  RegWriteW,
  ImmSrcD,
  ALUControlE,
  PCResultSrcE,

  // hazard unit flags
  ForwardAE,
  ForwardBE,
  StallF,
  StallD,
  FlushD,
  FlushE,

  // outputs
  // hazard unit inputs
  Rs1D,
  Rs2D,
  Rs1E,
  Rs2E,
  RdE,

  RdM,
  RdW,

  // ALU flags
  ZeroE,
  OverflowE,
  CarryE,
  NegativeE,

  PCF,
  InstrF,
  InstrD,
  ALUResultM,
  WriteDataM,
  MemDataM,
  InstrM_2b   //last 2 bits to be used on dmem
);
  input wire clk;
  input wire reset;

  input wire [2:0] ResultSrcW;
  input wire PCSrcE;
  input wire ALUSrcE;
  input wire RegWriteW;
  input wire [2:0] ImmSrcD;
  input wire [3:0] ALUControlE;
    input wire PCResultSrcE;

  input [1:0] ForwardAE;
  input [1:0] ForwardBE;
  input StallF;
  input StallD;
  input FlushD;
  input FlushE;

  output [4:0] Rs1D;
  output [4:0] Rs2D;
  output [4:0] Rs1E;
  output [4:0] Rs2E;
  output [4:0] RdE;

  output [4:0] RdM;
  output [4:0] RdW;

  // ALU flags
  output wire ZeroE;
  output wire OverflowE;
  output wire CarryE;
  output wire NegativeE;

  output wire [31:0] PCF;
  input wire [31:0] InstrF;
  output wire [31:0] InstrD;
  output wire [31:0] ALUResultM;
  output wire [31:0] WriteDataM;
  input wire [31:0] MemDataM;
  output wire [1:0] InstrM_2b;    //last 2 bits to be used on dmem

  wire [31:0] ReadDataM;
  wire [31:0] PCNextF;
  wire [31:0] PCTargetE;
  wire [31:0] PCResultE; // result of mux ALUResult and PCTarget

  reg [31:0] SrcAE;
  wire [31:0] SrcBE;
  wire [31:0] ResultW;

  reg [31:0] ResultW_r;

  // ============================================================================
  // pipeline Fetch - Decode
  // ============================================================================
  // inputs
  wire [31:0] PCPlus4F;

  // outputs
  // wire [31:0] InstrD;
  wire [31:0] PCD;
  wire [31:0] PCPlus4D;

  // ============================================================================
  // pipeline Decode - Execute
  // ============================================================================
  // inputs
  wire [31:0] RD1D;
  wire [31:0] RD2D;
  wire [4:0] RdD;
  wire [31:0] ImmExtD;

  // outputs
  wire [2:0] InstrE;
  wire [31:0] RD1E;
  wire [31:0] RD2E;
  wire [31:0] PCE;
  wire [31:0] ImmExtE;
  wire [31:0] PCPlus4E;

  // ============================================================================
  // pipeline Execute - Memory
  // ============================================================================
  // inputs
  reg [31:0] WriteDataE;
  wire [31:0] ALUResultE;

  // outputs
  wire [2:0] InstrM;
  wire [31:0] ImmExtM;
  wire [31:0] PCResultM;
  wire [31:0] PCPlus4M;

  // ============================================================================
  // pipeline Memory - Writeback
  // ============================================================================
  // outputs
  wire [31:0] ImmExtW;
  wire [31:0] ALUResultW;
  wire [31:0] ReadDataW;
  wire [31:0] PCResultW;
  wire [31:0] PCPlus4W;

  assign InstrM_2b = InstrM[1:0];

  // ============================================================================
  // pipelines instantiation
  // ============================================================================

  always @(posedge iclk) begin : sproc_pipeline_fet_dec
    if (irst | FlushD) begin
      InstrD   <= {{1'b0}};
      PCD      <= {{1'b0}};
      PCPlus4D <= {{1'b0}};
    end else begin
      if (~StallD) begin
        InstrD   <= InstrF;
        PCD      <= PCF;
        PCPlus4D <= PCPlus4F;
      end
    end
  end

  always @(posedge iclk) begin
    if (irst | FlushE) begin
      InstrE <= {{1'b0}};
    end else begin
      InstrE <= InstrD[14:12],
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_dec_exec
    if (irst | FlushE) begin
      RD1E     <= {{1'b0}};
      RD2E     <= {{1'b0}};
      PCE      <= {{1'b0}};
      Rs1E     <= {{1'b0}};
      Rs2E     <= {{1'b0}};
      RdE      <= {{1'b0}};
      ImmExtE  <= {{1'b0}};
      PCPlus4E <= {{1'b0}};
    end else begin
      RD1E     <= RD1D;
      RD2E     <= RD2D;
      PCE      <= PCD;
      Rs1E     <= Rs1D;
      Rs2E     <= Rs2D;
      RdE      <= RdD;
      ImmExtE  <= ImmExtD;
      PCPlus4E <= PCPlus4D;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_exec_mem
    if (irst) begin
      InstrM     <= {{1'b0}};
      ALUResultM <= {{1'b0}};
      WriteDataM <= {{1'b0}};
      ImmExtM    <= {{1'b0}};
      RdM        <= {{1'b0}};
      PCResultM  <= {{1'b0}};
      PCPlus4M   <= {{1'b0}};
    end else begin
      InstrM     <= InstrE;
      ALUResultM <= ALUResultE;
      WriteDataM <= WriteDataE;
      ImmExtM    <= ImmExtE;
      RdM        <= RdE;
      PCResultM  <= PCResultE;
      PCPlus4M   <= PCPlus4E;
    end
  end

  always @(posedge iclk) begin : sproc_pipeline_mem_writ
    if (irst) begin
      ALUResultW <= {{1'b0}};
      ReadDataW  <= {{1'b0}};
      ImmExtW    <= {{1'b0}};
      RdW        <= {{1'b0}};
      PCResultW  <= {{1'b0}};
      PCPlus4W   <= {{1'b0}};
    end else begin
      ALUResultW <= ALUResultM;
      ReadDataW  <= ReadDataM;
      ImmExtW    <= ImmExtM;
      RdW        <= RdM;
      PCResultW  <= PCResultM;
      PCPlus4W   <= PCPlus4M;
    end
  end

  // ============================================================================
  // hazard unit muxes
  // ============================================================================

  always @(*) begin : cproc_src_ae
    case (ForwardAE)
      2'b00:   SrcAE = RD1E;
      2'b01:   SrcAE = ResultW;
      2'b10:   SrcAE = ALUResultM;
      default: SrcAE = SrcAE;
    endcase
  end

  always @(*) begin : cproc_wdata_e
    case (ForwardBE)
      2'b00:   WriteDataE = RD2E;
      2'b01:   WriteDataE = ResultW;
      2'b10:   WriteDataE = ALUResultM;
      default: WriteDataE = WriteDataE;
    endcase
  end

  // ============================================================================
  // datapath
  // ============================================================================

  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];
  assign RdD  = InstrD[11:7];

  always @(posedge iclk or posedge irst) begin : sproc_pc_reg
    if (irst) begin
      PCF <= {{1'b0}};
    end else begin
      if (~StallF) begin
        PCF <= PCNextF;
      end
    end
  end

  assign PCPlus4F = PCF + 32'd4;
  assign PCTargetE = PCE + ImmExtE;

  assign PCResultE = PCResultSrcE ? ALUResultE : PCTargetE; // <<<<<<<<<<<<< check mux order. d0 and d1 might be swithced
  assign PCNextF = PCSrcE ? PCResultE : PCPlus4F;

  regfile rf(
    .clk(~clk),
    .we3(RegWriteW),
    .a1(InstrD[19:15]),
    .a2(InstrD[24:20]),
    .a3(RdW),
    .wd3(ResultW),
    .rd1(RD1D),
    .rd2(RD2D)
  );

  extendImm extImm(
    InstrD[31:7],
    ImmSrcD,
    ImmExtD
  );

  assign SrcBE = ALUSrcE ? ImmExtE : WriteDataE;

  alu u_alu(
    .SrcA(SrcAE),
    .SrcB(SrcBE),
    .ALUControl(ALUControlE),
    .ALUResult(ALUResultE),
    .Zero(ZeroE),
    .Overflow(OverflowE),
    .Carry(CarryE),
    .Negative(NegativeE)
  );

  assign ResultW = ResultW_r;

  always @(*) begin
    case(ResultSrcW)
      3'b000: ResultW_r = ALUResultW;
      3'b111: ResultW_r = ALUResultW;
      3'b001: ResultW_r = ReadDataW;
      3'b010: ResultW_r = PCPlus4W;
      3'b101: ResultW_r = PCResultW;
      3'b011: ResultW_r = ImmExtW;
      default: ResultW_r = {32{1'bx}};
    endcase
  end

  loaddec loaddec(
    MemDataM,
    InstrM,
    ALUResultM[1:0],

    ReadDataM
  );

endmodule
