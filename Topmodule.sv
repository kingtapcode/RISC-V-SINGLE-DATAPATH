module RISCV_core(
    input logic clk_i,
    input logic rst_ni,
    input  logic [31:0] switch_i,
    output logic [31:0] red_led_o,
    output logic [31:0] green_led_o
);
// I. Khai báo dây nối
// a. Nhóm PC và IMEM
logic [63:0] pc_wire, pc_next_wire, pc_plus_4_wire, pc_offset_wire;
logic [31:0] instr_wire;
logic [1:0] pc_sel_wire;
// b. Khối Control Unit
logic reg_write_en_wire, ALUSrc_wire, branch_wire, jal_wire, jalr_wire;
logic ctrl_read_en_wire, ctrl_write_en_wire;
logic [1:0] MemtoReg_wire;
logic [2:0] ALUOp_wire;
// c. Khối RegFile và ImmGen
logic [63:0] rs1_data_wire, rs2_data_wire;
logic [63:0] rd_data_wire;
logic [63:0] imm_gen_wire;
// d. Khối ALU (ALUcontrol, Mux ALU, ALU)
logic [63:0] mux_alu_wire;
logic [3:0] alu_ctrl_wire;
logic [63:0] alu_result_wire;
logic alu_zero_wire;
// e. Khối LSU 
logic [7:0] byte_mask_wire;
logic [63:0] wdata_aligned_wire;
logic [63:0] rdata_wire;
// f. Khối Address Decoder
logic [63:0] rdata_raw_wire;
logic mem_read_en_wire, mem_write_en_wire;
logic red_led_write_en_wire, green_led_write_en_wire;
logic switch_read_en_wire;
// g. Khối Dmem
logic [63:0] read_dmem_wire;
// II. Gọi module
ProgramCounter pc_inst(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .pc_next_i(pc_next_wire),
    .pc_o(pc_wire)
);
PC_adder plus_4(
    .a_i(pc_wire),
    .b_i(64'd4),
    .sum_o(pc_plus_4_wire)
);
PC_adder plus_offset(
    .a_i(pc_wire),
    .b_i(imm_gen_wire),
    .sum_o(pc_offset_wire)
);
IMEM imem_inst(
    .pc_i(pc_wire),
    .instr_o(instr_wire)
);
ControlUnit control_unit_inst(
    .opcode_i(instr_wire[6:0]),
    .reg_write_en_o(reg_write_en_wire),
    .ALUSrc_o(ALUSrc_wire),
    .ALUOp_o(ALUOp_wire),
    .ctrl_write_en_o(ctrl_write_en_wire),
    .ctrl_read_en_o(ctrl_read_en_wire),
    .MemtoReg_o(MemtoReg_wire),
    .branch_o(branch_wire),
    .jal_o(jal_wire),
    .jalr_o(jalr_wire)
);
RegFile regfile_inst(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .reg_write_en_i(reg_write_en_wire),
    .rs1_addr_i(instr_wire[19:15]),
    .rs1_data_o(rs1_data_wire),
    .rs2_addr_i(instr_wire[24:20]),
    .rs2_data_o(rs2_data_wire),
    .rd_addr_i(instr_wire[11:7]),
    .rd_data_i(rd_data_wire)
);
ImmGen32_64 imm_gen_instr(
    .instr_i(instr_wire),
    .imm_o(imm_gen_wire)
);
Mux_ALUSrc mux_alu_instr(
    .rs2_data_i(rs2_data_wire),
    .imm_i(imm_gen_wire),
    .ALUSrc_i(ALUSrc_wire),
    .out_o(mux_alu_wire)
);
ALUControl alu_control_instr(
    .ALUOp_i(ALUOp_wire),
    .funct3_i(instr_wire[14:12]),
    .funct7_5_i(instr_wire[30]),
    .alu_ctrl_o(alu_ctrl_wire)
);
ALU_64bit alu_instr(
    .a_i(rs1_data_wire),
    .b_i(mux_alu_wire),
    .alu_ctrl_i(alu_ctrl_wire),
    .alu_zero_o(alu_zero_wire),
    .alu_overflow_o(),
    .alu_result_o(alu_result_wire)
);
LSU lsu_instr(
    .ctrl_write_en_i(ctrl_write_en_wire),
    .ctrl_read_en_i(ctrl_read_en_wire),
    .addr_i(alu_result_wire),
    .funct3_i(instr_wire[14:12]),
    .rdata_raw_i(rdata_raw_wire),
    .wdata_i(rs2_data_wire),
    .byte_mask_o(byte_mask_wire),
    .wdata_aligned_o(wdata_aligned_wire),
    .rdata_o(rdata_wire)
);
Address_Decoder address_decoder_instr(
    .ctrl_write_en_i(ctrl_write_en_wire),
    .ctrl_read_en_i(ctrl_read_en_wire),
    .addr_i(alu_result_wire),
    .rdmem_i(read_dmem_wire),
    .rswitch_i({32'b0, switch_i}),
    .rdata_raw_o(rdata_raw_wire),
    .mem_read_en_o(mem_read_en_wire),
    .mem_write_en_o(mem_write_en_wire),
    .red_led_write_en_o(red_led_write_en_wire),
    .green_led_write_en_o(green_led_write_en_wire),
    .switch_read_en_o(switch_read_en_wire)
);
Dmem dmem_instr(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .mem_write_en_i(mem_write_en_wire),
    .mem_read_en_i(mem_read_en_wire),
    .addr_i(alu_result_wire),
    .wdata_i(wdata_aligned_wire),
    .byte_mask_i(byte_mask_wire),
    .rdata_o(read_dmem_wire)
);
Mux_MemtoReg mux_memtoReg_instr(
    .alu_result_i(alu_result_wire),
    .lsu_rdata_i(rdata_wire),
    .pc_4_i(pc_plus_4_wire),
    .MemtoReg_i(MemtoReg_wire),
    .out_o(rd_data_wire)
);
PCsel pc_sel_instr(
    .branch_i(branch_wire),
    .jal_i(jal_wire),
    .jalr_i(jalr_wire),
    .zero_i(alu_zero_wire),
    .pc_sel_o(pc_sel_wire)
);
PCMux3_1 pc_mux_instr(
    .pc_plus_4_i(pc_plus_4_wire),
    .pc_offset_i(pc_offset_wire),
    .alu_result_i(alu_result_wire),
    .pc_sel_i(pc_sel_wire),
    .pc_next_o(pc_next_wire)
);
//III. Ngoại vi
//1. Red Led
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        red_led_o <= 32'b0; // Đổi thành 32 bit 0
    end else if (red_led_write_en_wire) begin
        // Chỉ trích xuất 32 bit thấp (từ bit 0 đến 31) của CPU để ghi ra LED
        red_led_o <= rs2_data_wire[31:0]; 
    end
end
aalways_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        green_led_o <= 32'b0;
    end else if (green_led_write_en_wire) begin
        green_led_o <= rs2_data_wire[31:0];
    end
end
endmodule




