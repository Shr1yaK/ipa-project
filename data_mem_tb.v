`timescale 1ns/1ps

module data_mem_tb;

    reg clk;
    reg reset;
    reg [63:0] address;
    reg [63:0] write_data;
    reg MemRead;
    reg MemWrite;
    wire [63:0] read_data;

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

    initial begin
        clk = 0;
        reset = 1;
        address = 0;
        write_data = 0;
        MemRead = 0;
        MemWrite = 0;

        #10 reset = 0;

        // Write test value
        address = 64'd100;
        write_data = 64'h1122334455667788;
        MemWrite = 1;
        #10;
        MemWrite = 0;

        // Read back
        MemRead = 1;
        #10;
        MemRead = 0;

        #10;

        $display("Read Data = %h", read_data);

        $finish;
    end

endmodule