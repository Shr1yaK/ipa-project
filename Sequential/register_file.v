module register_file(
    input clk,
    input reset,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire [63:0] write_data,
    input wire reg_write_en,
    output wire [63:0] read_data1,
    output wire [63:0] read_data2
);
    reg [63:0] registers [31:0];
    integer i;
    //X0 hardwired to 64'b0
    //All registers hardwired to 64'b0 at t=0
    initial begin
    for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 64'b0;
        end
    end

    // Read data from registers
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    // Write data to registers or reset all registers
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers to 0
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 64'b0;
            end
        end else if (reg_write_en && write_reg != 5'b0) begin
            // Normal write operation (register x0 is hardwired to 0)
            registers[write_reg] <= write_data;
        end
    end

endmodule
