module data_mem(
    input clk,
    input reset,
    input [63:0] address,
    input [63:0] write_data,
    input MemRead,
    input MemWrite,
    output reg [63:0] read_data
);

    reg [7:0] mem [0:1023];

    integer i;

    always @(posedge clk) begin

        if (reset) begin
            read_data <= 64'd0;
        end

        else begin

            // Store (sd)
            if (MemWrite) begin
                mem[address]     <= write_data[63:56];
                mem[address + 1] <= write_data[55:48];
                mem[address + 2] <= write_data[47:40];
                mem[address + 3] <= write_data[39:32];
                mem[address + 4] <= write_data[31:24];
                mem[address + 5] <= write_data[23:16];
                mem[address + 6] <= write_data[15:8];
                mem[address + 7] <= write_data[7:0];
            end

            // Load (ld) — 1 cycle latency
            if (MemRead) begin
                read_data <= {
                    mem[address],
                    mem[address + 1],
                    mem[address + 2],
                    mem[address + 3],
                    mem[address + 4],
                    mem[address + 5],
                    mem[address + 6],
                    mem[address + 7]
                };
            end

        end
    end

endmodule