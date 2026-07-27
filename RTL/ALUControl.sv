module ALUControl(
    input logic [2:0] ALUOp_i,
    input logic [2:0] funct3_i,
    input logic funct7_5_i, // nối với bit [30] của ins
    output logic [3:0] alu_ctrl_o
);
always_comb begin
    alu_ctrl_o = 4'b0010; // mặc định là phép cộng
    case (ALUOp_i)
    3'b000: alu_ctrl_o = 4'b0010;
    3'b001: alu_ctrl_o = 4'b0110; // branch phép trừ
    3'b100: alu_ctrl_o = 4'b1001; // Xuất mã 1001 để MUX chọn ngõ PASS_B_i
    3'b101: alu_ctrl_o = 4'b1111; // cờ zero
    3'b010, 3'b011: begin // nhóm R format (010) nhóm I format (011)
        case (funct3_i)
        3'b000: begin
            if (ALUOp_i == 3'b010 && funct7_5_i== 1'b1) begin
                alu_ctrl_o = 4'b0110; // phép trừ
            end else begin
                alu_ctrl_o = 4'b0010; // phép cộng
            end
        end
        3'b111: alu_ctrl_o = 4'b0000; // AND
        3'b110: alu_ctrl_o = 4'b0001; // OR
        3'b001: alu_ctrl_o = 4'b0101; // SLL
        3'b010: alu_ctrl_o = 4'b1000; // SLT
        3'b100: alu_ctrl_o = 4'b0100; // XOR
        3'b101: begin
            if (funct7_5_i == 1'b1)
                alu_ctrl_o = 4'b0111; // SRA, srai
             else
                alu_ctrl_o = 4'b0011; // SRL, srli
             end
        default: alu_ctrl_o = 4'b0010;
        endcase
    end
    endcase
end
endmodule
