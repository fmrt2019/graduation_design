/********************************************************************************************************/
/*
Filename: RR_stage.v
Designer: Dragon
Create date: 2023.4.3
Modification date: 2023.4.3
//Reason for modification: Function validation error
Description: Read register pipeline segment.
*/
/********************************************************************************************************/
module	RR_stage	(
					input		[164:0]	ifmt1rr,		//第一条来自RNR阶段的信息

					input		[164:0]	ifmt2rr,		//第二条来自RNR阶段的信息
					
					input		rs1lc,					//第一条指令的rs数据所在位置
					input		rt1lc,					//第一条指令的rt数据所在位置
					input		[31:0]	rs1_data_a,		//第一条指令的rs来自ARF的数据
					input		[31:0]	rt1_data_a,		//第一条指令的rt来自ARF的数据
					input		rs1_denrr,				//第一条指令的rs1来自ROB的数据是否有效
					input		rt1_denrr,				//第一条指令的rt1来自ROB的数据是否有效
					input		[31:0]	rs1_data_r,		//第一条指令的rs来自ROB的数据
					input		[31:0]	rt1_data_r,		//第一条指令的rt来自ROB的数据
					input		[5:0]	rs1prr,			//第一条指令的rs寄存器的物理号
					input		[5:0]	rt1prr,			//第一条指令的rt寄存器的物理号
					input		[5:0]	rd1prr,			//第一条指令的目的寄存器物理号

					input		rs2lc,					//第二条指令的rs数据所在位置
					input		rt2lc,					//第一条指令的rt数据所在位置
					input		[31:0]	rs2_data_a,		//第二条指令的rs来自ARF的数据
					input		[31:0]	rt2_data_a,		//第二条指令的rt来自ARF的数据
					input		rs2_denrr,				//第二条指令的rs2来自ROB的数据是否有效
					input		rt2_denrr				//第二条指令的rt2来自ROB的数据是否有效
					input		[31:0]	rs2_data_r,		//第二条指令的rs来自ROB的数据
					input		[31:0]	rt2_data_r,		//第二条指令的rt来自ROB的数据
					input		[5:0]	rs2prr,			//第二条指令的rs寄存器的物理号
					input		[5:0]	rt2prr,			//第二条指令的rs寄存器的物理号
					input		[5:0]	rd2prr,			//第二条指令的目的寄存器物理号
					
				//第一条控制信号
					output		valid1,					//第一条指令有效（1代表指令有效）
					output		[31:0]	bpc1,			//指令的本PC
					output		[31:0]	npc1,			//下一条指令的PC
					output		pdc1,					//分支指令预测方向
					output		spilt1,					//指令是否分割
					output		br_right1,				//分支指令是否预测正确
					output		[1:0]	br_type1,		//分支指令类型
					output		[31:0]	paddr1,			//预测地址（写到保留站里面的）

					output		res_en1,				//保留站的写信号
					output		[1:0]	resnum1,		//保留站编号
					output		rs1_en,					//第一条指令rs是否有效
					output		rt1_en,					//第一条指令rt是否有效
					output		rd1_en,					//第一条指令的写使能信号
					output		[4:0]	rs1l,			//第一条指令的rs寄存器的逻辑号
					output		[4:0]	rt1l,			//第一条指令的rt寄存器的逻辑号
					output		[4:0]	rd1l,			//第一条指令的目的寄存器逻辑号
					output		[3:0]	fucontrol1,		//fu控制信号
					output		[31:0]	imm1,			//立即数

					output		memwrite1,				//memory的写信号（store指令）
					output		[4:0]	lsnum1,			//load/store编号

				//第一条数据
					output		[31:0]	rs1_datarr,		//第一条指令的rs1的数据
					output		[31:0]	rt1_datarr,		//第一条指令的rt1的数据
					output	reg	rs1datav,				//第一条指令的rs1的数据是否有效
					output	reg	rt1datav,				//第一条指令的rt1的数据是否有效

				//第二条控制信号
					output		valid2,					//指令是否有效（1代表指令有效）
					output		[31:0]	bpc2,			//指令的本PC
					output		[31:0]	npc2,			//下一条指令的PC
					output		pdc2,					//分支指令预测方向
					output		spilt2,					//指令是否分割
					output		br_right2,				//分支指令是否预测正确
					output		[1:0]	br_type2,		//分支指令类型
					output		[31:0]	paddr2,			//预测地址（写到保留站里面的）

					output		res_en2,				//保留站的写信号
					output		[1:0]	resnum2,		//保留站编号
					output		rs2_en,					//第二条指令rs是否有效
					output		rt2_en,					//第二条指令rt是否有效
					output		rd2_en,					//第二条指令的写使能信号
					output		[4:0]	rs2l,			//第二条指令的rs寄存器的逻辑号
					output		[4:0]	rt2l,			//第二条指令的rt寄存器的逻辑号
					output		[4:0]	rd2l,			//第二条指令的目的寄存器逻辑号
					output		[3:0]	fucontrol2,		//fu控制信号
					output		[31:0]	imm2,			//立即数

					output		memwrite2,				//memory的写信号（store指令）
					output		[4:0]	lsnum2,			//load/store编号

				//第二条数据
					output		[31:0]	rs2_datarr,		//第二条指令的rs2的数据
					output		[31:0]	rt2_datarr,		//第二条指令的rt2的数据
					output	reg	rs2datav,				//第二条指令的rs2的数据是否有效
					output	reg	rt2datav				//第二条指令的rt2的数据是否有效		
					);
					
					wire		[31:0]	rs1_data_rc;	//第一条指令的rs的数据在ROB中result和寄存器号拓展的选择结果
					wire		[31:0]	rt1_data_rc;	//第一条指令的rt的数据在ROB中result和寄存器号拓展的选择结果
					wire		[31:0]	rs2_data_rc;	//第二条指令的rs的数据在ROB中result和寄存器号拓展的选择结果
					wire		[31:0]	rt2_data_rc;	//第二条指令的rt的数据在ROB中result和寄存器号拓展的选择结果

					assign {valid1,bpc1,npc1,pdc1,spilt1,br_right1,br_type1,paddr1,res_en1,resnum1,rs1_en,rt1_en,rd1_en,rs1l,rt1l,rd1l,fucontrol1,imm1,memwrite1,lsnum1} = ifmt1rr;
					assign {valid2,bpc2,npc2,pdc2,spilt2,br_right2,br_type2,paddr2,res_en2,resnum2,rs2_en,rt2_en,rd2_en,rs2l,rt2l,rd2l,fucontrol2,imm2,memwrite2,lsnum2} = ifmt2rr;

					assign rs1_data_rc = rs1_denrr ? rs1_data_r : {26'b0,rs1prr};	//第一条指令的rs的数据在ROB中result和寄存器号拓展的选择
					assign rt1_data_rc = rt1_denrr ? rt1_data_r : {26'b0,rt1prr};	//第一条指令的rt的数据在ROB中result和寄存器号拓展的选择
					assign rs2_data_rc = rs2_denrr ? rs2_data_r : {26'b0,rs2prr};	//第二条指令的rs的数据在ROB中result和寄存器号拓展的选择
					assign rt2_data_rc = rt2_denrr ? rt2_data_r : {26'b0,rt2prr};	//第二条指令的rt的数据在ROB中result和寄存器号拓展的选择

					assign rs1_datarr = rs1lc ? rs1_data_a : rs1_data_rc;		//第一条指令的rs的数据在ARF和ROB的选择
					assign rt1_datarr = rt1lc ? rt1_data_a : rt1_data_rc;		//第一条指令的rt的数据在ARF和ROB的选择
					assign rs2_datarr = rs2lc ? rs2_data_a : rs2_data_rc;		//第二条指令的rs的数据在ARF和ROB的选择
					assign rt2_datarr = rt2lc ? rt2_data_a : rt2_data_rc;		//第二条指令的rt的数据在ARF和ROB的选择

					
					always @(*) begin
						if (rs1lc) begin
							rs1datav = 1'b1;
						end
						else  begin
							rs1datav = rs1_denrr;
						end
					end
					always @(*) begin
						if (rt1lc) begin
							rt1datav = 1'b1;
						end
						else  begin
							rt1datav = rt1_denrr;
						end
					end
					always @(*) begin
						if (rs2lc) begin
							rs2datav = 1'b1;
						end
						else  begin
							rs2datav = rs2_denrr;
						end
					end
					always @(*) begin
						if (rt2lc) begin
							rt2datav = 1'b1;
						end
						else  begin
							rt2datav = rt2_denrr;
						end
					end
endmodule