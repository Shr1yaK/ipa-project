`timescale 1ns / 1ps
`include "ID_EX.v"

module tb_ID_EX;

    reg clk, reset, flush;
    reg RegWrite_in, MemRead_in, MemWrite_in, MemToReg_in, Branch_in, ALUSrc_in;
    reg [1:0] ALUOp_in;
    reg [63:0] pc_in, read_data1_in, read_data2_in, imm_in;
    reg [4:0] rs1_in, rs2_in, rd_in;
    wire RegWrite_out, MemRead_out, MemWrite_out, MemToReg_out, Branch_out, ALUSrc_out;
    wire [1:0] ALUOp_out;
    wire [63:0] pc_out, read_data1_out, read_data2_out, imm_out;
    wire [4:0] rs1_out, rs2_out, rd_out;

    ID_EX uut (
        .clk(clk), .reset(reset), .flush(flush),
        .RegWrite_in(RegWrite_in), .MemRead_in(MemRead_in), .MemWrite_in(MemWrite_in),
        .MemToReg_in(MemToReg_in), .Branch_in(Branch_in), .ALUSrc_in(ALUSrc_in),
        .ALUOp_in(ALUOp_in), .pc_in(pc_in), .read_data1_in(read_data1_in),
        .read_data2_in(read_data2_in), .imm_in(imm_in), .rs1_in(rs1_in),
        .rs2_in(rs2_in), .rd_in(rd_in),
        .RegWrite_out(RegWrite_out), .MemRead_out(MemRead_out), .MemWrite_out(MemWrite_out),
        .MemToReg_out(MemToReg_out), .Branch_out(Branch_out), .ALUSrc_out(ALUSrc_out),
        .ALUOp_out(ALUOp_out), .pc_out(pc_out), .read_data1_out(read_data1_out),
        .read_data2_out(read_data2_out), .imm_out(imm_out), .rs1_out(rs1_out),
        .rs2_out(rs2_out), .rd_out(rd_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("ID_EX_results.vcd");
        $dumpvars(0, tb_ID_EX);  
        $monitor("Time: %0t | Reset: %b | Flush: %b | PC_In: %h | PC_Out: %h | Data_Out: %h", 
                 $time, reset, flush, pc_in, pc_out, read_data1_out);

        clk = 0; reset = 1; flush = 0;
        {RegWrite_in, MemRead_in, MemWrite_in, MemToReg_in, Branch_in, ALUSrc_in, ALUOp_in} = 0;
        {pc_in, read_data1_in, read_data2_in, imm_in} = 0;
        {rs1_in, rs2_in, rd_in} = 0;

        #10 reset = 0;
        
        //Latch 64-bit Data
        #10;
        RegWrite_in = 1; ALUOp_in = 2'b10; 
        pc_in = 64'h0000_0000_0000_0004;
        read_data1_in = 64'hAAAA_BBBB_CCCC_DDDD; 
        rd_in = 5'd10;
        
        //Verify Flush clears the register
        #20;
        flush = 1;
        #10 flush = 0;
        
        #20 $finish;
    end
endmodule