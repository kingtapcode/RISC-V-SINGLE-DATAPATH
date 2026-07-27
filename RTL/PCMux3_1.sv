module PCMux3_1(
    input logic [63:0] pc_plus_4_i,  // Nhận từ mạch cộng PC + 4 (pc_sel = 00)
    input logic [63:0] pc_offset_i,  // Nhận từ mạch cộng PC + imm (pc_sel = 01)
    input logic [63:0] alu_result_i, // Nhận từ ngõ ra ALU (pc_sel = 10)
    input logic [1:0] pc_sel_i,      // Nối với pc_sel_o của khối PCsel
    output logic [63:0] pc_next_o
);
    always_comb begin
        case (pc_sel_i)
            2'b00: pc_next_o = pc_plus_4_i;
            2'b01: pc_next_o = pc_offset_i;
            2'b10: begin
                // Chuẩn RISC-V yêu cầu lệnh JALR phải ép bit LSB về 0
                pc_next_o = {alu_result_i[63:1], 1'b0}; 
            end
            default: pc_next_o = pc_plus_4_i; // Mặc định an toàn
        endcase
    end
endmodule
