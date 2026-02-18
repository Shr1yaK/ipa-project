`include "ALUOPS/and64.v"
`include "ALUOPS/xor64.v"
`include "ALUOPS/or64.v"
`include "ALUOPS/add64.v"
`include "ALUOPS/sll64.v"
`include "ALUOPS/srl64.v"
`include "ALUOPS/slt64.v"
`include "ALUOPS/sra64.v"
module alu_64_bit(
    input [63:0] a,
    input [63:0] b,
    input [3:0] opcode,
    output [63:0] result,
    output carry_flag, 
    output overflow_flag, 
    output zero_flag
);
 wire [63:0] and_result, or_result, xor_result, add_result, sub_result, sll_result, slt_result, srl_result, sra_result, sltu_result;
 reg [63:0] temp_result;
 reg temp_cf,temp_of,temp_zf;
wire and_z, or_z, xor_z, add_z, sub_z;
wire slt_z, sltu_z;
wire sra_z, srl_z, sll_z;
wire add_o, sub_o;
wire add_c, sub_c;
assign result=temp_result;
assign carry_flag=temp_cf;
assign overflow_flag=temp_of;
assign zero_flag=temp_zf;
    localparam  ADD_Oper  = 4'b0000,
                SLL_Oper  = 4'b0001,
                SLT_Oper  = 4'b0010,
                SLTU_Oper = 4'b0011,
                XOR_Oper  = 4'b0100,
                SRL_Oper  = 4'b0101,
                OR_Oper   = 4'b0110,
                AND_Oper  = 4'b0111,
                SUB_Oper  = 4'b1000,
                SRA_Oper  = 4'b1101;
    
    xor64 xoroper(
        .in1(a), 
        .in2(b), 
        .out(xor_result), 
        .z_xor_flag(xor_z)
        );
    or64 oroper(
        .in1(a), 
        .in2(b), 
        .out(or_result), 
        .z_or_flag(or_z)
        );
    and64 andoper(
        .in1(a), 
        .in2(b), 
        .out(and_result), 
        .z_and_flag(and_z)
        );
    add64 addoper(
        .in1(a), 
        .in2(b), 
        .out(add_result), 
        .z_add_flag(add_z),
        .c_add_flag(add_c),
        .o_add_flag(add_o)
        );
    sub64 suboper(
        .in1(a), 
        .in2(b), 
        .out(sub_result), 
        .z_sub_flag(sub_z),
        .c_sub_flag(sub_c),
        .o_sub_flag(sub_o)
        );
    sll64 slloper(
        .in1(a), 
        .in2(b), 
        .out(sll_result), 
        .z_sll_flag(sll_z)
        );
    srl64 srloper(
        .in1(a), 
        .in2(b), 
        .out(srl_result), 
        .z_srl_flag(srl_z)
        );
    sra64 sraoper(
        .in1(a), 
        .in2(b), 
        .out(sra_result), 
        .z_sra_flag(sra_z)
        );
    sltu64 sltuoper(
        .in1(a), 
        .in2(b), 
        .out(sltu_result), 
        .z_sltu_flag(sltu_z)
    );
    slt64 sltoper(
        .in1(a), 
        .in2(b), 
        .out(slt_result), 
        .z_slt_flag(slt_z)
    );
    always @(*) begin
        
    case (opcode)
        AND_Oper: begin
            temp_result = and_result;
            temp_zf = and_z;
            temp_cf=1'b0;
            temp_of=1'b0;
        end
        OR_Oper: begin
            temp_result = or_result;
            temp_zf = or_z;
            temp_cf=1'b0;
            temp_of=1'b0;
        end
        XOR_Oper: begin
            temp_result = xor_result;
            temp_zf = xor_z;
            temp_cf=1'b0;
            temp_of=1'b0;
        end
        ADD_Oper: begin
            temp_result = add_result;
            temp_zf= add_z;
            temp_cf= add_c;
            temp_of= add_o;
        end
        SUB_Oper: begin
            temp_result = sub_result;
            temp_zf= sub_z;
            temp_cf= sub_c;
            temp_of= sub_o;
        end
        SLL_Oper: begin
            temp_result = sll_result;
            temp_zf= sll_z;
            temp_cf=1'b0;
            temp_of=1'b0;
        end
        SRL_Oper: begin
            temp_result = srl_result;
            temp_zf= srl_z;
            temp_cf=1'b0;
            temp_of=1'b0;
        end
        SRA_Oper: begin
            temp_result = sra_result;
            temp_zf= sra_z;
            temp_cf=1'b0;
            temp_of=1'b0;
        end
        SLTU_Oper: begin
            temp_result = sltu_result;
            temp_zf= sltu_z;
            temp_cf=1'b0;
            temp_of=1'b0;
        end
        SLT_Oper: begin
            temp_result = slt_result;
            temp_zf= slt_z;
            temp_cf=1'b0;
            temp_of=1'b0;
        end
        default: begin
            temp_result =64'b0;
            temp_zf=1'b1;
            temp_cf= 1'b0;
            temp_of= 1'b0;
        end
    endcase
    end
endmodule