module	EX_WB_reg	(
					input		clk,rst,stall,recover,
					//alu
					input		[31:0]	aluoute,							//alu的输出结果
					input		[5:0]	alurde,								//alu的目的寄存器物理号
					input		aluen,										//alu是否有效
					//sfu
					input		[31:0]	sfuoute,							//sfu的输出结果
					input		[5:0]	sfurde,								//sfu的目的寄存器物理号
					input		sfuen,										//sfu是否有效
					//bru
					input		pre_righte,									//分支预测是否正确
					input		b_typee,									//分支指令是不是B类型
					input		real_directione,							//分支指令真正的方向
					input		[31:0]	addre,								//分支指令的真正跳转地址
					input		[5:0]	brurde,								//bru的目的寄存器物理号
					input		bruen,										//bru是否有效
					//agu
					input		[31:0]	aguoute,							//agu的输出结果
					input		[5:0]	agurde,								//agu的目的寄存器
					input		aguen,										//agu是否有效

					//alu
					output		[31:0]	aluoutw,							//alu的输出结果
					output		[5:0]	alurdw,								//alu的目的寄存器物理号
					output		aluenw,										//alu是否有效
					//sfu
					output		[31:0]	sfuoutw,							//sfu的输出结果
					output		[5:0]	sfurdw,								//sfu的目的寄存器物理号
					output		sfuenw,										//sfu是否有效
					//bru
					output		pre_rightw,									//分支预测是否正确
					output		b_typew,									//分支指令是不是B类型
					output		real_directionw,							//分支指令真正的方向
					output		[31:0]	addrw,								//分支指令的真正跳转地址
					output		[5:0]	brurdw,								//bru的目的寄存器物理号
					output		bruenw,										//bru是否有效
					//agu
					output		[31:0]	aguoutw,							//agu的输出结果
					output		[5:0]	agurdw,								//agu的目的寄存器
					output		aguenw										//agu是否有效
					);

					wire	[38:0]	d1,q1;
					wire	[38:0]	d2,q2;
					wire	[41:0]	d3,q3;
					wire	[38:0]	d4,q4;

					wire	reset;
					assign  reset = rst | recover;

					assign d1 = {aluoute,alurde,aluen};
					assign d2 = {sfuoute,sfurde,sfuen};
					assign d3 = {pre_righte,b_typee,real_directione,addre,brurde,bruen};
					assign d4 = {aguoute,agurde,aguen};

					flopren	#(39) aluf	(clk,reset,stall,d1,q1);
					flopren	#(39) sfuf	(clk,reset,stall,d2,q2);
					flopren	#(42) bruf	(clk,reset,stall,d3,q3);
					flopren	#(39) aguf	(clk,reset,stall,d4,q4);

					assign {aluoutw,alurdw,aluenw} = q1;
					assign {sfuoutw,sfurdw,sfuenw} = q2;
					assign {pre_rightw,b_typew,real_directionw,addrw,brurdw,bruenw} = q3;
					assign {aguoutw,agurdw,aguenw} = q4;	
endmodule