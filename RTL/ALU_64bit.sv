module ALU_64bit(
    input logic [63:0] a_i,
    input logic [63:0] b_i,
    input logic [3:0] alu_ctrl_i,
    output logic [63:0] alu_result_o,
    output logic alu_zero_o,
    output logic alu_overflow_o
);
logic [63:0] and_result, or_result, addsub_result;
logic [63:0] xor_result, shift_result, slt_result, pass_b_result;
add_sub_64bit addsub_inst(
    .a_i(a_i),
    .b_i(b_i),
    .ctrl_i(alu_ctrl_i[2]), // bit thu 3 cua alu_ctrl_i chi ra phep cong tru
    .sum_o(addsub_result),
    .cout_o()
);
assign and_result = a_i & b_i;
assign or_result = a_i | b_i;
assign xor_result = a_i ^ b_i;
assign shift_result = (alu_ctrl_i == 4'b0101) ? (a_i << b_i[5:0]) :         // sll
                      (alu_ctrl_i == 4'b0011) ? (a_i >> b_i[5:0]) :         // srl
                      (alu_ctrl_i == 4'b0111) ? ($signed(a_i) >>> b_i[5:0]) : // sra
                      64'b0; // default case
assign pass_b_result = b_i;
logic sign_a, sign_b, sign_sum, is_sub;
assign sign_a = a_i[63];
assign sign_b = b_i[63];
assign sign_sum = addsub_result[63];
assign is_sub = alu_ctrl_i[2]; // bit thu 3 cua alu_ctrl_i chi ra phep cong tru
assign alu_overflow_o = (is_sub) ? (sign_a != sign_b) && (sign_sum != sign_a) : (sign_a == sign_b) && (sign_sum != sign_a);
assign slt_result = {63'b0, (sign_sum ^ alu_overflow_o)};
Mux8_1ALU mux_inst(
    .AND_i(and_result),
    .OR_i(or_result),
    .ADDSUB_i(addsub_result),
    .XOR_i(xor_result),
    .SHIFT_i(shift_result),
    .SLT_i(slt_result),
    .PASS_B_i(pass_b_result),
    .zero_i(64'b0),
    .Sel_i(alu_ctrl_i[3:0]), // bit thu 2 va 1 cua alu_ctrl_i chi ra AND OR ADDSUB
    .Y_o(alu_result_o)
);
assign alu_zero_o = (alu_result_o ==64'b0) ? 1'b1 : 1'b0;
endmodule
