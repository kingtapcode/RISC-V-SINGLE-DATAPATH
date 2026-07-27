module Mux8_1ALU(
    input logic [63:0] AND_i,
    input logic [63:0] OR_i,
    input logic [63:0] ADDSUB_i,
    input logic [63:0] XOR_i,       // Phép XOR
    input logic [63:0] SHIFT_i,     // Các phép dịch bit (sll, srl, sra)
    input logic [63:0] SLT_i,       // Lệnh so sánh (Set Less Than)
    input logic [63:0] PASS_B_i,    // Cho lệnh lui (Truyền thẳng cổng B)
    input logic [63:0] zero_i,
    input logic [3:0] Sel_i,
    output logic [63:0] Y_o
  );
always_comb begin
        case (Sel_i)
            4'b0000: Y_o = AND_i;
            4'b0001: Y_o = OR_i;
            4'b0010, 4'b0110: Y_o = ADDSUB_i;
            4'b0100: Y_o = XOR_i;
            4'b0101, 4'b0111, 4'b0011: Y_o = SHIFT_i;
            4'b1000: Y_o = SLT_i;
            4'b1001: Y_o = PASS_B_i;
            4'b1111: Y_o = zero_i;
            default: Y_o = 64'b0; // Chống sinh Latch
        endcase
    end
endmodule
