/**********************************************************************************************************/
/*
Filename: srat_2.v
Designer: Dragon
Create date: 2023.4.1
Modification date: 2023.4.2
//Reason for modification: Function validation error
Note:1 represents rd enable;
	:0 represents rs or rt enable
*/
/**********************************************************************************************************/
module		srat_2	(
					input		clk,rst,stall_RNR,stall_RR,recover,	//写时钟信号,复位信号,停顿信号,恢复信号
					//input		[191:0]	aratdata,				//ARAT用来恢复SRAT的物理号,0寄存器存到[5:0]
					//RR
					input		[4:0]	rs1l,					//第一条指令的rs寄存器的逻辑号
					input		[4:0]	rt1l,					//第一条指令的rt寄存器的逻辑号
					input		[4:0]	rs2l,					//第二条指令的rs寄存器的逻辑号
					input		[4:0]	rt2l,					//第二条指令的rt寄存器的逻辑号
					//input		[6:0]	wp_r,					//ROB的写指针
					//决定是否进行源寄存器的重命名过程
					//0为源寄存器有效,1为源寄存器无效
					input		rs1_en,							//第一条指令rs是否有效
					input		rt1_en,							//第一条指令rt是否有效
					input		rs2_en,							//第二条指令rs是否有效
					input		rt2_en,							//第二条指令rt是否有效
					//RNR
					input		[4:0]	rd1l,					//第一条指令的目的寄存器逻辑号
					input		[4:0]	rd2l,					//第二条指令的目的寄存器逻辑号
					//目的寄存器有效位,1有效
					input		rd1_en,							//第一条指令的写使能信号
					input		rd2_en,							//第二条指令的写使能信号
					input		[5:0]	rd1p,					//第一条指令的目的寄存器物理号
					input		[5:0]	rd2p,					//第二条指令的目的寄存器物理号
					//com（写回阶段读取）
					input		[4:0]	rd1l_c,					//提交阶段第一条指令的目的寄存器逻辑号
					input		[4:0]	rd2l_c,					//提交阶段第一条指令的目的寄存器逻辑号
					//RR
					output	reg	[5:0]	rs1p,					//第一条指令的rs寄存器的物理号
					output	reg	[5:0]	rt1p,					//第一条指令的rt寄存器的物理号
					output	reg	[5:0]	rs2p,					//第二条指令的rs寄存器的物理号
					output	reg	[5:0]	rt2p,					//第一条指令的rt寄存器的物理号
					//com（写回阶段读取）
					output	reg	[5:0]	rd1p_c,					//提交阶段第一条指令的目的寄存器物理号
					output	reg	[5:0]	rd2p_c					//提交阶段第二条指令的目的寄存器物理号
					);

					reg		[5:0]	robnum	[31:0];					//32个ROB的编号

					wire	[5:0]	midrs1p;
					wire	[5:0]	midrt1p;
					wire	[5:0]	midrs2p;
					wire	[5:0]	midrt2p;
					wire	[5:0]	midrd1p_c;
					wire	[5:0]	midrd2p_c;		

					integer		i;
					reg	[5:0]	j;
					reg	[31:0]	itran;
					//assign  itran = $unsigned(i);
					//assign  j = itran[5:0];
					
					/*
					initial	begin
						for(i = 0;i < 32;i++)	begin
								robnum[i] = 6'b000000;
						end
					end
					*/
/***********************************************写srat_2***************************************************/
					always @(posedge clk,posedge rst) begin
						//复位
						if (rst) begin
							for(i = 0;i < 32;i=i+1)	begin
								itran = $unsigned(i);
								j = itran[5:0];
								robnum[i] = j;
							end
						end
						else begin
							//不恢复
							if (!recover) begin
								//不停顿
								if (!stall_RNR) begin
									//两条指令的目的寄存器都有效
									if (rd1_en & rd2_en) begin
										//两条指令的目的寄存器相等
										if (rd1l == rd2l) begin
											robnum[rd2l] <= rd2p;
										end
										//两条指令的目的寄存器不相等
										else begin
											robnum[rd1l] <= rd1p;
											robnum[rd2l] <= rd2p;	
										end
									end
									//第一条指令的目的寄存器有效
									else if (rd1_en & !rd2_en) begin
										robnum[rd1l] <= rd1p;
									end
									//第二条指令的目的寄存器有效
									else if (!rd1_en & rd2_en) begin
										robnum[rd2l] <= rd2p;
									end
									//两条指令的目的寄存器都无效
									else begin
									
									end
								end
								//停顿
								else begin
								
								end
							end
							//恢复
							else  begin
								for(i = 0;i < 32;i=i+1)	begin
									itran = $unsigned(i);
									j = itran[5:0];
									robnum[i] = j;
								end
							end
						end
					end
/***********************************************************************************************************/

/***************************************************读srat_2***********************************************/
					assign midrs1p = robnum[rs1l];
					assign midrt1p = robnum[rt1l];
					assign midrs2p = robnum[rs2l];
					assign midrt2p = robnum[rt2l];
					assign midrd1p_c = robnum[rd1l_c];
					assign midrd2p_c = robnum[rd2l_c];

					always @(*) begin 
							if (stall_RR) begin
								rs1p <= 6'bx;
								rt1p <= 6'bx;
								rs2p <= 6'bx;
								rt2p <= 6'bx;
							end
							else begin
								if (!recover) begin
									//第一条指令的rs1重命名
									if (!rs1_en)begin
										rs1p <= midrs1p;
									end
									else begin
										rs1p <= 6'bx;
									end
									//第一条指令的rt1重命名
									if (!rt1_en) begin
										rt1p <= midrt1p;
									end
									else begin
										rt1p <= 6'bx;
									end
									//第二条指令的rs2重命名
									if (!rs2_en) begin
										if (rd1_en & (rs2l == rd1l)) begin
											rs2p <= rd1p;
										end
										else begin
											rs2p <= midrs2p;
										end
									end
									else  begin
										rs2p <= 6'bx;
									end
									//第二条指令的rt2重命名
									if (!rt2_en) begin
										if (rd1_en & (rt2l == rd1l)) begin
											rt2p <= rd1p;
										end
										else begin
											rt2p <= midrt2p;
										end
									end
									else begin
										rt2p <= 6'bx;
									end
								end
								else begin
									rs1p <= 6'bx;
									rt1p <= 6'bx;
									rs2p <= 6'bx;
									rt2p <= 6'bx;
								end
							end
							//提交读取,判断是否是最新映射
							rd1p_c <= midrd1p_c;
							rd2p_c <= midrd2p_c;
						
					end
/**********************************************************************************************************/
endmodule
