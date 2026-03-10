`timescale 1ns / 1ps
`include "Forwarding_Unit.v"

module tb_Forwarding_Unit;

    reg [4:0] ID_EX_rs1, ID_EX_rs2, EX_MEM_rd, MEM_WB_rd;
    reg EX_MEM_RegWrite, MEM_WB_RegWrite;
    wire [1:0] ForwardA, ForwardB;

    Forwarding_Unit uut (
        .ID_EX_rs1(ID_EX_rs1), 
        .ID_EX_rs2(ID_EX_rs2), 
        .EX_MEM_rd(EX_MEM_rd), 
        .MEM_WB_rd(MEM_WB_rd),
        .EX_MEM_RegWrite(EX_MEM_RegWrite), 
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ForwardA(ForwardA), 
        .ForwardB(ForwardB)
    );

    initial begin
        $dumpfile("Forwarding_results.vcd"); 
        $dumpvars(0, tb_Forwarding_Unit);
        
        $monitor("Time:%0t | rs1:%d rs2:%d | MEM_rd:%d WB_rd:%d | FwdA:%b FwdB:%b", 
                 $time, ID_EX_rs1, ID_EX_rs2, EX_MEM_rd, MEM_WB_rd, ForwardA, ForwardB);

        //No Hazard
        //no forwarding should occur
        {ID_EX_rs1, ID_EX_rs2, EX_MEM_rd, MEM_WB_rd} = {5'd1, 5'd2, 5'd3, 5'd4};
        EX_MEM_RegWrite = 0; MEM_WB_RegWrite = 0;
        #10; 

        // MEM to EX
        // Previous instruction writes to rs1 
        EX_MEM_rd = 5'd1; EX_MEM_RegWrite = 1;
        #10; 

        // MEM Hazard (WB to EX)
        // Instruction two cycles ago writes to rs2 
        MEM_WB_rd = 5'd2; MEM_WB_RegWrite = 1;
        #10; 

        // Case 4: x0 Protection
        // Register x0 must never be forwarded 
        ID_EX_rs1 = 5'd0; EX_MEM_rd = 5'd0;
        #10; 
        
        // Case 5: Double Hazard (Priority Test)
        // If both stages write to rs1, MEM (most recent) must take priority 
        ID_EX_rs1 = 5'd5; EX_MEM_rd = 5'd5; MEM_WB_rd = 5'd5;
        EX_MEM_RegWrite = 1; MEM_WB_RegWrite = 1;
        #10;
        
        $finish;
    end
endmodule