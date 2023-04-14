/*##########################################################################
#File name: decode_stage.sv
#Description: The module of decode.
#Author: Yanglirong
#Time: 2023-3-31 9:43
###########################################################################*/
module decode_stage (
	input clk,						//时钟信号，分配保留站编号时用
	input reset,					//复位信号，分配保留站编号时用

	input [31:2] instr_de_1,		//第一条指令
	input [31:0] pc_de_1,			//第一条指令的地址
	input pre_direction_de_1,		//第一条指令的预测方向，1表示预测跳转，0表示顺序取下一条指令
	input [31:0] pre_pc_de_1,		//第一条指令的预测地址
	input instr_is_compressde_1,	//第一条指令是否是压缩指令，1表示是压缩指令
	
	output rs_write_de_1,			//第一条指令是否需要写入保留站，lui、auipc、jal不用存入保留站，1表示要写入保留站
	output rs1_read_de_1,			//第一条指令是否有源寄存器1
	output ri2_de_1,				//第一条指令是否有源寄存器2
	output rd_write_de_1,			//第一条指令是否有目的寄存器，1表示有目的寄存器
	output st_de_1,					//第一条指令是否是store指令
	output detect_first_result_de_1,//对于预测结果的第一次判断结果，1表示预测正确，0表示预测错误
	output [1:0] rs_num_de_1,		//第一条指令对应的保留站,有4个保留站，00：alu_rs 01:sfu_rs 10:bru_rs 11:agu_rs
	output [1:0] br_type_de_1,		//第一条指令的类型，00:非分支跳转指令 01:call指令 10:return指令 11:普通的分支和无条件跳转指令
	output [3:0] rs_ctrl_de_1,		//第一条指令FU的控制信号
	output [4:0] rs1_de_1,			//第一条指令源寄存器1的逻辑寄存器号
	output [4:0] rs2_de_1,			//第一条指令源寄存器2的逻辑寄存器号
	output [4:0] rd_de_1,			//第一条指令目的寄存器的逻辑寄存器号
	output [4:0] ld_st_num_de_1,	//第一条指令st_load指令的编号
	output [31:0] imm_de_1,			//第一条指令的立即数
	output [31:0] next_pc_de_1,		//顺序下一条指令的地址，用于分支预测的更新和恢复，也是jal、jalr指令要写入目的寄存器的数据
	output [31:0] rs_bru_pc_de_1,	//要写入bru_pc列的数据，对于jalr指令，写入的预测pc，对于br，写入的是imm+pc的值


	input [31:2] instr_de_2,
	input [31:0] pc_de_2,
	input pre_direction_de_2,
	input [31:0] pre_pc_de_2,
	input instr_is_compressde_2,
	
	output rs_write_de_2,
	output rs1_read_de_2,
	output ri2_de_2,
	output rd_write_de_2,
	output st_de_2,
	output detect_first_result_de_2,
	output [1:0] rs_num_de_2,
	output [1:0] br_type_de_2,
	output [3:0] rs_ctrl_de_2,
	output [4:0] rs1_de_2,
	output [4:0] rs2_de_2,
	output [4:0] rd_de_2,
	output [4:0] ld_st_num_de_2,						//st_load指令的编号
	output [31:0] imm_de_2,
	output [31:0] next_pc_de_2,
	output [31:0] rs_bru_pc_de_2
		
);

	wire [31:0] pc_addend_1,pc_addend_2;
	decoder decoder_1(
		//input
		pre_direction_de_1,instr_de_1,pc_de_1,pre_pc_de_1,
		//output
		rs1_de_1,rs2_de_1,rd_de_1,imm_de_1,rs_bru_pc_de_1,rs_ctrl_de_1,rs_num_de_1,br_type_de_1,
		rs1_read_de_1,ri2_de_1,rd_write_de_1,st_de_1,rs_write_de_1,detect_first_result_de_1);
	decoder decoder_2(
		//input
		pre_direction_de_2,instr_de_2,pc_de_2,pre_pc_de_2,						
		//output
		rs1_de_2,rs2_de_2,rd_de_2,imm_de_2,rs_bru_pc_de_2,rs_ctrl_de_2,rs_num_de_2,br_type_de_2,
		rs1_read_de_2,ri2_de_2,rd_write_de_2,st_de_2,rs_write_de_2,detect_first_result_de_2);
	
	store_number store_load_number(
		//input
		clk,reset,st_de_1,st_de_2,
		//output
		ld_st_num_de_1,ld_st_num_de_2);

	assign pc_addend_1 = instr_is_compressde_1 ? 2 : 4;
	assign pc_addend_2 = instr_is_compressde_2 ? 2 : 4;
	assign next_pc_de_1 = pc_de_1 + pc_addend_1;
	assign next_pc_de_2 = pc_de_2 + pc_addend_2;

endmodule