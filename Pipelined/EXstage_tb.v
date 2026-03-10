`timescale 1ns / 1ps
`include "EXstage.v"

module tb_EX_stage;
    reg [63:0] read_data1, read_data2, imm, pc, EX_MEM_ALU_result, WB_data;
    reg [1:0] ForwardA, ForwardB;
    reg ALUSrc, Branch;
    reg [3:0] ALU_Control;
    wire [63:0] ALU_result;
    wire flush;

    EX_stage uut (
        .read_data1(read_data1), .read_data2(read_data2), .imm(imm), .pc(pc),
        .EX_MEM_ALU_result(EX_MEM_ALU_result), .WB_data(WB_data),
        .ForwardA(ForwardA), .ForwardB(ForwardB),
        .ALUSrc(ALUSrc), .Branch(Branch),
        .ALU_Control(ALU_Control),
        .ALU_result(ALU_result), .flush(flush)
    );

    initial begin
        $dumpfile("EX_stage_final_results.vcd");
        $dumpvars(0, tb_EX_stage);
        
        $monitor("Time:%0t | Result:%d | Flush:%b | FwdA:%b FwdB:%b | Op2_Src:%b", 
                 $time, ALU_result, flush, ForwardA, ForwardB, ALUSrc);
        // 100 + 200 = 300
        read_data1 = 64'd100; read_data2 = 64'd200;
        imm = 64'd0; ALUSrc = 0; Branch = 0; ALU_Control = 4'b0000;
        ForwardA = 2'b00; ForwardB = 2'b00;
        #10;

        // 500 (from MEM) + 200 = 700
        EX_MEM_ALU_result = 64'd500;
        ForwardA = 2'b10;
        #10;

        // 500 (MEM) + 999 (WB) = 1499
        WB_data = 64'd999;
        ForwardB = 2'b01;
        #10;

        // 500 (MEM) + 50 (Imm) = 550. ForwardB is ignored cuz ALUSrc=1
        imm = 64'd50;
        ALUSrc = 1; 
        #10;

        // 500 (MEM) - 500 (Register) = 0. Zero=1, Flush=1
        Branch = 1;
        ALU_Control = 4'b1000; 
        ALUSrc = 0;           
        read_data2 = 64'd500; 
        ForwardB = 2'b00;
        #10;
        
        $finish;
    end
endmodule