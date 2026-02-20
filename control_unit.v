module control_unit(
    input  [6:0] opcode,

    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg Branch,
    output reg [1:0] ALUOp
);

always @(*) begin
        
        Branch = 1'b0;
        MemRead = 1'b0;
        MemtoReg = 1'b0;
        ALUOp = 2'b00;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        RegWrite = 1'b0;
        
        case (opcode)

        7'b0110011: begin//Rtype,add,sub,and,or
            RegWrite = 1'b1;
            ALUSrc = 1'b0;
            MemtoReg = 1'b0;
            ALUOp = 2'b10;
        end

        7'b0010011: begin//Itype,addi
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            MemtoReg = 1'b0;
            ALUOp = 2'b00;
        end

        7'b0000011: begin//ld
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            MemRead = 1'b1;
            MemtoReg = 1'b1;
            ALUOp = 2'b00;
        end

        7'b0100011: begin//sd
            ALUSrc = 1'b1;
            MemWrite = 1'b1;
            ALUOp = 2'b00;
        end

        7'b1100011: begin//beq
            Branch = 1'b1;
            ALUSrc = 1'b0;
            ALUOp = 2'b01;
        end

        default: begin
        end

        endcase
end

endmodule