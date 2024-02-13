module flopr (
	clk,
	reset,
	d,
	q
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire [WIDTH - 1:0] d;
	
	output reg [WIDTH - 1:0] q;
	//or posedge reset
	always @(posedge clk)
		if (reset)
			q <= 0;
		else
			q <= d;
endmodule
