//------------------------------------------------------------------------------
module loaddec
//------------------------------------------------------------------------------
#(
  parameter MP_DATA_WIDTH = 32
)
(
  input  wire [MP_DATA_WIDTH-1 : 0] imem_data,
  input  wire [2:0]                 ifunct3,
  input  wire [1:0]                 iop,

  output wire [MP_DATA_WIDTH-1 : 0] ordata
);
//------------------------------------------------------------------------------

  wire [7:0]  wload_byte;
  wire [15:0] wload_half;
  wire [MP_DATA_WIDTH-1 : 0] wsigned;
  wire [MP_DATA_WIDTH-1 : 0] wunsigned;

  always @(*) begin : cproc_load_byte
    case(iop[1:0])
      2'b00: wload_byte = imem_data[7:0];
      2'b01: wload_byte = imem_data[15:8];
      2'b10: wload_byte = imem_data[23:16];
      2'b11: wload_byte = imem_data[31:24];
    endcase
  end

  always @(*) begin : cproc_load_half
    case(iop[1:0])
      2'b00: wload_half = imem_data[15:0];
      2'b01: wload_half = imem_data[23:8];
      2'b10: wload_half = imem_data[31:16];
      2'b11: wload_half = {imem_data[7:0], imem_data[31:24]};
    endcase
  end

`define SIGNEXTEND(num, ext, data) {{num{ext}}, data}

  always @(*) begin : cproc_signed
    case(ifunct3[1:0])
      2'b00: wsigned = `SIGNEXTEND(24, wload_byte[7], wload_byte);
      2'b01: wsigned = `SIGNEXTEND(16, wload_half[15], wload_half);
      2'b10: wsigned = imem_data; // lw
      default: wsigned = wsigned;
    endcase
  end

`define ZEROEXTEND(num, data) {{num{1'b0}}, data}

  always @(*) begin : cproc_unsigned
    case(ifunct3[0])
      1'b0: wunsigned = `ZEROEXTEND(16, wload_half);
      1'b1: wunsigned = `ZEROEXTEND(24, wload_byte);
    endcase
  end

  assign ordata = ifunct3[2] ? wsigned : wunsigned;

endmodule : loaddec