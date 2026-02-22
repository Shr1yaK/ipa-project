`timescale 1ns/1ps

module data_mem_tb;

    reg clk;
    reg reset;
    reg [63:0] address;
    reg [63:0] write_data;
    reg MemRead;
    reg MemWrite;
    wire [63:0] read_data;

    integer test_count;
    integer pass_count;

    data_mem uut (
        .clk(clk),
        .reset(reset),
        .address(address),
        .write_data(write_data),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .read_data(read_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    task run_test;
        input [63:0] addr;
        input [63:0] data;
        begin
            test_count = test_count + 1;

            // Write
            address = addr;
            write_data = data;
            MemWrite = 1;
            MemRead = 0;
            #10;
            MemWrite = 0;

            // Read
            MemRead = 1;
            #10;
            MemRead = 0;

            $display("Test %0d:", test_count);
            $display("  Address = %h", addr);
            $display("  Written = %h", data);
            $display("  Read    = %h", read_data);

            if (read_data === data) begin
                $display("  Status: PASS\n");
                pass_count = pass_count + 1;
            end else begin
                $display("  Status: FAIL\n");
            end

            #10;
        end
    endtask

    initial begin
        $dumpfile("data_mem_tb.vcd");
        $dumpvars(0, data_mem_tb); 
        clk = 0;
        reset = 1;
        address = 0;
        write_data = 0;
        MemRead = 0;
        MemWrite = 0;
        test_count = 0;
        pass_count = 0;

        #10 reset = 0;

        // Run multiple tests
        run_test(64'd100, 64'h1122334455667788);
        run_test(64'd200, 64'hdeadbeefcafebabe);
        run_test(64'd300, 64'hffffffffffffffff);
        run_test(64'd400, 64'h0000000000000000);

        $display("=====================================");
        $display("FINAL RESULT: Passed %0d/%0d tests",
                 pass_count, test_count);
        $display("=====================================");

        $finish;
    end

endmodule
