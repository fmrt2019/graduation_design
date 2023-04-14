/**************************************************************

Filename: alu.v
Designer: Dragon
Create date: 2023.3.25
Modification date: 2023.3.28
Reason for modification: Comparison function validation error
Description: Implement the functions of arithmetic, logic, and comparison set to 1.
Note:

***************************************************************/

module  alu (
			       input		 [31:0] a,b,
			       input 	     [2:0] control,
			       output reg  [31:0] c,
             output reg    overflow
            );

        wire [31:0] slt_result;
        wire s;

        wire	[32:0]	oa;
        wire	[32:0]	ob;
        reg		[32:0]	oc;

        assign oa = {1'b0,a};
        assign ob = {1'b0,b};

        assign s = control[0];                 //Control whether there is a symbolic comparison
        
        slt   slt1     (a,b,s,slt_result);     //Get a comparison result

        always@(*)	begin
			case(control)
				3'b000:	begin            //add
									oc = oa + ob;
									c = oc[31:0];
									overflow = oc[32];
							end		
				3'b001:	begin            //sub
									oc = oa - ob;
									c = oc[31:0];
									overflow = oc[32];
								end		
				3'b010:	begin            //slt
									oc = 33'bx;
									c = slt_result;	
									overflow = 0;
								end	
				3'b011:	begin        		//sltu
									oc = 33'bx;
									c = slt_result;
									overflow = 0;
								end
				3'b100:	begin      			//xor
									oc = 33'bx;
									c = a ^ b;
									overflow = 0;
								end
				3'b110:	begin      			//or
									oc = 33'bx;
									c = a | b;
									overflow = 0;
								end
				3'b111:	begin 			    //and
									oc = 33'bx;
									c = a & b;
									overflow = 0;
								end
				default:begin
									oc = 33'bx;
									c = 32'bx;
									overflow = 0;
								end
				endcase
		  end
endmodule


/*set less than
  If S==0, an unsigned comparison is performed, whereas a signed comparison is performed
*/

module  slt  (
             input        [31:0] a,b,
             input        s,
             output reg   [31:0] c
             );

              //reg [31:0] d0,d1;

              always @(*) begin
              //slt
                if (s == 0) begin
                  if (a[31] == 1 && b[31] == 0)       //a为负，b为正
                  begin      
								c = 1;
						end
                  else if(a[31] == 0 && b[31] == 1)   //a为正，b为负
						begin
                        c = 0;
						end
                  else if(a[31] == 0 && b[31] == 0)   //a,b都为正和无符号比较一样
						begin
                        c = (a < b)? 1:0;
						end
                  else                                //a,b均为负和无符号比较一样
						begin
                        c = (a < b)? 1:0;
						end
                end
              //sltu
                else  begin
                        c = (a < b)? 1:0;
                end
              end
endmodule