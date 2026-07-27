module Address_Decoder(
    //dmem đọc hay ghi
    input logic ctrl_write_en_i,
    input logic ctrl_read_en_i,
    //địa chỉ dữ liệu
    input logic [63:0] addr_i,
    //dữ liệu dmem hay switch
    input logic [63:0] rdmem_i,
    input logic [63:0] rswitch_i,
    //nối với LSU
    output logic [63:0] rdata_raw_o,
    //tín hiệu cho dmem, led, switch
    output logic mem_read_en_o,
    output logic mem_write_en_o,
    output logic red_led_write_en_o,
    output logic green_led_write_en_o,
    output logic switch_read_en_o
);
always_comb begin
    mem_read_en_o = 1'b0;
    mem_write_en_o = 1'b0;
    red_led_write_en_o = 1'b0;
    green_led_write_en_o = 1'b0;
    switch_read_en_o = 1'b0;
    rdata_raw_o = 64'b0;
     if (addr_i >= 64'h0000_0000 && addr_i <= 64'h0000_07FF) begin
         mem_write_en_o = ctrl_write_en_i ; // truyen lenh ghi dmem
         mem_read_en_o = ctrl_read_en_i ; // truyen lenh doc dmem
         if (mem_read_en_o) begin
            rdata_raw_o = rdmem_i;
         end
    end else if (addr_i >= 64'h1000_0000 && addr_i <= 64'h1000_0FFF) begin
        red_led_write_en_o = ctrl_write_en_i ; // truyen lenh bat led do
    end else if (addr_i >= 64'h1000_1000 && addr_i <= 64'h1000_1FFF) begin
        green_led_write_en_o = ctrl_write_en_i; // truyen lenh bat led xanh
    end else if (addr_i >= 64'h1001_0000 && addr_i <= 64'h1001_0FFF) begin
        switch_read_en_o = ctrl_read_en_i;
        if (switch_read_en_o) begin
            rdata_raw_o = rswitch_i;
        end
    end
end
endmodule







