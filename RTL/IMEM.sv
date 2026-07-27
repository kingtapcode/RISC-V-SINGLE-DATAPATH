module IMEM(
    input logic [63:0] pc_i,
    output logic [31:0] instr_o
);
logic [31:0] imem [0:255];
initial begin
    $readmemh("program.hex", imem);
end
assign instr_o = imem[pc_i[9:2]]; // pc_i[9:2] chi ra dia chi cua lenh trong imem
endmodule


