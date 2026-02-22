`include "alu_control.v"
module tb_alu_control;
    reg [1:0] ALUOp;
    reg [2:0] funct3;
    reg funct7;
    wire [3:0] ALUControl;

    alu_control uut (.ALUOp(ALUOp), .funct3(funct3), .funct7(funct7), .ALUControl(ALUControl));

    initial begin
        // ld sd addi add
        ALUOp = 2'b00; #10;
        $display("ALUOp 00: Result %b", ALUControl);

        // sub
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 1'b1; #10;
        $display("R-type SUB: Result %b", ALUControl);
        
        // and
        ALUOp = 2'b10; funct3 = 3'b111; #10;
        $display("R-type AND: Result %b", ALUControl);
    end

endmodule
