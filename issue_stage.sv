/*------------------------------------------------------------------------------------------------
#File:issue_stage.sv
#Description:Synthesis of issue stage
#Author:Yanglirong
#Time:2023-4-3 14:44
------------------------------------------------------------------------------------------------*/
module issue_stage (
//	inout [5:0]	 alu_rob_num,sfu_rob_num,bru_rob_num,agu_rob_num,
	input [66:0] alu_data,
	input [38:0] sfu_data,
	input [99:0] bru_data,
	input [104:0] agu_data,
//	inout alu_iss,sgu_iss,bru_iss,agu_iss,

	output bru_pre_direct,
	output [1:0]  sfu_ctrl,
	output [2:0]  alu_ctrl,bru_ctrl,
	output [3:0]  agu_ctrl,
	output [4:0]  sfu_src2,agu_load_num,
	output [31:0] alu_src1,sfu_src1,bru_src1,agu_src1,
				  alu_src2,bru_src2,agu_src2,
				  bru_pre_pc,agu_imm
);

//------------------alu------------------------
	assign alu_src1 = alu_data[31:0];
	assign alu_src2 = alu_data[63:32];
	assign alu_ctrl = alu_data[66:64];

//------------------sfu------------------------
	assign sfu_src1 = sfu_data[31:0];
	assign sfu_src2 = sfu_data[36:32];
	assign sfu_ctrl = sfu_data[38:37];

//------------------bru------------------------
	assign bru_src1 = bru_data[31:0];
	assign bru_src2 = bru_data[63:32];
	assign bru_pre_pc = bru_data[95:64];
	assign bru_pre_direct = bru_data[96];
	assign bru_ctrl = bru_data[99:97];

//------------------agu------------------------
	assign agu_src1 = agu_data[31:0];
	assign agu_src2 = agu_data[63:32];
	assign agu_imm  = agu_data[95:64];
	assign agu_load_num = agu_data[100:96];
	assign agu_ctrl = agu_data[104:101];
	
endmodule