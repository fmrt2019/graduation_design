/*****************************************************************************
Filename:compressed_decoder.v
Designer:FMRT2019_Megan
Create date:2023.04.10 19:49
Description:Basic components.
*******************************************************************************/


module mux2		#(parameter	width = 32)
	(input	[width-1:0] d0,d1,
	 input	s,
	 output [width-1:0] y);

	assign   y = s? d1 : d0;

endmodule

module mux3		#(parameter	width = 32)
	(input	[width-1:0] d0,d1,d2,
	 input	[1:0]  s,
	 output [width-1:0] y);

	assign   y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule

module mux4		#(parameter	width = 32)
	(input	[width-1:0] d0,d1,d2,d3,
	 input	[1:0] s,
	 output [width-1:0] y);

	assign   y = s[1] ? (s[0] ? d3 : d2):(s[0] ? d1 : d0);

endmodule

module adder	#(parameter width = 32)
	(input  [width-1:0] a,b,
	 output [width-1:0] y);

    assign  y = a + b;

endmodule

module subtracter	#(parameter	width = 32)
	(input	[width-1:0] a,b,
	 output	[width-1:0] y);

	assign   y = a - b;

endmodule

module tristate	#(parameter	width = 32)
	(input	[width-1:0] a,
	 input  en,
	 output [width-1:0] y);

	assign  y = en ? a : {width{1'bz}};

endmodule

module  flopr	#(parameter	width = 32)
				 (
				 input			clk,reset,
				 input			[width-1:0]	d,
				 output reg	[width-1:0]	q
				 );
    always @ (posedge clk,posedge reset)
      if(reset) q <= {width{1'b0}};
      else q <= d;

endmodule

module flopren	#(parameter	width = 32)
				 (input			clk,reset,en,
				 	input			[width-1:0]	d,
				  output reg	[width-1:0]	q);
    
    always @ (posedge clk,posedge reset)
      if(reset) q <= 'b0;
      else if(en) q <= d;

endmodule



