module PCsel(
    input logic branch_i,
    input logic jal_i,
    input logic jalr_i,
    input logic zero_i,
    output logic [1:0] pc_sel_o
);
always_comb begin
    if (jalr_i) begin
        pc_sel_o = 2'b10; // Ưu tiên JALR: Nhảy tới RS1 + imm
    end 
    else if (jal_i || (branch_i && zero_i)) begin
        pc_sel_o = 2'b01; // JAL hoặc BEQ Taken: Nhảy tới PC + imm
    end 
    else begin
        pc_sel_o = 2'b00; // Mặc định đi tiếp PC + 4
    end
end
endmodule
