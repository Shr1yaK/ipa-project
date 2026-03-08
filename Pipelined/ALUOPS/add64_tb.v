`timescale 1ns/1ps
module add64_tb;

// Inputs
reg [63:0]in1;
reg [63:0]in2;

// Outputs
wire [63:0]out;
wire z_add_flag;
wire c_add_flag;
wire o_add_flag;
// Instantiate the Unit Under Test (UUT)
add64 uut (
    .in1(in1),
    .in2(in2),
    .out(out),
    .z_add_flag(z_add_flag),
    .c_add_flag(c_add_flag),
    .o_add_flag(o_add_flag)
);

initial begin
    $dumpfile("add64_tb.vcd");
    $dumpvars(0,add64_tb);
    $monitor("yoppp",$time,in1,in2,out);
    // Initialize Inputs
     in1 = 64'h7000000000000000;
     in2 = 64'h7000000000000000;
     #100 $finish;
    end
initial begin
    $monitor("time = %0t, A = %0d,B = %0d,Y = %0d, carr flag = %0d, zero flag= %0d, overflow_flag= %0d",$time,in1,in2,out,c_add_flag,z_add_flag,o_add_flag);
end

endmodule