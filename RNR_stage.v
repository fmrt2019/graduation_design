/**************************************************************

Filename: RNR_stage.v
Designer: Dragon
Create date: 2023.4.3
Modification date: 2023.4.3
//Reason for modification: Function validation error
Description: Register rename pipeline segment.

***************************************************************/
module	RNR_stage	(
					input		[164:0]	ifmt1_rn,		//第一条指令来自译码的控制信息
					
					input		[164:0]	ifmt2_rn,		//第二条指令来自译码的控制信息

					output		[164:0]	nuifmt1rn,		//第一条输入到RNR_RR_reg的控制信号
					output		rd1_enrn,				//第一条指令的目的寄存器写使能信号(提交判断)
					output		[4:0]	rd1lrn,			//第一条指令的目的寄存器逻辑号(提交判断)

					output		[164:0]	nuifmt2rn,		//第二条输入到RNR_RR_reg的控制信号
					output		rd2_enrn,				//第二条指令的目的寄存器写使能信号(提交判断)
					output		[4:0]	rd2lrn			//第二条指令的目的寄存器逻辑号(提交判断)
					);
					
					//第一条
					wire	valid1;						//指令是否有效（1代表指令有效）
					wire	[31:0]	bpc1;				//指令的本PC
					wire	[31:0]	npc1;				//下一条指令的PC
					wire	pdc1;						//分支指令预测方向
					wire	spilt1;						//指令是否分割
					wire	br_right1;					//分支指令是否预测正确
					wire	[1:0]	br_type1;				//分支指令类型
					wire	[31:0]	paddr1;				//预测地址（写到保留站里面的）

					wire	res_en1;					//保留站的写信号
					wire	[1:0]	resnum1;			//保留站编号
					wire	rs1_en;						//第一条指令rs是否有效
					wire	rt1_en;						//第一条指令rt是否有效
					wire	[4:0]	rs1l;				//第一条指令的rs寄存器的逻辑号
					wire	[4:0]	rt1l;				//第一条指令的rt寄存器的逻辑号
					wire	[3:0]	fucontrol1;			//fu控制信号
					wire	[31:0]	imm1;				//立即数

					wire	memwrite1;					//memory的写信号（store指令）
					wire	[4:0]	lsnum1;				//load/store编号

					//第二条
					wire	valid2;						//指令是否有效（1代表指令有效）
					wire	[31:0]	bpc2;				//指令的本PC
					wire	[31:0]	npc2;				//下一条指令的PC
					wire	pdc2;						//分支指令预测方向
					wire	spilt2;						//指令是否分割
					wire	br_right2;					//分支指令是否预测正确
					wire	[1:0]	br_type2;			//分支指令类型
					wire	[31:0]	paddr2;				//预测地址（写到保留站里面的）

					wire	res_en2;					//保留站的写信号
					wire	[1:0]	resnum2;			//保留站编号
					wire	rs2_en;						//第二条指令rs是否有效
					wire	rt2_en;						//第二条指令rt是否有效
					wire	[4:0]	rs2l;				//第二条指令的rs寄存器的逻辑号
					wire	[4:0]	rt2l;				//第二条指令的rt寄存器的逻辑号
					wire	[3:0]	fucontrol2;			//fu控制信号
					wire	[31:0]	imm2;				//立即数

					wire	memwrite2;					//memory的写信号（store指令）
					wire	[4:0]	lsnum2;				//load/store编号


					assign {valid1,bpc1,npc1,pdc1,spilt1,br_right1,br_type1,paddr1,res_en1,resnum1,rs1_en,rt1_en,
							rd1_en,rs1l,rt1l,rd1l,fucontrol1,imm1,memwrite1,lsnum1} = ifmt1_rn;
					assign {valid2,bpc2,npc2,pdc2,spilt2,br_right2,br_type2,paddr2,res_en2,resnum2,rs2_en,rt2_en,
							rd2_en,rs2l,rt2l,rd2l,fucontrol2,imm2,memwrite2,lsnum2} = ifmt2_rn;

					assign nuifmt1rn = {valid1,bpc1,npc1,pdc1,spilt1,br_right1,br_type1,paddr1,res_en1,resnum1,rs1_en,rt1_en,rd1_en,rs1l,rt1l,rd1l,fucontrol1,imm1,memwrite1,lsnum1};
					assign nuifmt2rn = {valid2,bpc2,npc2,pdc2,spilt2,br_right2,br_type2,paddr2,res_en2,resnum2,rs2_en,rt2_en,rd2_en,rs2l,rt2l,rd2l,fucontrol2,imm2,memwrite2,lsnum2};
	
endmodule