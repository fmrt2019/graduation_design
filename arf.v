/******************************************************************************************************/
/*
Filename: arf.v
Designer: Dragon
Create date: 2023.3.30
Modification date: 2023.3.30
//Reason for modification: Function validation error
Description: logic register file.
Note:
*/
/****************************************************************************************************/
module		arf	(
						input			rst,clk,				//复位、写时钟信号
						//RR
						input			[4:0] rs1,				//第一条指令的源寄存器rs1
						input			[4:0] rt1,				//第一条指令的源寄存器rt1
						input			[4:0] rs2,				//第二条指令的源寄存器rs2
						input			[4:0] rt2,				//第二条指令的源寄存器rt2
						input			rs1_en,				//第一条指令的源寄存器rs1读使能位
						input			rt1_en,				//第一条指令的源寄存器rt1读使能位
						input			rs2_en,				//第二条指令的源寄存器rs2读使能位
						input			rt2_en,				//第二条指令的源寄存器rt2读使能位
						//COM
						input			[4:0] rd1,				//第一条指令的目的寄存器rd1逻辑号
						input			[4:0] rd2,				//第二条指令的目的寄存器rd2逻辑号		
						input			[31:0] rd_data1,		//第一条指令的目的寄存器的数据
						input			[31:0] rd_data2,		//第二条指令的目的寄存器的数据
						input			rd_en1,					//第一条指令的目的寄存器的写信号		
						input			rd_en2,					//第二条指令的目的寄存器的写信号
						  	
						output	reg		[31:0]	rsdata1,		//第一条指令的源寄存器rs1的读数据
						output	reg		[31:0]	rtdata1,		//第一条指令的源寄存器rt1的读数据
						output	reg		[31:0]	rsdata2,		//第二条指令的源寄存器rs2的读数据
						output	reg		[31:0]	rtdata2			//第二条指令的源寄存器rt2的读数据
						);


						reg		[31:0]	arf[31:0];

						wire	[31:0]	midrsdata1;
						wire	[31:0]	midrtdata1;
						wire	[31:0]	midrsdata2;
						wire	[31:0]	midrtdata2;

						integer			i;
						/*
						//初始化寄存器组
						initial	begin
						  	for(i = 0; i < 32; i = i+1)	begin
						  		arf[i][31：0] <= 32'b0;
						  	end
						end
						*/
/******************************************写寄存器****************************************/
						  always @(posedge clk,posedge rst) begin
						  	//复位信号
						  	if(rst)	begin
						  		for(i = 0; i < 32; i = i+1)	begin
						  			arf[i][31:0] <= 32'b0;
						  		end
						  	end
						  	//写寄存器
						  	else begin
						  		if(rd_en1 & (rd1 != 5'b00000))	begin
						  			arf[rd1][31:0] <= rd_data1;
						  		end
						  		if(rd_en2 & (rd2 != 5'b00000))	begin
						  			arf[rd2][31:0] <= rd_data2;
						  		end
						  	end
						  end

/******************************************读寄存器****************************************/
						assign midrsdata1 = arf[rs1][31:0];
						assign midrtdata1 = arf[rt1][31:0];
						assign midrsdata2 = arf[rs2][31:0];
						assign midrtdata2 = arf[rt2][31:0];

						always @(*) begin
							//读rs1
						  	if (rs1_en) begin
						  		rsdata1 <= midrsdata1;
						  	end
						  	else begin
						  		rsdata1 <= 32'bx;
						  	end

						  	//读rt1
						  	if (rt1_en) begin
						  		rtdata1 <= midrtdata1;
						  	end
						  	else begin
						  		rtdata1 <= 32'bx;
						  	end

						  	//读rs2
						  	if (rs2_en) begin
						  		rsdata2 <= midrsdata2;
						  	end
						  	else begin
						  		rsdata2 <= 32'bx;
						  	end

						  	//读rt2
						  	if (rt2_en) begin
						  		rtdata2 <= midrtdata2;
						  	end
							else begin
								rtdata2 <= 32'bx;
							end
						end
endmodule