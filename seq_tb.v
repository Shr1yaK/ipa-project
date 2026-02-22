`timescale 1ns/1ps

`include "top_cpu.v"
`include "control_unit.v"
`include "alu_control.v"
`include "imm_gen.v"
`include "data_mem.v"
`include "register_file.v"
`include "pc.v"
`include "instruction_mem.v"
`include "alu.v"

module seq_tb;

    reg clk;
    reg reset;
    wire [31:0] instruction;

    integer cycle_count;
    integer file_handle;
    integer i;

    reg [63:0] prev_pc;
    reg [3:0]  stable_count;

    // Instantiate CPU
    top_cpu uut (
        .clk(clk),
        .reset(reset),
        .instruction_out(instruction)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        cycle_count = 0;
        stable_count = 0;
        prev_pc = 64'd0;

        #10 reset = 0;
    end

    always @(posedge clk) begin
    if (!reset) begin
        cycle_count = cycle_count + 1;

        if (uut.pc_out >= 64'd60) begin

            file_handle = $fopen("register_file.txt", "w");

            for (i = 0; i < 32; i = i + 1) begin
                $fdisplay(file_handle, "%016h", uut.reg_file_inst.registers[i]);
            end

            $fdisplay(file_handle, "%0d", cycle_count);

            $fclose(file_handle);
            $finish;
        end
    end
end

endmodule