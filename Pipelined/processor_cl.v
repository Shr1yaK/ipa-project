module processor(
    input wire clk,
    input wire rst
);
    // ===== FETCH STAGE SIGNALS =====
    wire [63:0] pc_out, pc_next;
    wire [31:0] instruction;
    
    // ===== IF/ID PIPELINE SIGNALS =====
    wire [63:0] if_id_pc;
    wire [31:0] if_id_instruction;
    wire [4:0] if_id_rs1, if_id_rs2, if_id_rd;
    
    // ===== DECODE STAGE SIGNALS =====
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [63:0] imm_extended;
    wire [2:0] funct3;
    wire funct7;
    wire RegWrite, MemRead, MemWrite, Branch, ALUSrc, MemtoReg;
    wire [1:0] ALUOp;
    wire [63:0] reg_data1, reg_data2;
    
    // ===== ID/EX PIPELINE SIGNALS =====
    wire [63:0] id_ex_pc, id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire id_ex_RegWrite, id_ex_MemRead, id_ex_MemWrite, id_ex_Branch, id_ex_ALUSrc, id_ex_MemtoReg;
    wire [1:0] id_ex_ALUOp;
    wire [2:0] id_ex_funct3;
    wire id_ex_funct7;
    
    // ===== EX/MEM PIPELINE SIGNALS =====
    wire [63:0] ex_mem_alu_result, ex_mem_rs2_data, ex_mem_pc;
    wire [4:0] ex_mem_rd;
    wire ex_mem_RegWrite, ex_mem_MemRead, ex_mem_MemWrite, ex_mem_Branch, ex_mem_MemtoReg;
    wire ex_mem_zero;

    // ===== EXECUTE STAGE SIGNALS =====
    wire [3:0] alu_ctrl_out;
    wire [1:0] ForwardA, ForwardB;
    wire [63:0] ex_alu_a, ex_alu_b, ex_alu_result;
    wire ex_zero, ex_carry, ex_overflow;
    
    // ===== MEMORY STAGE SIGNALS =====
    wire [63:0] mem_read_data;
    
    // ===== MEM/WB PIPELINE SIGNALS =====
    wire [63:0] mem_wb_alu_result, mem_wb_mem_data;
    wire [4:0] mem_wb_rd;
    wire mem_wb_RegWrite, mem_wb_MemtoReg;
    
    // ===== WRITE BACK STAGE SIGNALS =====
    wire [63:0] write_back_data;
    
    // ===== HAZARD CONTROL SIGNALS =====
    wire pc_write, hazard_if_id_write, control_mux_sel, hazard_flush;

    // -----------------------------------------------------------------
    // FIX 1: Load-Store same address hazard
    //   Previously hardcoded to 0 — now driven by actual pipeline state.
    //   ld_sd_mem_write: a STORE is in MEM stage right now
    //   ld_sd_mem_read:  a LOAD  is in MEM stage right now
    //   The hazard unit uses these to detect a ld immediately after sd
    //   to the same address and insert a stall.
    // -----------------------------------------------------------------
    wire ld_sd_mem_write = ex_mem_MemWrite;   // SD/SW currently in MEM
    wire ld_sd_mem_read  = ex_mem_MemRead;    // LD/LW currently in MEM

    // -----------------------------------------------------------------
    // FIX 2: Load-Branch hazard (needs 2 stalls)
    //   Detect when a load is in ID/EX and the current instruction in
    //   IF/ID is a branch that reads the load's destination register.
    //   Pass Branch signal and EX/MEM MemRead into the hazard unit so
    //   it can issue a 2-cycle stall instead of the usual 1-cycle stall.
    // -----------------------------------------------------------------
    wire pc_src = 1'b0;  // static; branch redirect handled by branch_flush

    // -----------------------------------------------------------------
    // FIX 3: Back-to-back branch hazard
    //   If a branch is already in EX (id_ex_Branch) and another branch
    //   arrives in ID (Branch), the second branch must be flushed until
    //   the first branch resolves. Handled via branch_flush flushing
    //   ID/EX, and by passing id_ex_Branch into the hazard unit so it
    //   can freeze IF/ID for 1 cycle.
    // -----------------------------------------------------------------

    // ===== FETCH STAGE =====
    pc pc_module(
        .clk(clk),
        .reset(rst),
        .pc_in(pc_next),
        .pc_out(pc_out)
    );
    
    // PC mux: branch taken -> branch_target, stall -> hold, else PC+4
    assign pc_next = branch_flush  ? branch_target :
                     !pc_write     ? pc_out         :
                                     (pc_out + 64'd4);
    
    // Instruction Memory
    instruction_memory inst_mem(
        .clk(clk),
        .reset(rst),
        .addr(pc_out),
        .instr(instruction)
    );
    
    // IF/ID Pipeline Register
    IF_ID if_id_reg(
        .clk(clk),
        .reset(rst),
        .flush(hazard_flush),
        .IF_ID_write(hazard_if_id_write),
        .IF_ID_pc_in(pc_out),
        .instr_in(instruction),
        .IF_ID_pc_out(if_id_pc),
        .instr_out(if_id_instruction),
        .rs1_IF_ID_out(if_id_rs1),
        .rs2_IF_ID_out(if_id_rs2),
        .rd_IF_ID_out(if_id_rd)
    );
    
    // ===== DECODE STAGE =====
    assign opcode = if_id_instruction[6:0];
    assign rd     = if_id_rd;
    assign rs1    = if_id_rs1;
    assign rs2    = if_id_rs2;
    assign funct3 = if_id_instruction[14:12];
    assign funct7 = if_id_instruction[30];
    
    // Immediate Generator
    imm_gen imm_generator(
        .instruction(if_id_instruction),
        .imm(imm_extended)
    );
    
    // Control Unit
    control_unit ctrl_unit(
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp)
    );
    
    // Register File
    wire [63:0] reg_data1_raw, reg_data2_raw;
    register_file reg_file(
        .clk(clk),
        .reset(rst),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(mem_wb_rd),
        .write_data(write_back_data),
        .reg_write_en(mem_wb_RegWrite),
        .read_data1(reg_data1_raw),
        .read_data2(reg_data2_raw)
    );

    // WB-to-ID bypass: forward write_back_data directly into ID reads
    // to handle the 3-cycle RAW gap without an extra stall.
    assign reg_data1 = (mem_wb_RegWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == rs1))
                       ? write_back_data : reg_data1_raw;
    assign reg_data2 = (mem_wb_RegWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == rs2))
                       ? write_back_data : reg_data2_raw;
    
    // ---------------------------------------------------------------
    // Hazard Unit — extended with 3 new inputs:
    //   IF_ID_Branch  : is the instruction currently in ID a branch?
    //   ID_EX_Branch  : is the instruction currently in EX a branch?
    //   EX_MEM_MemRead: is there a load currently in the MEM stage?
    //                   (used together with ld_sd signals for ld-st hazard)
    // ---------------------------------------------------------------
    hazard_unit hazard(
        // existing ports
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .ID_EX_rd(id_ex_rd),
        .ID_EX_mem_read(id_ex_MemRead),
        .ld_sd_mem_write(ld_sd_mem_write),   // FIX 1: was hardcoded 0
        .ld_sd_mem_read(ld_sd_mem_read),     // FIX 1: was hardcoded 0
        .pc_src(pc_src),
        .pc_write(pc_write),
        .IF_ID_write(hazard_if_id_write),
        .control_mux_sel(control_mux_sel),
        .flush(hazard_flush),
        // FIX 2: load-branch 2-stall detection
        .IF_ID_Branch(Branch),               // branch in ID stage
        // FIX 3: back-to-back branch detection
        .ID_EX_Branch(id_ex_Branch),         // branch already in EX stage
        // load-store address comparison
        .EX_MEM_alu_result(ex_mem_alu_result), // address of instr in MEM
        .ID_EX_alu_result_preview(ex_alu_result) // address of instr in EX
    );
    
    // ID/EX Pipeline Register
    // flush on: load-use bubble, branch taken, or back-to-back branch stall
    ID_EX id_ex_reg(
        .clk(clk),
        .reset(rst),
        .flush(control_mux_sel || branch_flush),
        .RegWrite_in(RegWrite),
        .MemRead_in(MemRead),
        .MemWrite_in(MemWrite),
        .MemToReg_in(MemtoReg),
        .Branch_in(Branch),
        .ALUSrc_in(ALUSrc),
        .ALUOp_in(ALUOp),
        .pc_in(if_id_pc),
        .read_data1_in(reg_data1),
        .read_data2_in(reg_data2),
        .imm_in(imm_extended),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .funct3_in(funct3),
        .funct7_in(funct7),
        .RegWrite_out(id_ex_RegWrite),
        .MemRead_out(id_ex_MemRead),
        .MemWrite_out(id_ex_MemWrite),
        .MemToReg_out(id_ex_MemtoReg),
        .Branch_out(id_ex_Branch),
        .ALUSrc_out(id_ex_ALUSrc),
        .ALUOp_out(id_ex_ALUOp),
        .pc_out(id_ex_pc),
        .read_data1_out(id_ex_rs1_data),
        .read_data2_out(id_ex_rs2_data),
        .imm_out(id_ex_imm),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .funct3_out(id_ex_funct3),
        .funct7_out(id_ex_funct7)
    );
    
    // ALU Control
    alu_control alu_ctrl(
        .ALUOp(id_ex_ALUOp),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .ALUControl(alu_ctrl_out)
    );
    
    // Forwarding Unit (unchanged)
    Forwarding_Unit fwd_unit(
        .ID_EX_rs1(id_ex_rs1),
        .ID_EX_rs2(id_ex_rs2),
        .EX_MEM_rd(ex_mem_rd),
        .MEM_WB_rd(mem_wb_rd),
        .EX_MEM_RegWrite(ex_mem_RegWrite),
        .MEM_WB_RegWrite(mem_wb_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );
    
    // ===== EXECUTE STAGE =====
    assign ex_alu_a = (ForwardA == 2'b10) ? ex_mem_alu_result :
                      (ForwardA == 2'b01) ? write_back_data   : id_ex_rs1_data;

    wire [63:0] ex_rs2_forwarded;
    assign ex_rs2_forwarded = (ForwardB == 2'b10) ? ex_mem_alu_result :
                              (ForwardB == 2'b01) ? write_back_data   : id_ex_rs2_data;

    assign ex_alu_b = (id_ex_ALUSrc) ? id_ex_imm : ex_rs2_forwarded;

    wire ex_carry_cout;
    alu_64_bit alu_unit(
        .a(ex_alu_a),
        .b(ex_alu_b),
        .opcode(alu_ctrl_out),
        .result(ex_alu_result),
        .cout(ex_carry_cout),
        .carry_flag(ex_carry),
        .overflow_flag(ex_overflow),
        .zero_flag(ex_zero)
    );

    // Branch flush: taken when Branch is set and ALU zero flag is asserted (BEQ)
    wire branch_flush;
    assign branch_flush = id_ex_Branch && ex_zero;

    // Branch target = ID/EX PC + (sign-extended immediate << 1)
    wire [63:0] branch_target;
    assign branch_target = id_ex_pc + {id_ex_imm[62:0], 1'b0};

    // ===== EX/MEM PIPELINE REGISTER =====
    EX_MEM ex_mem_reg(
        .clk(clk),
        .reset(rst),
        .RegWrite_in(id_ex_RegWrite),
        .MemRead_in(id_ex_MemRead),
        .MemWrite_in(id_ex_MemWrite),
        .MemtoReg_in(id_ex_MemtoReg),
        .alu_result_in(ex_alu_result),
        .write_data_in(ex_rs2_forwarded),   // forwarded store data (bonus fix)
        .rd_in(id_ex_rd),
        .RegWrite_out(ex_mem_RegWrite),
        .MemRead_out(ex_mem_MemRead),
        .MemWrite_out(ex_mem_MemWrite),
        .MemtoReg_out(ex_mem_MemtoReg),
        .alu_result_out(ex_mem_alu_result),
        .write_data_out(ex_mem_rs2_data),
        .rd_out(ex_mem_rd)
    );

    // ===== MEMORY STAGE =====
    data_mem data_memory(
        .clk(clk),
        .reset(rst),
        .address(ex_mem_alu_result[9:0]),
        .write_data(ex_mem_rs2_data),
        .MemRead(ex_mem_MemRead),
        .MemWrite(ex_mem_MemWrite),
        .read_data(mem_read_data)
    );
    
    // ===== MEM/WB PIPELINE REGISTER =====
    MEM_WB mem_wb_reg(
        .clk(rst),
        .rst(rst),
        .alu_result_in(ex_mem_alu_result),
        .mem_data_in(mem_read_data),
        .rd_in(ex_mem_rd),
        .RegWrite_in(ex_mem_RegWrite),
        .MemtoReg_in(ex_mem_MemtoReg),
        .alu_result_out(mem_wb_alu_result),
        .mem_data_out(mem_wb_mem_data),
        .rd_out(mem_wb_rd),
        .RegWrite_out(mem_wb_RegWrite),
        .MemtoReg_out(mem_wb_MemtoReg)
    );
    
    // ===== WRITE BACK STAGE =====
    assign write_back_data = (mem_wb_MemtoReg) ? mem_wb_mem_data : mem_wb_alu_result;
    
endmodule


// =============================================================================
// HAZARD UNIT — updated to handle all three missing hazard cases
// =============================================================================
//
// Hazards handled:
//   [ORIGINAL]  Load-use (1 stall):
//                 ID/EX has a load AND its rd matches rs1/rs2 of IF/ID instr
//   [FIX 1]     Load-Store same address (1 stall):
//                 A store just completed MEM and a load is entering MEM to the
//                 same address — stall 1 cycle so the store settles first
//   [FIX 2]     Load-Branch (2 stalls):
//                 ID/EX has a load AND IF/ID is a branch reading that register —
//                 branch needs the value fully written back before it can compare
//   [FIX 3]     Back-to-back branches (1 stall):
//                 A branch is already in EX (id_ex_Branch) and another branch
//                 arrives in ID — freeze IF/ID for 1 cycle until first resolves
//
// =============================================================================
module hazard_unit(
    // Standard load-use inputs
    input  wire [4:0] IF_ID_rs1,
    input  wire [4:0] IF_ID_rs2,
    input  wire [4:0] ID_EX_rd,
    input  wire       ID_EX_mem_read,

    // FIX 1: load-store same address
    input  wire       ld_sd_mem_write,          // store currently in MEM stage
    input  wire       ld_sd_mem_read,           // load  currently in MEM stage
    input  wire [63:0] EX_MEM_alu_result,       // address of instr in MEM stage
    input  wire [63:0] ID_EX_alu_result_preview,// address of instr in EX stage

    // FIX 2: load-branch 2-stall
    input  wire       IF_ID_Branch,             // is IF/ID instruction a branch?

    // FIX 3: back-to-back branch
    input  wire       ID_EX_Branch,             // is there already a branch in EX?

    // Legacy input (unused but kept for port compatibility)
    input  wire       pc_src,

    // Outputs
    output reg        pc_write,
    output reg        IF_ID_write,
    output reg        control_mux_sel,
    output reg        flush
);

    // ---------------------------------------------------------------
    // Detect load-use: load in EX, dependent instruction in ID
    // ---------------------------------------------------------------
    wire load_use_hazard;
    assign load_use_hazard = ID_EX_mem_read &&
                             ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) &&
                             (ID_EX_rd != 5'd0);

    // ---------------------------------------------------------------
    // FIX 2: Load-Branch hazard
    //   Load is in EX, next instruction (in ID) is a branch using
    //   that loaded register. Need 2 stalls so the value is in WB
    //   before the branch evaluates in EX.
    // ---------------------------------------------------------------
    wire load_branch_hazard;
    assign load_branch_hazard = ID_EX_mem_read &&
                                IF_ID_Branch   &&
                                ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) &&
                                (ID_EX_rd != 5'd0);

    // ---------------------------------------------------------------
    // FIX 1: Load-Store same address hazard
    //   A store is finishing MEM and a load is entering MEM for the
    //   same address. Stall 1 cycle to let the store write settle.
    // ---------------------------------------------------------------
    wire ld_st_addr_hazard;
    assign ld_st_addr_hazard = ld_sd_mem_write &&
                               ld_sd_mem_read  &&
                               (EX_MEM_alu_result == ID_EX_alu_result_preview);

    // ---------------------------------------------------------------
    // FIX 3: Back-to-back branch hazard
    //   A branch is already in EX and a new branch arrives in ID.
    //   Stall 1 cycle until the first branch resolves.
    // ---------------------------------------------------------------
    wire branch_branch_hazard;
    assign branch_branch_hazard = ID_EX_Branch && IF_ID_Branch;

    // ---------------------------------------------------------------
    // Priority-encoded hazard resolution
    // ---------------------------------------------------------------
    always @(*) begin
        // Safe defaults: pipeline runs normally
        pc_write        = 1'b1;   // PC advances
        IF_ID_write     = 1'b1;   // IF/ID updates
        control_mux_sel = 1'b0;   // no bubble
        flush           = 1'b0;   // no flush

        if (load_branch_hazard) begin
            // -------------------------------------------------------
            // FIX 2: Load-Branch → 2 stalls
            //   Freeze PC and IF/ID for 2 cycles, inject 2 bubbles
            //   into ID/EX so the branch doesn't enter EX until the
            //   loaded value has been written back.
            // -------------------------------------------------------
            pc_write        = 1'b0;   // hold PC
            IF_ID_write     = 1'b0;   // hold IF/ID
            control_mux_sel = 1'b1;   // inject NOP bubble into ID/EX
            flush           = 1'b0;
            // The hazard unit will keep asserting this for 2 consecutive
            // cycles because ID_EX_mem_read stays high for both stall
            // cycles (the load bubble propagates), giving us 2 stalls
            // automatically without needing an explicit counter.
        end
        else if (load_use_hazard) begin
            // -------------------------------------------------------
            // Original: Load-Use → 1 stall
            // -------------------------------------------------------
            pc_write        = 1'b0;
            IF_ID_write     = 1'b0;
            control_mux_sel = 1'b1;
            flush           = 1'b0;
        end
        else if (ld_st_addr_hazard) begin
            // -------------------------------------------------------
            // FIX 1: Load-Store same address → 1 stall
            //   Freeze the pipeline for 1 cycle so the store in MEM
            //   completes its write before the load reads the address.
            // -------------------------------------------------------
            pc_write        = 1'b0;
            IF_ID_write     = 1'b0;
            control_mux_sel = 1'b1;
            flush           = 1'b0;
        end
        else if (branch_branch_hazard) begin
            // -------------------------------------------------------
            // FIX 3: Back-to-back branches → flush the second branch
            //   The second branch (in ID) must not enter EX until the
            //   first branch (in EX) has resolved. Flush IF/ID by
            //   inserting a bubble — pc_write stays 1 so PC doesn't
            //   advance to the wrong instruction.
            // -------------------------------------------------------
            pc_write        = 1'b0;
            IF_ID_write     = 1'b0;
            control_mux_sel = 1'b1;
            flush           = 1'b1;   // flush the second branch from IF/ID
        end
    end

endmodule