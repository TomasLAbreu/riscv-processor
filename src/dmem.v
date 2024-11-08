//------------------------------------------------------------------------------
module data_mem
//------------------------------------------------------------------------------
#(
  parameter MP_WIDTH = 32,
  parameter MP_DEPTH = 256
)
(
  input wire                    iclk,

  input wire  [MP_WIDTH-1 : 0]  ipos,   // memory position to access/index

  input wire                    iwen,   // write enable
  input wire  [1:0]             ibe,    // byte enable //<<<<<<<<<<<< add param?
  input wire  [MP_WIDTH-1 : 0]  iwdata, // write data
  output wire [MP_WIDTH-1 : 0]  ordata  // read data
);
//------------------------------------------------------------------------------
  reg [MP_WIDTH-1 : 0] rram [MP_DEPTH-1 : 0];

`define index ipos[MP_WIDTH-1 : 2]

  localparam [1:0]
    LP_STORE_BYTE = 2'b00,
    LP_STORE_HALF = 2'b01, // half word
    LP_STORE_WORD = 2'b10;

  integer i;
  // initial begin : init_regfile_ram
  //   for(i = 0; i < MP_DEPTH; i = i + 1)
  //     rram[i] = 0;
  // end

  assign ordata = rram[`index];

  always @(posedge iclk) begin : sproc_write_mem
    if (iwen) begin
      case(ibe)
        LP_STORE_BYTE:
          case(ipos[1:0])
            2'b00: rram[`index][7:0]   <= iwdata[7:0]; //<<<<<<<<<<<< rewrite this with generate
            2'b01: rram[`index][15:8]  <= iwdata[7:0];
            2'b10: rram[`index][23:16] <= iwdata[7:0];
            2'b11: rram[`index][31:24] <= iwdata[7:0];
          endcase
        LP_STORE_HALF:
          case(ipos[1:0])
            2'b00: rram[`index][15:0]  <= iwdata[15:0];
            2'b01: rram[`index][23:8]  <= iwdata[15:0];
            2'b10: rram[`index][31:16] <= iwdata[15:0];
            2'b11: begin
              rram[`index][31:24] <= iwdata[7:0];
              rram[`index][7:0]   <= iwdata[15:8];
            end
          endcase
        LP_STORE_WORD:   rram[`index] <= iwdata;
        default:         rram[`index] <= rram[`index];
      endcase
    end
  end

endmodule : data_mem
