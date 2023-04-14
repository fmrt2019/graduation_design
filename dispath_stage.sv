/*------------------------------------------------------------------------------------------------
#File:dispath_stage.sv
#Description:Synthesis of dispath stage
#Author:Yanglirong
#Time:2023-4-1 15:02
------------------------------------------------------------------------------------------------*/
module dispath_stage (
	input clk,					//时钟信号，更新store buffer write point
	input reset,				//复位信号，对store buffer write point进行赋0
	input rs_write_1,			//第一条指令是否写入保留站
	input instr_valid_1,		//第一条指令是否有效
	input ri2_1,				//第一条指令的第二个操作数是否是立即数，1表示有效
	input rs1_ready_rr_1,		//第一条指令的第一个源操作数是否就绪，1表示就绪
	input rs2_ready_rr_1,		//第一条指令的第二个源操作数是否就绪，1表示就绪
	input pre_direct_1,			//第一条指令的预测方向，1跳转
	input is_split_1,			//第一条指令是否分布在两个cache line，1是
	input st_1,					//第一条指令是否是store指令
	input alu_free_1,			//alu的保留站是否有1个空间，1表示有，0表示没有
	input sfu_free_1,			//sfu的保留站是否有1个空间，1表示有，
	input bru_free_1,			//bru的保留站是否有1个空间，1表示有
	input agu_free_1,			//agu的保留站是否有1个空间
	input [1:0] rs1_farword_1,	//第一条指令的源寄存器1是否与写回阶段的编号匹配，00:选择本身，01：选择转发的alu结果 10：选择转发的sfu结果 11：选择转发的agu结果
	input [1:0] rs2_farword_1,	//第一条指令的源寄存器2是否与写回阶段的编号匹配，00:选择本身，01：选择转发的alu结果 10：选择转发的sfu结果 11：选择转发的agu结果
	input [1:0] rs_num_1,		//第一条指令要派往哪个保留站
//	input [2:0] sb_write_point_1,
	input [3:0] fu_ctrl_1,		//fu要执行的操作
	input [4:0] st_ld_num_1,	//译码阶段分配的load和store编号
	input [5:0] rob_num_1,		//rd的物理寄存器号，一个该指令在rob中的位置
	input [31:0] rs1_data_1,	//从源寄存器1中读出的数据
	input [31:0] rs2_data_1,
	input [31:0] imm_1,
	input [31:0] lu_result_wb,
	input [31:0] sfu_result_wb,
	input [31:0] agu_result_wb,
	input [31:0] pre_pc_1,
	input [31:0] pc_1,
	input [31:0] next_pc_1,

	output [52:1] rs_must_write_point_1,
	output [34:0] alu_write_point_1_data,
	output [6:0]  sfu_write_point_1_data,
	output [67:0] bru_write_point_1_data,
	output [73:0] agu_write_point_1_data,
	output complete_1,
	output [31:0] rd_data_1,
	output [31:0] br_next_pc_1,
	output [31:0] rob_write_pc_1,
/*----------------------second instr-------------------------------------------------*/
	input rs_write_2,instr_valid_2,ri2_2,rs1_ready_rr_2,rs2_ready_rr_2,
		  pre_direct_2,is_split_2,st_2,
	input alu_free_2,sfu_free_2,bru_free_2,agu_free_2,
	input [1:0] rs1_farword_2,rs2_farword_2,
				rs_num_2,
//	input [2:0] sb_write_point_2,
	input [3:0] fu_ctrl_2,
	input [4:0] st_ld_num_2,//ard_2,
	input [5:0] rob_num_2,
	input [31:0] rs1_data_2,rs2_data_2,imm_2,
				 pre_pc_2,pc_2,next_pc_2,
	output [52:1] rs_must_2,
	output [34:0] op_00_alu_data_2,
	output [6:0]  op_01_sfu_data_2,
	output [67:0] op_10_bru_data_2,
	output [73:0] op_11_agu_data_2,
//--------------------------------rob----------------------------------------//
	output complete_2,
	output [31:0] rd_data_2,br_next_pc_2,rob_write_pc_2,

	output agu_write,bru_write,sfu_write,alu_write,
		   agu_write_num,bru_write_num,sfu_write_num,alu_write_num,
		   full,
	input  [4:0]sb_read_point,store_exe_num,
	output reg[3:0]sb_write_point


);
	wire [52:1] rs_must_1;
	wire [34:0] op_00_alu_data_1;
	wire [6:0]  op_01_sfu_data_1;
	wire [67:0] op_10_bru_data_1;
	wire [73:0] op_11_agu_data_1;
	wire rs1_ready_farword_1 = |rs1_farword_1,		//01,10,11均表示采用转发，也就是在执行阶段转发回来的数据
		 rs2_ready_farword_1 = |rs2_farword_1,
		 rrs1_ready_1,rrs2_ready_1;
	wire [3:0]	all_rs_write_1;
	wire [4:0]  agu_st_ld_num_1;
	wire [31:0] src2_rf_1,src1_1,src2_1;
	wire rs_write_valid_1 = rs_write_1 & instr_valid_1;
	wire ready_1;

	wire rs1_ready_farword_2 = |rs1_farword_2,		//01,10,11均表示采用转发，也就是在执行阶段转发回来的数据
		 rs2_ready_farword_2 = |rs2_farword_2,
		 rrs1_ready_2,rrs2_ready_2;
	wire [3:0]	all_rs_write_2;
	wire [4:0]  agu_st_ld_num_2;
	wire [31:0] src2_rf_2,src1_2,src2_2,src1_2_mid,src2_rf_2_mid;
	wire rs_write_valid_2 = rs_write_2 & instr_valid_2;
	wire ready_2;
	wire rs1_2_may_depened_1,rs2_2_may_depened_1;

	wire[3:0] all_rs_mid_write;
	wire alu_full,sfu_full,bru_full,agu_full,sb_full,
		 alu_free_write,sfu_free_write,bru_free_write,agu_free_write,
		 sb_free_0,sb_free_1,sb_free_2,
		 agu_write_rs;

