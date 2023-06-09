/*****************************************************************************
Filename:datapath.v
Designer:FMRT2019
Create date:2023.04.14 11:18
Description:overall datapath.
*******************************************************************************/
module datapath ();
/************************************************************RNR_stage****************************************/
    //input
	wire	[164:0]		ifmt1_rn,		//第一条指令来自译码的控制信息
	wire	[164:0]		ifmt2_rn,		//第二条指令来自译码的控制信息
    //output
	//1
	wire	[164:0]		nuifmt1rn,		//第一条输入到RNR_RR_reg的控制信号
	wire	rd1_enrn,				//第一条指令的目的寄存器写使能信号(提交判断)
	wire	[4:0]		rd1lrn,			//第一条指令的目的寄存器逻辑号(提交判断)
	//2
	wire	[164:0]		nuifmt2rn,		//第二条输入到RNR_RR_reg的控制信号
	wire	rd2_enrn,				//第二条指令的目的寄存器写使能信号(提交判断)
	wire	[4:0]		rd2lrn			//第二条指令的目的寄存器逻辑号(提交判断)
/*************************************************************************************************************/
/************************************************************RNR_RR_reg***************************************/
	//input		[164:0]	nuifmt1rn,		//第一条来自译码但是没有用到输入到RNR_RR_reg的控制信号
	wire	[5:0]		rs1prn,			//第一条指令的rs寄存器的物理号
	wire	[5:0]		rt1prn,			//第一条指令的rt寄存器的物理号
	wire	[5:0]		rd1prn,			//第一条指令的目的寄存器物理号
	//input		[164:0]	nuifmt2rn,		//第二条来自译码但是没有用到输入到RNR_RR_reg的控制信号
	wire	[5:0]		rs2prn,			//第二条指令的rs寄存器的物理号
	wire	[5:0]		rt2prn,			//第二条指令的rt寄存器的物理号
	wire	[5:0]		rd2prn,			//第二条指令的目的寄存器物理号
						
	wire	[164:0]		ifmt1rr,		//第一条来自译码但是没有用到输出到RR阶段的控制信号
	wire	[5:0]		rs1prr,			//第一条指令的rs寄存器的物理号
	wire	[5:0]		rt1prr,			//第一条指令的rt寄存器的物理号
	wire	[5:0]		rd1prr,			//第一条指令的目的寄存器物理号

	wire	[164:0]		ifmt2rr,		//第二条来自译码但是没有用到输出到RR阶段的控制信号
	wire	[5:0]		rs2prr,			//第二条指令的rs寄存器的物理号
	wire	[5:0]		rt2prr,			//第二条指令的rt寄存器的物理号
	wire	[5:0]		rd2prr			//第二条指令的目的寄存器物理号
/*************************************************************************************************************/
/*************************************************************RR_stage****************************************/
	
/*************************************************************************************************************/
/*************************************************************EX_stage****************************************/
    //input
	//alu
	wire	[31:0]	aluae,alube;			//执行阶段alu的两个操作数
	wire	[2:0]	alucontrole;			//执行阶段alu的控制信号
	//sfu
	wire	[31:0]	sfuae,sfube;			//执行阶段sfu的两个操作数
	wire	[1:0]	sfucontrole;			//执行阶段sfu的控制信号
	//bru
	wire	[31:0]	bruae,brube;			//执行阶段bru的两个操作数
	wire	[2:0]	brucontrole;			//执行阶段bru的控制信号
	wire	pdce;					//执行阶段bru中分支指令的预测方向
	wire	[31:0]	paddre;				//执行阶段bru中分支指令的预测地址
	//agu
	wire	[31:0]	aguae,agube;			//执行阶段agu的两个操作数
	wire	[3:0]	agucontrole;			//执行阶段agu的控制信号
    //out
	//alu
	wire	[31:0]	aluoute;			//执行阶段alu的输出
	wire	overflowe;				//执行阶段alu是否溢出
	//sfu
	wire	[31:0]	sfuoute;			//执行阶段sfu的输出
	//bru
	wire	prighte;				//执行阶段bru中分支指令是否预测正确
	wire	b_typee;				//执行阶段bru中分支指令的类型（1代表B类型）
	wire	rdce;					//执行阶段bru中分支指令的真正方向
	wire	[31:0]	raddre;				//执行阶段bru中分支指令的真正地址
  	//agu
	wire	[31:0]	aguoute;			//执行阶段agu的输出
