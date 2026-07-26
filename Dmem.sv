module Dmem(
    input logic clk_i,
    input logic rst_ni,
    input logic mem_write_en_i,
    input logic mem_read_en_i,
    input logic [63:0] addr_i,
    input logic [63:0] wdata_i,
    input logic [7:0] byte_mask_i,
    output logic [63:0] rdata_o
);
logic [63:0] dmem [0:255];
always_comb begin
    if (mem_read_en_i) begin
        rdata_o = dmem[addr_i[10:3]]; // addr_i[10:3] chi ra dia chi cua du lieu trong dmem
    end else begin
        rdata_o = 64'b0;
    end
end
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        for (int i = 0; i <256; i++) begin
            dmem [i] <= 64'b0;
        end
    end else if (mem_write_en_i) begin
        for (int i =0; i<8; i++) begin
            if (byte_mask_i[i]) begin
                dmem[addr_i[10:3]][8*i +: 8] <= wdata_i[8*i +: 8];
        end
    end
    end
end
endmodule


