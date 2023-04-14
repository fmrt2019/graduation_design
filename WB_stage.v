module	WB_stage	(
					//alu
					input		[31:0]	aluoutw,	//alu的输出数据
					input		[5:0]	alurdew,	//alu的目的寄存器的物理号
					input		aluen,				//alu是否有效
					//sfu
					input		[31:0]	sfuoutw,	//sfu的输出数据
					input		[5:0]	sfurdw,		//sfu的目的寄存器的物理号
					input		sfuen,				//sfu是否有效
					//bru
					input		pre_rightw,			//分支预测是否正确
					input		b_typew,			//分支指令是否是B类型指令
					input		real_directionw,	//分支指令真正的跳转方向
					input		[31:0]	addrw,		//分支指令真正的跳转地址
					input		[5:0]	brurdw,		//分支指令的目的寄存器的物理号
					input		bruen,				//bru是否有效

					//agu
					input		[31:0]	aguoutw,	//agu的输出数据
					input		[5:0]	agurdw,		//agu的目的寄存器的物理号
					input		aguen,				//agu是否有效

					//srat_2
					input		[5:0]	rd1ps,		//提交阶段的第一条指令目的寄存器最新映射的物理号
					input		[5:0]	rd2ps,		//提交阶段的第一条指令目的寄存器最新映射的物理号

					//RNR
					input		[4:0]	rd1lrn,		//重命名阶段第一条指令目的寄存器的逻辑号
					input		[4:0]	rd2lrn,		//重命名阶段第二条指令目的寄存器的逻辑号
					//rob
					//input		[6:0]	Owp_r,		//ROB的写指针
					//input		[6:0]	Orp_r,		//ROB的读指针

					input		rd_en1,				//第一条指令是否有目的寄存器(写ARF,ARAT)
					input		memwen1,			//第一条指令是否写内存

					inout		valid1,				//第一段流水线寄存器是否有效
					inout		[4:0]	rd1l,		//提交阶段第一条指令目的寄存器的逻辑号
					inout		[5:0]	rd1p,		//提交阶段的第一条指令目的寄存器物理号(比较且输出修改ARF)
					inout		[1:0]	br_type1,	//提交阶段第一条指令的分支指令类型
					inout		right1, 			//提交阶段第一条指令分支预测真确与否
					inout		rdc1, 				//提交阶段第一条指令分支跳转的真正方向
					inout		[31:0]	raddr1, 	//提交阶段第一条指令分支跳转的真正地址
					inout		spilt1,				//提交阶段第一条指令是否被分割
					inout		[31:0]	pc1,		//提交阶段第一条指令的PC值(分割的指令的下一个PC)
					inout		[31:0]	result1,	//提交阶段第一条指令目的寄存器的计算结果
					inout		[2:0]	sbnum1,		//提交阶段第一条指令的store buffer编号

					input		rd_en2,				//第二条指令是否有目的寄存器(写ARF,ARAT)
					input		memwen2,			//第二条指令是否写内存

					inout		valid2,				//第二段流水线寄存器是否有效
					inout		[4:0]	rd2l,		//提交阶段第二条指令目的寄存器的逻辑号
					inout		[5:0]	rd2p,		//提交阶段的第二条指令目的寄存器物理号(比较且输出修改ARF)
					inout		[1:0]	br_type2,	//提交阶段第二条指令的分支指令类型
					inout		right2, 			//提交阶段第二条指令分支预测真确与否
					inout		rdc2, 				//提交阶段第二条指令分支跳转的真正方向
					inout		[31:0]	raddr2, 	//提交阶段第二条指令分支跳转的真正地址
					inout		spilt2,				//提交阶段第二条指令是否被分割
					inout		[31:0]	pc2,		//提交阶段第二条指令的PC值(分割的指令的下一个PC)
					inout		[31:0]	result2,	//提交阶段第二条指令目的寄存器的计算结果
					inout		[2:0]	sbnum2,		//提交阶段第二条指令的store buffer编号

					//rob
					//output		[6:0]	Nwp_r		//ROB的写指针
					//output		[6:0]	Nrp_r		//ROB的读指针

					//to rob
					output		br_right_en,		//ROB中br_right属性的写使能信号
					output		raddren,			//ROB中raddr属性的写使能信号

					//to WB/COM
					//第一条指令
					output		srat_1en1,			//提交阶段第一条指令修改srat_1的使能位
					output		arfen1,				//提交阶段第一条指令修改arf的使能位
					output		araten1,			//提交阶段第一条指令修改arat的使能位
					output		write1,				//提交阶段第一条指令store buffer的状态位写使能

					//第二条指令
					output		srat_1en2,			//提交阶段第二条指令修改srat_1的使能位
					output		arfen2,				//提交阶段第二条指令修改arf的使能位
					output		araten2,			//提交阶段第二条指令修改arat的使能位
					output		write2				//提交阶段第二条指令store buffer的状态位写使能
					);

					//WB
					assign br_right_en = b_typew & (~pre_rightw);	//ROB中br_right属性的写使能信号
					assign raddren = real_directionw;				//ROB中raddr属性的写使能信号

					//WB/COM
					//修改srat_1的条件——是最新映射但是和寄存器重命名阶段的目的寄存器逻辑号不相等
					assign srat_1en1 = (rd1ps == rd1p) & (rd1lrn != rd1l);
					assign srat_1en2 = (rd2ps == rd2p) & (rd2lrn != rd2l);

					//arf写使能
					assign arfen1 = valid1 & rd_en1;
					assign arfen2 = valid1 & rd_en2;

					//ARAT写使能
					assign araten1 = valid1 & rd_en1;
					assign araten2 = valid1 & rd_en2;

					//store buffer的状态位写使能
					assign write1 = valid1 & memwen1;
					assign write2 = valid2 & memwen2;
endmodule