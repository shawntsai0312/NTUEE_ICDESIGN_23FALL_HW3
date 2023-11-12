`timescale 1ns/1ps

module poker(type, i0, i1, i2, i3, i4);
//DO NOT CHANGE!
	input  [5:0] i0, i1, i2, i3, i4;
	output [3:0] type;
//---------------------------------------------------
	wire flush;
	flushChecker FC(flush, i0[5:4], i1[5:4], i2[5:4], i3[5:4], i4[5:4]);

	wire 4ofAKind;
	4ofAKindChecker 4ofK(4ofAKind, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);

	
	
endmodule

module flushChecker(out, in0, in1, in2, in3, in4);
	input [1:0] in0, in1, in2, in3, in4;
	output out;

	wire s5bc0, s5bc1;
	same5BitChecker S5BC0(s5bc0, in0[0], in1[0], in2[0], in3[0], in4[0]);
	same5BitChecker S5BC1(s5bc1, in0[1], in1[1], in2[1], in3[1], in4[1]);
	
	AN2 an2(out, s5bc0, s5bc1);
endmodule

module 4ofAKindChecker(out, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out;

	wire i4rc0123, i4rc0124, i4rc0134, i4rc0234, i4rc1234;
	identical4RanksChecker(i4rc0123, in0, in1, in2, in3);
	identical4RanksChecker(i4rc0124, in0, in1, in2, in4);
	identical4RanksChecker(i4rc0134, in0, in1, in3, in4);
	identical4RanksChecker(i4rc0234, in0, in2, in3, in4);
	identical4RanksChecker(i4rc1234, in1, in2, in3, in4);

	wire temp;
	OR3 or31(temp, i4rc0123, i4rc0124, i4rc0134);
	OR3 or32( out,     temp, i4rc0234, i4rc1234);
endmodule

module same5BitChecker(out, in0, in1, in2, in3, in4);
	input in0, in1, in2, in3, in4;
	output out;
	// F = abcde + (a+b+c+d+e)'
	//	 = [(abcde)' (a+b+c+d+e)]'

	wire and3, nand5;
	AN3 an3(and3, 	 in0, in1, in2);
	ND3 nd3(nand5, and3, in3, in4);

	wire tempOr3, tempOr5;
	OR3 or3(tempOr3,	 in0, in1, in2);
	OR3 OR3(tempOr5, tempOr3, in3, in4);

	ND2 nd2(out, nand5, tempOr5);
endmodule

module same4BitChecker(out, in0, in1, in2, in3);
	input in0, in1, in2, in3;
	output out;
	// F = abcd + (a+b+c+d)'

	wire and4;
	AN4 an4(and4, in0, in1, in2, in3);

	wire nor4;
	NR4 nr4(nor4, in0, in1, in2, in3);

	OR2 or2(out, and4, nor4);
endmodule

module same3BitChecker(out, in0, in1, in2);
	input in0, in1, in2;
	output out;
	// F = abc + (a+b+c)'

	wire and3;
	AN3 an3(and3, in0, in1, in2);

	wire nor3;
	NR3 nr3(nor3, in0, in1, in2);

	OR2 or2(out, and3, nor3);
endmodule

module same2BitChecker(out, in0, in1);
	input in0, in1;
	output out;
	// F = ab + (a+b)'
	// although we can use xnor, but the delay is too high !!!
	// this module can lower the delay from 1.1 to 0.527
	wire and2;
	AN2 an2(and2, in0, in1);

	wire nor2;
	NR2 nr2(nor2, in0, in1);

	OR2 or2(out, and2, nor2);
endmodule

module identical4RanksChecker(out, in0, in1, in2, in3)
	input [3:0] in0, in1, in2, in3;
	output out;

	wire s4bc0, s4bc1, s4bc2, s4bc3;
	same4BitChecker S4BC0(s4bc0, in0[0], in1[0], in2[0], in3[0]);
	same4BitChecker S4BC1(s4bc1, in0[1], in1[1], in2[1], in3[1]);
	same4BitChecker S4BC2(s4bc2, in0[2], in1[2], in2[2], in3[2]);
	same4BitChecker S4BC3(s4bc3, in0[3], in1[3], in2[3], in3[3]);

	AN4 an4(out, s4bc0, s4bc1, s4bc2, s4bc3);
endmodule

module identical3RanksChecker(out, in0, in1, in2)
	input [3:0] in0, in1, in2;
	output out;

	wire s3bc0, s3bc1, s3bc2, s3bc3;
	same3BitChecker S3BC0(s3bc0, in0[0], in1[0], in2[0]);
	same3BitChecker S3BC1(s3bc1, in0[1], in1[1], in2[1]);
	same3BitChecker S3BC2(s3bc2, in0[2], in1[2], in2[2]);
	same3BitChecker S3BC3(s3bc3, in0[3], in1[3], in2[3]);

	AN4 an4(out, s3bc0, s3bc1, s3bc2, s3bc3);
endmodule

module identical2RanksChecker(out, in0, in1)
	input [3:0] in0, in1;
	output out;

	wire s2bc0, s2bc1, s2bc2, s2bc3;
	same2BitChecker S2BC0(s2bc0, in0[0], in1[0]);
	same2BitChecker S2BC1(s2bc1, in0[1], in1[1]);
	same2BitChecker S2BC2(s2bc2, in0[2], in1[2]);
	same2BitChecker S2BC3(s2bc3, in0[3], in1[3]);

	AN4 an4(out, s2bc0, s2bc1, s2bc2, s2bc3);
endmodule