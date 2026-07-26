module Mux_ALUSrc(
    input logic [63:0] rs2_data_i,
    input logic [63:0] imm_i,
    input logic ALUSrc_i,
    output logic [63:0] out_o
);
assign out_o = (ALUSrc_i) ? imm_i : rs2_data_i;
endmodule