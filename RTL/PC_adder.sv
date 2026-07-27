module PC_adder(
    input logic [63:0] a_i,
    input logic [63:0] b_i,
    output logic [63:0] sum_o
);
assign sum_o = a_i + b_i;
endmodule
