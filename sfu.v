/**************************************************************

Filename: sfu.v
Designer: Dragon
Create date: 2023.3.26
Modification date: 2023.3.28
Reason for modification: Function validation error
Description: Shift instruction execution unit.

***************************************************************/

module sfu (
           input         [31:0]   a,
           input         [31:0]   b,
           input         [1:0]   control,
           output reg    [31:0]  c
           );

        reg     [31:0]  srlresult; 

        always @(*) begin
            srlresult = a >> b;
        end

        always @(*) begin
            case(control)
                2'b00:       c = a << b;                                    //sll       
                2'b01:       c = a >> b;                                    //srl   
                2'b11:       c = {a[31],srlresult[30:0]};         //sra
                default      c = 32'bx;
            endcase
        end
endmodule