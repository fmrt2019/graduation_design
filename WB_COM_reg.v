module	WB_COM_reg		(
						input		clk,rst,stall,recover,	//写时钟信号,复位信号,停顿信号,恢复信号
						//第一段流水线寄存器
						input		valid1,				//第一段流水线寄存器是否有效
						input		[4:0]	rd1lr,		//提交阶段第一条指令目的寄存器的逻辑号
						input		[5:0]	rd1pr,		//提交阶段的第一条指令目的寄存器物理号(比较且输出修改ARF)
						input		[1:0]	br_type1,	//提交阶段第一条指令的分支指令类型
						input		right1, 			//提交阶段第一条指令分支预测真确与否
						input		rdc1, 				//提交阶段第一条指令分支跳转的真正方向
						input		[31:0]	raddr1, 	//提交阶段第一条指令分支跳转的真正地址
						//input		spilt1,				//提交阶段第一条指令是否被分割
						input		[31:0]	pc1,		//提交阶段第一条指令的PC值(分割的指令的下一个PC)
						input		[31:0]	result1,	//提交阶段第一条指令目的寄存器的计算结果
						input		[2:0]	sbnum1,		//提交阶段第一条指令的store buffer编号

						input		srat_1en1,			//提交阶段第一条指令修改srat_1的使能位
						input		arfen1,				//提交阶段第一条指令修改arf的使能位
						input		araten1,			//提交阶段第一条指令修改arat的使能位
						input		write1,				//提交阶段第一条指令store buffer的状态位写使能

						//第二段流水线寄存器
						input		valid2,				//第二段流水线寄存器是否有效
						input		[4:0]	rd2lr,		//提交阶段第二条指令目的寄存器的逻辑号
						input		[5:0]	rd2pr,		//提交阶段的第二条指令目的寄存器物理号(比较且输出修改ARF)
						input		[1:0]	br_type2,	//提交阶段第二条指令的分支指令类型
						input		right2, 			//提交阶段第二条指令分支预测真确与否
						input		rdc2, 				//提交阶段第二条指令分支跳转的真正方向
						input		[31:0]	raddr2, 	//提交阶段第二条指令分支跳转的真正地址
						//input		spilt1,				//提交阶段第二条指令是否被分割
						input		[31:0]	pc2,		//提交阶段第二条指令的PC值(分割的指令的下一个PC)
						input		[31:0]	result2,	//提交阶段第二条指令目的寄存器的计算结果
						input		[2:0]	sbnum2,		//提交阶段第二条指令的store buffer编号

						input		srat_1en2,			//提交阶段第二条指令修改srat_1的使能位
						input		arfen2,				//提交阶段第二条指令修改arf的使能位
						input		araten2,			//提交阶段第二条指令修改arat的使能位
						input		write2,				//提交阶段第二条指令store buffer的状态位写使能

						//第一段流水线寄存器
						output		valid1C,			//第一段流水线寄存器是否有效
						output		[4:0]	rd1lrC,		//提交阶段第一条指令目的寄存器的逻辑号
						output		[5:0]	rd1prC,		//提交阶段的第一条指令目的寄存器物理号(比较且输出修改ARF)
						output		[1:0]	br_type1C,	//提交阶段第一条指令的分支指令类型
						output		right1C, 			//提交阶段第一条指令分支预测真确与否
						output		rdc1C, 				//提交阶段第一条指令分支跳转的真正方向
						output		[31:0]	raddr1C, 	//提交阶段第一条指令分支跳转的真正地址
						//output		spilt1C,			//提交阶段第一条指令是否被分割
						output		[31:0]	pc1C,		//提交阶段第一条指令的PC值(分割的指令的下一个PC)
						output		[31:0]	result1C,	//提交阶段第一条指令目的寄存器的计算结果
						output		[2:0]	sbnum1C,	//提交阶段第一条指令的store buffer编号

						output		srat_1en1C,			//提交阶段第一条指令修改srat_1的使能位
						output		arfen1C,			//提交阶段第一条指令修改arf的使能位
						output		araten1C,			//提交阶段第一条指令修改arat的使能位
						output		write1C,			//提交阶段第一条指令store buffer的状态位写使能

						//第二段流水线寄存器
						output		valid2C,			//第二段流水线寄存器是否有效
						output		[4:0]	rd2lrC,		//提交阶段第二条指令目的寄存器的逻辑号
						output		[5:0]	rd2prC,		//提交阶段的第二条指令目的寄存器物理号(比较且输出修改ARF)
						output		[1:0]	br_type2C,	//提交阶段第二条指令的分支指令类型
						output		right2C, 			//提交阶段第二条指令分支预测真确与否
						output		rdc2C, 				//提交阶段第二条指令分支跳转的真正方向
						output		[31:0]	raddr2C, 	//提交阶段第二条指令分支跳转的真正地址
						//output		spilt2C,			//提交阶段第二条指令是否被分割
						output		[31:0]	pc2C,		//提交阶段第二条指令的PC值(分割的指令的下一个PC)
						output		[31:0]	result2C,	//提交阶段第二条指令目的寄存器的计算结果
						output		[2:0]	sbnum2C,	//提交阶段第二条指令的store buffer编号

						output		srat_1en2C,			//提交阶段第二条指令修改srat_1的使能位
						output		arfen2C,			//提交阶段第二条指令修改arf的使能位
						output		araten2C,			//提交阶段第二条指令修改arat的使能位
						output		write2C				//提交阶段第二条指令store buffer的状态位写使能
						);

						wire 	[119:0]	d1,q1;
						wire 	[119:0]	d2,q2;

						wire	reset;
						assign  reset = rst | recover;

						assign	d1 = {valid1,rd1lr,rd1pr,br_type1,right1,rdc1,raddr1,pc1,result1,sbnum1,srat_1en1,arfen1,araten1,write1};
						assign	d2 = {valid2,rd2lr,rd2pr,br_type2,right2,rdc2,raddr2,pc2,result2,sbnum2,srat_1en2,arfen2,araten2,write2};

						flopren		#(120)		firstc	(clk,reset,stall,d1,q1);
						flopren		#(120)		secondc (clk,reset,stall,d2,q2);

						assign	{valid1C,rd1lrC,rd1prC,br_type1C,right1C,rdc1C,raddr1C,pc1C,result1C,sbnum1C,srat_1en1C,arfen1C,araten1C,write1C} = q1;
						assign	{valid2C,rd2lrC,rd2prC,br_type2C,right2C,rdc2C,raddr2C,pc2C,result2C,sbnum2C,srat_1en2C,arfen2C,araten2C,write2C} = q2;
endmodule