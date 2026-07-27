module full_adder(
    input logic a_i,
    input logic b_i,
    input logic cin_i,
    output logic sum_o,
    output logic cout_o
  );
  assign sum_o= a_i^b_i^cin_i;
  assign cout_o=(a_i&b_i)|(a_i&cin_i)|(b_i&cin_i);
endmodule

module add_sub_64bit(
    input logic [63:0] a_i,
    input logic [63:0] b_i,
    input logic ctrl_i,
    output logic [63:0] sum_o,
    output logic cout_o
  );
  logic [63:0] w_b_xor;
  logic [64:0] w_carry;
  genvar i;
  assign w_carry[0] = ctrl_i;
  assign cout_o = w_carry[64];
  generate
    for (i=0; i<64; i=i+1) begin : gen_add_sub
      assign w_b_xor[i] = b_i[i]^ctrl_i;
    end
  endgenerate
  generate
    for (i=0; i<64; i=i+1) begin : gen_full_adders
        full_adder fa_inst (
          .a_i(a_i[i]),
          .b_i(w_b_xor[i]),
          .cin_i(w_carry[i]),
          .sum_o(sum_o[i]),
          .cout_o(w_carry[i+1])
        );
    end
  endgenerate
endmodule


 
