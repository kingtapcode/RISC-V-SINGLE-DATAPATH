module LSU(
    input logic ctrl_write_en_i,
    input logic ctrl_read_en_i,
    input logic [2:0] funct3_i,
    input logic [63:0] addr_i,
    input logic [63:0] wdata_i,
    input logic [63:0] rdata_raw_i,
    output logic [7:0] byte_mask_o,
    output logic [63:0] wdata_aligned_o,
    output logic [63:0] rdata_o
);
always_comb begin
    byte_mask_o = 8'b0000_0000;
    wdata_aligned_o = wdata_i;
    if (ctrl_write_en_i) begin
        case (funct3_i)
            3'b000: begin
                byte_mask_o = 8'b0000_0001 << addr_i[2:0];
                wdata_aligned_o = wdata_i << (addr_i[2:0]*8);
            end
            3'b001: begin
                byte_mask_o = 8'b0000_0011 << addr_i[2:0];
                wdata_aligned_o = wdata_i << (addr_i[2:0]*8);
            end
            3'b010: begin
                byte_mask_o = 8'b0000_1111 << addr_i[2:0];
                wdata_aligned_o = wdata_i << (addr_i[2:0]*8);
            end
            3'b011: begin
                byte_mask_o = 8'b1111_1111;
                wdata_aligned_o =wdata_i;
            end
            default: begin
                byte_mask_o = 8'b0000_0000;
                wdata_aligned_o = 64'b0;
            end
        endcase 
    end
end
logic [63:0] rdata_extracted_wire;
always_comb begin
    rdata_extracted_wire = rdata_raw_i >> (addr_i[2:0]*8);
    if (ctrl_read_en_i) begin
        case (funct3_i)
        //load có dấu
        3'b000: rdata_o = {{56{rdata_extracted_wire[7]}}, rdata_extracted_wire[7:0]}; //1 byte
        3'b001: rdata_o = {{48{rdata_extracted_wire[15]}}, rdata_extracted_wire[15:0]}; // 2 bytes
        3'b010: rdata_o = {{32{rdata_extracted_wire[31]}}, rdata_extracted_wire[31:0]}; //4 bytes
        3'b011: rdata_o = rdata_extracted_wire; //8 bytes
        //load không dấu
        3'b100: rdata_o = {56'b0, rdata_extracted_wire[7:0]}; //1 byte  
        3'b101: rdata_o = {48'b0, rdata_extracted_wire[15:0]}; //2 bytes
        3'b110: rdata_o = {32'b0, rdata_extracted_wire[31:0]}; //4 bytes
        default: rdata_o = 64'b0;
        endcase
    end else begin
        rdata_o = 64'b0;
    end
end
endmodule


