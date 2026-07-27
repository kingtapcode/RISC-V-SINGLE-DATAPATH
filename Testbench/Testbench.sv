`timescale 1ns/1ps
module tb_RISCV_core();
    // 1. Khai báo các tín hiệu kết nối với lõi CPU (DUT)
    logic clk_i;
    logic rst_ni;
    logic [63:0] switch_i;
    logic [63:0] red_led_o;
    logic [63:0] green_led_o;
    // 2. Gọi (Instantiate) module RISCV_core đã thiết kế
    RISCV_core dut (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .switch_i(switch_i),
        .red_led_o(red_led_o),
        .green_led_o(green_led_o)
    );
    // 3. Khối tạo xung nhịp (Clock Generation)
    // Chu kỳ 10ns tương đương tần số 100MHz
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i; 
    end
    // 4. Khối kích thích hệ thống (Stimulus)
    initial begin
        // Yêu cầu EDA Playground xuất file dữ liệu dạng sóng
        $dumpfile("dump.vcd"); 
        $dumpvars(0, tb_RISCV_core);

        // A. Trạng thái khởi động ban đầu
        // Bật thử 4 công tắc đầu tiên (4 bit LSB) lên mức 1
        switch_i = 64'h0000_0000_0000_000F; 
        rst_ni = 1'b0; // Kéo cờ Reset xuống 0 (Active-low) để xóa toàn bộ thanh ghi
        // B. Giữ Reset trong 20ns (2 chu kỳ clock) để mạch ổn định hoàn toàn
        #20;
        rst_ni = 1'b1; // Nhả Reset, PC bắt đầu đếm từ 0 và CPU bắt đầu nạp lệnh
        // C. Để CPU tự do chạy các lệnh trong bộ nhớ
        // Thời gian mô phỏng là 1000ns (Tương đương 100 chu kỳ lệnh)
        // Nếu chương trình Assembly của bạn dài hơn, hãy tăng con số này lên
        #1000;
        // D. Kết thúc mô phỏng
        $display("----------------------------------------");
        $display("Hoan tat mo phong RISC-V RV64I Datapath!");
        $display("----------------------------------------");
        $finish;
    end

    // 5. (Tùy chọn) Theo dõi trực tiếp trên Terminal
    // In ra màn hình console bất cứ khi nào CPU xuất lệnh đổi trạng thái đèn LED
    always @(red_led_o or green_led_o) begin
        if (rst_ni) begin
            $display("[Time: %0t ns] LED STATUS CHANGED -> Red: %h | Green: %h", $time, red_led_o, green_led_o);
        end
    end
endmodule
