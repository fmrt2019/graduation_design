/*###########################################################################################
#File name: store_num.sv
#Description: The module of store_num.
#Author:Yanglirong
#Time: 2023-3-29 21：00 
###########################################################################################*/
module store_number (
	input clk,reset,st_1,st_2,
	output[4:0] store_num_1,store_num_2						//load/store指令的编号
);
	reg [4:0] store_couter;					//计数器,用于分配编号
	wire [4:0] store_couter_1,store_couter_2,store_couter_next;
	assign store_couter_1 = store_couter + 5'b00001;
	assign store_couter_2 = store_couter + 5'b00010;
	mux4 #(5) store2 (store_couter,store_couter_1,store_couter_1,store_couter_2,{st_2,st_1},store_couter_next);
	assign store_num_1 = st_1 ? store_couter_1 : store_couter;
	assign store_num_2 = store_couter_next;
	always @ (posedge clk,posedge reset) begin				//是否需要复位
		if(reset) store_couter <= 5'b0;
		else store_couter <= store_couter_next;
	end
endmodule



