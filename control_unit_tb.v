`include "control_unit.v"

module tb_control_unit;
    reg [6:0] opcode;
    wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch;
    wire [1:0] ALUOp;

    control_unit uut (
        .opcode(opcode), 
        .RegWrite(RegWrite), 
        .MemRead(MemRead), 
        .MemWrite(MemWrite), 
        .MemtoReg(MemtoReg), 
        .ALUSrc(ALUSrc), 
        .Branch(Branch), 
        .ALUOp(ALUOp)
    );

    initial begin
        $monitor("Time: %0t | Op: %b | RegW: %b | ALUSrc: %b | ALUOp: %b", $time, opcode, RegWrite, ALUSrc, ALUOp);
        
        //add sub and or
        opcode = 7'b0110011; #10;
        //addi
        opcode = 7'b0010011; #10;
        //ld
        opcode = 7'b0000011; #10;
        //sd
        opcode = 7'b0100011; #10;
        //beq
        opcode = 7'b1100011; #10;
        //null
        opcode = 7'b0000000; #10; 
        
        $finish;
    end
endmodule