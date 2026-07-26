module RegFile(
    input logic clk_i,
    input logic rst_ni,
    input logic reg_write_en_i,
    // đọc thanh 1
    input logic [4:0] rs1_addr_i,
    output logic [63:0] rs1_data_o,
    // đọc thanh 2
    input logic [4:0] rs2_addr_i,
    output logic [63:0] rs2_data_o,
    //ghi thanh
    input logic [4:0] rd_addr_i,
    input logic [63:0] rd_data_i
);
logic [63:0] registers [31:0]; // 32 thanh ghi, 1 thanh 64 bit
assign rs1_data_o = ( rs1_addr_i == 5'b0) ? 64'b0 : registers[rs1_addr_i];
assign rs2_data_o = ( rs2_addr_i == 5'b0) ? 64'b0 : registers[rs2_addr_i];
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
        for (int i=0; i<32; i++) begin
            registers[i] <=64'b0;
        end
    end else if (reg_write_en_i == 1'b1 && rd_addr_i != 5'b0) begin
        registers[rd_addr_i] <= rd_data_i;
    end
end
endmodule
