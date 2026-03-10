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
    wire [2:0]id_ex_funct3;
    wire id_ex_funct7;
    
    // ===== EXECUTE STAGE SIGNALS =====
    wire [3:0] alu_ctrl_out;
    wire [1:0] ForwardA, ForwardB;
    wire [63:0] ex_alu_a, ex_alu_b, ex_alu_result;
    wire ex_zero, ex_carry, ex_overflow;
    
    
    // ===== EX/MEM PIPELINE SIGNALS =====
    wire [63:0] ex_mem_alu_result, ex_mem_rs2_data, ex_mem_pc;
    wire [4:0] ex_mem_rd;
    wire ex_mem_RegWrite, ex_mem_MemRead, ex_mem_MemWrite, ex_mem_Branch, ex_mem_MemtoReg;
    wire ex_mem_zero;
    
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
    wire pc_src = 1'b0;
    wire ld_sd_mem_write = 1'b0;
    wire ld_sd_mem_read = 1'b0;
    
    // ===== FETCH STAGE =====
    pc pc_module(
        .clk(clk),
        .reset(rst),
        .pc_in(pc_next),
        .pc_out(pc_out)
    );
    
    // PC mux: branch taken -> branch_target (EX stage), stall -> hold, else PC+4
    // branch_target is declared as a forward wire reference below - legal in Verilog.
    assign pc_next = branch_flush  ? branch_target  :
                     !pc_write     ? pc_out          :
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
        .flush(hazard_flush),  // branch_flush excluded: pc_out already == branch_target
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
    // Decode instruction fields
    assign opcode = if_id_instruction[6:0];
    assign rd = if_id_rd;
    assign rs1 = if_id_rs1;
    assign rs2 = if_id_rs2;
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

    // WB-to-ID bypass: if WB is writing to the same register being read in ID
    // this cycle, forward the write_back_data directly (fixes 3-cycle RAW gap)
    assign reg_data1 = (mem_wb_RegWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == rs1))
                       ? write_back_data : reg_data1_raw;
    assign reg_data2 = (mem_wb_RegWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == rs2))
                       ? write_back_data : reg_data2_raw;
    
    // Hazard Unit
    hazard_unit hazard(
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .ID_EX_rd(id_ex_rd),
        .ID_EX_mem_read(id_ex_MemRead),
        .ld_sd_mem_write(ld_sd_mem_write),
        .ld_sd_mem_read(ld_sd_mem_read),
        .pc_src(pc_src),
        .pc_write(pc_write),
        .IF_ID_write(hazard_if_id_write),
        .control_mux_sel(control_mux_sel),
        .flush(hazard_flush)
    );
    
    // ID/EX Pipeline Register
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
    
    // funct3 and funct7 are now properly pipelined via ID_EX register (see funct3_out, funct7_out above)
    
    // ALU Control
    alu_control alu_ctrl(
        .ALUOp(id_ex_ALUOp),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .ALUControl(alu_ctrl_out)
    );
    
    // Forwarding Unit
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
    // Forwarding Multiplexers
    assign ex_alu_a = (ForwardA == 2'b10) ? ex_mem_alu_result :
                      (ForwardA == 2'b01) ? write_back_data : id_ex_rs1_data;

    // ForwardB selects the forwarded rs2 (before ALUSrc mux)
    // Also used as store data for SD/SW to fix the unforwarded store bug
    wire [63:0] ex_rs2_forwarded;
    assign ex_rs2_forwarded = (ForwardB == 2'b10) ? ex_mem_alu_result :
                              (ForwardB == 2'b01) ? write_back_data : id_ex_rs2_data;

    assign ex_alu_b = (id_ex_ALUSrc) ? id_ex_imm : ex_rs2_forwarded;

    // ALU
    wire ex_carry_cout; // separate wire to avoid multi-driver on ex_carry
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

    // Branch flush: taken when Branch is set and ALU result is zero (BEQ)
    wire branch_flush;
    assign branch_flush = id_ex_Branch && ex_zero;

    // Branch target = PC of the branch (in ID/EX stage) + sign-extended imm << 1
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
        .write_data_in(ex_rs2_forwarded),
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
    // Load-Store Forwarding Unit
    wire ld_sd_forward_sel;
    
    ld_sd_forward ld_sd_fwd_unit(
        .ld_rd(mem_wb_rd),
        .sd_rs2_data(ex_mem_rd),
        .ld_sd_mem_to_reg(mem_wb_MemtoReg),
        .ld_sd_mem_write(ex_mem_MemWrite),
        .ld_sd_sel(ld_sd_forward_sel)
    );
    
    // Data Memory - with load-store forwarding
    // If forwarding is needed, use mem_wb_mem_data instead of reading from memory
    wire [63:0] mem_stage_read_data;
    assign mem_stage_read_data = (ld_sd_forward_sel && mem_wb_MemtoReg) 
                                  ? mem_wb_mem_data 
                                  : mem_read_data;
    
    // Data Memory
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
        .clk(clk),
        .rst(rst),
        .alu_result_in(ex_mem_alu_result),
        .mem_data_in(mem_stage_read_data),
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
    // Write Back Multiplexer
    assign write_back_data = (mem_wb_MemtoReg) ? mem_wb_mem_data : mem_wb_alu_result;
    
endmodule