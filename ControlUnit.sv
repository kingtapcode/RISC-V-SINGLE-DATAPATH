module ControlUnit(
    input logic [6:0] opcode_i,
    output logic reg_write_en_o,
    output logic ALUSrc_o,
    output logic ctrl_write_en_o,
    output logic ctrl_read_en_o,
    output logic [2:0] ALUOp_o,
    output logic [1:0] MemtoReg_o,
    output logic branch_o,
    output logic jal_o,
    output logic jalr_o
);
always_comb begin
    reg_write_en_o = 1'b0;
    ALUSrc_o = 1'b0;
    ctrl_write_en_o = 1'b0;
    ctrl_read_en_o = 1'b0;
    ALUOp_o = 3'b000;
    MemtoReg_o = 2'b00;
    branch_o = 1'b0;
    jal_o = 1'b0;
    jalr_o = 1'b0;
    case (opcode_i)
         7'b0110011: begin //R format
            reg_write_en_o = 1'b1;
            ALUOp_o = 3'b010;
         end
        7'b0000011: begin // load
            ALUSrc_o = 1'b1;
            MemtoReg_o = 2'b01; // chọn kênh lấy data từ dmem
            reg_write_en_o = 1'b1;
            ctrl_read_en_o = 1'b1;
        end
        7'b0100011: begin // store
            ALUSrc_o = 1'b1;
            ctrl_write_en_o = 1'b1;
            // không cần bỏ memtoreg vì regwrite =0 nên không ghi data được
        end
        7'b1100011: begin // branch
            branch_o = 1'b1;
            ALUOp_o = 3'b001;
        end
        7'b0010011: begin // I format (ALU)
            reg_write_en_o = 1'b1;
            ALUSrc_o = 1'b1;
            ALUOp_o = 3'b011;
            MemtoReg_o =2'b00; // chọn kênh lấy data từ ALU 
        end
        7'b1101111: begin // jal (J format)
            reg_write_en_o = 1'b1;
            jal_o = 1'b1;
            MemtoReg_o = 2'b10; // chọn kênh lấy PC + 4
        end
        7'b1100111: begin // jalr
            jalr_o = 1'b1;         // (1) Báo cho PC_MUX nhảy jalr
            reg_write_en_o = 1'b1; // (2) Mở cửa Thanh ghi cất đường về
            MemtoReg_o = 2'b10;    // (3) Chọn kênh lấy PC + 4
            ALUSrc_o = 1'b1;       // (4) Đưa số Offset vào ALU
        end
        7'b0110111: begin // lui (U format)
            reg_write_en_o = 1'b1; // Lưu vào thanh ghi
            ALUSrc_o = 1'b1;       // Gạt MUX đưa số hằng số to vào ALU
            ALUOp_o = 3'b100;
        end
        default: begin
        end
    endcase
end
endmodule






