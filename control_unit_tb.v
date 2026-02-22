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
        $display("Opcode\t| Type\t| RegW\t| ASrc\t| MtoR\t| MRead\t| MWrite| Brch\t| ALUOp");
        $display("-------------------------------------------------------------------------------");

        //and sub add or
        opcode = 7'b0110011; #10;
        $display("%b\t| R\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b", opcode, RegWrite, ALUSrc, MemtoReg, MemRead, MemWrite, Branch, ALUOp);

        //addi
        opcode = 7'b0010011; #10;
        $display("%b\t| I\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b", opcode, RegWrite, ALUSrc, MemtoReg, MemRead, MemWrite, Branch, ALUOp);

        //ld
        opcode = 7'b0000011; #10;
        $display("%b\t| LD\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b", opcode, RegWrite, ALUSrc, MemtoReg, MemRead, MemWrite, Branch, ALUOp);

        //sd
        opcode = 7'b0100011; #10;
        $display("%b\t| SD\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b", opcode, RegWrite, ALUSrc, MemtoReg, MemRead, MemWrite, Branch, ALUOp);

        //beq
        opcode = 7'b1100011; #10;
        $display("%b\t| BEQ\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b", opcode, RegWrite, ALUSrc, MemtoReg, MemRead, MemWrite, Branch, ALUOp);

        //null
        opcode = 7'b0000000; #10;
        $display("%b\t| NULL\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b\t| %b", opcode, RegWrite, ALUSrc, MemtoReg, MemRead, MemWrite, Branch, ALUOp);

        $display("-------------------------------------------------------------------------------");
        $finish;
    end

endmodule
