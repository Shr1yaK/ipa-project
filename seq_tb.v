`timescale 1ns/1ps

module seq_tb;

    reg clk;
    reg reset;
    wire [31:0] instruction;

    integer cycle_count;

    // Instantiate top_cpu
    top_cpu uut (
        .clk(clk),
        .reset(reset),
        .instruction_out(instruction)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        cycle_count = 0;

        $dumpfile("cpu.vcd");
        $dumpvars(0, seq_tb);

        #10 reset = 0;
    end

    // Debug + cycle monitor
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;

            $display("C%0d | PC=%0d | Instr=%h | ALU=%0d | MR=%b MW=%b | x1=%0d x2=%0d x3=%0d x4=%0d",
                cycle_count,
                uut.pc_out,
                instruction,
                uut.alu_result,
                uut.MemRead,
                uut.MemWrite,
                uut.reg_file_inst.registers[1],
                uut.reg_file_inst.registers[2],
                uut.reg_file_inst.registers[3],
                uut.reg_file_inst.registers[4]
            );


            if (cycle_count > 60) begin
                $display("Timeout reached.");
                $finish;
            end
        end
    end

endmodule