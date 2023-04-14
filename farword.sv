module farword (
	input [5:0] alu_rob_num_wb,sfu_rob_num_wb,agu_rob_num_wb,
				rrs1_num_dis_1,rrs2_num_dis_1,
				rrs1_num_dis_2,rrs2_num_dis_2,

	output [1:0] rs1_farword_dis_1,rs2_farword_dis_1,
				 rs1_farword_dis_2,rs2_farword_dis_2,

	
);

	assign rs1_farword_1 = {(rrs1_num_dis_1 == agu_rob_num_wb),
						    (rrs1_num_dis_1 == sfu_rob_num_wb),
						    (rrs1_num_dis_1 == alu_rob_num_wb)};  //是否存在错误就绪的信号，因为有的没有目的寄存器。（感觉不会错误就绪）
	assign rs2_farword_1 = {(rrs2_num_dis_1 == agu_rob_num_wb),
						    (rrs2_num_dis_1 == sfu_rob_num_wb),
						    (rrs2_num_dis_1 == alu_rob_num_wb)};
	assign rs1_farword_2 = {(rrs1_num_dis_1 == agu_rob_num_wb),
						    (rrs1_num_dis_1 == sfu_rob_num_wb),
						    (rrs1_num_dis_1 == alu_rob_num_wb)};  //是否存在错误就绪的信号，因为有的没有目的寄存器。（感觉不会错误就绪）
	assign rs2_farword_2 = {(rrs2_num_dis_1 == agu_rob_num_wb),
						    (rrs2_num_dis_1 == sfu_rob_num_wb),
						    (rrs2_num_dis_1 == alu_rob_num_wb)};

	always @ (*) begin
		case (rs1_farword_1)
			3'b000 : rs1_farword_dis_1 = 2'b00;
			3'b001 : rs1_farword_dis_1 = 2'b01;	//alu
			3'b010 : rs1_farword_dis_1 = 2'b10;	//sfu
			3'b100 : rs1_farword_dis_1 = 2'b11;	//agu
			default : begin 
				rs1_farword_dis_1 = 2'bxx;
				$display("one instruction more reserved station");
			end
		endcase
		case (rs2_farword_1)
			3'b000 : rs2_farword_dis_1 = 2'b00;
			3'b001 : rs2_farword_dis_1 = 2'b01;	//alu
			3'b010 : rs2_farword_dis_1 = 2'b10;	//sfu
			3'b100 : rs2_farword_dis_1 = 2'b11;	//agu
			default : begin
				rs2_farword_dis_1 = 2'bxx;
				$display("one instruction more reserved station");
			end
		endcase
		case (rs1_farword_2)
			3'b000 : rs1_farword_dis_2 = 2'b00;
			3'b001 : rs1_farword_dis_2 = 2'b01;	//alu
			3'b010 : rs1_farword_dis_2 = 2'b10;	//sfu
			3'b100 : rs1_farword_dis_2 = 2'b11;	//agu
			default : begin 
				rs1_farword_dis_2 = 2'bxx;
				$display("one instruction more reserved station");
			end
		endcase
		case (rs2_farword_2)
			3'b000 : rs2_farword_dis_2 = 2'b00;
			3'b001 : rs2_farword_dis_2 = 2'b01;	//alu
			3'b010 : rs2_farword_dis_2 = 2'b10;	//sfu
			3'b100 : rs2_farword_dis_2 = 2'b11;	//agu
			default : begin
				rs2_farword_dis_2 = 2'bxx;
				$display("one instruction more reserved station");
			end
		endcase
	end
endmodule