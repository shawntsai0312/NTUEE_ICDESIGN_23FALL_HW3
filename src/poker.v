`timescale 1ns/1ps

module poker(type, i0, i1, i2, i3, i4);
//DO NOT CHANGE!
	input  [5:0] i0, i1, i2, i3, i4;
	output [3:0] type;
//---------------------------------------------------
	wire flush;
	flushChecker(flush, i0[5:4], i1[5:4], i2[5:4], i3[5:4], i4[5:4]);

	// wire straight;

	wire fourOfAKind, notFour;
	fourOfAKindChecker(fourOfAKind, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	IV(notFour, fourOfAKind);

	wire fullHouse, notFull;
	fullHouseChecker(fullHouse, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	IV(notFull, fullHouse);

	wire threeOfAKind, threeOfAKinkPossible, notThree, notThreePossible;
	threeOfAKindPossibleChecker(threeOfAKinkPossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	IV(notThreePossible, threeOfAKinkPossible);
	AN2(threeOfAKind, threeOfAKinkPossible, notFull);
	IV(notThree, threeOfAKind);

	wire twoPairs, twoPairsPossible, notTwos, notTwoPossible; // delay is too high
	twoPairsPossibleChecker(twoPairsPossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	IV(notTwoPossible, twoPairsPossible);
	AN3(twoPairs, twoPairsPossible, notFour, notFull);
	IV(notTwo, twoPairs);

	wire onePair, onePairPossible, notOne, notOnePossible;
	onePairPossibleChecker(onePairPossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	AN3(onePair, onePairPossible, notThreePossible, notTwoPossible);
	IV(notOne, onePair);
	

endmodule

module flushChecker(out, in0, in1, in2, in3, in4);
	input [1:0] in0, in1, in2, in3, in4;
	output out;

	wire s5bc0, s5bc1;
	same5BitChecker(s5bc0, in0[0], in1[0], in2[0], in3[0], in4[0]);
	same5BitChecker(s5bc1, in0[1], in1[1], in2[1], in3[1], in4[1]);
	
	AN2(out, s5bc0, s5bc1);
endmodule

module straightChecker(out, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out;



endmodule

module fourOfAKindChecker(out, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out;

	wire i4rc0123, i4rc0124, i4rc0134, i4rc0234, i4rc1234;
	identical4RanksChecker(i4rc0123, in0, in1, in2, in3);
	identical4RanksChecker(i4rc0124, in0, in1, in2, in4);
	identical4RanksChecker(i4rc0134, in0, in1, in3, in4);
	identical4RanksChecker(i4rc0234, in0, in2, in3, in4);
	identical4RanksChecker(i4rc1234, in1, in2, in3, in4);

	OR5(out, i4rc0123, i4rc0124, i4rc0134, i4rc0234, i4rc1234);
endmodule

module fullHouseChecker(out, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out;

	// use ChatGPT to generate those cases in short time
	// case0 012, 34
	wire i3rc012, i2rc34, case0;
	identical3RanksChecker(i3rc012, in0, in1, in2);
	identical2RanksChecker( i2rc34, in3, in4);
	AN2(case0, i3rc012, i2rc34);

	// case1 013, 24
	wire i3rc013, i2rc24, case1;
	identical3RanksChecker(i3rc013, in0, in1, in3);
	identical2RanksChecker( i2rc24, in2, in4);
	AN2(case1, i3rc013, i2rc24);

	// case2 014, 23
	wire i3rc014, i2rc23, case2;
	identical3RanksChecker(i3rc014, in0, in1, in4);
	identical2RanksChecker(i2rc23, in2, in3);
	AN2(case2, i3rc014, i2rc23);

	// case3 023, 14
	wire i3rc023, i2rc14, case3;
	identical3RanksChecker(i3rc023, in0, in2, in3);
	identical2RanksChecker(i2rc14, in1, in4);
	AN2(case3, i3rc023, i2rc14);

	// case4 024, 13
	wire i3rc024, i2rc13, case4;
	identical3RanksChecker(i3rc024, in0, in2, in4);
	identical2RanksChecker(i2rc13, in1, in3);
	AN2(case4, i3rc024, i2rc13);

	// case5 034, 12
	wire i3rc034, i2rc12, case5;
	identical3RanksChecker(i3rc034, in0, in3, in4);
	identical2RanksChecker(i2rc12, in1, in2);
	AN2(case5, i3rc034, i2rc12);

	// case6 123, 04
	wire i3rc123, i2rc04, case6;
	identical3RanksChecker(i3rc123, in1, in2, in3);
	identical2RanksChecker(i2rc04, in0, in4);
	AN2(case6, i3rc123, i2rc04);

	// case7 124, 03
	wire i3rc124, i2rc03, case7;
	identical3RanksChecker(i3rc124, in1, in2, in4);
	identical2RanksChecker(i2rc03, in0, in3);
	AN2(case7, i3rc124, i2rc03);

	// case8 134, 02
	wire i3rc134, i2rc02, case8;
	identical3RanksChecker(i3rc134, in1, in3, in4);
	identical2RanksChecker(i2rc02, in0, in2);
	AN2(case8, i3rc134, i2rc02);

	// case9 234, 01
	wire i3rc234, i2rc01, case9;
	identical3RanksChecker(i3rc234, in2, in3, in4);
	identical2RanksChecker(i2rc01, in0, in1);
	AN2(case9, i3rc234, i2rc01);

	OR10(out, case0, case1, case2, case3, case4, case5, case6, case7, case8, case9);
endmodule

module threeOfAKindPossibleChecker(out, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out;

	// case0 012, 34
	wire i3rc012;
	identical3RanksChecker(i3rc012, in0, in1, in2);

	// case1 013, 24
	wire i3rc013;
	identical3RanksChecker(i3rc013, in0, in1, in3);

	// case2 014, 23
	wire i3rc014;
	identical3RanksChecker(i3rc014, in0, in1, in4);

	// case3 023, 14
	wire i3rc023;
	identical3RanksChecker(i3rc023, in0, in2, in3);

	// case4 024, 13
	wire i3rc024;
	identical3RanksChecker(i3rc024, in0, in2, in4);

	// case5 034, 12
	wire i3rc034;
	identical3RanksChecker(i3rc034, in0, in3, in4);

	// case6 123, 04
	wire i3rc123;
	identical3RanksChecker(i3rc123, in1, in2, in3);

	// case7 124, 03
	wire i3rc124;
	identical3RanksChecker(i3rc124, in1, in2, in4);

	// case8 134, 02
	wire i3rc134;
	identical3RanksChecker(i3rc134, in1, in3, in4);

	// case9 234, 01
	wire i3rc234;
	identical3RanksChecker(i3rc234, in2, in3, in4);

	OR10(out, i3rc012, i3rc013, i3rc014, i3rc023, i3rc024, i3rc034, i3rc123, i3rc124, i3rc134, i3rc234);
endmodule

module twoPairsPossibleChecker(out, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out;

	wire sub0123, sub0124, sub0134, sub0234, sub1234;
	twoPairsSubPossibleChecker(sub0123, in0, in1, in2, in3);
	twoPairsSubPossibleChecker(sub0124, in0, in1, in2, in4);
	twoPairsSubPossibleChecker(sub0134, in0, in1, in3, in4);
	twoPairsSubPossibleChecker(sub0234, in0, in2, in3, in4);
	twoPairsSubPossibleChecker(sub1234, in1, in2, in3, in4);

	OR5(out, sub0123, sub0124, sub0134, sub0234, sub1234);
endmodule

module twoPairsSubPossibleChecker(out, in0, in1, in2, in3);
	input [3:0] in0, in1, in2, in3;
	output out;

	wire same01, same02, same03, same12, same13, same23;
	identical2RanksChecker(same01, in0, in1);
	identical2RanksChecker(same02, in0, in2);
	identical2RanksChecker(same03, in0, in3);
	identical2RanksChecker(same12, in1, in2);
	identical2RanksChecker(same13, in1, in3);
	identical2RanksChecker(same23, in2, in3);

	// wire same0123, notSame0123;
	// identical4RanksChecker(same0123, in0, in1, in2, in3);

	// out = s01&s23 + s02&s13 + s03&s12
	//     = ((s01&s23)' & (s02&s13)' & (s03&s12)')'
	wire case0, case1, case2;

	// case0 : check if rank0 = rank1 = x and rank2 = rank3 = y but x != y
	ND2(case0, same01, same23);

	// case1 :  check if rank0 = rank2 = x and rank1 = rank3 = y but x != y]
	ND2(case1, same02, same13);

	// case2 : check if rank0 = rank3 = x and rank1 = rank2 = y but x != y
	ND2(case2, same03, same12);

	ND3(out, case0, case1, case2);
endmodule

module onePairPossibleChecker(out, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out;

	// rank0 = rank1
	wire i2rc01;
	identical2RanksChecker(i2rc01, in0, in1);

	// rank0 = rank2
	wire i2rc02;
	identical2RanksChecker(i2rc02, in0, in2);

	// rank0 = rank3
	wire i2rc03;
	identical2RanksChecker(i2rc03, in0, in3);

	// rank0 = rank4
	wire i2rc04;
	identical2RanksChecker(i2rc04, in0, in4);

	// rank1 = rank2
	wire i2rc12;
	identical2RanksChecker(i2rc12, in1, in2);

	// rank1 = rank3
	wire i2rc13;
	identical2RanksChecker(i2rc13, in1, in3);

	// rank1 = rank4
	wire i2rc14;
	identical2RanksChecker(i2rc14, in1, in4);

	// rank2 = rank3
	wire i2rc23;
	identical2RanksChecker(i2rc23, in2, in3);

	// rank2 = rank4
	wire i2rc24;
	identical2RanksChecker(i2rc24, in2, in4);

	// rank3 = rank4
	wire i2rc34;
	identical2RanksChecker(i2rc34, in3, in4);

	OR10(out, i2rc01, i2rc02, i2rc03, i2rc04, i2rc12, i2rc13, i2rc14, i2rc23, i2rc24, i2rc34);
endmodule

module same5BitChecker(out, in0, in1, in2, in3, in4);
	input in0, in1, in2, in3, in4;
	output out;
	// F = abcde + (a+b+c+d+e)'
	//	 = [(abcde)' (a+b+c+d+e)]'

	wire and3, nand5;
	AN3( and3,	in0, in1, in2);
	ND3(nand5, and3, in3, in4);

	wire or5;
	OR5(or5, in0, in1, in2, in3, in4);

	ND2(out, nand5, or5);
endmodule

module same4BitChecker(out, in0, in1, in2, in3);
	input in0, in1, in2, in3;
	output out;
	// F = abcd + (a+b+c+d)'

	wire and4;
	AN4(and4, in0, in1, in2, in3);

	wire nor4;
	NR4(nor4, in0, in1, in2, in3);

	OR2(out, and4, nor4);
endmodule

module same3BitChecker(out, in0, in1, in2);
	input in0, in1, in2;
	output out;
	// F = abc + (a+b+c)'

	wire and3;
	AN3(and3, in0, in1, in2);

	wire nor3;
	NR3(nor3, in0, in1, in2);

	OR2(out, and3, nor3);
endmodule

module same2BitChecker(out, in0, in1);
	input in0, in1;
	output out;
	// F = ab + (a+b)'
	// although we can use xnor, but the delay is too high !!!
	// this module can lower the delay from 1.1 to 0.527
	wire and2;
	AN2(and2, in0, in1);

	wire nor2;
	NR2(nor2, in0, in1);

	OR2(out, and2, nor2);
endmodule

module identical4RanksChecker(out, in0, in1, in2, in3);
	input [3:0] in0, in1, in2, in3;
	output out;

	wire s4bc0, s4bc1, s4bc2, s4bc3;
	same4BitChecker(s4bc0, in0[0], in1[0], in2[0], in3[0]);
	same4BitChecker(s4bc1, in0[1], in1[1], in2[1], in3[1]);
	same4BitChecker(s4bc2, in0[2], in1[2], in2[2], in3[2]);
	same4BitChecker(s4bc3, in0[3], in1[3], in2[3], in3[3]);

	AN4(out, s4bc0, s4bc1, s4bc2, s4bc3);
endmodule

module identical3RanksChecker(out, in0, in1, in2);
	input [3:0] in0, in1, in2;
	output out;

	wire s3bc0, s3bc1, s3bc2, s3bc3;
	same3BitChecker(s3bc0, in0[0], in1[0], in2[0]);
	same3BitChecker(s3bc1, in0[1], in1[1], in2[1]);
	same3BitChecker(s3bc2, in0[2], in1[2], in2[2]);
	same3BitChecker(s3bc3, in0[3], in1[3], in2[3]);

	AN4(out, s3bc0, s3bc1, s3bc2, s3bc3);
endmodule

module identical2RanksChecker(out, in0, in1);
	input [3:0] in0, in1;
	output out;

	wire s2bc0, s2bc1, s2bc2, s2bc3;
	same2BitChecker(s2bc0, in0[0], in1[0]);
	same2BitChecker(s2bc1, in0[1], in1[1]);
	same2BitChecker(s2bc2, in0[2], in1[2]);
	same2BitChecker(s2bc3, in0[3], in1[3]);

	AN4(out, s2bc0, s2bc1, s2bc2, s2bc3);
endmodule

module OR5(Z,A,B,C,D,E);
	// or 5
	// f = a+b+c+d+e
	//   = ((a+b+c)'(d+e)')'
	// delay = 0.525
	input A, B, C, D, E;
	output Z;
	
	wire nor3, nor2;
	NR3(nor3, A, B, C);
	NR2(nor2, D, E);
	ND2(Z, nor3, nor2);
endmodule

module AN5(Z,A,B,C,D,E);
	// and 5
	// f = abcde
	//   = ((abc)'+(de)')'
	// delay = 0.453
	input A, B, C, D, E;
	output Z;
	
	wire nand3, nand2;
	ND3(nand3, A, B, C);
	ND2(nand2, D, E);
	NR2(Z, nand3, nand2);
endmodule

module OR6(Z,A,B,C,D,E,F);
	// or 5
	// f = a+b+c+d+e+f
	//   = ((a+b+c)'(d+e+f)')'
	// delay = 0.525
	input A, B, C, D, E, F;
	output Z;
	
	wire nor31, nor32;
	NR3(nor31, A, B, C);
	NR3(nor32, D, E, F);
	ND2(Z, nor31, nor32);
endmodule

module NR6(Z,A,B,C,D,E,F);
	// nor 6
	// f = (a+b+c+d+e+f)'
	//   = (a+b+c)'(d+e+f)'
	// delay = 0.574
	input A, B, C, D, E, F;
	output Z;
	
	wire nor31, nor32;
	NR3(nor31, A, B, C);
	NR3(nor32, D, E, F);
	AN2(Z, nor31, nor32);
endmodule

module OR10(Z,A,B,C,D,E,F,G,H,I,J);
	// or10
	// F = (a+b+c)+(d+e+f)+(g+h+i+j)
	//   = [(a+b+c)' (d+e+f)'(g+h+i+j)' ]'
	// delay 0.571
	input A,B,C,D,E;
	input F,G,H,I,J;
	output Z;
	wire nor31, nor32, nor4;
	NR3(nor31,A,B,C);
	NR3(nor32,D,E,F);
	NR4(nor4,G,H,I,J);
	ND3(Z,nor31,nor32,nor4);
endmodule