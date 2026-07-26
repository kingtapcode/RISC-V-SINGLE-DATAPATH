module ProgramCounter(
    input logic clk_i,
    input logic rst_ni,
    input logic [63:0] pc_next_i,
    output logic [63:0] pc_o
);
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
        pc_o <= 64'b0;
    end else begin
        pc_o <= pc_next_i;
    end
end
endmodule