`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:52:55 04/07/2013 
// Design Name: 
// Module Name:    fp_adder 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: See the notebook or textbook for description
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module fp_adder(
	input wire sign1, sign2,
	input wire [3:0] exp1, exp2,
	input wire [7:0] frac1, frac2,	//first significand, second significand
	output reg sign_out,
	output reg [3:0] exp_out,
	output reg [7:0] frac_out
    );
	 
	 reg signb, signs;
	 reg [3:0] expb, exps, expn, exp_diff;
	 reg [7:0] fracb, fracs, fraca, fracn, sum_norm;
	 reg [8:0] sum;	//sum of the significands with a ninth bit for a carry
	 reg [2:0] lead0;	//number of leading 0's in the sum of the significands
	 
	 always@*
	 begin 	
	 //first stage: sort to find the larger number and set the relevant variables accordingly
		if ({exp1, frac1} > {exp2, frac2})
			begin
			signb = sign1; //The sign of the big number = sign of the first significand in
			signs = sign2; //the inverse
			expb = exp1; 	//Big number's exponent is first number's exponent
			exps = exp2;	//small number's exponent is first number's exponent
			fracb = frac1; //big number's significand is first number's significand
			fracs = frac2;
		end
	else //including if they are equal
		begin
			signb = sign2; //The sign of the big number = sign of the second number in
			signs = sign1; //the inverse
			expb = exp2; 	//Big number's exponent is second number's exponent
			exps = exp1;	//small number's exponent is second number's exponent
			fracb = frac2; //big number's significand is second number's significand
			fracs = frac1;
		end
		
		
	//second stage: add?align
	exp_diff = expb - exps;	//This is the computation of the difference between the two exponents
	fraca = fracs >> exp_diff;	//Introducing fraca: the smallest number shifted over by the above difference
										//If they have the same exponent, then the difference is zero, and nothing changes.
										
	//Third stage: add/subtract
	if (signb == signs)	//If
/\558\	the small and large number have the same sign
		sum = {1'b0, fracb} + {1'b0, fraca};	//We tack on a 0 in case of a carry
	else 
		sum = {1'b0, fracb} - {1'b0, fraca};
		
	//Fourth stage: normalize
	//count leading 0's
	if (sum[7])	//=1
		lead0 = 3'o0;	//if the MSB sum[7] is 1, then there are 0 leading 0's, represented by the octal number 3'o0
	else if (sum[6])
		lead0 = 3'o1;
	else if (sum[5])
		lead0 = 3'o2;
	else if (sum[4])
		lead0 = 3'o3;
	else if (sum[3])
		lead0 = 3'o4;
	else if (sum[2])
		lead0 = 3'o5;
	else if (sum[1])
		lead0 = 3'o6;
	else
		lead0 = 3'o7;
		
	//Now, knowing how many leading 0's we have, we can shift the significand to the left by that many 0's thus normalizing it
	sum_norm = sum << lead0;
	
	if (sum[8])	//=1   With a carry out, shift frac to the right
		begin
			expn = expb + 1;	//expn = the big number's exponent + 1 to account for the carry bit
			fracn = sum[8:1];	//the 8 bits are shifted to include the carry and exclude the LSB
		end
	else if (lead0 > expb)	// This is the case where it's too small to normalize
		begin
			expn = 0;
			fracn = sum_norm;
		end
	else 
		begin
			expn = expb - lead0;
			fracn = sum_norm;
		end
		
	//Form output
	sign_out = signb;
	exp_out = expn;
	frac_out = fracn;
	
	end

endmodule
