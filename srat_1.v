/**************************************************************

Filename: srat_1.v
Designer: Dragon
Create date: 2023.4.3
Modification date: 2023.4.3
//Reason for modification: Function validation error
Note:1 represents rd enable;
	:1 represents ARF
***************************************************************/
module	srat_1		(
					input	clk,rst,stall_RNR,stall_RR,recover,	//写时钟信号,复位信号,停顿信号,恢复信号
					//RR
					input		[4:0]	rs1l,					//第一条指令的rs寄存器的逻辑号
					input		[4:0]	rt1l,					//第一条指令的rt寄存器的逻辑号
					input		[4:0]	rs2l,					//第二条指令的rs寄存器的逻辑号
					input		[4:0]	rt2l,					//第二条指令的rt寄存器的逻辑号
					//RNR
					input		[4:0]	rd1l,					//第一条指令的目的寄存器逻辑号
					input		[4:0]	rd2l,					//第二条指令的目的寄存器逻辑号
					input		rd1_en,							//第一条指令的写使能信号
					input		rd2_en,							//第二条指令的写使能信号
					//COM
					input		[4:0]	rd1l_c,					//提交阶段第一条指令的目的寄存器逻辑号
					input		[4:0]	rd2l_c,					//提交阶段第一条指令的目的寄存器逻辑号
					input		rdl_enc,						//提交阶段第一条指令的目的寄存器修改srat_1使能位(有无目的寄存器且是否是最新映射)
					input		rd2_enc,						//提交阶段第一条指令的目的寄存器修改srat_1使能位(有无目的寄存器且是否是最新映射)
					//RR
					output	reg	rs1lc,							//第一条指令的rs数据所在位置
					output	reg	rt1lc,							//第一条指令的rt数据所在位置
					output	reg	rs2lc,							//第二条指令的rs数据所在位置
					output	reg	rt2lc							//第一条指令的rt数据所在位置
					);

					reg			aorr [63:0];		//64个寄存器操作数所在位置

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
									//寄存器重命名阶段无目的寄存器,提交修改
									if (!rd1_en & !rd2_en) begin
										//提交的第一条指令有目的寄存器且是最新映射需要修改SRAT_1
										if (rdl_enc) begin
											aorr[rd1l_c] <= 1'b1;
										end
										//提交的第二条指令有目的寄存器且是最新映射需要修改SRAT_1
										if (rd2_enc) begin
											aorr[rd2l_c] <= 1'b1;
										end
									end
									//寄存器重命名阶段第一条指令有目的寄存器
									if (rd1_en & !rd2_en) begin
										//提交的第一条指令有目的寄存器且是最新映射需要修改SRAT_1
										if (rdl_enc) begin
											//提交的第一条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号相等
											if (rd1l == rd1l_c) begin
												aorr[rd1l_c] <= 1'b0;
											end
											//提交的第一条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号不相等
											else begin
												aorr[rd1l_c] <= 1'b1;
												aorr[rd1l] <= 1'b0;
											end
										end
										//提交的第二条指令有目的寄存器且是最新映射需要修改SRAT_1
										if (rd2_enc) begin
											//提交的第二条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号相等
											if (rd1l == rd2l_c) begin
												aorr[rd1l_c] <= 1'b0;
											end
											//提交的第二条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号不相等
											else begin
												aorr[rd2l_c] <= 1'b1;
												aorr[rd1l] <= 1'b0;
											end
										end
									end
									//寄存器重命名阶段第二条指令有目的寄存器
									if (!rd1_en & rd2_en) begin
										//提交的第一条指令有目的寄存器且是最新映射需要修改SRAT_1
										if (rdl_enc) begin
											//提交的第一条指令的目的寄存器和寄存器重命名阶段第二条指令的目的寄存器逻辑号相等
											if (rd2l == rd1l_c) begin
												aorr[rd1l_c] <= 1'b0;
											end
											//提交的第一条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号不相等
											else begin
												aorr[rd1l_c] <= 1'b1;
												aorr[rd2l] <= 1'b0;
											end
										end
										//提交的第二条指令有目的寄存器且是最新映射需要修改SRAT_1
										if (rd2_enc) begin
											//提交的第二条指令的目的寄存器和寄存器重命名阶段第二条指令的目的寄存器逻辑号相等
											if (rd2l == rd2l_c) begin
												aorr[rd1l_c] <= 1'b0;
											end
											//提交的第二条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号不相等
											else begin
												aorr[rd2l_c] <= 1'b1;
												aorr[rd2l] <= 1'b0;
											end
										end
									end
									//寄存器重命名阶段两条指令都有目的寄存器
									else begin
										//提交的第一条指令有目的寄存器且是最新映射需要修改SRAT_1
										if (rdl_enc) begin
											//提交的第一条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号相等,与第二条不等
											if (rd1l == rd1l_c & rd2l != rd1l_c) begin
												aorr[rd1l_c] <= 1'b0;
												aorr[rd2l] <= 1'b0;
											end
											//提交的第一条指令的目的寄存器和寄存器重命名阶段第二条指令的目的寄存器逻辑号相等,与第一条不等
											else if (rd2l == rd1l_c & rd1l != rd1l_c) begin
												aorr[rd1l_c] <= 1'b0;
												aorr[rd1l] <= 1'b0;
											end
											//提交的第一条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号相等,与第二条也相等
											else if (rd1l == rd1l_c & rd2l == rd1l_c) begin
												aorr[rd1l_c] <= 1'b0;
											end
											//提交的第一条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号不等,与第二条也不等
											else begin
												aorr[rd1l_c] <= 1'b1;
												aorr[rd1l] <= 1'b0;
												aorr[rd2l] <= 1'b0;
											end
										end
										//提交的第二条指令有目的寄存器且是最新映射需要修改SRAT_1
										if (rd2_enc) begin
											//提交的第二条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号相等,与第二条不等
											if (rd1l == rd2l_c & rd2l != rd2l_c) begin
												aorr[rd2l_c] <= 1'b0;
												aorr[rd2l] <= 1'b0;
											end
											//提交的第二条指令的目的寄存器和寄存器重命名阶段第二条指令的目的寄存器逻辑号相等,与第一条不等
											else if (rd2l == rd2l_c & rd1l != rd2l_c) begin
												aorr[rd2l_c] <= 1'b0;
												aorr[rd1l] <= 1'b0;
											end
											//提交的第二条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号相等,与第二条也相等
											else if (rd1l == rd2l_c & rd2l == rd2l_c) begin
												aorr[rd2l_c] <= 1'b0;
											end
											//提交的第二条指令的目的寄存器和寄存器重命名阶段第一条指令的目的寄存器逻辑号不等,与第二条也不等
											else begin
												aorr[rd2l_c] <= 1'b1;
												aorr[rd1l] <= 1'b0;
												aorr[rd2l] <= 1'b0;
											end
										end
									end
								end
								//停顿
								else begin
									
								end	
							end
							//恢复
							else begin
								for(i = 0;i < 32;i=i+1)	begin
									aorr[i] <= 1'b1;
								end	
							end
						end
					end
/*****************************************************************************************************************/
endmodule