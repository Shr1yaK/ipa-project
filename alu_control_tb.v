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
        $display("ALUOp | Funct3 | Funct7 | ALUControl | Expected | Type");
        $display("-----------------------------------------------------");

        //ld, sd, addi
        ALUOp = 2'b00; funct3 = 3'b000; funct7 = 1'b0; #10;
        $display("  %b  |   %b  |    %b   |    %b    |   0000   | LD/SD/ADDI", ALUOp, funct3, funct7, ALUControl);

        //beq-uses sub
        ALUOp = 2'b01; funct3 = 3'b000; funct7 = 1'b0; #10;
        $display("  %b  |   %b  |    %b   |    %b    |   1000   | BEQ (SUB)", ALUOp, funct3, funct7, ALUControl);

        //add
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 1'b0; #10;
        $display("  %b  |   %b  |    %b   |    %b    |   0000   | R-ADD", ALUOp, funct3, funct7, ALUControl);

        // sub
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 1'b1; #10;
        $display("  %b  |   %b  |    %b   |    %b    |   1000   | R-SUB", ALUOp, funct3, funct7, ALUControl);

        //and
        ALUOp = 2'b10; funct3 = 3'b111; funct7 = 1'b0; #10;
        $display("  %b  |   %b  |    %b   |    %b    |   0111   | R-AND", ALUOp, funct3, funct7, ALUControl);

        //or
        ALUOp = 2'b10; funct3 = 3'b110; funct7 = 1'b0; #10;
        $display("  %b  |   %b  |    %b   |    %b    |   0110   | R-OR", ALUOp, funct3, funct7, ALUControl);

        //default
        ALUOp = 2'b11; funct3 = 3'bxxx; funct7 = 1'bx; #10;
        $display("  %b  |   %b  |    %b   |    %b    |   0000   | Default", ALUOp, funct3, funct7, ALUControl);

        $display("-----------------------------------------------------");
        $finish;
    end
endmodule

