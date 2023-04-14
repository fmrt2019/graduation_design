/**************************************************************

Filename: EX_stage.v
Designer: Dragon
Create date: 2023.4.6
Modification date: 2023.4.6
//Reason for modification: Function validation error
Description: Execution module.

***************************************************************/

module	EX_stage	(
					//alu
					input 		[31:0]	alu_ae,alu_be,						//alu的两个操作数
					input		[2:0]	alucontrole,						//alu的控制信号
					inout		[5:0]	alurde,								//alu的目的寄存器物理号
					inout		aluen,										//alu是否有效
					//sfu
					input		[31:0]	sfu_ae,sfu_be,					//sfu的两个操作数
					input		[1:0]	sfucontrole,						//sfu的控制信号
					inout		[5:0]	sfurde,								//sfu的目的寄存器物理号
					inout		sfuen,										//sfu是否有效
					//bru
					input		[31:0]	bru_ae,bru_be,						//bru的两个操作数
					input		[2:0]	brucontrole,						//bru的控制信号
					input		pre_directione,								//分支指令预测方向
					input		[31:0]	pre_addre,							//分支指令预测地址
					inout		[5:0]	brurde,								//bru的目的寄存器物理号（ROB编号）
					inout		bruen,										//bru是否有效
					//agu
					input		[31:0]	agu_ae,agu_be,						//agu的俩个操作数
					input		[3:0]	agucontrol,							//agu的控制信号
					inout		[5:0]	agurde,								//agu的目的寄存器物理号（ROB编号）
					inout		aguen,										//agu是否有效

					//alu
					output		[31:0]	aluoute,							//alu的输出数据
					output		overflow,
					//sfu
					output		[31:0]	sfuoute,							//sfu的输出数据
					//bru
					output		pre_righte,									//bru的预测是否正确
					output		b_typee,									//bru的分支类型是否为B类型（1B）
					output		real_directione,							//bru的分支指令真正的跳转方向
					output		[31:0]	addre,								//分支指令的真正的目标地址
					//agu
					output		[31:0]	aguout								//agu的输出数据
					);
				
				//wire 	overflow;
				alu 	alu1	(alu_ae,alu_be,alucontrole,aluoute,overflow);
				sfu 	sfu1	(sfu_ae,sfu_be,sfucontrole,sfuoute);
				bru 	bru1	(bru_ae,bru_be,brucontrole,pre_directione,pre_addre,pre_righte,b_typee,real_directione,addre);
				agu	agu1	(agu_ae,agu_be,agucontrol,aguout);
endmodule