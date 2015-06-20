`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:39:00 04/20/2013 
// Design Name: 
// Module Name:    free_run_bin_counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 	A free running binary counter circulates through a binary sequence
//						and starts over when it reaches the end. This code is for a parameterized
//						counter defaulted at 8.
//						A new type of signal is introduced here: a tick. A tick is a special kind
//						of signal that is asserted for a single clock cycle. In this case, when the counter
//						reaches its maximal value. It is commonly used to signal other circuitry.
//						The reg count is my own addition to the book's code, and is a tick put there to make the
//						physical implementation of the design visible to the human eye.
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module free_run_bin_counter #(parameter N = 8)
	(
	input clk, reset, 
	input on,
	output max_tick,		//set to 1 when the counter has reached it max value
	output [N-1:0] q
    );
	
	reg [N-1:0] r_reg;
	wire [N-1:0] r_next;
	reg [22:0] count;	//tick set to one when the clock cycles reach a given value
	
	always @(posedge clk, posedge reset, posedge on)
		if (reset) begin		//if we reset, then the count starts over, and r_reg is back to 0
			count <= 0;
			r_reg <= 0;
			end	
		else if (on) begin	//if we reset, then the count starts over, and r_reg is back to 0
			count <= 0;
			r_reg <= 0;
			end
		else if (count == 7400000) begin	//once the count reaches this value, start showing the next number
			count <= 0;							//and start the count over
			r_reg <= r_next;
			end
		else					//if nothing special happens, just increase count by 1 every clock cycle
			count <= count + 1;

	//next-state logic
	assign r_next = r_reg + 1;	//
	//output logic
	assign q = r_reg;			//we're still in the always statement, so r_reg <= r_next has yet to be evaluated (b/c of non-blocking "<=")
	assign max_tick = (r_reg==2**N-1)? 1'b1: 1'b0;	//we use "==" b/c this is a binary check
	
endmodule
