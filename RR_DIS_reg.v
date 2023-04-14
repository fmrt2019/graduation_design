/********************************************************************************************************/
/*
Filename: RR_DISreg.v
Designer: Dragon
Create date: 2023.4.3
Modification date: 2023.4.3
//Reason for modification: Function validation error
Description: Read Register/Distribute Pipeline Register.
*/
/********************************************************************************************************/
module	RR_DIS_reg		(
						input		clk,rst,stall,recover,	//写时钟信号,复位信号,停顿信号,恢复信号
						//input		[:0]	nuifmt1rr,		//第一条来自译码但是没有用到输入到RNR_RR_reg的控制信号
					//第一条控制信号
						input		valid1rr,				//第一条指令有效（1代表指令有效）
						input		[31:0]	bpc1rr,			//指令的本PC
						input		[31:0]	npc1rr,			//下一条指令的PC
						input		pdc1rr,					//分支指令预测方向
						input		spilt1rr,				//指令是否分割
						input		br_right1rr,			//分支指令是否预测正确
						input		br_type1rr,				//分支指令类型
						input		[31:0]	paddr1rr,		//预测地址（写到保留站里面的）

						input		res_en1rr,				//保留站的写信号
						input		[1:0]	resnum1rr,		//保留站编号
						input		rs1_enrr,				//第一条指令rs是否有效
						input		rt1_enrr,				//第一条指令rt是否有效
						input		rd1_enrr,				//第一条指令的写使能信号
						//input		[4:0]	rs1lrr,			//第一条指令的rs寄存器的逻辑号
						//input		[4:0]	rt1lrr,			//第一条指令的rt寄存器的逻辑号
						input		[4:0]	rd1lrr,			//第一条指令的目的寄存器逻辑号
						input		[5:0]	rs1prr,			//第一条指令的rs寄存器的物理号
						input		[5:0]	rt1prr,			//第一条指令的rt寄存器的物理号
						input		[5:0]	rd1prr,			//第一条指令的目的寄存器物理号
						input		[3:0]	fucontrol1rr,	//fu控制信号
						input		[31:0]	imm1rr,			//立即数

						input		memwrite1rr,			//memory的写信号（store指令）
						input		[4:0]	lsnum1rr,		//load/store编号

					//第一条数据
						input		[31:0]	rs1_datarr,		//第一条指令的rs1的数据
						input		[31:0]	rt1_datarr,		//第一条指令的rt1的数据
						input		rs1_denrr,				//第一条指令的rs1的数据是否有效
						input		rt1_denrr,				//第一条指令的rt1的数据是否有效


						//input		[:0]	nuifmt2rr,		//第二条来自译码但是没有用到输入到RNR_RR_reg的控制信号
					//第二条控制信号
						input	valid2rr,					//指令是否有效（1代表指令有效）
						input	[31:0]	bpc2rr,				//指令的本PC
						input	[31:0]	npc2rr,				//下一条指令的PC
						input	pdc2rr,						//分支指令预测方向
						input	spilt2rr,					//指令是否分割
						input	br_right2rr,				//分支指令是否预测正确
						input	br_type2rr,					//分支指令类型
						input	[31:0]	paddr2rr,			//预测地址（写到保留站里面的）

						input	res_en2rr,					//保留站的写信号
						input	[1:0]	resnum2rr,			//保留站编号
						input	rs2_enrr,					//第二条指令rs是否有效
						input	rt2_enrr,					//第二条指令rt是否有效
						input	rd2_enrr,					//第二条指令的写使能信号
						//input	[4:0]	rs2lrr,				//第二条指令的rs寄存器的逻辑号
						//input	[4:0]	rt2lrr,				//第二条指令的rt寄存器的逻辑号
						input	[4:0]	rd2lrr,				//第二条指令的目的寄存器逻辑号
						input	[5:0]	rs2prr,				//第二条指令的rs寄存器的物理号
						input	[5:0]	rt2prr,				//第二条指令的rt寄存器的物理号
						input	[5:0]	rd2prr,				//第二条指令的目的寄存器物理号
						input	[3:0]	fucontrol2rr,		//fu控制信号
						input	[31:0]	imm2rr,				//立即数

						input	memwrite2rr,				//memory的写信号（store指令）
						input	[4:0]	lsnum2rr,			//load/store编号

					//第二条数据
						input		[31:0]	rs2_datarr,		//第二条指令的rs2的数据
						input		[31:0]	rt2_datarr,		//第二条指令的rt2的数据
						input		rs2_denrr,				//第二条指令的rs2的数据是否有效
						input		rt2_denrr,				//第二条指令的rt2的数据是否有效

						//input		[31:0]	rs1_datarr,		//第一条指令的rs1的数据
						//input		[31:0]	rt1_datarr,		//第一条指令的rt1的数据
						//input		[31:0]	imm1rr,			//第一条指令的立即数数据
						//input		[5:0]	robnum1rr,		//第一条指令的ROB编号(目的寄存器的物理号)
						//input		[4:0]	rd1lrr,			//第一条指令的目的寄存器逻辑号
						//input		rd1_enrr,				//第一条指令的写使能信号

						//input		[31:0]	rs2_datarr,		//第二条指令的rs2的数据
						//input		[31:0]	rt2_datarr,		//第二条指令的rt2的数据
						//input		[31:0]	imm2rr,			//第二条指令的立即数数据
						//input		[5:0]	robnum2rr,		//第二条指令的ROB编号(目的寄存器的物理号)
						//input		[4:0]	rd2lrr,			//第二条指令的目的寄存器逻辑号
						//input		rd2_enrr,				//第二条指令的写使能信号

						//output		[:0]	nuifmt1dis,	//第一条来自译码但是没有用到输入到RNR_RR_reg的控制信号
					//第一条控制信号
						output		valid1dis,				//第一条指令有效（1代表指令有效）
						output		[31:0]	bpc1dis,		//指令的本PC
						output		[31:0]	npc1dis,		//下一条指令的PC
						output		pdc1dis,				//分支指令预测方向
						output		spilt1dis,				//指令是否分割
						output		br_right1dis,			//分支指令是否预测正确
						output		br_type1dis,			//分支指令类型
						output		[31:0]	paddr1dis,		//预测地址（写到保留站里面的）

						output		res_en1dis,				//保留站的写信号
						output		[1:0]	resnum1dis,		//保留站编号
						output		rs1_endis,				//第一条指令rs是否有效
						output		rt1_endis,				//第一条指令rt是否有效
						output		rd1_endis,				//第一条指令的写使能信号
						//output		[4:0]	rs1ldis,		//第一条指令的rs寄存器的逻辑号
						//output		[4:0]	rt1ldis,		//第一条指令的rt寄存器的逻辑号
						output		[4:0]	rd1ldis,		//第一条指令的目的寄存器逻辑号
						output		[5:0]	rs1pdis,		//第一条指令的rs寄存器的物理号
						output		[5:0]	rt1pdis,		//第一条指令的rt寄存器的物理号
						output		[5:0]	rd1pdis,		//第一条指令的目的寄存器物理号
						output		[3:0]	fucontrol1dis,	//fu控制信号
						output		[31:0]	imm1dis,		//立即数

						output		memwrite1dis,			//memory的写信号（store指令）
						output		[4:0]	lsnum1dis,		//load/store编号

					//第一条数据
						output		[31:0]	rs1_datadis,	//第一条指令的rs1的数据
						output		[31:0]	rt1_datadis,	//第一条指令的rt1的数据
						output		rs1_dendis,				//第一条指令的rs1的数据是否有效
						output		rt1_dendis,				//第一条指令的rt1的数据是否有效

						//output		[:0]	nuifmt2dis,	//第二条来自译码但是没有用到输入到RNR_RR_reg的控制信号
					//第二条控制信号
						output	valid2dis,					//指令是否有效（1代表指令有效）
						output	[31:0]	bpc2dis,			//指令的本PC
						output	[31:0]	npc2dis,			//下一条指令的PC
						output	pdc2dis,					//分支指令预测方向
						output	spilt2dis,					//指令是否分割
						output	br_right2dis,				//分支指令是否预测正确
						output	br_type2dis,				//分支指令类型
						output	[31:0]	paddr2dis,			//预测地址（写到保留站里面的）

						output	res_en2dis,					//保留站的写信号
						output	[1:0]	resnum2dis,			//保留站编号
						output	rs2_endis,					//第二条指令rs是否有效
						output	rt2_endis,					//第二条指令rt是否有效
						output	rd2_endis,					//第二条指令的写使能信号
						//output	[4:0]	rs2ldis,			//第二条指令的rs寄存器的逻辑号
						//output	[4:0]	rt2ldis,			//第二条指令的rt寄存器的逻辑号
						output	[4:0]	rd2ldis,			//第二条指令的目的寄存器逻辑号
						output	[5:0]	rs2pdis,			//第二条指令的rs寄存器的物理号
						output	[5:0]	rt2pdis,			//第二条指令的rt寄存器的物理号
						output	[5:0]	rd2pdis,			//第二条指令的目的寄存器物理号
						output	[3:0]	fucontrol2dis,		//fu控制信号
						output	[31:0]	imm2dis,			//立即数

						output	memwrite2dis,				//memory的写信号（store指令）
						output	[4:0]	lsnum2dis,			//load/store编号

					//第二条数据
						output		[31:0]	rs2_datadis,	//第二条指令的rs2的数据
						output		[31:0]	rt2_datadis,	//第二条指令的rt2的数据
						output		rs2_dendis,				//第二条指令的rs2的数据是否有效
						output		rt2_dendis				//第二条指令的rt2的数据是否有效
						//output		[31:0]	rs1_datadis,//第一条指令的rs1的数据
						//output		[31:0]	rt1_datadis,//第一条指令的rt1的数据
						//output		[31:0]	imm1dis,	//第一条指令的立即数数据
						//output		[5:0]	robnum1dis,	//第一条指令的ROB编号(目的寄存器的物理号)
						//output		[4:0]	rd1ldis,	//第一条指令的目的寄存器逻辑号
						//output		rd1_endis,			//第一条指令的写使能信号

						//output		[31:0]	rs2_datadis,//第二条指令的rs2的数据
						//output		[31:0]	rt2_datadis,//第二条指令的rt2的数据
						//output		[31:0]	imm2dis,	//第二条指令的立即数数据
						//output		[5:0]	robnum2dis,	//第二条指令的ROB编号(目的寄存器的物理号)
						//output		[4:0]	rd2ldis,	//第二条指令的目的寄存器逻辑号
						//output		rd2_endis			//第二条指令的写使能信号
						);

						//assign {} = nuifmt1rr;
						//assign {} = nuifmt2rr;

						wire		[237:0]	d1,q1;
						wire		[237:0]	d2,q2;

						wire	reset;
						assign  reset = rst | recover;

						assign d1 = {valid1rr,bpc1rr,npc1rr,pdc1rr,spilt1rr,br_right1rr,br_type1rr,paddr1rr,res_en1rr,resnum1rr,rs1_enrr,rt1_enrr,rd1_enrr,rd1lrr,rs1prr,rt1prr,rd1prr,fucontrol1rr,imm1rr,memwrite1rr,lsnum1rr,rs1_datarr,rt1_datarr,rs1_denrr,rt1_denrr};
						assign d2 = {valid2rr,bpc2rr,npc2rr,pdc2rr,spilt2rr,br_right2rr,br_type2rr,paddr2rr,res_en2rr,resnum2rr,rs2_enrr,rt2_enrr,rd2_enrr,rd2lrr,rs2prr,rt2prr,rd2prr,fucontrol2rr,imm2rr,memwrite2rr,lsnum2rr,rs2_datarr,rt2_datarr,rs2_denrr,rt2_denrr};

						flopren  #(238)	rr_dis_reg1(clk,reset,stall,d1,q1);
						flopren  #(238)	rr_dis_reg2(clk,reset,stall,d2,q2);

						assign {valid1dis,bpc1dis,npc1dis,pdc1dis,spilt1dis,br_right1dis,br_type1dis,paddr1dis,res_en1dis,resnum1dis,rs1_endis,rt1_endis,rd1_endis,rd1ldis,rs1pdis,rt1pdis,rd1pdis,fucontrol1dis,imm1dis,memwrite1dis,lsnum1dis,rs1_datadis,rt1_datadis,rs1_dendis,rt1_dendis} = q1;
						assign {valid2dis,bpc2dis,npc2dis,pdc2dis,spilt2dis,br_right2dis,br_type2dis,paddr2dis,res_en2dis,resnum2dis,rs2_endis,rt2_endis,rd2_endis,rd2ldis,rs2pdis,rt2pdis,rd2pdis,fucontrol2dis,imm2dis,memwrite2dis,lsnum2dis,rs2_datadis,rt2_datadis,rs2_dendis,rt2_dendis} = q2;

endmodule