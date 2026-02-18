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

        // Release reset after some time
        #10 reset = 0;
    end

    // Cycle counter
    always @(posedge clk) begin
        if (!reset)
            cycle_count = cycle_count + 1;
    end

        always @(posedge clk) begin
        if (!reset) begin
            if (instruction == 32'b0) begin
                $display("Program finished.");
                $display("Total cycles = %0d", cycle_count);

                // Call register dump task
                // uut.reg_file_inst.dump_registers();

                $finish;
            end
        end
    end


endmodule