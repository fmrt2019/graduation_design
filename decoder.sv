/*###########################################################################################
#File name: decoder.sv
#Description: The module of decoder.
#Author:Yanglirong
#Time: 2023-3-29 21：00 
###########################################################################################*/
module decoder (
	input pre_direction,
	input [31:0] instr,pc,pre_pc,						
	output [4:0] rs1,rs2,rd,					//寄存器编号
	output [31:0] imm_de,rs_bru_pc,				//立即数
	output [3:0] ctrl,							//FU的控制信号,保存在保留站中
	output [1:0] rs_num,br_type,				//rs_num保留站的编号,00:ALU  01:SFU  10:BRU 11:AGU
												//br_type分支类型,00:非BR,JAL,JALR指令  01:CALL  10:RETURN  11:BR,无条件的跳转
	output	rs1_read,ri2,rdwrite,st,			//rs1_read:0:寄存器数 1:立即数 
												//rdwrite:0:无目的寄存器 1:有目的寄存器 
												//st:0:非store指令 1:store指令							
	output rs_write,detect_first_result
);

	wire [2:0] funct3 = instr[14:12];
	wire [31:0] imm_i,imm_s,imm_b,imm_u,imm_j,imm_pc_pre,imm_add_pc;
	wire op_4_2_000,op_4_2_001,op_4_2_011,op_4_2_100,op_4_2_101,
		 op_6_5_00,op_6_5_01,op_6_5_11,
		 imm_i_0,
		 rd_x0,rd_x1,
		 rs1_x1,
		 funct3_000,funct3_13_12_01,
		 j,pc_if_detect,detect_pc;							//是否是JAL或JALR指令，1是，0不是

	assign rs1 = instr[19:15];
	assign rs2 = instr[24:20];
	assign rd  = instr[11:7];
	assign imm_i = {{20{instr[31]}},instr[31:20]};
	assign imm_s = {{20{instr[31]}},instr[31:25],instr[11:8],instr[7]};
	assign imm_b = {{20{instr[31]}},instr[7],instr[11:8],1'b0};
	assign imm_u = {instr[31:12],12'b0};
	assign imm_j = {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};
	assign op_4_2_100 = (instr[4:2] == 3'b100);		//alu
	assign op_4_2_000 = (instr[4:2] == 3'b000);		//br,sw,ld
	assign op_4_2_001 = (instr[4:2] == 3'b001);		//jalr
	assign op_4_2_011 = (instr[4:2] == 3'b011);		//jal
	assign op_4_2_101 = (instr[4:2] == 3'b101);		//lui,auipc
	assign op_6_5_00  = (instr[6:5] == 2'b00) ;		//load,addi,auipc
	assign op_6_5_01  = (instr[6:5] == 2'b01) ;		//add,sw
//  assign op_6_5_10  = (instr[6:5] == 2'b10) ;		
	assign op_6_5_11  = (instr[6:5] == 2'b11) ;		//jal,br,trap
	assign funct3_13_12_01 = (instr[13:12] == 2'b01);
	assign funct3_000 = (funct3 == 2'b000);
	assign rd_x0 = (rd == 5'b00000);
	assign rd_x1 = (rd == 5'b00001);
	assign rs1_x1 = (rs1 == 5'b00001);
	assign imm_i_0 = (imm_i == 0);
	assign imm_pc_pre = instr[3] ? imm_j : (instr[2] ? imm_u : imm_b);
	assign imm_add_pc = imm_pc_pre + pc;
/*------------------------------------------detect_first------------------------------------*/
	assign pc_if_detect = j ^ rs_write;
	assign detect_pc = (pc_if_detect ? (pre_pc == imm_add_pc) : 1'b1);			//jal地址的判断，br跳转地址的判断
	assign detect_first_result = (pre_direction ? detect_pc : (j ? 1'b0 : 1'b1));		//0预测错误，1预测正确	
	always @ (*) begin
		if (op_4_2_101 & op_6_5_01) begin				//LUI
			rs1_read = 1'b1;
			ri2 = 1'b1;
			rdwrite = 1'b1;
			st = 1'b0;
			br_type = 2'b00;
			imm_de = imm_u;
			rs_write = 1'b0;
			j =1'b0;
			ctrl = 4'bxxxx;
			rs_num = 2'b00;
			rs_bru_pc = pre_pc;
		end
		else if (op_4_2_101 & op_6_5_00) begin			//AUIPC
			rs1_read = 1'b1;
			ri2 = 1'b1;
			rdwrite = 1'b1;
			st = 1'b0;
			br_type = 2'b00;
			imm_de = imm_add_pc;
			rs_write = 1'b0;
			j =1'b0;
			ctrl = 4'bxxxx;
			rs_num = 2'b00;
			rs_bru_pc = pre_pc;
		end
/*-------------------------------------------ALU or SFU-------------------------------------------*/
		else if (op_4_2_100 & op_6_5_01) begin		//alu,sfu(r)
			rs1_read = 1'b0;
			ri2 = 1'b0;
			rdwrite = 1'b1;
			st = 1'b0;
			br_type = 2'b00;
			rs_write = 1'b1;
			j = 1'b0;
			imm_de = {32'bx};
			rs_bru_pc = pre_pc;
			if (!funct3_13_12_01) begin				//alu(r)
				rs_num = 2'b00;
				if (funct3_000 & instr[30])							//sub
					ctrl = {3'b0,instr[30]};		
				else	
					ctrl = {1'b0,funct3};							//add,slt,sltu,xor,or,and
			end
			else begin
				rs_num = 2'b01;
				ctrl = {instr[30],funct3};			//sfu(r)
			end
		end
		else if (op_4_2_100 & op_6_5_00) begin		//alu,sfu(i)
			rs1_read = 1'b0;
			ri2 = 1'b1;
			rdwrite = 1'b1;
			st = 1'b0;
			br_type = 2'b00;
			imm_de = imm_i;
			rs_write = 1'b1;
			j = 1'b0;
			rs_bru_pc = pre_pc;
			if (!funct3_13_12_01) begin				//alu(i)
				rs_num = 2'b00;
				ctrl = {1'b0,funct3};							//add,slt,sltu,xor,or,and
			end
			else begin
				rs_num = 2'b01;
				ctrl = {instr[30],funct3};			//sfu(i)
			end
		end
/*-------------------------------------------BR or J-------------------------------------------*/
		else if (op_4_2_000 & op_6_5_11) begin		//br
			rs1_read = 1'b0;
			ri2 = 1'b0;
			rdwrite = 1'b0;
			st = 1'b0;
			rs_num = 2'b10;
			rs_bru_pc = imm_add_pc;
			br_type = 2'b11;
			ctrl = {1'b0,funct3};
			imm_de = imm_add_pc;							//跳转的pc
			rs_write = 1'b1;
			j = 1'b0;
		end
		else if (op_4_2_001 & op_6_5_11) begin		//jalr
			rs1_read = 1'b0;
			ri2 = 1'b1;
			st = 1'b0;
			rs_num = 2'b10;
			ctrl = 4'b0010;
			rs_bru_pc = pre_pc;
			imm_de = imm_i;
			rs_write = 1'b1;
			j = 1'b1;
			rdwrite = 1'b0;
			if(rd_x0) begin
				if(imm_i_0 & rs1_x1)
					br_type = 2'b10;				//return
				else 
					br_type = 2'b11;
			end
			else if(rd_x1) begin
				br_type = 2'b01;					//call
			end
			else begin								//jump
				br_type = 2'b11;
			end
		end
		else if(op_4_2_011 & op_6_5_11) begin		//jal
			rs1_read = 1'b1;
			ri2 = 1'b1;
			st = 1'b0;
			rs_num = 2'b11;
			rs_bru_pc = pre_pc;
			ctrl = 4'bxxxx;
			imm_de = imm_add_pc;
			rs_write = 1'b0;
			j = 1'b1;
			rdwrite = 1'b1;
			if(rd_x1) begin
				br_type = 2'b01;					//call
			end
			else begin
				br_type = 2'b11;					//jump
			end
		end
/*-------------------------------------------end BRU-------------------------------------------*/

/*-------------------------------------------AGU-------------------------------------------*/
		else if (op_4_2_000 & op_6_5_00) begin		//AGU_ld
			rs1_read = 1'b0;
			ri2 = 1'b1;
			rdwrite = 1'b1;
			br_type = 2'b00;
			st = 1'b0;
			rs_num = 2'b11;
			rs_bru_pc = pre_pc;
			imm_de = imm_i;
			ctrl = {1'b0,funct3};
			rs_write = 1'b1;
			j = 1'b0;
		end
		else if (op_4_2_000 & op_6_5_01) begin		//AGU_st
			rs1_read = 1'b0;
			ri2 = 1'b0;
			rdwrite = 1'b0;
			br_type =2'b00;
			st = 1'b1;
			rs_num = 2'b11;
			rs_bru_pc = pre_pc;
			imm_de = imm_s;
			ctrl = {1'b1,funct3};
			rs_write = 1'b1;
			j = 1'b0;
		end
/*-------------------------------------------end-------------------------------------------*/
		else begin 
		    rs1_read = 1'b0;
			ri2 = 1'b0;
			rdwrite = 1'b0;
			br_type =2'b00;
			st = 1'b0;
			rs_num = 2'bxx;
			rs_bru_pc = pre_pc;
			imm_de = {32'bx};
			ctrl = 4'bxxxx;
			rs_write = 1'b0;
			j = 1'b0;
		end
	end
endmodule