/**************************************************************

Filename: srat_1.v
Designer: Dragon
Create date: 2023.4.3
Modification date: 2023.4.3
//Reason for modification: Function validation error
Note:1 represents rd enable;
	:1 represents ARF
***************************************************************/
module	srat_1	(
		input	clk,rst,stall_RNR,stall_RR,recover,	//写时钟信号,复位信号,停顿信号,恢复信号
		//RR
		input		[4:0]	rs1l,			//第一条指令的rs寄存器的逻辑号
		input		[4:0]	rt1l,			//第一条指令的rt寄存器的逻辑号
		input		[4:0]	rs2l,			//第二条指令的rs寄存器的逻辑号
		input		[4:0]	rt2l,			//第二条指令的rt寄存器的逻辑号
		//RNR
		input		[4:0]	rd1l,			//第一条指令的目的寄存器逻辑号
		input		[4:0]	rd2l,			//第二条指令的目的寄存器逻辑号
		input		rd1_en,				//第一条指令的写使能信号
		input		rd2_en,				//第二条指令的写使能信号
		//COM
		input		[4:0]	rd1l_c,			//提交阶段第一条指令的目的寄存器逻辑号
		input		[4:0]	rd2l_c,			//提交阶段第一条指令的目的寄存器逻辑号
		input		rdl_enc,			//提交阶段第一条指令的目的寄存器修改srat_1使能位(有无目的寄存器且是否是最新映射)
		input		rd2_enc,			//提交阶段第一条指令的目的寄存器修改srat_1使能位(有无目的寄存器且是否是最新映射)
		//RR
		output	reg	rs1lc,				//第一条指令的rs数据所在位置
		output	reg	rt1lc,				//第一条指令的rt数据所在位置
		output	reg	rs2lc,				//第二条指令的rs数据所在位置
		output	reg	rt2lc				//第一条指令的rt数据所在位置
		);

		reg	aorr [63:0];		//64个寄存器操作数所在位置

		integer		i;
		wire	[5:0]	j;
		wire	[31:0]	itran;

		wire		midaorr_rs1lc;			//读出的第一条指令的rs数据所在位置
		wire		midaorr_rt1lc;			//读出的第一条指令的rt数据所在位置
		wire		midaorr_rs2lc;			//读出的第二条指令的rs数据所在位置
		wire		midaorr_rt2lc;			//读出的第二条指令的rt数据所在位置
		/*
		initial	begin
			for(i = 0;i < 32;i++)	begin
				aorr[i] = 1'b1;
			end
		end
		*/
/***********************************************读SRAT_1*****************************************************/
		assign midaorr_rs1lc = aorr[rs1l];
		assign midaorr_rt1lc = aorr[rt1l];
		assign midaorr_rs2lc = aorr[rs2l];
		assign midaorr_rt2lc = aorr[rt2l];

		always @(*) begin
			if (rst) begin
								
			end
			else  begin
				if (!stall_RR) begin
					if(!recover)begin
						rs1lc <= midaorr_rs1lc;
						rt1lc <= midaorr_rt1lc;
						rs2lc <= midaorr_rs2lc;
						rt2lc <= midaorr_rt2lc;
					end
					else begin
									
					end
				end
				else begin
								
				end
			end
		end
/*************************************************************************************************************/

/********************************************写SRAT_1*********************************************************/
		always @(posedge clk,posedge rst) begin
			//复位
			if (rst) begin
				for(i = 0;i < 32;i=i+1)	begin
					aorr[i] <= 1'b1;
				end
			end
			else begin
				//不恢复
				if (!recover) begin
					//不停顿
					if (!stall_RNR) begin
						//提交的两条指令的目的寄存器逻辑号不相等
						if (rd1l_c != rd2l_c) begin
							case (rd1_enc,rd2_enc) 
								2'b00:	begin 						//两条指令都不需要修改
											
									end
								2'b01:	begin 						//第二条指令需要修改
										aorr[rd2l_c] <= 1'b1;
									end
								2'b10:	begin 						//第一条指令需要修改
										aorr[rd1l_c] <= 1'b1;
									end
								2'b11:	begin 						//两条指令都需要修改
										aorr[rd1l_c] <= 1'b1;
										aorr[rd2l_c] <= 1'b1;
									end
								default	begin
													
									end
							endcase
						end
						//提交的两条指令的目的寄存器逻辑号相等
						else begin
							if (rd2_enc) begin 						//第一条指令必定不需要修改，第二条指令需要修改
								aorr[rd2l_c] <= 1'b1;
							end
						end
					end
					//停顿
					else 	begin
									
						end	
					end
				//恢复
				else 	begin
						for(i = 0;i < 32;i=i+1)	begin
							aorr[i] <= 1'b1;
						end	
					end
			end
		end
/*****************************************************************************************************************/
endmodule