//-------------------------------store
	wire[3:0] sb_write_point_1,sb_write_point_2;
	wire [1:0] store_couter;
/*-----------------------------------------information of first instr -----------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------FU--------------------------------------------------------------------------------------------*/
	assign rs_must_1 = {src1_1,rob_num_1,rs2_data_1[5:0],rs1_data_1[5:0],rrs2_ready_1,rrs1_ready_1};
	assign op_00_alu_data_1 = {fu_ctrl_1[2:0],src2_1};  	 //alu_ctrl 为译码的ctrl（4-bit）的低3-bit
	assign op_01_sfu_data_1 = {fu_ctrl_1[3:2],src2_1[4:0]};	 //sfu_ctrl 为译码的ctrl（4-bit）的高2-bit
	assign op_10_bru_data_1 = {fu_ctrl_1[2:0],pre_direct_1,pre_pc_1,src2_1};  //bru_ctrl 为译码的ctrl（4-bit）的低3-bit
	//agu_ctrl 为译码的ctrl，其中ctrl[3]表示是st（1），load（0），ctrl[2]表示load否无符号，有符号（0）,无符号（1），ctrl[1：0]表示访问的是字节、半字、字
	assign op_11_agu_data_1 = {ready_1,fu_ctrl_1,agu_st_ld_num_1,imm_1,src2_1};
	//op1 and op2 ready sign at dispath  
	assign rrs1_ready_1 = (rs1_ready_rr_1 | rs1_ready_farword_1);
	assign rrs2_ready_1 = (ri2_1 ? 1'b1 : (rs2_ready_rr_1 | rs2_ready_farword_1));

	//select op1
	mux4 #(32) src1_select_1(rs1_data_1,alu_result_wb,sfu_result_wb,agu_result_wb,rs1_farword_1,src1_1);

	//select op2
	mux4 #(32) src2_select_1(rs2_data_1,alu_result_wb,sfu_result_wb,agu_result_wb,rs2_farword_1,src2_rf_1);
	assign src2_1 = (ri2_1 ? imm_1 : src2_rf_1);

	//select st_ld_num
	assign agu_st_ld_num_1 = fu_ctrl_1[3] ? {1'b0,sb_write_point_1} : st_ld_num_1;

	//------------------生成rs最后的写信号--------------------
//	assign {agu_write_1,bru_write_1,sfu_write_1,alu_write_1} = {all_rs_write_1};
	rs_sign_decoder rs_write_sign_1 (rs_write_valid_1,rs_num_1,all_rs_write_1);

/*-------------------------------------------------------------ROB----------------------------------------------------------------------------------------------*/
	assign complete_1 = (~rs_write_1) & instr_valid_1;
	assign rd_data_1 = (rs_num_1 == 2'b00) ? imm_1 : next_pc_1;			//rd_data（32-bit）:要写入目的寄存器的数据
	assign br_next_pc_1 = (rs_num_1 == 2'b10) ? next_pc_1 : imm_1;		//br_next_pc（32-bit）:分支和跳转指令真正要去的地止(除了j指令，其他写next_pc)（可能是该指令的下一个pc，也可能是跳转的地址）
	assign rob_write_pc_1 = is_split_1 ? next_pc_1 : pc_1;							//pc（32-bit）:该指令的pc,对于分布在两个cache line中的指令来说，存的是它的下一条pc的地址



/*-----------------------------------------information of second instr -----------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------FU--------------------------------------------------------------------------------------------*/
	assign rs_must_2 = {src1_2,rob_num_2,rs2_data_2[5:0],rs1_data_2[5:0],rrs2_ready_2,rrs1_ready_2};
	assign op_00_alu_data_2 = {fu_ctrl_2[2:0],src2_2};  	 //alu_ctrl 为译码的ctrl（4-bit）的低3-bit
	assign op_01_sfu_data_2 = {fu_ctrl_2[3:2],src2_2[4:0]};	 //sfu_ctrl 为译码的ctrl（4-bit）的高2-bit
	assign op_10_bru_data_2 = {fu_ctrl_2[2:0],pre_direct_2,pre_pc_2,src2_2};  //bru_ctrl 为译码的ctrl（4-bit）的低3-bit
	//agu_ctrl 为译码的ctrl，其中ctrl[3]表示是st（1），load（0），ctrl[2]表示load否无符号，有符号（0）,无符号（1），ctrl[1：0]表示访问的是字节、半字、字
	assign op_11_agu_data_2 = {ready_2,fu_ctrl_2,agu_st_ld_num_2,imm_2,src2_2};
	//op1 and op2 ready sign at dispath  
	assign rrs1_ready_2 = (rs1_ready_rr_2 | rs1_ready_farword_2 | rs1_2_may_depened_1);
	assign rrs2_ready_2 = (ri2_2 ? 1'b1 : (rs2_ready_rr_2 | rs2_ready_farword_2 | rs2_2_may_depened_1));

	assign rs1_2_may_depened_1 = complete_1 & (rob_num_1 == rs1_data_2[5:0]);
	assign rs2_2_may_depened_1 = complete_1 & (rob_num_1 == rs2_data_2[5:0]);

	//select op1
	mux4 #(32) src1_select_2(rs1_data_2,alu_result_wb,sfu_result_wb,agu_result_wb,rs1_farword_2,src1_2_mid);
	assign src1_2 = rs1_2_may_depened_1 ? rd_data_1 : src1_2_mid; 

	//select op2
	mux4 #(32) src2_select_2(rs2_data_2,alu_result_wb,sfu_result_wb,agu_result_wb,rs2_farword_2,src2_rf_2_mid);
	assign src2_rf_2 = rs1_2_may_depened_1 ? rd_data_1 : src2_rf_2_mid; 

	assign src2_2 = (ri2_2 ? imm_2 : src2_rf_2);

	//select st_ld_num
//注注注
	assign agu_st_ld_num_2 = fu_ctrl_1[3] ? {1'b0,sb_write_point_2} : st_ld_num_2;

	//------------------生成rs最后的写信号--------------------
//	assign {agu_write_2,bru_write_2,sfu_write_2,alu_write_2} = {all_rs_write_2};
	rs_sign_decoder rs_write_sign_2 (rs_write_valid_2,rs_num_2,all_rs_write_2);

/*-------------------------------------------------------------ROB----------------------------------------------------------------------------------------------*/
	assign complete_2 = (~rs_write_2) & instr_valid_2;
	assign rd_data_2 = (rs_num_2 == 2'b00) ? imm_2 : next_pc_2;			//rd_data（32-bit）:要写入目的寄存器的数据
	assign br_next_pc_2 = (rs_num_2 == 2'b10) ? next_pc_2 : imm_2;		//br_next_pc（32-bit）:分支和跳转指令真正要去的地止(除了j指令，其他写next_pc)（可能是该指令的下一个pc，也可能是跳转的地址）
	assign rob_write_pc_2 = is_split_2 ? next_pc_2 : pc_2;	


//-----------------------------------------------------------finally result -----------------------------------------//
	assign {agu_write_num,bru_write_num,sfu_write_num,alu_write_num} = (all_rs_write_1 & all_rs_write_2);
	assign all_rs_mid_write = (all_rs_write_1 | all_rs_write_2);
	assign {agu_write_rs,bru_write,sfu_write,alu_write} = (all_rs_mid_write & {agu_free_write,bru_free_write,sfu_free_write,alu_free_write});

	assign full = &{agu_full,bru_full,sfu_full,alu_full,sb_full};

	assign alu_full = all_rs_mid_write[0] ? alu_free_write : 1'b1;
	assign sfu_full = all_rs_mid_write[1] ? sfu_free_write : 1'b1;
	assign bru_full = all_rs_mid_write[2] ? bru_free_write : 1'b1;
	assign agu_full = all_rs_mid_write[3] ? agu_free_write : 1'b1;

	assign alu_free_write = alu_write_num ? alu_free_2 : alu_free_1;
	assign sfu_free_write = sfu_write_num ? sfu_free_2 : sfu_free_1;
	assign bru_free_write = bru_write_num ? bru_free_2 : bru_free_1;
	assign agu_free_write = agu_write_num ? agu_free_2 : agu_free_1;

	assign rs_must_write_point_1  = rs_write_valid_1 ? rs_must_1 : rs_must_2;
	assign alu_write_point_1_data = all_rs_write_1[0] ? op_00_alu_data_1 : op_00_alu_data_2;
	assign sfu_write_point_1_data = all_rs_write_1[1] ? op_01_sfu_data_1 : op_01_sfu_data_2;
	assign bru_write_point_1_data = all_rs_write_1[2] ? op_10_bru_data_1 : op_10_bru_data_2;
	assign agu_write_point_1_data = all_rs_write_1[3] ? op_11_agu_data_1 : op_11_agu_data_2;

//----------------------------------------store buffer -----------------------------------------------------------
	assign sb_free_0 = |(sb_write_point^sb_read_point^4'b1000);		//一个都不剩余
	assign sb_free_1 = ((|((sb_write_point+1)^sb_read_point^4'b1000)) & sb_free_0);//有且只有一个剩余
//	assign sb_free_2 = ((|((sb_write_point+2)^sb_read_point^4'b1000)) & sb_free_1);
	assign store_couter = st_1 + st_2;
	assign sb_full = store_couter[1]  ? sb_free_1 : (store_couter[0] ? sb_free_0 : 1'b1);
	assign agu_write = agu_write_rs & sb_full;
	assign sb_write_point_1 = sb_write_point;
	assign sb_write_point_2 = st_1 ? (sb_write_point+4'b0001) : sb_write_point;
	assign ready_1 = (st_ld_num_1 == store_exe_num);
	assign ready_2 = (st_ld_num_2 == store_exe_num);

	always @ (posedge clk ,posedge reset)
		if (reset) begin
			sb_write_point <= 4'b0000;
		end
		else if (agu_write) 
			sb_write_point <= sb_write_point + store_couter ;
		else
			sb_write_point <= sb_write_point;

endmodule



/*-----------ROB-------------
	assign complete_1 = rs_write_1;										//conplete（1-bit）:指令是否执行完成
	assign rdwrite_1  = rdwrite_1;										//rd_write（1-bit）:目的寄存器的写信号
	assign ard_1		= rdl_1;										//ard（5-bit）:目的寄存器的逻辑寄存器号						
	assign st_point = st_write_point
	assign br_type_1  = br_type_1;										//br_type（2-bit）:（分支）指令的类型
	assign br_direct_1 = j;												//br_direct（1-bit）:表示分支指令的真正方向					
	assign pre_detect_1 = pre_detect_1;									//pre_detect（1-bit）:对于分支预测正确与否的判断结果，1表示分支预测正确

	wire [] rob = {complete,rdwrite,ard,rd_data,br,st,st_point}			
			br  = {br_type,br_direct,br_next_pc,pre_detect,pc} 
*/

module rs_sign_decoder(
	input en,
	input [1:0] data,
	output [3:0] sign
);

	always @ (*)
		if(en) begin
			case (data)
				2'b00 : sign = 4'b0001;
				2'b01 : sign = 4'b0010;
				2'b10 : sign = 4'b0100;
				2'b11 : sign = 4'b1000;
			endcase
		end
		else
			sign = 4'b0000;
endmodule

/*
module rs_sign_decoder(
	input en,
	input [4:0] data,
	output [8:0] sign
);

	always @ (*)
		if(en) begin
			case (data)
				4'b0000 : sign = 8'b0001_0001;
				4'b0001 : sign = 8'b0011_0000;
				4'b0010 : sign = 8'b0101_0000;
				4'b0011 : sign = 8'b1001_0000;

				4'b0100 : sign = 8'b0011_0000;
				4'b0101 : sign = 8'b0010_0010;
				4'b0110 : sign = 8'b0110_0000;
				4'b0111 : sign = 8'b1010_0000;

				4'b1000 : sign = 8'b0101_0000;
				4'b1001 : sign = 8'b0110_0000;
				4'b1010 : sign = 8'b0100_0100;
				4'b1011 : sign = 8'b1100_0000;

				4'b1100 : sign = 8'b1001_0000;
				4'b1101 : sign = 8'b1010_0000;
				4'b1110 : sign = 8'b1100_0000;
				4'b1111 : sign = 8'b1000_1000;
			endcase
		end
		else
			sign = 8'b0000_0000;
endmodule
*/


