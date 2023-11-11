`timescale 1ns/1ps

module poker(type, i0, i1, i2, i3, i4);
//DO NOT CHANGE!
	input  [5:0] i0, i1, i2, i3, i4;
	output [3:0] type;
//---------------------------------------------------

// flush checker
	wire flush;
	flushChecker FC(flush, in0[5:4], in1[5:4], in2[5:4], in3[5:4], in4[5:4]);

// rank sorter
	// sort ik into iks (increasing order);
	// concept : insertion sort

	// wire cij = (i>=j)? 1:0
	wire c01,c02,c03,c04,c12,c13,c14,c23,c24,c34;
	wire c10,c20,c30,c40,c21,c31,c41,c32,c42,c43;

	comparator2 Compare01(c01,i0[3:0],i1[3:0]);
	comparator2 Compare02(c02,i0[3:0],i2[3:0]);
	comparator2 Compare03(c03,i0[3:0],i3[3:0]);
	comparator2 Compare04(c04,i0[3:0],i4[3:0]);
	IV Iv01(c10,c01);
	IV Iv02(c20,c02);
	IV Iv03(c30,c03);
	IV Iv04(c40,c04);

	comparator2 Compare12(c12,i1[3:0],i2[3:0]);
	comparator2 Compare13(c13,i1[3:0],i3[3:0]);
	comparator2 Compare14(c14,i1[3:0],i4[3:0]);
	IV Iv12(c21,c12);
	IV Iv13(c31,c13);
	IV Iv14(c41,c14);

	comparator2 Compare23(c23,i2[3:0],i3[3:0]);
	comparator2 Compare24(c24,i2[3:0],i4[3:0]);
	IV Iv23(c32,c23);
	IV Iv24(c42,c24);

	comparator2 Compare34(c34,i3[3:0],i4[3:0]);
	IV Iv34(c43,c34);

	// wire bus = number of inputs smaller than ik
	wire [2:0] smallerCounter0, smallerCounter1, smallerCounter2, smallerCounter3, smallerCounter4;
	add4Bit A4B0(smallerCounter0, c01, c02, c03, c04);
	add4Bit A4B1(smallerCounter1, c10, c12, c13, c14);
	add4Bit A4B2(smallerCounter2, c20, c21, c23, c24);
	add4Bit A4B3(smallerCounter3, c30, c31, c32, c34);
	add4Bit A4B4(smallerCounter4, c40, c41, c42, c43);

	// wire with sorted order
	wire [3:0] i0Sorted, i1Sorted, i2Sorted, i3Sorted, i4Sorted;

	wire Equal0_0, Equal0_1, Equal0_2, Equal0_3, Equal0_4;
	Equal0Checker E0_0(Equal0_0, smallerCounter0);
	Equal0Checker E0_1(Equal0_1, smallerCounter1);
	Equal0Checker E0_2(Equal0_2, smallerCounter2);
	Equal0Checker E0_3(Equal0_3, smallerCounter3);
	switchCaseBus SCB0(i0Sorted, Equal0_0, Equal0_1, Equal0_2, Equal0_3, i0, i1, i2, i3, i4);

	wire Equal1_0, Equal1_1, Equal1_2, Equal1_3, Equal1_4;
	Equal1Checker E1_0(Equal1_0, smallerCounter0);
	Equal1Checker E1_1(Equal1_1, smallerCounter1);
	Equal1Checker E1_2(Equal1_2, smallerCounter2);
	Equal1Checker E1_3(Equal1_3, smallerCounter3);
	switchCaseBus SCB1(i0Sorted, Equal1_0, Equal1_1, Equal1_2, Equal1_3, i0, i1, i2, i3, i4);

	wire Equal2_0, Equal2_1, Equal2_2, Equal2_3, Equal2_4;
	Equal2Checker E2_0(Equal2_0, smallerCounter0);
	Equal2Checker E2_1(Equal2_1, smallerCounter1);
	Equal2Checker E2_2(Equal2_2, smallerCounter2);
	Equal2Checker E2_3(Equal2_3, smallerCounter3);
	switchCaseBus SCB2(i0Sorted, Equal2_0, Equal2_1, Equal2_2, Equal2_3, i0, i1, i2, i3, i4);

	wire Equal3_0, Equal3_1, Equal3_2, Equal3_3, Equal3_4;
	Equal3Checker E3_0(Equal3_0, smallerCounter0);
	Equal3Checker E3_1(Equal3_1, smallerCounter1);
	Equal3Checker E3_2(Equal3_2, smallerCounter2);
	Equal3Checker E3_3(Equal3_3, smallerCounter3);
	switchCaseBus SCB3(i0Sorted, Equal3_0, Equal3_1, Equal3_2, Equal3_3, i0, i1, i2, i3, i4);

	wire Equal4_0, Equal4_1, Equal4_2, Equal4_3, Equal4_4;
	Equal4Checker E4_0(Equal4_0, smallerCounter0);
	Equal4Checker E4_1(Equal4_1, smallerCounter1);
	Equal4Checker E4_2(Equal4_2, smallerCounter2);
	Equal4Checker E4_3(Equal4_3, smallerCounter3);
	switchCaseBus SCB4(i0Sorted, Equal4_0, Equal4_1, Equal4_2, Equal4_3, i0, i1, i2, i3, i4);
	


// straight checker

// output selector
	
	
endmodule

module flushChecker(out, in0, in1, in2, in3, in4);
	input [1:0] in0, in1, in2, in3, in4;
	output out;

	wire out_smc1, out_smc0;
	sameBitChecker SMC1(out_smc1, in0[1], in1[1], in2[1], in3[1], in4[1]);
	sameBitChecker SMC0(out_smc0, in0[0], in1[0], in2[0], in3[0], in4[0]);

	AN2 sameBitChecker(out, out_smc1, out_smc0);
endmodule

module sameBitChecker(out, in0, in1, in2, in3, in4);
	input in0, in1, in2, in3, in4;
	output out;

	wire and3, nand5;
	AN3 an3(and3, 	 in0, in1, in2);
	ND3 nd3(nand5, and3, in3, in4);

	wire tempOr3, tempOr5;
	OR3 or3(tempOr3,	 in0, in1, in2);
	OR3 OR3(tempOr5, tempOr3, in3, in4);

	ND2 nd2(out, nand5, tempOr5);
endmodule

module switchCaseBus(out, cond0, cond1, cond2, cond3, in0, in1, in2, in3, inDefault);
	input cond0, cond1, cond2, cond3, in0;
	input [3:0] in1, in2, in3, inDefault;
	output [3:0] out;

	switchCase SC0(out[0], cond0, cond1, cond2, cond3, in0[0], in1[0], in2[0], in3[0], inDefault[0]);
	switchCase SC1(out[1], cond0, cond1, cond2, cond3, in0[1], in1[1], in2[1], in3[1], inDefault[1]);
	switchCase SC2(out[2], cond0, cond1, cond2, cond3, in0[2], in1[2], in2[2], in3[2], inDefault[2]);
	switchCase SC3(out[3], cond0, cond1, cond2, cond3, in0[3], in1[3], in2[3], in3[3], inDefault[3]);
endmodule

module switchCase(out, cond0, cond1, cond2, cond3, in0, in1, in2, in3, inDefault);
	// similar to C++ switch case
	input cond0, cond1, cond2, cond3, in0, in1, in2, in3, inDefault;
	output out;
	/*
	cond0 is the highest command, if it is true => return in0
	out = cond0  & in0
		| cond0' & (  cond1  & in1
					| cond1' & ( cond2  & in2
								|cond2' & ( cond3  & in3
										   |cond3' & inDefault
										  )
							   )
		 		   )
	*/

	wire temp01, temp12, temp23;
	// avoid cascading mux
	MUX21H Mux0(temp01,	 inDefault, in0, cond0);
	MUX21H Mux1(temp12,		temp01,	in1, cond1);
	MUX21H Mux2(temp23,		temp12,	in2, cond2);
	MUX21H Mux3(   out,		temp23,	in3, cond3);
	// wire iCond0, iCond1, iCond2, iCond3;
	// IV I0(iCond0,cond0);
	// IV i1(iCond1,cond1);
	// IV i2(iCond2,cond2);
	// IV i3(iCond3,cond3);
endmodule

module comparator2(out1, out2, outEq, in1, in2);
	// out12 = (in1 >= in2)
	// out21 = (in2 >= in1)
	input [3:0] in1, in2;
	output out1, out2, outEq;

	// outEq by sameBitChecker 
	// out1, out2 by switchCase, but the delay is high
	// alternative solution should be considered

	wire flag0, flag1, flag2, flag3;
	EO NotEqual0(flag0,in1[0],in2[0]);
	EO NotEqual1(flag1,in1[1],in2[1]);
	EO NotEqual2(flag2,in1[2],in2[2]);
	EO NotEqual3(flag3,in1[3],in2[3]);
	// switchCase SC(out12, flag0, flag1, flag2, flag3, in1[0], in1[1], in1[2], in1[3], 1);
endmodule

module add4Bit(out, in0, in1, in2, in3);
	input in0, in1, in2, in3;
	output [2:0] out;

	wire xor3;
	EO3 eo3(xor3, in0, in1, in2); // EO3 should be avoid
	EO eo2(out[0], xor3, in3);

	wire and01, and23;
	AN2 an201(and01, in0, in1);
	AN2 an223(and23, in2, in3);

	wire nor31, nor32, and4;
	NR3 nr31(nor31, in2, in3, and01);
	NR3 nr32(nor32, in0, in1, and23);
	AN4 an4(and4, in0, in1, in2, in3);
	NR3 nr3o(out[1], nor31, nor32, and4);
	
	assign out[2] = and4;
endmodule

module Equal0Checker(out,in);
	// check in == 000
	input [2:0] in;
	output out;

	NR3 nr3(out,in[0],in[1],in[2]);
endmodule

module Equal1Checker(out,in);
	// check in == 001
	input [2:0] in;
	output out;

	wire not0;
	IV iv0(not0,in[0]);
	NR3 nr3(out,not0,in[1],in[2]);
endmodule

module Equal2Checker(out,in);
	// check in == 010
	input [2:0] in;
	output out;

	wire not1;
	IV iv1(not1,in[1]);
	NR3 nr3(out,in[0],not1,in[2]);
endmodule

module Equal3Checker(out,in);
	// check in == 011
	input [2:0] in;
	output out;

	wire not2;
	IV iv2(not2,in[2]);
	AN3 an3(out,in[0],in[1],not2);
endmodule

module Equal4Checker(out,in);
	// check in == 100
	input [2:0] in;
	output out;

	wire not2;
	IV iv2(not2,in[2]);
	NR3 nr3(out,in[0],in[1],not2);
endmodule
