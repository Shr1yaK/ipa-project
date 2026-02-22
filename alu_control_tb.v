`include "alu_control.v"

module tb_alu_control;
    reg [1:0] ALUOp;
    reg [2:0] funct3;
    reg funct7;
    wire [3:0] ALUControl;

    alu_control uut (
        .ALUOp(ALUOp), 
        .funct3(funct3), 
        .funct7(funct7), 
        .ALUControl(ALUControl)
    );

    initial begin
        $display("ALUOp\t| Funct3| Funct7\t| ALUControl\t| Expected\t| Type");
        $display("-------------------------------------------------------------------------------------");

        //ld, sd, addi
        ALUOp = 2'b00; funct3 = 3'b000; funct7 = 1'b0; #10;
        $display("%b\t| %b\t| %b\t\t| %b\t\t| 0000\t\t| LD/SD/ADDI", ALUOp, funct3, funct7, ALUControl);

        //beq-uses sub
        ALUOp = 2'b01; funct3 = 3'b000; funct7 = 1'b0; #10;
        $display("%b\t| %b\t| %b\t\t| %b\t\t| 1000\t\t| BEQ (SUB)", ALUOp, funct3, funct7, ALUControl);

        //add
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 1'b0; #10;
        $display("%b\t| %b\t| %b\t\t| %b\t\t| 0000\t\t| R-ADD", ALUOp, funct3, funct7, ALUControl);

        //sub
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 1'b1; #10;
        $display("%b\t| %b\t| %b\t\t| %b\t\t| 1000\t\t| R-SUB", ALUOp, funct3, funct7, ALUControl);

        //and
        ALUOp = 2'b10; funct3 = 3'b111; funct7 = 1'b0; #10;
        $display("%b\t| %b\t| %b\t\t| %b\t\t| 0111\t\t| R-AND", ALUOp, funct3, funct7, ALUControl);

        //or
        ALUOp = 2'b10; funct3 = 3'b110; funct7 = 1'b0; #10;
        $display("%b\t| %b\t| %b\t\t| %b\t\t| 0110\t\t| R-OR", ALUOp, funct3, funct7, ALUControl);

        //default
        ALUOp = 2'b11; funct3 = 3'bxxx; funct7 = 1'bx; #10;
        $display("%b\t| %b\t| %b\t\t| %b\t\t| 0000\t\t| Default", ALUOp, funct3, funct7, ALUControl);

        $display("-------------------------------------------------------------------------------------");
        $finish;
    end
endmodule

