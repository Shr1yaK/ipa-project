`timescale 1ns/1ps
`include "processor.v"
`include "alu.v"
`include "PC.v"
`include "instruction_mem.v"
`include "IF_ID.v"
`include "imm_gen.v"
`include "control_unit.v"
`include "register_file.v"
`include "hazard_unit.v"
`include "ID_EX.v"
`include "alu_control.v"
`include "Forwarding_unit.v"
`include "EXstage.v"
`include "EX_MEM.v"
`include "data_mem.v"
`include "MEM_WB.v"
`include "ld_sd_forward.v"
//`include "processor.v"
module processor_tb;
    reg clk, rst;
    integer cycle_count;
    integer i, file_handle;
    integer status_file;

    // ---------------------------------------------------------------
    // Pipeline-drain tracking for accurate cycle counting
    //
    // Strategy:
    //   1. Detect the last valid instruction by watching the IF stage.
    //      An instruction is "valid" when the PC is within the program
    //      (instruction memory returns a non-NOP / non-X value).
    //      We mark a fetch as valid when the fetched instruction is not
    //      all-zeros (NOP / empty memory) and not X.
    //
    //   2. Once we see an invalid/empty fetch after at least one valid
    //      instruction, we know the program has finished fetching.
    //      We then wait exactly 4 more cycles for the last instruction
    //      to drain through ID → EX → MEM → WB.
    //
    //   3. cycle_count is incremented only for cycles where at least
    //      one pipeline stage is doing real work i.e., from the first
    //      valid fetch until the last WB completes.
    // ---------------------------------------------------------------

    reg         program_started;   // 1 after first valid instruction fetch
    reg         fetch_done;        // 1 once PC has gone past valid program
    reg  [2:0]  drain_counter;     // counts the 4 drain cycles after fetch_done
    reg         sim_done;          // triggers end-of-simulation

    // Instantiate processor
    processor dut(
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation
    always begin
        clk = 0;
        #5 clk = 1;
        #5;
    end
    
    initial begin
        cycle_count     = 0;
        program_started = 0;
        fetch_done      = 0;
        drain_counter   = 0;
        sim_done        = 0;
        rst = 1;
        status_file = $fopen("status.txt", "w");
        
        $fwrite(status_file, "RISC-V 64-bit Pipelined Processor Status Log\n");
        $fwrite(status_file, "=============================================\n\n");
        
        #10;
        rst = 0;

        // Wait until the simulation logic signals completion
        @(posedge sim_done);

        // Write final results to file
        file_handle = $fopen("register_file.txt", "w");
        for (i = 0; i < 32; i = i + 1) begin
            $fwrite(file_handle, "%016h\n", dut.reg_file.registers[i]);
        end
        $fwrite(file_handle, "%d\n", cycle_count);
        $fclose(file_handle);
        $fclose(status_file);

        $display("Simulation complete after %0d cycles. Results written to register_file.txt", cycle_count);
        $finish;
    end
    
    // ---------------------------------------------------------------
    // Cycle counter + pipeline-drain state machine
    // ---------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst) begin

            // ---- Detect whether the current IF fetch is a real instruction ----
            // Use === (4-state equality) to detect X/Z bits:
            //   (x === 32'hxxxxxxxx) is TRUE only when all bits are X.
            // A real instruction is one that is fully defined and non-zero.
            if ((dut.instruction !== 32'hxxxxxxxx) &&
                (dut.instruction !== 32'hzzzzzzzz) &&
                (dut.instruction !== 32'h00000000)) begin
                program_started <= 1;
                fetch_done      <= 0;   // still fetching real instructions
            end else if (program_started && !fetch_done) begin
                // First idle/empty fetch after real work — program ROM exhausted
                fetch_done <= 1;
            end

            // ---- Count cycles only while real work is in-flight ----
            if (program_started && !sim_done) begin
                cycle_count = cycle_count + 1;
            end

            // ---- Drain counter: 4 cycles to flush last instruction through ----
            // ID(1) + EX(2) + MEM(3) + WB(4) after the last IF cycle
            if (fetch_done && !sim_done) begin
                if (drain_counter < 4) begin
                    drain_counter <= drain_counter + 1;
                end else begin
                    sim_done <= 1;   // pipeline fully drained
                end
            end

            // ---- Log status every active cycle ----
            if (program_started && !sim_done) begin
                log_pipeline_status();
            end
        end
    end
    
    // Task to log pipeline status
    task log_pipeline_status;
        begin
            $fwrite(status_file, "=== Cycle %0d ===\n", cycle_count);
            
            // FETCH STAGE
            $fwrite(status_file, "\n[FETCH STAGE]\n");
            $fwrite(status_file, "  PC: 0x%016h\n", dut.pc_out);
            $fwrite(status_file, "  Instruction: 0x%08h\n", dut.instruction);
            
            // IF/ID PIPELINE REGISTER
            $fwrite(status_file, "\n[IF/ID Pipeline Register]\n");
            $fwrite(status_file, "  IF_ID_PC: 0x%016h\n", dut.if_id_pc);
            $fwrite(status_file, "  IF_ID_Instruction: 0x%08h\n", dut.if_id_instruction);
            $fwrite(status_file, "  IF_ID_rs1: x%0d\n", dut.if_id_rs1);
            $fwrite(status_file, "  IF_ID_rs2: x%0d\n", dut.if_id_rs2);
            $fwrite(status_file, "  IF_ID_rd: x%0d\n", dut.if_id_rd);
            
            // DECODE STAGE
            $fwrite(status_file, "\n[DECODE STAGE]\n");
            $fwrite(status_file, "  Opcode: 0x%02h\n", dut.opcode);
            $fwrite(status_file, "  rs1: x%0d, rs2: x%0d, rd: x%0d\n", dut.rs1, dut.rs2, dut.rd);
            $fwrite(status_file, "  Immediate: 0x%016h\n", dut.imm_extended);
            $fwrite(status_file, "  RegWrite: %0d, MemRead: %0d, MemWrite: %0d\n", dut.RegWrite, dut.MemRead, dut.MemWrite);
            $fwrite(status_file, "  Branch: %0d, ALUSrc: %0d, MemtoReg: %0d\n", dut.Branch, dut.ALUSrc, dut.MemtoReg);
            $fwrite(status_file, "  ALUOp: %0d\n", dut.ALUOp);
            $fwrite(status_file, "  Read_Data1: 0x%016h, Read_Data2: 0x%016h\n", dut.reg_data1, dut.reg_data2);
            
            // ID/EX PIPELINE REGISTER
            $fwrite(status_file, "\n[ID/EX Pipeline Register]\n");
            $fwrite(status_file, "  ID_EX_PC: 0x%016h\n", dut.id_ex_pc);
            $fwrite(status_file, "  ID_EX_rs1_data: 0x%016h\n", dut.id_ex_rs1_data);
            $fwrite(status_file, "  ID_EX_rs2_data: 0x%016h\n", dut.id_ex_rs2_data);
            $fwrite(status_file, "  ID_EX_imm: 0x%016h\n", dut.id_ex_imm);
            $fwrite(status_file, "  ID_EX_rs1: x%0d, ID_EX_rs2: x%0d, ID_EX_rd: x%0d\n", dut.id_ex_rs1, dut.id_ex_rs2, dut.id_ex_rd);
            $fwrite(status_file, "  ID_EX_RegWrite: %0d, ID_EX_MemRead: %0d, ID_EX_MemWrite: %0d\n", dut.id_ex_RegWrite, dut.id_ex_MemRead, dut.id_ex_MemWrite);
            $fwrite(status_file, "  ID_EX_Branch: %0d, ID_EX_ALUSrc: %0d, ID_EX_MemtoReg: %0d\n", dut.id_ex_Branch, dut.id_ex_ALUSrc, dut.id_ex_MemtoReg);
            $fwrite(status_file, "  ID_EX_ALUOp: %0d\n", dut.id_ex_ALUOp);
            
            // EXECUTE STAGE
            $fwrite(status_file, "\n[EXECUTE STAGE]\n");
            $fwrite(status_file, "  ALU_Control: 0x%01h\n", dut.alu_ctrl_out);
            $fwrite(status_file, "  ForwardA: %0d, ForwardB: %0d\n", dut.ForwardA, dut.ForwardB);
            $fwrite(status_file, "  ALU_A: 0x%016h\n", dut.ex_alu_a);
            $fwrite(status_file, "  ALU_B: 0x%016h\n", dut.ex_alu_b);
            $fwrite(status_file, "  ALU_Result: 0x%016h\n", dut.ex_alu_result);
            $fwrite(status_file, "  Zero: %0d, Carry: %0d, Overflow: %0d\n", dut.ex_zero, dut.ex_carry, dut.ex_overflow);
            
            // EXstage OUTPUT
            // $fwrite(status_file, "\n[EXstage Module Output]\n");
            // $fwrite(status_file, "  exstage_alu_result: 0x%016h\n", dut.exstage_alu_result);
            // $fwrite(status_file, "  exstage_rs2_data: 0x%016h\n", dut.exstage_rs2_data);
            // $fwrite(status_file, "  exstage_rd: x%0d\n", dut.exstage_rd);
            // $fwrite(status_file, "  exstage_RegWrite: %0d, exstage_MemRead: %0d, exstage_MemWrite: %0d\n", 
            //          dut.exstage_RegWrite, dut.exstage_MemRead, dut.exstage_MemWrite);
            
            // EX/MEM PIPELINE REGISTER
            $fwrite(status_file, "\n[EX/MEM Pipeline Register]\n");
            $fwrite(status_file, "  EX_MEM_alu_result: 0x%016h\n", dut.ex_mem_alu_result);
            $fwrite(status_file, "  EX_MEM_rs2_data (write_data): 0x%016h\n", dut.ex_mem_rs2_data);
            $fwrite(status_file, "  EX_MEM_rd: x%0d\n", dut.ex_mem_rd);
            $fwrite(status_file, "  EX_MEM_RegWrite: %0d, EX_MEM_MemRead: %0d, EX_MEM_MemWrite: %0d\n", 
                     dut.ex_mem_RegWrite, dut.ex_mem_MemRead, dut.ex_mem_MemWrite);
            $fwrite(status_file, "  EX_MEM_MemtoReg: %0d\n", dut.ex_mem_MemtoReg);
            
            // MEMORY STAGE
            $fwrite(status_file, "\n[MEMORY STAGE]\n");
            $fwrite(status_file, "  Address: 0x%h\n", dut.ex_mem_alu_result[9:0]);
            $fwrite(status_file, "  Write_Data: 0x%016h\n", dut.ex_mem_rs2_data);
            $fwrite(status_file, "  MemRead: %0d, MemWrite: %0d\n", dut.ex_mem_MemRead, dut.ex_mem_MemWrite);
            $fwrite(status_file, "  Read_Data: 0x%016h\n", dut.mem_read_data);
            
            // MEM/WB PIPELINE REGISTER
            $fwrite(status_file, "\n[MEM/WB Pipeline Register]\n");
            $fwrite(status_file, "  MEM_WB_alu_result: 0x%016h\n", dut.mem_wb_alu_result);
            $fwrite(status_file, "  MEM_WB_mem_data: 0x%016h\n", dut.mem_wb_mem_data);
            $fwrite(status_file, "  MEM_WB_rd: x%0d\n", dut.mem_wb_rd);
            $fwrite(status_file, "  MEM_WB_RegWrite: %0d, MEM_WB_MemtoReg: %0d\n", dut.mem_wb_RegWrite, dut.mem_wb_MemtoReg);
            
            // WRITE BACK STAGE
            $fwrite(status_file, "\n[WRITE BACK STAGE]\n");
            $fwrite(status_file, "  Write_Back_Data: 0x%016h\n", dut.write_back_data);
            $fwrite(status_file, "  Write to Register x%0d\n", dut.mem_wb_rd);
            
            // REGISTER FILE STATUS
            $fwrite(status_file, "\n[REGISTER FILE]\n");
            for (i = 0; i < 32; i = i + 1) begin
                if (i % 4 == 0) $fwrite(status_file, "  ");
                $fwrite(status_file, "x%0d:0x%016h  ", i, dut.reg_file.registers[i]);
                if (i % 4 == 3) $fwrite(status_file, "\n");
            end
            
            // HAZARD SIGNALS
            $fwrite(status_file, "\n[HAZARD CONTROL SIGNALS]\n");
            $fwrite(status_file, "  pc_write: %0d\n", dut.pc_write);
            $fwrite(status_file, "  hazard_if_id_write: %0d\n", dut.hazard_if_id_write);
            $fwrite(status_file, "  control_mux_sel: %0d\n", dut.control_mux_sel);
            $fwrite(status_file, "  hazard_flush: %0d\n", dut.hazard_flush);
            
            $fwrite(status_file, "\n----------------------------------------\n\n");
        end
    endtask
    
endmodule