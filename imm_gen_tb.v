`include "imm_gen.v"

module tb_imm_gen;
    reg [31:0] instruction;
    wire [63:0] imm;

    imm_gen uut (.instruction(instruction), .imm(imm));
    initial begin
        $display("Instruction\t| Type\t| 64-bit Hex Result\t| Value");
        $display("-------------------------------------------------------------------------");

        //addi x1, x2, 5.....+ve
        instruction = 32'h00500093; #10;
        $display("%h\t| I\t| %h\t| 5", instruction, imm);

        //addi x1, x2, -1......-ve
        instruction = 32'hfff00093; #10;
        $display("%h\t| I\t| %h\t| -1", instruction, imm);

        //sd x1, 8(x2)....bits [31:25] and [11:7]
        instruction = 32'h00113423; #10;
        $display("%h\t| S\t| %h\t| 8", instruction, imm);

        //beq....backward jump
        instruction = 32'hfe000ce3; #10;
        $display("%h\t| B\t| %h\t| -8", instruction, imm);

        //add...... 0 immediate
        instruction = 32'h00000033; #10;
        $display("%h\t| R\t| %h\t| 0", instruction, imm);

        $display("-------------------------------------------------------------------------");
        $finish;
    end
endmodule
