module PCsel(
    input logic branch_i,
    input logic jal_i,
    input logic jalr_i,
    input logic zero_i,
    output logic [1:0] pc_sel_o
);
always_comb begin
    pc_sel_o = 2'b00; // mặc định là PC + 4
    case ({jal_i, jalr_i, branch_i, zero_i})
    4'b0000: pc_sel_o = 2'b00; // PC + 4
    4'b0010: pc_sel_o = 2'b00; // PC + 4
    4'b0011: pc_sel_o = 2'b01; // PC + offset
    4'b1000: pc_sel_o = 2'b01; // PC + offset
    4'b0100: pc_sel_o = 2'b10; // PC + ALU
    default: pc_sel_o = 2'b00;
    endcase
end
endmodule



