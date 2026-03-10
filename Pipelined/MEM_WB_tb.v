`timescale 1ns/1ps

module MEM_WB_tb;

reg clk;

reg RegWrite_in;
reg MemtoReg_in;
reg [63:0] mem_data_in;
reg [63:0] alu_result_in;
reg [4:0] rd_in;

wire RegWrite_out;
wire MemtoReg_out;
wire [63:0] mem_data_out;
wire [63:0] alu_result_out;
wire [4:0] rd_out;


// DUT
MEM_WB dut(
    .clk(clk),

    .RegWrite_in(RegWrite_in),
    .MemtoReg_in(MemtoReg_in),

    .mem_data_in(mem_data_in),
    .alu_result_in(alu_result_in),
    .rd_in(rd_in),

    .RegWrite_out(RegWrite_out),
    .MemtoReg_out(MemtoReg_out),
    .mem_data_out(mem_data_out),
    .alu_result_out(alu_result_out),
    .rd_out(rd_out)
);


// Clock generation
always #5 clk = ~clk;


initial begin

    // GTKWave dump
    $dumpfile("MEM_WB.vcd");
    $dumpvars(0, MEM_WB_tb);

    // Initialize clock
    clk = 0;

    // Input stimulus
    RegWrite_in = 1;
    MemtoReg_in = 1;
    mem_data_in = 64'hAAAA;
    alu_result_in = 64'hBBBB;
    rd_in = 5'd3;

    #10;

    // Display outputs
    $display("Mem Data Out = %h", mem_data_out);
    $display("ALU Result Out = %h", alu_result_out);
    $display("RD Out = %d", rd_out);

    #10;

    $finish;

end

endmodule