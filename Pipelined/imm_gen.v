module imm_gen(
    input  [31:0] instruction,
    output reg [63:0] imm
);


always @(*) begin
    case (instruction[6:0])

        7'b0010011,7'b0000011: begin //Itype,addi,ld
            imm = {{52{instruction[31]}}, instruction[31:20]};
        end

        7'b0100011: begin//sd
            imm = {{52{instruction[31]}},instruction[31:25],instruction[11:7]};
        end

        7'b1100011: begin//beq
            imm = {{51{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};

        end

        default: begin // Rtype,add,sub,and,or
            imm = 64'b0;
        end

    endcase
end

endmodule