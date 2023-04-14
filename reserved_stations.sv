/*------------------------------------------------------------------------------------------------
#File:reserved station.sv
#Description:The module of reserved station
#Author:Yanglirong
#Time:2023-4-1 15:39
------------------------------------------------------------------------------------------------*/
module reserved_stations #(parameter num_b = 4, num_d = 16, 
									 width = 35,rs2_width = 32)(		
//first write ,then read
	input clk1,clk2,reset,rs_write_dis,write_num_dis,
//	input [num_b-1:0] write_point,
	input [52:1] rs_must_1,rs_must_2,
	input [width-1:0] write_data_1,write_data_2,
/*------------------------awake-----------------------------------*/
	input hit_wb_agu,
	input [5:0] rd_alu_wb,rd_sfu_wb,rd_agu_wb,
	input [31:0] result_alu_wb,result_sfu_wb,result_agu_wb,	//用于awake
//	output [1:0] full_state,	
	output [5:0] iss_rob_num,
	output [width+31:0] read_data,
	output if_iss,free_1,free_2
);
	reg [width+52:0]   rs[num_d-1:0];
	reg [num_b-1:0]   write_point;
	wire [num_d-1:0]   ready_state;
	wire [num_b-1:0]   iss_ponit,write_point_addend;
	wire [num_d-1:0]   press_sign;
	wire [width+52:0]  press_data[num_d-2:0];
	wire [num_d-1:0]   awake_rs1_sign,awake_rs2_sign;
	wire [31:0]		   awake_rs1_data[num_d-1:0];
	wire [rs2_width-1:0] awake_rs2_data[num_d-1:0];
	wire rs_free_1,rs_free_2;

	wire [num_b:0] in,i,awake_wr,awake;
	always @ (*) 
		case ({rs_write_dis,write_num_dis,if_iss})
			3'b000	: write_point_addend = 0;
			3'b001	: write_point_addend = {num_b{1'b1}};
			3'b010	: write_point_addend = 0;
			3'b011	: write_point_addend = {num_b{1'b1}};
			3'b100	: write_point_addend = {num_b{1'b1}};
			3'b101	: write_point_addend = 0;
			3'b110	: write_point_addend = 'b10;
			default : write_point_addend = {num_b{1'b1}};
		endcase
/*--------------------------write poing-----------------------------------------------*/
	always @ (posedge clk2,posedge reset) begin
		if(reset)	write_point = 0;
		else		write_point = write_point + write_point_addend;
	end
/*---------------------------仲裁（arbitrare）-----------------------------------------*/
	always @ (*) begin
		for (i = 0; i < num_d; i++) begin
			ready_state[i] = rs[i][0]&rs[i][1]&rs[i][2];
		end
		begin:encoder
			for (i = 0; i < num_d; i++) begin
				if (ready_state[i] == 1'b1) begin
					iss_ponit = i[num_b-1:0];
					if_iss = 1'b1;					//1表示有指令就绪可以发射
					disable encoder;
				end
				else begin
					iss_ponit = 0;
					if_iss = 1'b0;
				end
			end
		end
	end
/*--------------------------唤醒(awake)---------------------------------------------*/
	always @ (*) begin 
		/*--------------------------rs1_唤醒（awake）---------------------------------------------*/
		for (awake = 0; awake < num_d; awake++) begin
//			if(rs[awake][0]) begin
				if (rs[awake][8:3] == rd_alu_wb) begin
					awake_rs1_sign[awake] = rs[awake][0];
					awake_rs1_data[awake] = result_alu_wb;
				end
				else if (rs[awake][8:3] == rd_sfu_wb) begin
					awake_rs1_sign[awake] = rs[awake][0];
					awake_rs1_data[awake] = result_sfu_wb;
				end
				else if ((rs[awake][8:3] == rd_agu_wb) & hit_wb_agu) begin
					awake_rs1_sign[awake] = rs[awake][0];
					awake_rs1_data[awake] = result_agu_wb;
				end
				else begin
					awake_rs1_sign[awake] = 0;
				end 
		/*--------------------------rs2_唤醒（awake）---------------------------------------------*/
				if (rs[awake][14:9] == rd_alu_wb) begin
					awake_rs2_sign[awake] = rs[awake][0];
					awake_rs2_data[awake] = result_alu_wb[rs2_width-1:0];
				end
				else if (rs[awake][14:9] == rd_sfu_wb) begin
					awake_rs2_sign[awake] = rs[awake][0];
					awake_rs2_data[awake] = result_sfu_wb[rs2_width-1:0];
				end
				else if ((rs[awake][14:9] == rd_agu_wb) & hit_wb_agu) begin
					awake_rs2_sign[awake] = rs[awake][0];
					awake_rs2_data[awake] = result_agu_wb[rs2_width-1:0];
				end
				else begin
					awake_rs2_sign[awake] = 0;
				end 
//			end
//			else begin
//				awake_rs1_sign[awake] = 0;
//				awake_rs2_sign[awake] = 0;
//			end
		end
	end

/*---------------------------压缩----------------------------------------------------*/
	always @ (*) begin
			if (if_iss) 
				for (i = 0; i < num_d; i++) begin 
					if( i < iss_ponit)
						press_sign[i] = 1'b0;
					else
						press_sign[i] = 1'b1;
				end
			else
				press_sign = 0;	
	end
/*-------------------------dispath write reserved stations-----------------------------*/
	always @ (posedge clk1,posedge clk2,posedge reset) begin
		if (reset) begin
			for (in = 0; in < num_d; in++) begin
				rs[in][0] = 0;
			end
		end
		else begin
			if (clk1) begin
				if(rs_write_dis) begin
					rs[write_point] <= {write_data_1,rs_must_1,rs_write_dis};
					if(write_num_dis)
						rs[write_point+1] <= {write_data_2,rs_must_2,write_num_dis};
				end
				if(if_iss)		 rs[iss_ponit][0]   <= 1'b0;
				for(awake_wr = 0 ; awake_wr < num_d ; awake_wr++) begin
			 		if (awake_rs1_sign[awake_wr]) begin
			 			rs[awake_wr][1] <= 1'b1;
			 			rs[awake_wr][52:21] <= awake_rs1_data[awake_wr];
			 		end
			 		if (awake_rs2_sign[awake_wr]) begin
			 			rs[awake_wr][2] <= 1'b1;
			 			rs[awake_wr][rs2_width+52:53] <= awake_rs2_data[awake_wr];
			 		end
				end
			end
			if (clk2) begin
				for (i = 0; i < num_d-1; i++) begin
					rs[i] <= press_sign[i] ? rs[i+1] : rs[i];
				end
				rs[num_b-1] <= press_sign[num_d-1] ? 0 : rs[num_b-1];
			end
		end
	end
				

/*-------------------------issue read reserved stations-----------------------------*/
/*	always @ (iss_ponit,if_iss) begin 				//读和压缩应该怎么控制先后，（if_iss出来后，会读,也生成压缩信号，进行压缩）
		if(if_iss) begin
			iss_rob_num <= rs[iss_ponit][20:15];
			read_data   <= rs[iss_ponit][width+52:21];
		end
	end	
*/
	assign {read_data,iss_rob_num} = if_iss ? rs[iss_ponit][width+52:15] : 0;
	assign {rs_free_1,rs_free_2} = {rs[num_d-1][0],rs[num_d-2][0]};
	assign free_1 = ~(rs_free_1 & rs_free_2);
	assign free_2 = ~(rs_free_1 | rs_free_2);

endmodule