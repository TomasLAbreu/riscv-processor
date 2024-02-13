//------------------------------------------------------------------------------
module riscvpipeline
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32
)
(
  input wire          iclk,
  input wire          irst,
  output wire [31:0]  PCF,
  input wire  [31:0]  InstrF,
  output wire [1:0]   InstrM,
  output wire         MemWriteM,
  output wire [MP_DATA_WIDTH-1 : 0] ALUResultM,
  output wire [MP_DATA_WIDTH-1 : 0] WriteDataM,
  input wire  [MP_DATA_WIDTH-1 : 0] ReadDataM
);
//------------------------------------------------------------------------------

  // ------ controler outputs
  wire [2:0] ResultSrcW;
  wire ALUSrcE;

  wire RegWriteW;
  wire RegWriteM;

  wire PCResultSrcE;
  wire [2:0] ImmSrcD;
  wire [3:0] ALUControlE;
  wire ResultSrcb0E;

  // ------ datapath outputs
  wire [4:0] Rs1D;
  wire [4:0] Rs2D;
  wire [4:0] Rs1E;
  wire [4:0] Rs2E;
  wire [4:0] RdE;
  wire PCSrcE;

  wire [4:0] RdM;
  wire [4:0] RdW;

  wire [31:0] InstrD;
  // ALU flags
  wire ZeroE;
  wire OverflowE;
  wire CarryE;
  wire NegativeE;

  // ------ hazard unit flags
  wire [1:0] ForwardAE;
  wire [1:0] ForwardBE;
  wire StallF;
  wire StallD;
  wire FlushD;
  wire FlushE;

  wire [6:0] opD;
  wire [2:0] funct3D;
  wire funct7b5D;

  // ============================================================================
  // riscv pipeline processor
  // ============================================================================

  assign opD = InstrD[6:0];
  assign funct3D = InstrD[14:12];
  assign funct7b5D = InstrD[30];

  controller c(
    iclk,
    irst,
    FlushE,

    opD,
    funct3D,
    funct7b5D,

    // ALU flags
    ZeroE,
    OverflowE,
    CarryE,
    NegativeE,

    ResultSrcW,
    MemWriteM,
    PCSrcE,
    ALUSrcE,

    RegWriteM,
    RegWriteW,

        PCResultSrcE,
    ImmSrcD,
    ALUControlE,
    ResultSrcb0E
  );

  datapath dp(
    // inputs
    iclk,
    irst,

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
    ReadDataM,
    InstrM
  );

  hazardUnit hu(
    Rs1D,
    Rs2D,

    Rs1E,
    Rs2E,
    RdE,
    PCSrcE,
    ResultSrcb0E,

    RdM,
    RdW,
    RegWriteM,
    RegWriteW,

    // outputs
    ForwardAE,
    ForwardBE,
    StallF,
    StallD,
    FlushD,
    FlushE
  );
endmodule
