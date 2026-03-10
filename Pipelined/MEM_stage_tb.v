module MEM_stage_tb;

reg clk;
reg reset;
reg MemRead;
reg MemWrite;
reg [63:0] alu_result;
reg [63:0] write_data;

wire [63:0] mem_read_data;

MEM_stage dut(
    .clk(clk),
    .reset(reset),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .alu_result(alu_result),
    .write_data(write_data),
    .mem_read_data(mem_read_data)
);

always #5 clk = ~clk;

initial begin

    $dumpfile("MEM_stage.vcd");
    $dumpvars(0, MEM_stage_tb);

    clk = 0;
    reset = 0;

    MemWrite = 1;
    MemRead = 0;

    alu_result = 64'd5;
    write_data = 64'hDEADBEEF;

    #10;

    MemWrite = 0;
    MemRead = 1;

    #10;

    $display("Read Data = %h", mem_read_data);

    #10 $finish;

end

endmodule