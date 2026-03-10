// module Forwarding_Unit(
//     input wire [4:0] ID_EX_rs1, ID_EX_rs2,
//     input wire [4:0] EX_MEM_rd, MEM_WB_rd,
//     input wire EX_MEM_RegWrite, MEM_WB_RegWrite,
//     output reg [1:0] ForwardA, ForwardB
// );
//     always @(*) begin
//         ForwardA = 2'b00; ForwardB = 2'b00;

//         //MEM to EX
//         if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1))
//             ForwardA = 2'b10;
//         //WB to EX
//         else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1))
//             ForwardA = 2'b01;
//         if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2))
//             ForwardB = 2'b10;
//         else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2))
//             ForwardB = 2'b01;
//     end
// endmodule
// Forwarding Unit for pipeline hazard resolution
module Forwarding_Unit(
    input wire [4:0] ID_EX_rs1,          
    input wire [4:0] ID_EX_rs2,          
    input wire [4:0] EX_MEM_rd,          
    input wire EX_MEM_RegWrite,         
    input wire [4:0] MEM_WB_rd,          
    input wire MEM_WB_RegWrite,         
    output wire [1:0] ForwardA,           // forwarding control for first ALU operand
    output wire [1:0] ForwardB            // second ALU operand
);

    // ForwardX values, 00 = No forwarding (use ID/EX register, as it is)
    // 01 = Forward from MEM/WB stage
    // 10 = Forward from EX/MEM stage

    reg [1:0] ForwardA_reg, ForwardB_reg;

    always @(*) begin

        // Assume no forwarding
        ForwardA_reg = 2'b00;
        ForwardB_reg = 2'b00;
        
        // EX hazard for rs1 (ForwardA)
        if (EX_MEM_RegWrite && 
            (EX_MEM_rd != 5'b0) &&
            (EX_MEM_rd == ID_EX_rs1)) begin
            ForwardA_reg = 2'b10;  
        end

        // MEM hazard for rs1 (ForwardA)
        else if (MEM_WB_RegWrite && 
                 (MEM_WB_rd != 5'b0) &&
                 !(EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) && // give priority to EX/MEM stage
                 (MEM_WB_rd == ID_EX_rs1)) begin
            ForwardA_reg = 2'b01;  // from MEM/WB 
        end
        
        // EX hazard for rs2 (ForwardB)
        if (EX_MEM_RegWrite && 
            (EX_MEM_rd != 5'b0) &&
            (EX_MEM_rd == ID_EX_rs2)) begin
            ForwardB_reg = 2'b10;  // from EX/MEM 
        end
        // MEM hazard for rs2 (ForwardB)
        else if (MEM_WB_RegWrite && 
                 (MEM_WB_rd != 5'b0) &&
                 !(EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) && // give priority to EX/MEM stage
                 (MEM_WB_rd == ID_EX_rs2)) begin
            ForwardB_reg = 2'b01;  // from MEM/WB
        end
    end

    assign ForwardA = ForwardA_reg;
    assign ForwardB = ForwardB_reg;

endmodule

// #TODO : ld followed by store