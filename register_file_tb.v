`timescale 1ns/1ps
`include "register_file.v"
module register_file_tb;
    // Signals declaration
    reg clk;
    reg [4:0] read_reg1;
    reg [4:0] read_reg2;
    reg [4:0] write_reg;
    reg [63:0] write_data;
    reg reg_write_en;
    wire [63:0] read_data1;
    wire [63:0] read_data2;
    
    // Test counters
    integer test_count = 0;
    integer pass_count = 0;

    // Instantiate register file
    register_file dut (
        .clk(clk),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .reg_write_en(reg_write_en),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test task
    task run_test;
        input [4:0] test_read_reg1;
        input [4:0] test_read_reg2;
        input [4:0] test_write_reg;
        input [63:0] test_write_data;
        input test_reg_write_en;
        input [63:0] expected_data1;
        input [63:0] expected_data2;
        input [127:0] test_name;  // Fixed: Using a reg array for the string
        begin
            test_count = test_count + 1;
            
            // Apply test inputs
            @(negedge clk);
            read_reg1 = test_read_reg1;
            read_reg2 = test_read_reg2;
            write_reg = test_write_reg;
            write_data = test_write_data;
            reg_write_en = test_reg_write_en;
            
            @(posedge clk);
            @(negedge clk);  // Wait for write to complete
            
            // Display test information
            $display("\nTest Case %0d: %s", test_count, test_name);
            $display("Inputs:");
            $display("  read_reg1 = %d", read_reg1);
            $display("  read_reg2 = %d", read_reg2);
            $display("  write_reg = %d", write_reg);
            $display("  write_data = %h", write_data);
            $display("  reg_write_en = %b", reg_write_en);
            
            // Compare results
            if (read_data1 === expected_data1 && read_data2 === expected_data2) begin
                $display("Status: PASS");
                $display("  read_data1 = %h (Expected: %h)", read_data1, expected_data1);
                $display("  read_data2 = %h (Expected: %h)", read_data2, expected_data2);
                pass_count = pass_count + 1;
            end else begin
                $display("Status: FAIL");
                $display("  read_data1 = %h (Expected: %h)", read_data1, expected_data1);
                $display("  read_data2 = %h (Expected: %h)", read_data2, expected_data2);
            end
        end
    endtask

    // Main test sequence
    initial begin
        // Initialize signals
        clk = 0;
        read_reg1 = 0;
        read_reg2 = 0;
        write_reg = 0;
        write_data = 0;
        reg_write_en = 0;

        #10;

        // Test 1: Verify x0 is hardwired to 0
        run_test(5'd0, 5'd0, 5'd0, 64'hFFFFFFFFFFFFFFFF, 1'b1, 
                64'h0, 64'h0, 
                "x0 hardwired to 0");

        #10;

        // Test 2: Write to reg1 and verify
        run_test(5'd1, 5'd0, 5'd1, 64'hDEADBEEFDEADBEEF, 1'b1, 
                64'hDEADBEEFDEADBEEF, 64'h0, 
                "Write to reg1");
        
        #10;

        // Test 3: Write to reg2 while reading reg1
        run_test(5'd1, 5'd2, 5'd2, 64'hCAFEBABECAFEBABE, 1'b1, 
                64'hDEADBEEFDEADBEEF, 64'hCAFEBABECAFEBABE, 
                "Write to reg2, read reg1");

        #10;

        // Test 4: Attempt write with reg_write_en=0
        run_test(5'd1, 5'd2, 5'd1, 64'h1111111111111111, 1'b0,
                64'hDEADBEEFDEADBEEF, 64'hCAFEBABECAFEBABE, 
                "Write disabled");

        #10;

        // Test 5: Write to x0 (should remain 0)
        run_test(5'd0, 5'd1, 5'd0, 64'hFFFFFFFFFFFFFFFF, 1'b1,
                64'h0, 64'hDEADBEEFDEADBEEF, 
                "Write to x0 (should be ignored)");

        #10;

        // Test 6: Write to last register (x31)
        run_test(5'd31, 5'd1, 5'd31, 64'h1234567890ABCDEF, 1'b1,
                64'h1234567890ABCDEF, 64'hDEADBEEFDEADBEEF, 
                "Write to x31");

        #10;

        // Test 7: Multiple reads of same register
        run_test(5'd2, 5'd2, 5'd3, 64'hAAAAAAAAAAAAAAAA, 1'b1,
                64'hCAFEBABECAFEBABE, 64'hCAFEBABECAFEBABE, 
                "Multiple reads of same register");

        #10;

        // Print test summary
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", test_count - pass_count);
        $display("==================\n");

        $finish;
    end

    // Generate VCD file
    initial begin
        $dumpfile("register_file_tb.vcd");
        $dumpvars(0, register_file_tb);
    end

endmodule