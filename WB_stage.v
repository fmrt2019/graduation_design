module	WB_stage	(
				//生成WB阶段是否修改ROB对应属性的使能信号
					input		pre_rightw,			//分支预测是否正确
					input		b_typew,			//分支指令是否是B类型指令
					input		real_directionw,	//分支指令真正的跳转方向

				//(参与比较是否需要修改srat_1)
					input		[5:0]	rd1ps,		//提交阶段的第一条指令目的寄存器最新映射的物理号
					input		[5:0]	rd2ps,		//提交阶段的第一条指令目的寄存器最新映射的物理号

				//RNR
				//(参与比较是否需要修改srat_1)
					input		rd1_enrn			//重命名阶段第一条指令目的寄存器是否有效
					input		[4:0]	rd1lrn,		//重命名阶段第一条指令目的寄存器的逻辑号
					input		rd2_enrn			//重命名阶段第二条指令目的寄存器是否有效
					input		[4:0]	rd2lrn,		//重命名阶段第二条指令目的寄存器的逻辑号

				//WB/COM
				//(参与生成arf、store buffer/cache/memory的使能信号)	
					input		rd_en1,				//第一条指令是否有目的寄存器(写ARF,ARAT)
					input		memwen1,			//第一条指令是否写内存
					input		valid1,				//第一段流水线寄存器是否有效
				//(参与比较是否需要修改srat_1)
					input		[4:0]	rd1l,		//提交阶段第一条指令目的寄存器的逻辑号
					input		[5:0]	rd1p,		//提交阶段的第一条指令目的寄存器物理号(比较且输出修改srat_1)

				//(参与生成arf、store buffer/cache/memory的使能信号)
					input		rd_en2,				//第二条指令是否有目的寄存器(写ARF,ARAT)
					input		memwen2,			//第二条指令是否写内存
					input		valid2,				//第二段流水线寄存器是否有效
				//(参与比较是否需要修改srat_1)
					input		[4:0]	rd2l,		//提交阶段第二条指令目的寄存器的逻辑号
					input		[5:0]	rd2p,		//提交阶段的第二条指令目的寄存器物理号(比较且输出修改srat_1)

				//WB阶段是否修改ROB对应属性的使能信号
					output		br_right_en,		//ROB中br_right属性的写使能信号
					output		raddren,			//ROB中raddr属性的写使能信号

				//to WB/COM
					//第一条指令
					output		srat_1en1,			//提交阶段第一条指令修改srat_1的使能位
					output		arfen1,				//提交阶段第一条指令修改arf的使能位
					output		write1,				//提交阶段第一条指令store buffer的状态位写使能

					//第二条指令
					output		srat_1en2,			//提交阶段第二条指令修改srat_1的使能位
					output		arfen2,				//提交阶段第二条指令修改arf的使能位
					output		write2				//提交阶段第二条指令store buffer的状态位写使能
					);

					//WB
					assign br_right_en = b_typew & (~pre_rightw);	//ROB中br_right属性的写使能信号
					assign raddren = real_directionw;				//ROB中raddr属性的写使能信号

					//WB/COM
					//修改srat_1的条件——有目的寄存器且是最新映射但是和寄存器重命名阶段的有效的目的寄存器逻辑号不相等
					assign srat_1en1 = rd_en1 & (rd1ps == rd1p) & (~((rd1_enrn & (rd1lrn == rd1l)) | (rd2_enrn & (rd2lrn == rd1l))));
					assign srat_1en2 = rd_en2 & (rd2ps == rd2p) & (~((rd1_enrn & (rd1lrn == rd1l)) | (rd2_enrn & (rd2lrn == rd1l))));

					//arf写使能
					assign arfen1 = valid1 & rd_en1;
					assign arfen2 = valid1 & rd_en2;

					//store buffer的状态位写使能
					assign write1 = valid1 & memwen1;
					assign write2 = valid2 & memwen2;
endmodule
