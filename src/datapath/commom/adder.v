module adder (
	a,
	b,
	y
);
	input [31:0] a;
	input [31:0] b;
	output wire [31:0] y;
	
	assign y = a + b;
endmodule
