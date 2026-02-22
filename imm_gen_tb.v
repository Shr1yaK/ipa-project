`include "imm_gen.v"
module tb_imm_gen;
    reg [31:0] instruction;
    wire [63:0] imm;

    imm_gen uut (.instruction(instruction), .imm(imm));

    initial begin
        $display("\nTesting Immediate Generator...");
        //addi x1, x2, 5 -> imm = 5
        instruction = 32'h00500093; #10;
        $display("5: Result %h", imm);

        //addi x1, x2, -1 -> imm = FFFFFFFFFFFFFFFF
        instruction = 32'hfff00093; #10;
        $display("-1: Result %h", imm);

        //beq
        // [31] [30:25] [24:20] [19:15] [14:12] [11:8] [7] [6:0]
        instruction = 32'hfe000ce3; #10;
        $display("beq: Result %h", imm);
    end

endmodule
