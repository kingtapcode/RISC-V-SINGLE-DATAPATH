# RISC-V-SINGLE-DATAPATH
Designing RISC_V core processor RV64I Single Cycle by System Verilog
## 1. Giới thiệu chung (Introduction to Datapath)
File này tập trung thiết kế và mô phỏng lõi vi xử lý **RISC-V 64-bit (RV64I)** dựa trên kiến trúc **Single-Cycle** (đơn chu kỳ) sử dụng ngôn ngữ mô tả phần cứng SystemVerilog. Thiết kế tuân thủ tập lệnh cơ sở (Base Integer Instruction Set) của RISC-V, tối ưu hóa quá trình xử lý luồng dữ liệu (datapath) để hoàn tất một lệnh trong một chu kỳ xung nhịp duy nhất.
Kiến trúc cốt lõi được chia thành 5 giai đoạn (stages) xử lý liền mạch:
1. **Instruction Fetch (IF):** Khối `ProgramCounter` cập nhật địa chỉ và trích xuất mã lệnh 32-bit từ bộ nhớ lệnh `IMEM`.
2. **Instruction Decode (ID):** Khối `ControlUnit` giải mã lệnh và thiết lập các cờ tín hiệu điều khiển. Cùng lúc đó, khối `ImmGen` trích xuất hằng số tức thời, và các toán hạng được đọc ra từ tập thanh ghi `RegFile`.
3. **Execute (EX):** Khối `ALU_64bit` đảm nhiệm các phép toán số học (ADD, SUB), logic (AND, OR, XOR) và dịch bit (SLL, SRL, SRA). Song song đó, khối `PC_adder` tính toán sẵn địa chỉ đích cho các lệnh rẽ nhánh.
4. **Memory Access (MEM):** Giao tiếp với bộ nhớ dữ liệu `Dmem`. Bộ Load/Store Unit (`LSU`) đặc biệt được tích hợp để xử lý việc căn chỉnh (alignment) và mở rộng bit (sign/zero extension) chính xác cho đa dạng kích thước dữ liệu (Byte, Half-word, Word, Double-word).
5. **Write Back (WB):** Hệ thống bộ ghép kênh (như `Mux_MemtoReg`) đóng vai trò định tuyến, lựa chọn luồng dữ liệu cuối cùng từ ALU hoặc Dmem để ghi ngược cấu hình trở lại `RegFile`.
6. **Memory-Mapped I/O (MMIO):** Hệ thống được tích hợp khối giải mã địa chỉ (`Address_Decoder`) để giao tiếp trực tiếp với các thiết bị ngoại vi bên ngoài. Các ngoại vi 32-bit bao gồm ngõ vào (`switch_i`) và ngõ ra hiển thị (`red_led_o`, `green_led_o`) được ánh xạ trực tiếp vào không gian bộ nhớ. Thiết kế này cho phép CPU điều khiển phần cứng linh hoạt chỉ bằng các lệnh Load/Store tiêu chuẩn, đồng thời áp dụng kỹ thuật chèn bit (Zero-Extension) để ép kiểu tương thích giữa bus 64-bit của lõi và vi mạch 32-bit.
<p align="center">
  <img src="Image/RISCV SINGLE DATAPATH.drawio.png" alt="RISC-V Single-Cycle Datapath Block Diagram" width="850">
</p>
<p align="center">
  <em>Hình 1: Sơ đồ nguyên lý Datapath kiến trúc RV64I Single-Cycle</em>
</p>
## 2. Kịch bản Kiểm thử (Testbenches & Verification)
Quá trình kiểm tra tính đúng đắn của Datapath được thực hiện bằng cách nạp mã máy (machine code) biên dịch từ tập lệnh Assembly vào bộ nhớ `IMEM`, sau đó quan sát sự biến đổi của các tín hiệu điều khiển và luồng dữ liệu trên đồ thị sóng (Waveform).
### 2.1. Test Lệnh Số Học (ADD / SUB)
**Mục tiêu:** Xác minh luồng dữ liệu đi từ tập thanh ghi (`RegFile`) và khối `ImmGen32_64`, xuyên qua khối tính toán (`ALU_64bit`) và ghi ngược kết quả chính xác về lại thanh ghi đích.
**Đoạn mã Assembly được nạp (Minh họa phép tính 5 + 10 = 15):**
```assembly
addi x1, x0, 5      // Cycle 1: x1 = 0 + 5 = 5
addi x2, x0, 10     // Cycle 2: x2 = 0 + 10 = 10
add  x3, x1, x2     // Cycle 3: x3 = x1 + x2 = 15
**Phân tích kết quả trên Waveform (Định dạng Hexadecimal):**

<p align="center">
  <img src="Image/add_waveform.png" width="1000" alt="Waveform test lệnh ADD">
</p>
<p align="center">
  <em>Hình 2: Trạng thái các tín hiệu nội bộ khi CPU thực thi chuỗi lệnh ADD/ADDI (Hệ cơ số 16)</em>
</p>

* **Chu kỳ 1 (`pc_o = 0x0`):** Lệnh `ADDI` đầu tiên được thực thi. `rs1_addr_i = 0x0` (thanh ghi `x0`), khối `ImmGen` tạo ra giá trị tức thời `imm_o = 0x5`. ALU tính ra `alu_result_o = 0x5` và ghi thành công vào `rd_data_i = 0x5` (tại thanh ghi đích `x1` có địa chỉ `rd_addr_i = 0x1`).
* **Chu kỳ 2 (`pc_o = 0x4`):** Lệnh `ADDI` thứ hai hoạt động tương tự. Khối `ImmGen` tạo ra giá trị tức thời `0xa` (tức là 10). Ngõ ra của ALU đạt `0xa` và được chốt về thanh ghi đích `x2` (`rd_addr_i = 0x2`, `rd_data_i = 0xa`).
* **Chu kỳ 3 (`pc_o = 0x8`):** Lệnh `ADD` được kích hoạt. Lõi xuất chính xác địa chỉ của 2 thanh ghi nguồn (`rs1_addr_i = 0x1`, `rs2_addr_i = 0x2`), kéo theo dữ liệu `0x5` và `0xa` vào ngõ vào ALU. Ngõ ra `alu_result_o` cộng chính xác ra `0xf` (tức là 15) và chốt về `rd_data_i` để lưu vào thanh ghi `x3` (`rd_addr_i = 0x3`).

