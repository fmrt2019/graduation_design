/**************************************************************

Filename: rob.v
Designer: Dragon
Create date: 2023.3.30
Modification date: 2023.3.30
//Reason for modification: Function validation error
Description: reorder buffer.
Note:

***************************************************************/
module	rob			 (input				rst,clk,stall,recover,
					  //input				[data_WIDTH-1:0]	wdata1,
					  //input				[data_WIDTH-1:0]	wdata2,
					//RNR
					  input			valid1rn,				//重命名阶段第一条指令有效（1代表指令有效）
					  input			valid2rn,				//重命名阶段第二条指令有效（1代表指令有效）
					//DIS
					  input			valid1dis,				//第一条指令有效（1代表指令有效）
					  input			complete1,				//第一条指令的完成信号
					  input			rd1_en,					//第一条指令的目的寄存器的写信号
					  input			[4:0]	rd1ld,			//第一条指令目的寄存器的逻辑号
					  input			[5:0]	rd1pd,			//第一条指令目的寄存器的物理号（指令在ROB的编号）
					  input			[31:0]	result1d,		//第一条指令目的寄存器的结果
					  //bru
					  input			[1:0]	br_type1, 		//分支指令的类型
					  input			rdc1d,					//分支指令真正的跳转方向（部分正确）
					  input			[31:0] raddr1,			//分支指令的真正跳转地址（部分正确）
					  input			right1,					//分支预测是否正确（部分正确）
					  //input			split1				//指令是否分在两个cache line中（1表示分割）
					  input			[31:0] pc1,				//指令PC，（分割指令的下一个PC）
					  //agu
					  input			memwen1d,				//memory write信号
					  input			[2:0]	sbnum1,			//store buffer的编号

					  input			valid2dis,				//第二条指令有效（1代表指令有效）
					  input			complete2,				//第二条指令的完成信号
					  input			rd2_en,					//第二条指令的目的寄存器的写信号
					  input			[4:0]	rd2ld,			//第二条指令目的寄存器的逻辑号
					  input			[5:0]	rd2pd,			//第二条指令目的寄存器的物理号（指令在ROB的编号）
					  input			[31:0] result2d,		//第二条指令目的寄存器的结果
					  //bru
					  input			[1:0]	br_type2, 		//分支指令的类型
					  input			rdc2d,					//分支指令真正的跳转方向（部分正确）
					  input			[31:0] raddr2,			//分支指令的真正跳转地址（部分正确）
					  input			right2,					//分支预测是否正确（部分正确）
					  //input			split2				//指令是否分在两个cache line中（1表示分割）
					  input			[31:0]	pc2,			//指令PC，（分割指令的下一个PC）
					  //sfu
					  input			memwen2d,				//memory write信号
					  input			[2:0]	sbnum2,			//store buffer的编号

					//WB
					  //alu
					  input			[5:0]	rd1pw,			//alu的目的寄存器的物理号
					  input			[31:0]	aluout,			//alu的输出结果
					  input			aluen,					//alu是否有效

					  //sfu
					  input			[5:0]	rd2pw,			//sfu的目的寄存器的物理号
					  input			[31:0]	sfuout,			//sfu的输出结果
					  input			sfuen,					//sfu是否有效

					  //bru
					  input			[5:0]	rd3pw,			//bru的目的寄存器的物理号
					  input			br_right_en,			//br_right的写使能信号
					  input			raddren,				//raddr的写使能信号
					  input			br_rightw,				//分支指令是否预测正确
					  input			rdcw,					//分支指令真正的方向
					  input			[31:0]	raddrw,			//分支指令真正的地址
					  input			bruen,					//bru是否有效

					  //agu
					  input			[5:0]	rd4pw,			//agu的目的寄存器的物理号
					  input			[31:0]	aguout,			//agu的输出结果
					  input			aguen,					//agu是否有效

					//COM
					  /************************to one*****************************************/
					  //第一条
					  output	reg	valid1,					//第一段流水线寄存器是否有效
					  output	reg	[1:0]	outbr_type1,	//第一条指令分支指令的类型
					  output	reg	outbr_right1,			//第一条指令分支指令预测是否正确
					  output	reg	outrdc1,				//第一条指令分支指令的真正跳转方向
					  output	reg	[31:0]	outraddr1,		//第一条指令分支指令的真正跳转地址
					  //output		split1w					//第一条指令是否分在两个cache line中（1表示分割）
					  output	reg	[31:0]	outpc1,			//第一条指令的PC,（分割指令的下一个PC）

					  //第二条
					  output	reg	valid2,					//第二段流水线寄存器是否有效
					  output	reg	[1:0]	outbr_type2,	//第二条指令分支指令的类型
					  output	reg	outbr_right2,			//第二条指令分支指令预测是否正确
					  output	reg	outrdc2,				//第二条指令分支指令的真正跳转方向
					  output	reg	[31:0]	outraddr2,		//第二条指令分支指令的真正跳转地址
					  //output		split2w					//第二条指令是否分在两个cache line中（1表示分割）
					  output	reg	[31:0]	outpc2,			//第二条指令的PC,（分割指令的下一个PC）
					  /******************************************************************************/

					  /*******************************to me******************************************/
					//arf	
					  output	reg	rd_en1,					//第一条指令是否有目的寄存器
					  //output		[4:0]	outrdl,			//第一条指令写arf的目的寄存器的逻辑号
					  output	reg	[31:0]	outresult1,		//第一条指令写arf的数据

					  output	reg	rd_en2,					//第二条指令是否有目的寄存器
					  //output		[4:0]	outrd2,			//第二条指令写arf的目的寄存器的逻辑号
					  output	reg	[31:0]	outresult2,		//第二条指令写arf的数据

					//srat_1
					  output	reg	[4:0]	rd1l,			//第一条指令的目的寄存器逻辑号
					  output	reg	[5:0]	rd1p, 			//第一条指令的目的寄存器物理号

					  output	reg	[4:0]	rd2l,			//第二条指令的目的寄存器逻辑号
					  output	reg	[5:0]	rd2p, 			//第二条指令的目的寄存器物理号
					  /******************************************************************************/

					  /******************************to three****************************************/
					  output	reg	memwen1,				//第一条是否是store
					  output	reg	[2:0]	sbnum1c,		//第一条store buffer的编号

					  output	reg	memwen2,				//第二条是否是store
					  output	reg	[2:0]	sbnum2c,		//第二条store buffer的编号
					  /******************************************************************************/

					//RNR
					  output	reg	[5:0]	inum1,			//第一条指令在ROB中的编号
					  output	reg	[5:0]	inum2,			//第二条指令在ROB中的编号

					//RR
					  output	reg outcomplete1,			//第一条指令完成信号
					  output	reg outcomplete2,			//第二条指令完成信号

					  output	reg	outfull,				//rob满信号
					  output	reg	outempty				//rob空信号
					  );

					 //reg		[data_WIDTH-1:0]	fifo [addr_WIDTH-1:0];

						reg		complete [63:0];		//64个完成信号

						reg 	[1:0]	br_type [63:0];	//64个是否为分支指令类型的信号(00:普通;01:call;10:return;11:br/jump)
						reg		br_right [63:0];		//64个分支指令预测成功的信号
						//reg 	spilt [63:0];			//64条指令是否被分割，处于两条cache line里
						reg 	[31:0]	pc 	[63:0];		//64个PC(分割的指令的下一个PC)
						reg		rdc [63:0];				//64个分支指令真正的跳转方向
						reg 	[31:0]	raddr [63:0];	//64个分支指令真正的跳转地址

						reg		memwen[63:0];			//64个存储器写信号
						reg 	[2:0]	sbnum [63:0];	//64个store buffer的编号

						reg		rden [63:0];			//64个是否有目的寄存器
						reg 	[4:0]	rdl [63:0];		//64个目的寄存器的逻辑号
						reg 	[5:0]	rdp [63:0];		//64个目的寄存器的物理号
						reg 	[31:0]	result [63:0];	//64个结果


						reg	[5:0]	wp_r;				//写指针
						//reg	[5:0]	nwp_r;			//写指针
						reg	[5:0]	rp_r;				//读指针
						//reg	[5:0]	nrp_r;			//读指针
						reg	[6:0]	counter;			//计数器(加一个bit防止溢出判断错误)
						//reg	[6:0]	ncounter;

						reg	br_en [63:0];		//64个是否为分支指令

						wire	midcomplete1;
						wire	[1:0]	midoutbr_type1;
						wire	midoutbr_right1;
						wire	midoutrdc1;
						wire	[31:0]	midoutraddr1;
						wire	[31:0]	midoutpc1;
						wire	midrd_en1;
						wire	[31:0]	midoutresult1;
						wire	[4:0]	midrd1l;
					 	wire	[5:0]	midrd1p;
					 	wire	midmemwen1;
					 	wire	[2:0]	midsbnum1c;
					 	wire midbr_en1;

					 	wire	midcomplete2;
					 	wire	[1:0]	midoutbr_type2;
					 	wire	midoutbr_right2;
					 	wire	midoutrdc2;
					 	wire	[31:0]	midoutraddr2;
					 	wire	[31:0]	midoutpc2;
					 	wire	midrd_en2;
					 	wire	[31:0]	midoutresult2;
					 	wire	[4:0]	midrd2l;
					 	wire	[5:0]	midrd2p;
					 	wire	midmemwen2;
					 	wire	[2:0]	midsbnum2c;
					 	wire midbr_en2;


						reg		full,empty;			//rob的满空信号
						wire 	[6:0] wnum;			//写指令个数，为了计算对齐
						reg 		[6:0] rnum;			//读指令个数，为了计算对齐

						integer	i;
					
					/*
					//初始化ROB
					initial	begin
						for(i = 0; i <= 6'b111111; i = i+1)	begin
						  			complete[i] <= 1'b0;

						  			br_type[i] <= 2'b0;
						  			br_right <= 1'b1;
						  			//spilt[i] <= 1'b0;
						  			pc[i][31:0] <= 32'b0;
						  			rdc[i] <= 1'b0;
						  			raddr[i][31:0] <= 32'b0;

						  			memwen[i] <= 1'b0;
						  			sbnum[i][2:0] <= 3'b0;

						  			rden[i] <= 1'b0;
						  			rdl[i][4:0] <= 5'b0;		
					 				rdp[i][5:0] <= 6'b0;		
					 				result[i][31:0] <= 32'b0;

					 				wp_r <= 7'b0;			
					 				rp_r <= 7'b0;			
					 				counter <= 7'b0;
						end
					end
					*/
					
					wire   reset;
					assign   reset = rst | recover;
					
					//flopr  #(6)		fwp_r(clk,reset,wp_r,wp_r);
					//flopr  #(6)		frp_r(clk,reset,nrp_r,rp_r);
					//flopr  #(7)		fcounter(clk,reset,counter,counter);
					

					//定义是否为分支指令,中间信号
					always @(*) begin
						for(i = 0; i < 64; i = i+1)	begin
							if(br_type[i][1:0] == 2'b00)begin
								br_en[i]=1'b0;
							end
							else begin
								br_en[i]=1'b1;
							end
						end
					end
/******************************************满空判断*********************************************************/
					assign wnum = {6'b0,valid1rn} + {6'b0,valid2rn};		//加一个bit防止溢出判断错误

					always @(posedge clk) begin 							//写满判断
						if ((wnum + counter) > 7'b1000000) begin
							full = 1'b1;
						end
						else	begin
							full = 1'b0;
						end
					end

					always @(*) begin 							//读空判断
						if (counter == 7'b0) begin
							empty = 1'b1;
						end
						else	begin
							empty = 1'b0;
						end
					end					
/***********************************************************************************************************/


/******************************************写***************************************************************/
					
					always @(posedge clk,posedge reset)begin
						if(reset)begin
							for(i = 0; i < 64; i = i+1)	begin
								complete[i] <= 1'b0;

						  		br_type[i] <= 2'b0;
						  		br_right[i] <= 1'b1;
						  		//spilt[i] <= 1'b0;
								pc[i][31:0] <= 32'b0;
					  			rdc[i] <= 1'b0;
					  			raddr[i][31:0] <= 32'b0;

					  			memwen[i] <= 1'b0;
					  			sbnum[i][2:0] <= 3'b0;

					  			rden[i] <= 1'b0;
					  			rdl[i][4:0] <= 5'b0;		
					 			rdp[i][5:0] <= 6'b0;		
					 			result[i][31:0] <= 32'b0;
					 		end
							
					 		wp_r <= 6'b0;			
					 			//rp_r <= 6'b0;			
									
						end

						else begin
							/*if (recover) begin
								for(i = 0; i < 64; i = i+1)	begin
									complete[i] <= 1'b0;

						  			br_type[i] <= 2'b0;
						  			br_right[i] <= 1'b1;
						  			//spilt[i] <= 1'b0;
									pc[i][31:0] <= 32'b0;
					  				rdc[i] <= 1'b0;
					  				raddr[i][31:0] <= 32'b0;

					  				memwen[i] <= 1'b0;
					  				sbnum[i][2:0] <= 3'b0;

					  				rden[i] <= 1'b0;
					  				rdl[i][4:0] <= 5'b0;		
					 				rdp[i][5:0] <= 6'b0;		
					 				result[i][31:0] <= 32'b0;
					 			end		
					 				wp_r <= 6'b0;			
					 				rp_r <= 6'b0;			
									counter <= 7'b0;
								
							end
*/
							//else begin
								if (stall) begin 				//重命名阶段停顿
									
								end

								else begin
								//RNR
									if(full)begin
										outfull <= full;
									end
									else begin
										inum1 = wp_r;
										inum2 = wp_r + 6'b1;
										wp_r = wp_r + wnum[5:0];
										//counter = counter + wnum;
									end
									
								//DIS
									if(!valid1dis)begin

									end
									else if (valid1dis & !valid2dis) begin
										complete[rd1pd] <= complete1;

						  				br_type[rd1pd] <= br_type1;
						  				br_right[rd1pd] <= right1;
						  				//spilt[rd1pd] <= split1;
										pc[rd1pd][31:0] <= pc1;
					  					rdc[rd1pd] <= rdc1d;
					  					raddr[rd1pd][31:0] <= raddr1;

					  					memwen[rd1pd] <= memwen1d;
					  					sbnum[rd1pd][2:0] <= sbnum1;

					  					rden[rd1pd] <= rd1_en;
					  					rdl[rd1pd][4:0] <= rd1ld;		
					 					rdp[rd1pd][5:0] <= rd1pd;		
					 					result[rd1pd][31:0] <= result1d;
									end
									else begin
										//第一条
										complete[rd1pd] <= complete1;

						  				br_type[rd1pd] <= br_type1;
						  				br_right[rd1pd] <= right1;
						  				//spilt[rd1pd] <= split1;
										pc[rd1pd][31:0] <= pc1;
					  					rdc[rd1pd] <= rdc1d;
					  					raddr[rd1pd][31:0] <= raddr1;

					  					memwen[rd1pd] <= memwen1d;
					  					sbnum[rd1pd][2:0] <= sbnum1;

					  					rden[rd1pd] <= rd1_en;
					  					rdl[rd1pd][4:0] <= rd1ld;		
					 					rdp[rd1pd][5:0] <= rd1pd;		
					 					result[rd1pd][31:0] <= result1d;

					 					//第二条
					 					complete[rd2pd] <= complete2;

						  				br_type[rd2pd] <= br_type2;
						  				br_right[rd2pd] <= right2;
						  				//spilt[rd2pd] <= split2;
										pc[rd2pd][31:0] <= pc2;
					  					rdc[rd2pd] <= rdc2d;
					  					raddr[rd2pd][31:0] <= raddr2;

					  					memwen[rd2pd] <= memwen2d;
					  					sbnum[rd2pd][2:0] <= sbnum2;

					  					rden[rd2pd] <= rd2_en;
					  					rdl[rd2pd][4:0] <= rd2ld;		
					 					rdp[rd2pd][5:0] <= rd2pd;		
					 					result[rd2pd][31:0] <= result2d;
									end

								//WB
									//alu
									if (aluen) begin
										result[rd1pw][31:0] <= aluout;
									end
									//sfu
									if (sfuen) begin
										result[rd2pw][31:0] <= sfuout;
									end
									//bru
									if (bruen) begin
										if(br_right_en)begin
											br_right[rd3pw]  <= br_rightw;
										end

										if (raddren) begin
											raddr[rd3pw][31:0] <= raddrw;
										end
										rdc[rd3pw] <= rdcw;
									end
									//agu
									if (aguen) begin
										result[rd4pw][31:0] <= aguout;
									end
								end	
							//end
						end
					end
			
			/*always @(*) begin
				if(rp_r <= 6'b111110)begin
						rp_r = rp_r + rnum[5:0];
				end
				else	begin
						rp_r <= 6'b000000;
						//rp_r[6] <= ~rp_r[6];
				end
				counter = counter - rnum  + wnum;	
			end
			*/
/***************************************************************************************************************************************/
			//assign	counter = counter + wnum -rnum;

/******************************************读ROB************************************************************/
					assign 	midcomplete1 = complete[rp_r];
					assign 	midoutbr_type1[1:0] = br_type[rp_r];
					assign 	midoutbr_right1 =br_right[rp_r];
					assign 	midoutrdc1 = rdc[rp_r];
					assign 	midoutraddr1[31:0] = raddr[rp_r];
					assign 	midoutpc1[31:0] = pc[rp_r];
					assign 	midrd_en1 = rden[rp_r];
					assign 	midoutresult1[31:0] = result[rp_r];
					assign 	midrd1l[4:0] = rdl[rp_r];
					assign 	midrd1p = rdp[rp_r];
					assign 	midmemwen1 = memwen[rp_r];
					assign 	midsbnum1c[2:0] = sbnum[rp_r];
					assign	midbr_en1 = br_en[rp_r];

					assign 	midcomplete2 = complete[rp_r+1];
					assign 	midoutbr_type2[1:0] = br_type[rp_r+1];
					assign 	midoutbr_right2 =br_right[rp_r+1];
					assign 	midoutrdc2 = rdc[rp_r+1];
					assign 	midoutraddr2[31:0] = raddr[rp_r+1];
					assign 	midoutpc2[31:0] = pc[rp_r+1];
					assign 	midrd_en2 = rden[rp_r+1];
					assign 	midoutresult2[31:0] = result[rp_r+1];
					assign 	midrd2l[4:0] = rdl[rp_r+1];
					assign 	midrd2p = rdp[rp_r+1];
					assign 	midmemwen2 = memwen[rp_r+1];
					assign 	midsbnum2c[2:0] = sbnum[rp_r+1];
					assign	midbr_en2 = br_en[rp_r+1];
					
					

					always @(*) begin
						if(reset) begin
							valid1 = 1'b0;
							outbr_type1[1:0] <= 2'b00;
							outbr_right1 <=1'b1;
							outrdc1 <= 1'b0;
							outraddr1[31:0] <= 32'b0;
							outpc1[31:0] <= 32'b0;
							rd_en1 <= 1'b0;
							outresult1[31:0] <= 32'b0;
							rd1l[4:0] <= 5'b0;
							rd1p[5:0] <= 6'b0;
							memwen1 <= 1'b0;
							sbnum1c[2:0] <= 3'b0;

							valid2 = 1'b0;
							outbr_type2[1:0] <= 2'b00;
							outbr_right2 <=1'b1;
							outrdc2 <= 1'b0;
							outraddr2[31:0] <= 32'b0;
							outpc2[31:0] <= 32'b0;
							rd_en2 <= 1'b0;
							outresult2[31:0] <= 32'b0;
							rd2l[4:0] <= 5'b0;
							rd2p[5:0] <= 6'b0;
							memwen2 <= 1'b0;
							sbnum2c[2:0] <= 3'b0;

							rnum = 6'b0;
																
							rp_r <= 6'b0;
							counter <= 7'b0;
						end
						
						else	begin
								if (!empty) begin
								//COM
									outempty <= empty;
									casex({midcomplete1,midbr_en1,midoutbr_right1,midcomplete2,midbr_en2,midoutbr_right2})
										//两条指令都未完成。不提交指令
										6'b0_x_x_x_x_x:		begin
																valid1 = 1'b0;
																outbr_type1[1:0] <= 2'b00;
																outbr_right1 <=1'b1;
																outrdc1 <= 1'b0;
																outraddr1[31:0] <= 32'b0;
																outpc1[31:0] <= 32'b0;
																rd_en1 <= 1'b0;
																outresult1[31:0] <= 32'b0;
																rd1l[4:0] <= 5'b0;
																rd1p[5:0] <= 6'b0;
																memwen1 <= 1'b0;
																sbnum1c[2:0] <= 3'b0;

																valid2 = 1'b0;
																outbr_type2[1:0] <= 2'b00;
																outbr_right2 <=1'b1;
																outrdc2 <= 1'b0;
																outraddr2[31:0] <= 32'b0;
																outpc2[31:0] <= 32'b0;
																rd_en2 <= 1'b0;
																outresult2[31:0] <= 32'b0;
																rd2l[4:0] <= 5'b0;
																rd2p[5:0] <= 6'b0;
																memwen2 <= 1'b0;
																sbnum2c[2:0] <= 3'b0;

																rnum = 6'b0;
																rp_r = rp_r + rnum[5:0];
																counter = counter - rnum + wnum;
															end

										//第一条指令完成。提交一条
										6'b1_x_x_0_x_x:		begin
																valid1 = 1'b1;
																outbr_type1[1:0] <= midoutbr_type1[1:0];
																outbr_right1 <=midoutbr_right1;
																outrdc1 <= midoutrdc1;
																outraddr1[31:0] <= midoutraddr1[31:0];
																outpc1[31:0] <= midoutpc1[31:0];
																rd_en1 <= midrd_en1;
																outresult1[31:0] <= midoutresult1[31:0];
																rd1l[4:0] <= midrd1l[4:0];
																rd1p[5:0] <= midrd1p[5:0];
																memwen1 <= midmemwen1;
																sbnum1c[2:0] <= midsbnum1c[2:0];

																valid2 = 1'b0;
																outbr_type2[1:0] <= 2'b00;
																outbr_right2 <=1'b1;
																outrdc2 <= 1'b0;
																outraddr2[31:0] <= 32'b0;
																outpc2[31:0] <= 32'b0;
																rd_en2 <= 1'b0;
																outresult2[31:0] <= 32'b0;
																rd2l[4:0] <= 5'b0;
																rd2p[5:0] <= 6'b0;
																memwen2 <= 1'b0;
																sbnum2c[2:0] <= 3'b0;

																rnum = 6'b1;

																if(rp_r <= 6'b111110)begin
																	rp_r = rp_r + rnum[5:0];
																end
																else	begin
																	rp_r <= 6'b000000;
																	//rp_r[6] <= ~rp_r[6];
																end

																counter = counter - rnum + wnum;
															end

										//两条指令完成第一条指令不是分支指令。提交两条
										6'b1_0_x_1_x_x:		begin
																//如果有多于一条的指令，则提交两条
																if(counter != 6'b000001)begin
																	valid1 = 1'b1;
																	outbr_type1[1:0] <= midoutbr_type1[1:0];
																	outbr_right1 <=midoutbr_right1;
																	outrdc1 <= midoutrdc1;
																	outraddr1[31:0] <= midoutraddr1[31:0];
																	outpc1[31:0] <= midoutpc1[31:0];
																	rd_en1 <= midrd_en1;
																	outresult1[31:0] <= midoutresult1[31:0];
																	rd1l[4:0] <= midrd1l[4:0];
																	rd1p[5:0] <= midrd1p[5:0];
																	memwen1 <= midmemwen1;
																	sbnum1c[2:0] <= midsbnum1c[2:0];

																	valid2 = 1'b1;
																	outbr_type2[1:0] <= midoutbr_type2[1:0];
																	outbr_right2 <= midoutbr_right2;
																	outrdc2 <= midoutrdc2;
																	outraddr2[31:0] <= midoutraddr2[31:0];
																	outpc2[31:0] <= midoutpc2[31:0];
																	rd_en2 <= midrd_en2;
																	outresult2[31:0] <= midoutresult2[31:0];
																	rd2l[4:0] <= midrd2l[4:0];
																	rd2p[5:0] <= midrd2p[5:0];
																	memwen2 <= midmemwen2;
																	sbnum2c[2:0] <= midsbnum2c[2:0];

																	rnum = 6'b10;

																	if(rp_r <= 6'b111101)begin
																		rp_r = rp_r + rnum[5:0];
																	end
																	else	begin
																		rp_r <= 6'b000000;
																		//rp_r[6] <= ~rp_r[6];
																	end

																	counter = counter - rnum + wnum;
																end
																//只有一条指令则提交一条
																else begin
																	valid1 = 1'b1;
																	outbr_type1[1:0] <= midoutbr_type1[1:0];
																	outbr_right1 <=midoutbr_right1;
																	outrdc1 <= midoutrdc1;
																	outraddr1[31:0] <= midoutraddr1[31:0];
																	outpc1[31:0] <= midoutpc1[31:0];
																	rd_en1 <= midrd_en1;
																	outresult1[31:0] <= midoutresult1[31:0];
																	rd1l[4:0] <= midrd1l[4:0];
																	rd1p[5:0] <= midrd1p[5:0];
																	memwen1 <= midmemwen1;
																	sbnum1c[2:0] <= midsbnum1c[2:0];

																	valid2 = 1'b0;
																	outbr_type2[1:0] <= 2'b00;
																	outbr_right2 <=1'b1;
																	outrdc2 <= 1'b0;
																	outraddr2[31:0] <= 32'b0;
																	outpc2[31:0] <= 32'b0;
																	rd_en2 <= 1'b0;
																	outresult2[31:0] <= 32'b0;
																	rd2l[4:0] <= 5'b0;
																	rd2p[5:0] <= 6'b0;
																	memwen2 <= 1'b0;
																	sbnum2c[2:0] <= 3'b0;

																	rnum = 6'b01;

																	if(rp_r <= 6'b111110)begin
																		rp_r = rp_r + rnum[5:0];
																	end
																	else	begin
																		rp_r <= 6'b000000;
																		//rp_r[6] <= ~rp_r[6];
																	end

																	counter = counter - rnum + wnum;
																end
															end

										//两条指令完成第一条指令是分支指令且预测错误。提交一条
										6'b1_1_0_1_x_x:		begin
																valid1 = 1'b1;
																outbr_type1[1:0] <= midoutbr_type1[1:0];
																outbr_right1 <=midoutbr_right1;
																outrdc1 <= midoutrdc1;
																outraddr1[31:0] <= midoutraddr1[31:0];
																outpc1[31:0] <= midoutpc1[31:0];
																rd_en1 <= midrd_en1;
																outresult1[31:0] <= midoutresult1[31:0];
																rd1l[4:0] <= midrd1l[4:0];
																rd1p[5:0] <= midrd1p[5:0];
																memwen1 <= midmemwen1;
																sbnum1c[2:0] <= midsbnum1c[2:0];

																valid2 = 1'b0;
																outbr_type2[1:0] <= 2'b00;
																outbr_right2 <=1'b1;
																outrdc2 <= 1'b0;
																outraddr2[31:0] <= 32'b0;
																outpc2[31:0] <= 32'b0;
																rd_en2 <= 1'b0;
																outresult2[31:0] <= 32'b0;
																rd2l[4:0] <= 5'b0;
																rd2p[5:0] <= 6'b0;
																memwen2 <= 1'b0;
																sbnum2c[2:0] <= 3'b0;

																rnum = 6'b01;

																if(rp_r <= 6'b111110)begin
																	rp_r = rp_r + rnum[5:0];
																end
																else	begin
																	rp_r <= 6'b000000;
																	//rp_r[6] <= ~rp_r[6];
																end

																counter = counter - rnum + wnum;
															end

										//两条指令完成第一条是分支指令且预测正确,第二条不是分支指令。提交两条
										6'b1_1_1_1_0_x:		begin
																//如果有多于一条的指令，则提交两条
																if(counter != 6'b000001)begin
																	valid1 = 1'b1;
																	outbr_type1[1:0] <= midoutbr_type1[1:0];
																	outbr_right1 <=midoutbr_right1;
																	outrdc1 <= midoutrdc1;
																	outraddr1[31:0] <= midoutraddr1[31:0];
																	outpc1[31:0] <= midoutpc1[31:0];
																	rd_en1 <= midrd_en1;
																	outresult1[31:0] <= midoutresult1[31:0];
																	rd1l[4:0] <= midrd1l[4:0];
																	rd1p[5:0] <= midrd1p[5:0];
																	memwen1 <= midmemwen1;
																	sbnum1c[2:0] <= midsbnum1c[2:0];

																	valid2 = 1'b1;
																	outbr_type2[1:0] <= midoutbr_type2[1:0];
																	outbr_right2 <= midoutbr_right2;
																	outrdc2 <= midoutrdc2;
																	outraddr2[31:0] <= midoutraddr2[31:0];
																	outpc2[31:0] <= midoutpc2[31:0];
																	rd_en2 <= midrd_en2;
																	outresult2[31:0] <= midoutresult2[31:0];
																	rd2l[4:0] <= midrd2l[4:0];
																	rd2p[5:0] <= midrd2p[5:0];
																	memwen2 <= midmemwen2;
																	sbnum2c[2:0] <= midsbnum2c[2:0];

																	rnum = 6'b10;

																	if(rp_r <= 6'b111101)begin
																		rp_r = rp_r + rnum[5:0];
																	end
																	else	begin
																		rp_r <= 6'b000000;
																		//rp_r[6] <= ~rp_r[6];
																	end

																	counter = counter - rnum + wnum;
																end
																//只有一条指令则提交一条
																else begin
																	valid1 = 1'b1;
																	outbr_type1[1:0] <= midoutbr_type1[1:0];
																	outbr_right1 <=midoutbr_right1;
																	outrdc1 <= midoutrdc1;
																	outraddr1[31:0] <= midoutraddr1[31:0];
																	outpc1[31:0] <= midoutpc1[31:0];
																	rd_en1 <= midrd_en1;
																	outresult1[31:0] <= midoutresult1[31:0];
																	rd1l[4:0] <= midrd1l[4:0];
																	rd1p[5:0] <= midrd1p[5:0];
																	memwen1 <= midmemwen1;
																	sbnum1c[2:0] <= midsbnum1c[2:0];

																	valid2 = 1'b0;
																	outbr_type2[1:0] <= 2'b00;
																	outbr_right2 <=1'b1;
																	outrdc2 <= 1'b0;
																	outraddr2[31:0] <= 32'b0;
																	outpc2[31:0] <= 32'b0;
																	rd_en2 <= 1'b0;
																	outresult2[31:0] <= 32'b0;
																	rd2l[4:0] <= 5'b0;
																	rd2p[5:0] <= 6'b0;
																	memwen2 <= 1'b0;
																	sbnum2c[2:0] <= 3'b0;

																	rnum = 6'b01;

																	if(rp_r <= 6'b111110)begin
																		rp_r = rp_r + rnum[5:0];
																	end
																	else begin
																		rp_r <= 6'b000000;
																		//rp_r[6] <= ~rp_r[6];
																	end

																	counter = counter - rnum + wnum;
																end
															end

										//两条指令完成第一条是分支指令且预测正确,第二条是分支指令。提交一条
										6'b1_1_1_1_1_x:		begin
																		valid1 = 1'b1;
																		outbr_type1[1:0] <= midoutbr_type1[1:0];
																		outbr_right1 <=midoutbr_right1;
																		outrdc1 <= midoutrdc1;
																		outraddr1[31:0] <= midoutraddr1[31:0];
																		outpc1[31:0] <= midoutpc1[31:0];
																		rd_en1 <= midrd_en1;
																		outresult1[31:0] <= midoutresult1[31:0];
																		rd1l[4:0] <= midrd1l[4:0];
																		rd1p[5:0] <= midrd1p[5:0];
																		memwen1 <= midmemwen1;
																		sbnum1c[2:0] <= midsbnum1c[2:0];

																		valid2 = 1'b0;
																		outbr_type2[1:0] <= 2'b00;
																		outbr_right2 <=1'b1;
																		outrdc2 <= 1'b0;
																		outraddr2[31:0] <= 32'b0;
																		outpc2[31:0] <= 32'b0;
																		rd_en2 <= 1'b0;
																		outresult2[31:0] <= 32'b0;
																		rd2l[4:0] <= 5'b0;
																		rd2p[5:0] <= 6'b0;
																		memwen2 <= 1'b0;
																		sbnum2c[2:0] <= 3'b0;

																		rnum = 6'b01;

																		if(rp_r <= 6'b111110)begin
																			rp_r = rp_r + rnum[5:0];
																		end
																		else	begin
																			rp_r <= 6'b000000;
																			//rp_r[6] <= ~rp_r[6];
																		end

																		counter = counter - rnum + wnum;
																end

										default				begin
																valid1 = 1'b0;
																outbr_type1[1:0] <= 2'b00;
																outbr_right1 <=1'b1;
																outrdc1 <= 1'b0;
																outraddr1[31:0] <= 32'b0;
																outpc1[31:0] <= 32'b0;
																rd_en1 <= 1'b0;
																outresult1[31:0] <= 32'b0;
																rd1l[4:0] <= 5'b0;
																rd1p[5:0] <= 6'b0;
																memwen1 <= 1'b0;
																sbnum1c[2:0] <= 3'b0;

																valid2 = 1'b0;
																outbr_type2[1:0] <= 2'b00;
																outbr_right2 <=1'b1;
																outrdc2 <= 1'b0;
																outraddr2[31:0] <= 32'b0;
																outpc2[31:0] <= 32'b0;
																rd_en2 <= 1'b0;
																outresult2[31:0] <= 32'b0;
																rd2l[4:0] <= 5'b0;
																rd2p[5:0] <= 6'b0;
																memwen2 <= 1'b0;
																sbnum2c[2:0] <= 3'b0;

																rnum = 6'b00;
																rp_r = rp_r + rnum[5:0];
																counter = counter - rnum + wnum;
															end
												
									endcase
								end
								
								//读空状态
								else begin
									outempty <= empty;
									valid1 = 1'b0;
									outbr_type1[1:0] <= 2'b00;
									outbr_right1 <=1'b1;
									outrdc1 <= 1'b0;
									outraddr1[31:0] <= 32'b0;
									outpc1[31:0] <= 32'b0;
									rd_en1 <= 1'b0;
									outresult1[31:0] <= 32'b0;
									rd1l[4:0] <= 5'b0;
									rd1p[5:0] <= 6'b0;
									memwen1 <= 1'b0;
									sbnum1c[2:0] <= 3'b0;

									valid2 = 1'b0;
									outbr_type2[1:0] <= 2'b00;
									outbr_right2 <=1'b1;
									outrdc2 <= 1'b0;
									outraddr2[31:0] <= 32'b0;
									outpc2[31:0] <= 32'b0;
									rd_en2 <= 1'b0;
									outresult2[31:0] <= 32'b0;
									rd2l[4:0] <= 5'b0;
									rd2p[5:0] <= 6'b0;
									memwen2 <= 1'b0;
									sbnum2c[2:0] <= 3'b0;

									rnum = 6'b0;
									rp_r = rp_r + rnum[5:0];
									counter = counter - rnum + wnum;
								end
								//RNR
								/*
									if (!valid1rn) begin
										inum1[5:0] <= 6'bx;
										inum2[5:0] <= 6'bx;
									end
									else if (valid1rn & !valid2rn) begin
										inum1[5:0] <= wp_r;
										inum2[5:0] <= 6'bx;
									end
									else begin
										inum1[5:0] <= wp_r;
										inum2[5:0] <= wp_r + 1;
									end
								*/

								//RR
								if (!valid1rn) begin
									outcomplete1 <= 1'bx;
									outcomplete2 <= 1'bx;
								end
								else if (valid1rn & !valid2rn) begin
									outcomplete1 <= midcomplete1;
									outcomplete2 <= 1'bx;
								end
								else begin
									outcomplete1 <= midcomplete1;
									outcomplete2 <= midcomplete2;
								end
							end	
					end
/***********************************************************************************************************/
endmodule
