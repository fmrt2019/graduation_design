/**************************************************************

Filename: bru.v
Designer: Dragon
Create date: 2023.3.28
Modification date: 2023.3.28
Reason for modification: Function validation error
Description: Shift Branch computing unit.
Note:1 represents a branch jump;
	:1 represents correct branch prediction 

***************************************************************/

module		bru  (
					  //input				[5:0]				//ROB编号
					  input				[31:0] a,b,				//两个操作数，b-type的比较数，jalr的计算数
					  input				[2:0]	control,		//控制信号
					  input				pre_direction,			//预测方向
					  input				[31:0]pre_addr,			//b-type的跳转地址/jalr的预测地址
					  
					  output			pre_right,				//预测是否正确	
					  output	reg	b_type,					//是否是b-type类型指令
					  output	reg	real_direction,			//真正的方向
					  output			[31:0]	addr 			//真正的地址
					  );

					 //reg	real_direction;		//真正的跳转方向，跳转为1

					 wire	sign_greater,sign_less;									//有符号的大于等于、小于的判断值

					 wire	[31:0]addr_real_jalr;									//jalr的真正跳转地址
					 wire	addr_jalr_right;										//jalr地址是否预测正确，1代表预测正确

					 reg	addr_right;												//B-type的地址预测是否正确，在这里假设
					 wire	addr_rightall;											//分支预测地址正确	

					 
					 sless 	sl1	(a,b,sign_less);							//有符号的小于的判断值计算
					 assign sign_greater = ~sign_less;								//有符号的大于等于的判断值计算

					 assign addr_real_jalr = (a + b) & 32'hfffe;					//jalr的真正地址计算
					 assign addr_jalr_right = ((addr_real_jalr ^ pre_addr) == 0) ? 1'b1:1'b0;			//jalr的地址预测正确与否
					 
					 always @(*)	begin
					 	case(control)
					 	3'b000:		begin													//beq
											real_direction = (a == b);
											b_type = 1;
											addr_right = 1;
										end
											
					 	3'b001:		begin													//bne
											real_direction = (a != b);
											b_type = 1;
											addr_right = 1;
										end
											
					 	3'b010:		begin													//jalr
											real_direction = 1'b1;
											b_type = 0;
											addr_right = 1;
										end
											
					 	//3'b011:
					 	3'b100:		begin													//blt
											real_direction = sign_less;
											b_type = 1;
											addr_right = 1;
										end
											
					 	3'b101:		begin													//bge
											real_direction = (sign_greater);
											b_type = 1;
											addr_right = 1;
										end
										
					 	3'b110:		begin													//bltu
											real_direction = (a < b);
											b_type = 1;
											addr_right = 1;
										end
										
					 	3'b111:		begin													//bgeu
											real_direction = (a >= b);
											b_type = 1;
											addr_right = 1;
										end
										
					 	default		begin
											real_direction = 1'bx;
											b_type = 1;
											addr_right = 1;
										end
						endcase
					end

					 assign direction_right =  ~ (real_direction ^ pre_direction);							//1代表方向预测正确
					 assign addr_rightall = (control==3'b010) ? addr_jalr_right : addr_right;				//1代表地址预测正确
					 assign pre_right = direction_right & addr_rightall;									//1代表分支预测正确
					 assign addr = (b_type) ? pre_addr : addr_real_jalr;									//b-type和jalr的地址选择

endmodule

module  sless		(
						input		[31:0] a,b,
						output	reg c
						);

					 always @(*)	begin
					 	if (a[31] == 1 && b[31] == 0)       //a为负，b为正
                        		c = 1;
                  		else if(a[31] == 0 && b[31] == 1)   //a为正，b为负
                       			c = 0;
                  		else if(a[31] == 0 && b[31] == 0)   //a,b都为正和无符号比较一样
                        		c = (a < b)? 1'b1:1'b0;
                  		else                                //a,b均为负和无符号比较一样
                        		c = (a < b)? 1'b1:1'b0;
                     end
endmodule