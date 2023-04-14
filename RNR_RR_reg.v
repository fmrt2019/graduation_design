/********************************************************************************************************/
/*
Filename: RNR_RR_reg.v
Designer: Dragon
Create date: 2023.4.3
Modification date: 2023.4.3
//Reason for modification: Function validation error
Description: Register Rename/Read Register Pipeline Register.
*/
/********************************************************************************************************/
module	RNR_RR_reg		(
						input		clk,rst,stall,recover,	//写时钟信号,复位信号,停顿信号,恢复信号

						input		[164:0]	nuifmt1rn,		//第一条来自译码但是没有用到输入到RNR_RR_reg的控制信号
						input		[5:0]	rs1prn,			//第一条指令的rs寄存器的物理号
						input		[5:0]	rt1prn,			//第一条指令的rt寄存器的物理号
						input		[5:0]	rd1prn,			//第一条指令的目的寄存器物理号

						input		[164:0]	nuifmt2rn,		//第二条来自译码但是没有用到输入到RNR_RR_reg的控制信号
						input		[5:0]	rs2prn,			//第二条指令的rs寄存器的物理号
						input		[5:0]	rt2prn,			//第二条指令的rt寄存器的物理号
						input		[5:0]	rd2prn,			//第二条指令的目的寄存器物理号
						
						output		[164:0]	ifmt1rr,		//第一条来自译码但是没有用到输出到RR阶段的控制信号
						output		[5:0]	rs1prr,			//第一条指令的rs寄存器的物理号
						output		[5:0]	rt1prr,			//第一条指令的rt寄存器的物理号
						output		[5:0]	rd1prr,			//第一条指令的目的寄存器物理号

						output		[164:0]	ifmt2rr,		//第二条来自译码但是没有用到输出到RR阶段的控制信号
						output		[5:0]	rs2prr,			//第二条指令的rs寄存器的物理号
						output		[5:0]	rt2prr,			//第二条指令的rt寄存器的物理号
						output		[5:0]	rd2prr			//第二条指令的目的寄存器物理号
						);
						
						wire		[182:0]	d1,q1;
						wire		[182:0]	d2,q2;

						wire	reset;
						assign  reset = rst | recover;

						assign d1 = {ifmt1rn,rs1prn,rt1prn,rd1prn};
						assign d2 = {ifmt2rn,rs2prn,rt2prn,rd2prn};

						flopren	#(182) rnr_rr_reg1(clk,reset,stall,d1,q1);
						flopren	#(182) rnr_rr_reg2(clk,reset,stall,d2,q2);

						assign {ifmt1rr,rs1prr,rt1prr,rd1prr} = q1;
						assign {ifmt2rr,rs2prr,rt2prr,rd2prr} = q2;
endmodule