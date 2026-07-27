module Mux_MemtoReg(
    input logic [63:0] alu_result_i, //2'b00
    input logic [63:0] lsu_rdata_i, // 2'b01
    input logic [63:0] pc_4_i, //2'b10
    input logic [1:0] MemtoReg_i,
    output logic [63:0] out_o
);
always_comb begin
    out_o = 64'b0;
    case (MemtoReg_i)
    2'b00: out_o = alu_result_i;
    2'b01: out_o = lsu_rdata_i;
    2'b10: out_o = pc_4_i;
    default: out_o = 64'b0;
    endcase
end
endmodule
