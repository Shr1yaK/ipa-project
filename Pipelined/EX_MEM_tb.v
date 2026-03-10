module EX_MEM_tb;

reg clk;
reg reset;

reg RegWrite_in, MemRead_in, MemWrite_in, MemtoReg_in;
reg [63:0] alu_result_in;
reg [63:0] write_data_in;
reg [4:0] rd_in;

wire RegWrite_out, MemRead_out, MemWrite_out, MemtoReg_out;
wire [63:0] alu_result_out;
wire [63:0] write_data_out;
wire [4:0] rd_out;

EX_MEM dut(
    .clk(clk),
    .reset(reset),

    .RegWrite_in(RegWrite_in),
    .MemRead_in(MemRead_in),
    .MemWrite_in(MemWrite_in),
    .MemtoReg_in(MemtoReg_in),

    .alu_result_in(alu_result_in),
    .write_data_in(write_data_in),
    .rd_in(rd_in),

    .RegWrite_out(RegWrite_out),
    .MemRead_out(MemRead_out),
    .MemWrite_out(MemWrite_out),
    .MemtoReg_out(MemtoReg_out),

    .alu_result_out(alu_result_out),
    .write_data_out(write_data_out),
    .rd_out(rd_out)
);

always #5 clk = ~clk;

initial begin

    $dumpfile("EX_MEM.vcd");
    $dumpvars(0, EX_MEM_tb);

    clk = 0;
    reset = 1;
    #10 reset = 0;

    RegWrite_in = 1;
    MemRead_in = 0;
    MemWrite_in = 0;
    MemtoReg_in = 0;

    alu_result_in = 64'h1234;
    write_data_in = 64'hABCD;
    rd_in = 5'd10;

    #10;

    $display("ALU Result Out = %h", alu_result_out);
    $display("Write Data Out = %h", write_data_out);
    $display("RD Out = %d", rd_out);

    #10 $finish;

end

endmodule