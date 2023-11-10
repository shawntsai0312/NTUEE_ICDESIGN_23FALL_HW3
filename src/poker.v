`timescale 1ns/1ps

module poker(type, i0, i1, i2, i3, i4);
//DO NOT CHANGE!
	input  [5:0] i0, i1, i2, i3, i4;
	output [3:0] type;
//---------------------------------------------------

// flush checker
	// wire flush;
	wire f_5_temp1, f_5_temp2, f_4_temp1, f_4_temp2;
	EN3(f_5_temp1,		i0[5],	i1[5],	i2[5]);
	EN3(f_5_temp2,	f_5_temp1,	i3[5],	i4[5]);
	EN3(f_4_temp1,		i0[4],	i1[4],	i2[4]);
	EN3(f_4_temp2,	f_4_temp1,	i3[4],	i4[4]);
	// AN2(flush,		f_5_temp2,	f_4_temp2);
	AN2(type[3],		f_5_temp2,	f_4_temp2);
	assign type[2:0] = 3'b000;

	

// rank sorter
	// wire [3:0] i0s, i1s, i2s, i3s, i4s;

endmodule