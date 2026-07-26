module ImmGen32_64(
    input logic [31:0] instr_i,
    output logic [63:0] imm_o
);
logic [6:0] opcode;
assign opcode = instr_i[6:0];
always_comb begin
    case (opcode)
    7'b0000011, 7'b0010011, 7'b1100111: begin // I-type
        imm_o= {{52{instr_i[31]}}, instr_i[31:20]};
    end
    7'b0100011: begin // S-type
        imm_o= {{52{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
    end
    7'b1100011: begin // B-type
        imm_o = {{51{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
    end
    7'b0110111, 7'b0010111: begin // U-type
        imm_o = {{32{instr_i[31]}}, instr_i[31:12], {12{1'b0}}};
    end
    7'b1101111: begin // J-type
        imm_o = {{43{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
    end
    default: begin
        imm_o = 64'b0;
    end
    endcase
end
endmodule
    