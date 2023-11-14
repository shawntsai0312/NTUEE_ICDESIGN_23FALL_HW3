`timescale 1ns/1ps

module poker(type, i0, i1, i2, i3, i4);
//DO NOT CHANGE!
	input  [5:0] i0, i1, i2, i3, i4;
	output [3:0] type;
//---------------------------------------------------

	// flush
	wire flush;
	flushChecker(flush, i0[5:4], i1[5:4], i2[5:4], i3[5:4], i4[5:4]);

	// four of a kind
	wire fourOfAKind, notFour;
	fourOfAKindChecker(fourOfAKind, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	IV(notFour, fourOfAKind);

	// full house
	wire fullHouse, notFull;
	fullHouseChecker(fullHouse, notFull, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);

	// three of a kind
	wire threeOfAKind, threeOfAKinkPossible, notThree, notThreePossible;
	threeOfAKindPossibleChecker(threeOfAKinkPossible, notThreePossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	AN2(threeOfAKind, threeOfAKinkPossible, notFull);
	ND2(notThree, threeOfAKinkPossible, notFull);

	// two pairs
	wire twoPairs, twoPairsPossible, notTwo, notTwoPossible;
	twoPairsPossibleChecker(twoPairsPossible, notTwoPossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	AN3(twoPairs, twoPairsPossible, notFour, notFull);				// 0.275 + 0.402 = 0.677
	ND3(  notTwo, twoPairsPossible, notFour, notFull);				// 0.226 + 0.402 = 0.628

	// one pair
	wire onePair, onePairPossible, notOne, notOnePossible;
	onePairPossibleChecker(onePairPossible, notOnePossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	AN3(onePair, onePairPossible, notThreePossible, notTwoPossible);
	ND3( notOne, onePairPossible, notThreePossible, notTwoPossible);

	// straight
	// 10,11,12,13,1 to be done
	wire straightPossible, notStraightPossible, straight;
	straightPossibleChecker(straightPossible, notStraightPossible, i0[3:0], i1[3:0], i2[3:0], i3[3:0], i4[3:0]);
	AN2(straight, straightPossible, notOnePossible);

	// output tester
	reg [3:0] typeReg;
	always @(*) begin
		if(flush) begin
			if(straight)		typeReg = 4'b1000;
			else 				typeReg = 4'b0101;
		end
		else if(straight)		typeReg = 4'b0100;
		else if(fourOfAKind)	typeReg = 4'b0111;
		else if(fullHouse)		typeReg = 4'b0110;
		else if(threeOfAKind)	typeReg = 4'b0011;
		else if(twoPairs)		typeReg = 4'b0010;
		else if(onePair)		typeReg = 4'b0001;
		else					typeReg = 4'b0000;
	end
endmodule

module flushChecker(out, in0, in1, in2, in3, in4);
	input [1:0] in0, in1, in2, in3, in4;
	output out;

	wire s5bc0, s5bc1;
	same5BitChecker(s5bc0, in0[0], in1[0], in2[0], in3[0], in4[0]);
	same5BitChecker(s5bc1, in0[1], in1[1], in2[1], in3[1], in4[1]);
	
	AN2(out, s5bc0, s5bc1);
endmodule

module straightPossibleChecker(out, notOut, in0, in1, in2, in3, in4);
	input [3:0] in0, in1, in2, in3, in4;
	output out, notOut;

	// since all 5 cards are not the same rank
	// go through twoNeighborChecker
	// 3 results is true and 2 results is false
	// if 4/5 results is true, just return true, since they are all don't care terms
	// out = abc + abd + abe + ... + cde , total 10 cases or
	// use nand3 and nand10 to accelerate
	wire case0, case1, case2, case3, case4;
	twoNeighborChecker(case0, in0, in1, in2, in3, in4);
	twoNeighborChecker(case1, in1, in0, in2, in3, in4);
	twoNeighborChecker(case2, in2, in0, in1, in3, in4);
	twoNeighborChecker(case3, in3, in0, in1, in2, in4);
	twoNeighborChecker(case4, in4, in0, in1, in2, in3);

	wire nd012, nd013, nd014, nd023, nd024, nd034, nd123, nd124, nd134, nd234;
	ND3(nd012, case0, case1, case2);
	ND3(nd013, case0, case1, case3);
	ND3(nd014, case0, case1, case4);
	ND3(nd023, case0, case2, case3);
	ND3(nd024, case0, case2, case4);
	ND3(nd034, case0, case3, case4);
	ND3(nd123, case1, case2, case3);
	ND3(nd124, case1, case2, case4);
	ND3(nd134, case1, case3, case4);
	ND3(nd234, case2, case3, case4);
	ND10(out, nd012, nd013, nd014, nd023, nd024, nd034, nd123, nd124, nd134, nd234);
	AN10(notOut, nd012, nd013, nd014, nd023, nd024, nd034, nd123, nd124, nd134, nd234);
endmodule

module neighborChecker(out, notOut, in0, in1);
	input [3:0] in0, in1;
	output out, notOut;

	// case1 : xxx0 , xxx1
	// case2 : xx01 , xx10
	// case3 : x011 , x100
	// case4 : 0111 , 1000
	// 4 cases or
	wire case1, case2, case3, case4;
	wire notC1, notC2, notC3, notC4;
	theLeast1BitChangeChecker(case1, notC1, in0, in1);
	theLeast2BitChangeChecker(case2, notC2, in0, in1);
	theLeast3BitChangeChecker(case3, notC3, in0, in1);
	theLeast4BitChangeChecker(case4, notC4, in0, in1);
	
	ND4(out, notC1, notC2, notC3, notC4);
	NR4(notOut, case1, case2, case3, case4);
endmodule

module twoNeighborChecker(out, main, in1, in2, in3, in4);
	input [3:0] main, in1, in2, in3, in4;
	output out;

	// the input might be the same rank but we don't have to worry about it!
	// we will use notOnePossible above to filter the final result!
	wire isNeighbor1, notNeighbor1, isNeighbor2, notNeighbor2;
	wire isNeighbor3, notNeighbor3, isNeighbor4, notNeighbor4;

	neighborChecker(isNeighbor1, notNeighbor1, main, in1);
	neighborChecker(isNeighbor2, notNeighbor2, main, in2);
	neighborChecker(isNeighbor3, notNeighbor3, main, in3);
	neighborChecker(isNeighbor4, notNeighbor4, main, in4);

	// out = is1&is2 + is1&is3 + ... + is3&is4	, delay =  and2 +   or6 = 0.225 + 0.525
	//	   = [()' & ()' & ... & ()']'			, delay = nand2 + nand6 = 0.176 + 0.453  <-- choose this
	wire case12, case13, case14, case23, case24, case34;
	ND2(case12, isNeighbor1, isNeighbor2);
	ND2(case13, isNeighbor1, isNeighbor3);
	ND2(case14, isNeighbor1, isNeighbor4);
	ND2(case23, isNeighbor2, isNeighbor3);
	ND2(case24, isNeighbor2, isNeighbor4);
	ND2(case34, isNeighbor3, isNeighbor4);
	ND6(out, case12, case13, case14, case23, case24, case34);
endmodule

module theLeast4BitChangeChecker(out, notOut, in0, in1);
	input [3:0] in0, in1;
	output out, notOut;

	// 0111,1000
	// (in0[3:0] == 0111 & in1[3:0] == 1000) + (inverse)
	// in0 = a, in1 = b
	// out = a3'a2a1a0b3b2'b1'b0' + a3a2'a1'a0'b3'b2b1b0
	//	   = [(a3'a2a1a0b3b2'b1'b0')'&(a3a2'a1'a0'b3'b2b1b0)']'
	wire not00, not01, not02, not03, not10, not11, not12, not13;
	IV(not00, in0[0]);
	IV(not01, in0[1]);
	IV(not02, in0[2]);
	IV(not03, in0[3]);
	IV(not10, in1[0]);
	IV(not11, in1[1]);
	IV(not12, in1[2]);
	IV(not13, in1[3]);

	wire nand81, nand82;
	ND8(nand81, not03, in0[2], in0[1], in0[0], in1[3], not12, not11, not10);
	ND8(nand82, in0[3], not02, not01, not00, not13, in1[2], in1[1], in1[0]);
	ND2(out, nand81, nand82);			// delay = iv + nand8 + nand2 = 0.127 + 0.501 + 0.176 = 0.804
	AN2(notOut, nand81, nand82);		// delay = iv + nand8 +  and2 = 0.127 + 0.501 + 0.225 = 0.853
endmodule

module theLeast3BitChangeChecker(out, notOut, in0, in1);
	input [3:0] in0, in1;
	output out, notOut;

	// x011 , x100
	// (in0[2:0] == 011 & in1[2:0] == 100) + (inverse)
	// in0 = a, in1 = b
	// check = a2'a1a0b2b1'b0' + a2a1'a0'b2'b1b0
	//		 = [(a2'a1a0b2b1'b0')'&(a2a1'a0'b2'b1b0)']'  , delay = iv + nand6 + nand2 = 0.127 + 0.451 + 0.176 = 0.754
	// check'= ....										 , delay = iv + nand6 +  and2 = 0.127 + 0.451 + 0.225 = 0.803
	wire not00, not01, not02, not10, not11, not12;
	IV(not00, in0[0]);
	IV(not01, in0[1]);
	IV(not02, in0[2]);
	IV(not10, in1[0]);
	IV(not11, in1[1]);
	IV(not12, in1[2]);

	wire check, ncheck, nand61, nand62;
	ND6(nand61, not02, in0[1], in0[0], in1[2], not11, not10);
	ND6(nand62, in0[2], not01, not00, not12, in1[1], in1[0]);
	AN2(check, nand61, nand62);
	ND2(ncheck, nand61, nand62);
	
	wire xor3, xnor3;
	EO(xor3, in0[3], in1[3]);
	XNOR2(xnor3, in0[3], in1[3]);

	NR2(out, check, xor3);			// delay =  check +  nor2 = 0.754 + 0.227 = 0.981
	ND2(notOut, ncheck, xnor3);		// delay = ncheck + nand2 = 0.803 + 0.176 = 0.979
endmodule

module theLeast2BitChangeChecker(out, notOut, in0, in1);
	input [3:0] in0, in1;
	output out, notOut;

	// xx01,xx10
	// (in0[1:0] == 01 & in1[1:0] == 10) + (inverse)
	// in0 = a, in1 = b
	// check10 = a1'a0b1b0' + a1a0'b1'b0
	//		   = [(a1'a0b1b0')'&(a1a0'b1'b0)']'
	wire not00, not01, not10, not11;
	IV(not00, in0[0]);
	IV(not01, in0[1]);
	IV(not10, in1[0]);
	IV(not11, in1[1]);

	wire check10, nand41, nand42;
	ND4(nand41, not01, in0[0], in1[1], not10);
	ND4(nand42, in0[1], not00, not11, in1[0]);
	ND2(check10, nand41, nand42);
	
	//	3		2	
	// xnor & xnor  	, delay = xnor + and2 = 0.470 + 0.371 = 0.841
	//(xor +  xor)'		, delay =  xor + nor2 = 0.343 + 0.227 = 0.570  <-- choose this
	wire same32;
	EO(xor3, in0[3], in1[3]);
	EO(xor2, in0[2], in1[2]);
	NR2(same32, xor3, xor2);

	AN2(out, check10, same32);
	ND2(notOut, check10, same32);
endmodule

module theLeast1BitChangeChecker(out, notOut, in0, in1);
	input [3:0] in0, in1;
	output out, notOut;

	// xxx0,xxx1
	//	3		2		1		0
	// xnor & xnor  & xnor  &  xor 		, delay = xnor + and4 = 0.470 + 0.371 = 0.841
	//( xor +  xor  +  xor  + xnor)'	, delay = xnor + nor4 = 0.470 + 0.345 = 0.815  <-- choose this

	wire xor3, xor2, xor1, xnor0;
	EO(xor3, in0[3], in1[3]);
	EO(xor2, in0[2], in1[2]);
	EO(xor1, in0[1], in1[1]);
	XNOR2(xnor0, in0[0], in1[0]);
	NR4(out, xor3, xor2, xor1, xnor0);

	// notOut delay = xnor + nand4 = 0.470 + 0.296 = 0.766
	wire xnor3, xnor2, xnor1, xor0;
	XNOR2(xnor3, in0[3], in1[3]);
	XNOR2(xnor2, in0[2], in1[2]);
	XNOR2(xnor1, in0[1], in1[1]);
	EO(xor0, in0[0], in1[0]);
	ND4(notOut, xnor3, xnor2, xnor1, xor0);
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

	XNOR2(out, in0, in1);
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

module XNOR2(Z, A, B);
	input A, B;
	output Z;
	// F = ab + (a+b)'	, delay = nor2 + or2 = 0.227 + 0.300 = 0.527
	//   = (a'b+ab')'   , delay = xor2 + inv = 0.343 + 0.127 = 0.470 <-- choose this
	// although we can use xnor, but the delay is too high !!!
	wire xor2;
	EO(xor2, A, B);
	IV(Z, xor2);
endmodule

module OR5(Z,A,B,C,D,E);
	// or 5
	// f = a+b+c+d+e
	//   = ((a+b+c)'(d+e)')'	, delay = nor3 + nand2 = 0.345 + 0.176 = 0.521
	//   = ((a+b)'(c+d)'e')'	, delay = nor2 + nand3 = 0.227 + 0.226 = 0.453  <-- choose this
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
	//	 = (a+b)'(c+d)'e'	, delay = nor2 + and3 = 0.227 + 0.275 = 0.502  <-- choose this
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
	//   = ((abc)'+(de)')'	 , delay = nand3 + nor2 = 0.226 + 0.227 = 0.453  <-- choose this
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
	//   = [(a+b+c)'(d+e+f)']'		, delay = nor3 + nand2 = 0.345 + 0.176 = 0.521
	//   = [(a+b)'(c+d)'(e+f)']'	, delay = nor2 + nand3 = 0.227 + 0.226 = 0.453  <-- choose this
	input A, B, C, D, E, F;
	output Z;
	
	wire nor21, nor22, nor23;
	NR2(nor21, A, B);
	NR2(nor22, C, D);
	NR2(nor23, E, F);
	ND3(Z, nor21, nor22, nor23);
endmodule

module NR6(Z,A,B,C,D,E,F);
	// nor 6
	// f = (a+b+c+d+e+f)'
	//   = (a+b+c)'(d+e+f)'		, delay = nor3 + and2 = 0.345 + 0.225 = 0.570
	//   = (a+b)'(c+d)'(e+f)'	, delay = nor2 + and3 = 0.227 + 0.275 = 0.502  <-- choose this
	input A, B, C, D, E, F;
	output Z;
	
	wire nor21, nor22, nor23;
	NR2(nor21, A, B);
	NR2(nor22, C, D);
	NR2(nor23, E, F);
	AN3(Z, nor21, nor22, nor23);
endmodule

module ND6(Z,A,B,C,D,E,F);
	// nand 6
	// f = (abcdef)'
	//   = (abc)'+(def)'			, delay = nand3 +   or2 = 0.226 + 0.300 = 0.526
	//   = (ab)'+(cd)'+(ef)'		, delay = nand2 +   or3 = 0.176 + 0.430 = 0.606
	//	 = ((abc)(def))'			, delay =  and3 + nand2 = 0.275 + 0.176 = 0.451  <-- choose this
	//   = ((ab)(cd)(ed))'			, delay =  and2 + nand3 = 0.225 + 0.226 = 0.451
	// delay = 0.574
	input A, B, C, D, E, F;
	output Z;
	
	wire and31, and32;
	AN3(and31, A, B, C);
	AN3(and32, D, E, F);
	ND2(Z, and31, and32);
endmodule

module ND8(Z,A,B,C,D,E,F,G,H);
	// nand8
	// F = [(abc)(def)(gh)]'		, delay =  and3 + nand3 = 0.275 + 0.226 = 0.501  <-- choose this
	//   = [(abcd)(efgh)]'			, delay =  and4 + nand2 = 0.371 + 0.176 = 0.547
	//   = [(ab)(cd)(ef)(gh)]'		, delay =  and2 + nand4 = 0.225 + 0.296 = 0.521
	input A,B,C,D;
	input E,F,G,H;
	output Z;
	wire and2, and31, and32;
	AN3(and31,A,B,C);
	AN3(and32,D,E,F);
	AN2(and2,G,H);
	ND3(Z,and31,and32,and2);
endmodule

module AN8(Z,A,B,C,D,E,F,G,H);
	// and8
	// F = (abc)(def)(gh)				, delay =   and3 + and3 = 0.275 + 0.275 = 0.550
	//   = [(abc)'+(def)'+(gh)']'		, delay =  nand3 + nor3 = 0.226 + 0.345 = 0.571
	//   = [(abcd)'+(efgh)']'			, delay =  nand4 + nor2 = 0.296 + 0.227 = 0.523  <-- choose this
	input A,B,C,D;
	input E,F,G,H;
	output Z;
	wire nand41, nand42;
	ND4(nand41,A,B,C,D);
	ND4(nand42,E,F,G,H);
	NR2(Z,nand41,nand42);
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
	//   = [(abc)(def)(gh)(ij)]'	, delay =  and3 + nand4 = 0.275 + 0.296 = 0.571  <-- choose this
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