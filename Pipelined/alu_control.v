module alu_control(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7,
    output reg [3:0] ALUControl
);

always @(*) begin
    case (ALUOp)

        2'b00: ALUControl = 4'b0000;//ld,sd,add
        2'b01: ALUControl = 4'b1000;//beq,sub
        2'b10: begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 1'b1)
                        ALUControl = 4'b1000;//sub
                    else
                        ALUControl = 4'b0000;//add
                end
                3'b111: ALUControl = 4'b0111;//and
                3'b110: ALUControl = 4'b0110;//or
                default: ALUControl = 4'b0000;
            endcase
        end
        default: ALUControl = 4'b0000;

    endcase
end

endmodule