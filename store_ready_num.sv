/*------------------------------------------------------------------------------------------------
#File:store_ready_num.sv
#Description:The module of store_ready_num
#Author:Yanglirong
#Time:2023-4-12 10:52
------------------------------------------------------------------------------------------------*/
module store_ready_num (
	input clk,reset,
	input agu_iss,agu_ctrl_3,
	output [4:0] store_exe_num
	
);
	reg[4:0] store_exe_num;

	always @ (posedge clk,posedge reset)
		if (reset) store_exe_num <= 5'b0;
		else if (agu_iss & agu_ctrl_3) store_exe_num <= store_exe_num + 5'b1;

endmodule