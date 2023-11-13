`timescale 1ns/1ps

module poker(type, i0, i1, i2, i3, i4);
//DO NOT CHANGE!
	input  [5:0] i0, i1, i2, i3, i4;
	output [3:0] type;
//---------------------------------------------------
	wire flush;
	flushChecker(flush, i0[5:4], i1[5:4], i2[5:4], i3[5:4], i4[5:4]);

	wire fourOfAKind, notFour;
	fourOfAKindChecker(fourOfAKind, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	IV(notFour, fourOfAKind);

	wire fullHouse, notFull;
	fullHouseChecker(fullHouse, notFull, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);

	wire threeOfAKind, threeOfAKinkPossible, notThree, notThreePossible;
	threeOfAKindPossibleChecker(threeOfAKinkPossible, notThreePossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	AN2(threeOfAKind, threeOfAKinkPossible, notFull);
	ND2(notThree, threeOfAKinkPossible, notFull);

	wire twoPairs, twoPairsPossible, notTwo, notTwoPossible;
	twoPairsPossibleChecker(twoPairsPossible, notTwoPossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	AN3(twoPairs, twoPairsPossible, notFour, notFull);				// 0.275 + 0.402 = 0.677
	ND3(  notTwo, twoPairsPossible, notFour, notFull);				// 0.226 + 0.402 = 0.628

	wire onePair, onePairPossible, notOne, notOnePossible;
	onePairPossibleChecker(onePairPossible, notOnePossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	AN3(onePair, onePairPossible, notThreePossible, notTwoPossible);
	ND3( notOne, onePairPossible, notThreePossible, notTwoPossible);

	reg [3:0] typeReg;
	always @(*) begin
		if(flush) 				typeReg = 4'b0101;
		else if(fourOfAKind)	typeReg = 4'b0111;
		else if(fullHouse)		typeReg = 4'b0110;
		else if(threeOfAKind)	typeReg = 4'b0011;
		else if(twoPairs)		typeReg = 4'b0010;
		else if(onePair)		typeReg = 4'b0001;
		else					typeReg = 4'b0000;
	end
	
	// wire straight;
	
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

module fullHouseChecker(out, notOut, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out, notOut;

	// use ChatGPT to generate those cases in short time
	// out  = ( & )  + ( & )  + ... + ( & ) 		,delay =  and2 +   or10 = 0.225 + 0.571 = 0.796
	//	    =[( & )' & ( & )' & ... & ( & )']'		,delay = nand2 + nand10 = 0.176 + 0.571 = 0.747 <-- choose this
	// out' = ...									,delay = nand2 +  and10 = 0.176 + 0.571 = 0.747 <-- choose this
	// case0 012, 34
	wire i3rc012, i2rc34, case0;
	identical3RanksChecker(i3rc012, in0, in1, in2);
	identical2RanksChecker( i2rc34, in3, in4);
	ND2(case0, i3rc012, i2rc34);

	// case1 013, 24
	wire i3rc013, i2rc24, case1;
	identical3RanksChecker(i3rc013, in0, in1, in3);
	identical2RanksChecker( i2rc24, in2, in4);
	ND2(case1, i3rc013, i2rc24);

	// case2 014, 23
	wire i3rc014, i2rc23, case2;
	identical3RanksChecker(i3rc014, in0, in1, in4);
	identical2RanksChecker(i2rc23, in2, in3);
	ND2(case2, i3rc014, i2rc23);

	// case3 023, 14
	wire i3rc023, i2rc14, case3;
	identical3RanksChecker(i3rc023, in0, in2, in3);
	identical2RanksChecker(i2rc14, in1, in4);
	ND2(case3, i3rc023, i2rc14);

	// case4 024, 13
	wire i3rc024, i2rc13, case4;
	identical3RanksChecker(i3rc024, in0, in2, in4);
	identical2RanksChecker(i2rc13, in1, in3);
	ND2(case4, i3rc024, i2rc13);

	// case5 034, 12
	wire i3rc034, i2rc12, case5;
	identical3RanksChecker(i3rc034, in0, in3, in4);
	identical2RanksChecker(i2rc12, in1, in2);
	ND2(case5, i3rc034, i2rc12);

	// case6 123, 04
	wire i3rc123, i2rc04, case6;
	identical3RanksChecker(i3rc123, in1, in2, in3);
	identical2RanksChecker(i2rc04, in0, in4);
	ND2(case6, i3rc123, i2rc04);

	// case7 124, 03
	wire i3rc124, i2rc03, case7;
	identical3RanksChecker(i3rc124, in1, in2, in4);
	identical2RanksChecker(i2rc03, in0, in3);
	ND2(case7, i3rc124, i2rc03);

	// case8 134, 02
	wire i3rc134, i2rc02, case8;
	identical3RanksChecker(i3rc134, in1, in3, in4);
	identical2RanksChecker(i2rc02, in0, in2);
	ND2(case8, i3rc134, i2rc02);

	// case9 234, 01
	wire i3rc234, i2rc01, case9;
	identical3RanksChecker(i3rc234, in2, in3, in4);
	identical2RanksChecker(i2rc01, in0, in1);
	ND2(case9, i3rc234, i2rc01);

	ND10(   out, case0, case1, case2, case3, case4, case5, case6, case7, case8, case9);
	AN10(notOut, case0, case1, case2, case3, case4, case5, case6, case7, case8, case9);
endmodule

module threeOfAKindPossibleChecker(out, notOut, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out, notOut;

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

	OR10(   out, i3rc012, i3rc013, i3rc014, i3rc023, i3rc024, i3rc034, i3rc123, i3rc124, i3rc134, i3rc234);
	NR10(notOut, i3rc012, i3rc013, i3rc014, i3rc023, i3rc024, i3rc034, i3rc123, i3rc124, i3rc134, i3rc234);
endmodule

module twoPairsPossibleChecker(out, notOut, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out, notOut;

	wire sub0123, sub0124, sub0134, sub0234, sub1234;
	twoPairsPossibleSubChecker(sub0123, in0, in1, in2, in3);
	twoPairsPossibleSubChecker(sub0124, in0, in1, in2, in4);
	twoPairsPossibleSubChecker(sub0134, in0, in1, in3, in4);
	twoPairsPossibleSubChecker(sub0234, in0, in2, in3, in4);
	twoPairsPossibleSubChecker(sub1234, in1, in2, in3, in4);

	OR5(   out, sub0123, sub0124, sub0134, sub0234, sub1234);
	NR5(notOut, sub0123, sub0124, sub0134, sub0234, sub1234);
endmodule

module twoPairsPossibleSubChecker(out, in0, in1, in2, in3);
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

	// out  = s01&s23 + s02&s13 + s03&s12
	//      = ((s01&s23)' & (s02&s13)' & (s03&s12)')'	, delay = nand2 + nand3 = 0.176 + 0.226 = 0.402
	wire case0, case1, case2;

	// case0 : check if rank0 = rank1 = x and rank2 = rank3 = y but x != y
	ND2(case0, same01, same23);

	// case1 :  check if rank0 = rank2 = x and rank1 = rank3 = y but x != y]
	ND2(case1, same02, same13);

	// case2 : check if rank0 = rank3 = x and rank1 = rank2 = y but x != y
	ND2(case2, same03, same12);

	ND3(out, case0, case1, case2);
endmodule

module onePairPossibleChecker(out, notOut, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out, notOut;

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

	OR10(   out, i2rc01, i2rc02, i2rc03, i2rc04, i2rc12, i2rc13, i2rc14, i2rc23, i2rc24, i2rc34);
	NR10(notOut, i2rc01, i2rc02, i2rc03, i2rc04, i2rc12, i2rc13, i2rc14, i2rc23, i2rc24, i2rc34);
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
	// F = abcd + (a+b+c+d)'			delay = and4 + or2 = 0.371 + 0.300 = 0.671
	//   = [(abcd)' (a+b+c+d)]'		delay = or4 + iv + nd2 = 0.345 + 0.127 + 0.176 = 0.648
	// nor4 -> inverter = 0.345 + 0.127 = 0.472
	// or4 = 0.544

	wire nand4;
	ND4(nand4, in0, in1, in2, in3);

	wire nor4, or4;
	NR4(nor4, in0, in1, in2, in3);
	IV(or4,nor4);

	ND2(out, nand4, or4);
endmodule

module same3BitChecker(out, in0, in1, in2);
	input in0, in1, in2;
	output out;
	// F = abc + (a+b+c)'		delay = nor3 + or2  = 0.349 + 0.300 = 0.649
	//   = [(abc)' (a+b+c)]'	delay = or3 + nand2 = 0.430 + 0.176 = 0.606

	wire or3;
	OR3(or3, in0, in1, in2);

	wire nand3;
	ND3(nand3, in0, in1, in2);

	ND2(out, or3, nand3);
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
	//   = ((a+b+c)'(d+e)')'	, delay = nor3 + nand2 = 0.345 + 0.176 = 0.521
	//   = ((a+b)'(c+d)'e')'	, delay = nor2 + nand3 = 0.227 + 0.226 = 0.453
	input A, B, C, D, E;
	output Z;
	
	wire nor21, nor22, notE;
	NR2(nor21, A, B);
	NR2(nor22, C, D);
	IV(notE, E);
	ND3(Z, nor21, nor22, notE);
endmodule

module NR5(Z,A,B,C,D,E);
	// nor 5
	// f = (a+b+c+d+e)'
	//   = (a+b+c)'(d+e)'	, delay = nor3 + and2 = 0.345 + 0.225 = 0.570
	//	 = (a+b)'(c+d)'e'	, delay = nor2 + and3 = 0.227 + 0.275 = 0.502
	input A, B, C, D, E;
	output Z;
	
	wire nor21, nor22, notE;
	NR2(nor21, A, B);
	NR2(nor22, C, D);
	IV(notE, E);
	AN3(Z, nor21, nor22, notE);
endmodule

module AN5(Z,A,B,C,D,E);
	// and 5
	// f = abcde
	//   = ((abc)'+(de)')'	 , delay = nand3 + nor2 = 0.226 + 0.227 = 0.453
	//	 = ((ab)'+(cd)'+e')' , delay = nand2 + nor3 = 0.176 + 0.345 = 0.521
	input A, B, C, D, E;
	output Z;
	
	wire nand3, nand2;
	ND3(nand3, A, B, C);
	ND2(nand2, D, E);
	NR2(Z, nand3, nand2);
endmodule

module OR6(Z,A,B,C,D,E,F);
	// or6
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
	//   = [(a+b+c+0)'(d+e+f+0)'(g+h+i+j)']'
	// delay = nor4 + nand3 = 0.345 + 0.226 = 0.571
	// nor4 is faster than nor3
	input A,B,C,D,E;
	input F,G,H,I,J;
	output Z;
	wire nor31, nor32, nor4;
	NR4(nor31,A,B,C,1'b0);
	NR4(nor32,D,E,F,1'b0);
	NR4(nor4,G,H,I,J);
	ND3(Z,nor31,nor32,nor4);
endmodule

module NR10(Z,A,B,C,D,E,F,G,H,I,J);
	// nor10
	// F = [(a+b+c)+(d+e+f)+(g+h+i+j)]'		, delay =  or4 + nor3 = 0.472 + 0.345 = 0.818
	//   = (a+b+c+0)'(d+e+f+0)'(g+h+i+j)'	, delay = nor4 + and3 = 0.345 + 0.275 = 0.620 <-- choose this
	//	 = (a+b+c+0)'(d+e+f+0)'(g+h)'(i+j)'	, delay = nor3 + and4 = 0.345 + 0.371 = 0.716
	input A,B,C,D,E;
	input F,G,H,I,J;
	output Z;
	wire nor31, nor32, nor4;
	NR4(nor31,A,B,C,1'b0);
	NR4(nor32,D,E,F,1'b0);
	NR4(nor4,G,H,I,J);
	AN3(Z,nor31,nor32,nor4);
endmodule

module ND10(Z,A,B,C,D,E,F,G,H,I,J);
	// nand10
	// F = [(abc)(def)(ghij)]'		, delay =  and4 + nand3 = 0.371 + 0.226 = 0.697
	//   = [(abc)(def)(gh)(ij)]'	, delay =  and3 + nand4 = 0.275 + 0.296 = 0.571 <-- choose this
	//   = (abc)'+(def)'+(ghij)'	, delay = nand4 +   or3 = 0.296 + 0.430 = 0.726
	input A,B,C,D,E;
	input F,G,H,I,J;
	output Z;
	wire and21, and22, and31, and32;
	AN3(and31,A,B,C);
	AN3(and32,D,E,F);
	AN2(and21,G,H);
	AN2(and22,I,J);
	ND4(Z,and31,and32,and21,and22);
endmodule

module AN10(Z,A,B,C,D,E,F,G,H,I,J);
	// and10
	// F = (abc)(def)(ghij)				, delay =   and4 + and3 = 0.371 + 0.275 = 0.646
	//   = [(abc)'+(def)'+(gh)'+(ij)']'	, delay =  nand3 + nor4 = 0.226 + 0.345 = 0.571 <-- choose this
	//   = [(abc)'+(def)'+(ghij)']'		, delay =  nand4 + nor3 = 0.296 + 0.345 = 0.641
	input A,B,C,D,E;
	input F,G,H,I,J;
	output Z;
	wire nand21, nand22, nand31, nand32;
	ND3(nand31,A,B,C);
	ND3(nand32,D,E,F);
	ND2(nand21,G,H);
	ND2(nand22,I,J);
	NR4(Z,nand31,nand32,nand21,nand22);
endmodule