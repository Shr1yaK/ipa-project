module EX_stage(
    input wire [63:0] read_data1, read_data2, imm, pc,
    input wire [63:0] EX_MEM_ALU_result, WB_data,
    input wire [1:0] ForwardA, ForwardB,
    input wire ALUSrc, Branch,
    input wire [3:0] ALU_Control,

    output wire [63:0] ALU_result,
    output wire flush
);
    wire [63:0] op1, op2, mux_out2;
    wire zero_flag, cout, carry_flag, overflow_flag;

    assign op1 = (ForwardA == 2'b10) ? EX_MEM_ALU_result :
                 (ForwardA == 2'b01) ? WB_data : read_data1;

    assign mux_out2 = (ForwardB == 2'b10) ? EX_MEM_ALU_result :
                      (ForwardB == 2'b01) ? WB_data : read_data2;

    assign op2 = (ALUSrc) ? imm : mux_out2;

    alu_64_bit my_alu (
        .a(op1), .b(op2), .opcode(ALU_Control),
        .result(ALU_result), .cout(cout), .carry_flag(carry_flag),
        .overflow_flag(overflow_flag), .zero_flag(zero_flag)
    );

    // Flush if branch instruction is active and branch is taken (zero_flag == 1)
    assign flush = Branch && zero_flag; 
endmodule