/*****************************************************************************
Filename:datapath.v
Designer:FMRT2019
Create date:2023.04.14 11:18
Description:overall datapath.
*******************************************************************************/
module datapath ();
  
  
  
  
  
  
  decode_stage decode (
		clk,reset,
//first input
		instr_dec_1,pc_dec_1,pre_direction_dec_1,pre_pc_dec_1,instr_is_compressdec_1,
//first output	
		rs_write_dec_1,rs1_read_dec_1,ri2_dec_1,rd_write_dec_1,st_dec_1,dectect_first_result_dec_1,rs_num_dec_1,br_type_dec_1,rs_ctrl_dec_1,
		rs1_dec_1,rs2_dec_1,rd_dec_1,ld_st_num_dec_1imm_dec_1,next_pc_dec_1,rs_bru_pc_dec_1,
//second input
		instr_dec_2,pc_dec_2,pre_direction_dec_2,pre_pc_dec_2,instr_is_compressdec_2,
//second output
		rs_write_dec_2,rs1_read_dec_2,ri2_dec_2,rd_write_dec_2,st_dec_2,dectect_first_result_dec_2,rs_num_dec_2,br_type_dec_2,rs_ctrl_dec_2,
		rs1_dec_2,rs2_dec_2,rd_dec_2,ld_st_num_dec_2,imm_dec_2,next_pc_dec_2,rs_bru_pc_dec_2
	);

	flopren decode_rename_reg (330)(
		clk1,reset,en,
//information of first insrtuction
		{pc_dec_1,pre_direction_dec_1,
		 rs_write_dec_1,rs1_read_dec_1,ri2_dec_1,rd_write_dec_1,st_dec_1,dectect_first_result_dec_1,rs_num_dec_1,br_type_dec_1,rs_ctrl_dec_1,
		 rs1_dec_1,rs2_dec_1,rd_dec_1,ld_st_num_dec_1,imm_dec_1,next_pc_dec_1,rs_bru_pc_dec_1,
		 is_split_dec_1,instr_valid_de_1},
//information second instruction
		{pc_rnr_2,pre_direction_rnr_2,
		 rs_write_rnr_2,rs1_read_rnr_2,ri2_rnr_2,rd_write_rnr_2,st_rnr_2,rnrtect_first_result_rnr_2,rs_num_rnr_2,br_type_rnr_2,rs_ctrl_rnr_2,
		 rs1_rnr_2,rs2_rnr_2,rd_rnr_2,ld_st_num_rnr_2,imm_rnr_2,next_pc_rnr_2,rs_bru_pc_rnr_2,
		 is_split_rnr_2,instr_valid_rnr_2}
	);
/*
	dispath_stage dispath (
		


	)
	
	EX_WB_reg	ex_wb_reg(clk,rst,stall,recover,aluoute,alurde,aluen,sfuoute,sfurde,sfuen,pre_righte,b_typee,real_directione,addre,brurde,bruen,aguoute,agurde,
				  aguen,aluoutw,alurdw,	aluenw,	sfuoutw,sfurdw,	sfuenw,	pre_rightw,b_typew,real_directionw,addrw,brurdw,bruenw,aguoutw,agurdw,aguenw);











	reserved_stations alu_rs #(4,16,35,32)
	reserved_stations sfu_rs #(3,8,7,5)
	reserved_stations bru_rs #(3,8,68,32)
	agu_reserved_station agu_rs #(3,8,74,32)
*/
endmodule