/**************************************************************************************************************/
	
  decode_stage decode (
		clk,reset,
//first input
		instr_dec_1,pc_dec_1,pre_direction_dec_1,pre_pc_dec_1,instr_is_compressdec_1,
//first output	
		rs_write_dec_1,rs1_read_dec_1,ri2_dec_1,rd_write_dec_1,st_dec_1,dectect_first_result_dec_1,rs_num_dec_1,br_type_dec_1,rs_ctrl_dec_1,
		rs1_dec_1,rs2_dec_1,rd_dec_1,ld_st_num_dec_1imm_dec_1,next_pc_dec_1,rs_bru_pc_dec_1,
//second input
		instr_dec_2,pc_dec_2,pre_direction_dec_2,pre_pc_dec_2,instr_is_compressdec_2,
//second output
		rs_write_dec_2,rs1_read_dec_2,ri2_dec_2,rd_write_dec_2,st_dec_2,dectect_first_result_dec_2,rs_num_dec_2,br_type_dec_2,rs_ctrl_dec_2,
		rs1_dec_2,rs2_dec_2,rd_dec_2,ld_st_num_dec_2,imm_dec_2,next_pc_dec_2,rs_bru_pc_dec_2
	);

  flopren decode_rename_reg (330)(
		clk1,reset,en,
//input	
	//information of first insrtuction
		{pc_dec_1,pre_direction_dec_1,
		 rs_write_dec_1,rs1_read_dec_1,ri2_dec_1,rd_write_dec_1,st_dec_1,dectect_first_result_dec_1,rs_num_dec_1,br_type_dec_1,rs_ctrl_dec_1,
		 rs1_dec_1,rs2_dec_1,rd_dec_1,ld_st_num_dec_1,imm_dec_1,next_pc_dec_1,rs_bru_pc_dec_1,
		 is_split_dec_1,instr_valid_de_1,
	//information second instruction
		 pc_dec_2,pre_direction_dec_2,
		 rs_write_dec_2,rs1_read_dec_2,ri2_dec_2,rd_write_dec_2,st_dec_2,dectect_first_result_dec_2,rs_num_dec_2,br_type_dec_2,rs_ctrl_dec_2,
		 rs1_dec_2,rs2_dec_2,rd_dec_2,ld_st_num_dec_2,imm_dec_2,next_pc_dec_2,rs_bru_pc_dec_2,
		 is_split_dec_2,instr_valid_dec_2},
//output
	//information of first insrtuction
		 {pc_rnr_1,pre_direction_rnr_1,
		 rs_write_rnr_1,rs1_read_rnr_1,ri2_rnr_1,rd_write_rnr_1,st_rnr_1,rnrtect_first_result_rnr_1,rs_num_rnr_1,br_type_rnr_1,rs_ctrl_rnr_1,
		 rs1_rnr_1,rs2_rnr_1,rd_rnr_1,ld_st_num_rnr_1,imm_rnr_1,next_pc_rnr_1,rs_bru_pc_rnr_1,
		 is_split_rnr_1,instr_valid_de_1,
	//information second instruction
		 pc_rnr_2,pre_direction_rnr_2,
		 rs_write_rnr_2,rs1_read_rnr_2,ri2_rnr_2,rd_write_rnr_2,st_rnr_2,rnrtect_first_result_rnr_2,rs_num_rnr_2,br_type_rnr_2,rs_ctrl_rnr_2,
		 rs1_rnr_2,rs2_rnr_2,rd_rnr_2,ld_st_num_rnr_2,imm_rnr_2,next_pc_rnr_2,rs_bru_pc_rnr_2,
		 is_split_rnr_2,instr_valid_rnr_2}
	);
	
	RNR_stage	rnr_stage	(ifmt1_rn,ifmt2_rn,nuifmt1rn,rd1_enrn,rd1lrn,nuifmt2rn,rd2_enrn,rd2lrn);
	
	RNR_RR_reg	rnr_rr_reg	(clk,rst,stall,recover,nuifmt1rn,rs1prn,rt1prn,rd1prn,nuifmt2rn,rs2prn,rt2prn,rd2prn,ifmt1rr,rs1prr,rt1prr,rd1prr,
					 ifmt2rr,rs2prr,rt2prr,rd2prr);

	dispath_stage dispath (
		


	)
	EX_stage	ex_stage	(alu_ae,alu_be,alucontrole,sfu_ae,sfu_be,sfucontrole,bru_ae,bru_be,brucontrole,pdce,paddre,agu_ae,agu_be,
					agucontrole,aluoute,overflowe,sfuoute,prighte,b_typee,rdce,raddre,aguoute);
	
	WB_stage	wb_stage	(prightw,b_typew,rdcw,rd1ps,rd2ps,rd1_enrn,rd1lrn,rd2_enrn,rd2lrn,rd_en1w,memwen1w,valid1w,rd1lw,rd1pw,rd_en2w,
					memwen2w,valid2w,rd2lw,rd2pw,br_right_en,raddren,srat_1en1,arfen1,write1,srat_1en2,arfen2,write2);
	






	reserved_stations alu_rs #(4,16,35,32)
	reserved_stations sfu_rs #(3,8,7,5)
	reserved_stations bru_rs #(3,8,68,32)
	agu_reserved_station agu_rs #(3,8,74,32)
*/
endmodule
