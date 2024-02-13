module extendAddr (
	funct3,
	addr,
	addrext
);
	input wire [31:0] addr;
	input wire [2:0] funct3;
	output reg [31:0] addrext;
	reg debug;
	
	always @(*) begin
		case (funct3)
			// lb
			3'b000: addrext = {{24{addr[7]}}, addr[7:0]};
			// lh
			3'b001: addrext = {{16{addr[15]}}, addr[15:0]};
			// lw
			3'b010: addrext = addr;
			// lbu
			3'b100: addrext = {{24{1'b0}}, addr[7:0]};
			// lhu
			3'b101: addrext = {{16{1'b0}}, addr[15:0]};

			default: addrext = {32{1'bx}};
		endcase
		debug = 0;
    end
endmodule
