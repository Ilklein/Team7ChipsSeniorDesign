
`timescale 1ns/1ps

module tb_fixeds_point_div;

    // Inputs
    reg signed [15:0] a;
    reg signed [15:0] b;

    // Output
    wire signed [31:0] result;

    // Instantiate the module
    fixed_point_div uut (
        .a(a),
        .b(b),
        .result(result)
    );

    // Test procedure
    initial begin
        $display("Time\t a\t b\t result");

        // Test 1: positive numbers
        a = 16'sd64;   // 1.0 in Q10.6
        b = 16'sd128;  // 2.0 in Q10.6
        #10;
        $display("%0dns\t %d\t %d\t %d", $time, a, b, result);

        // Test 2: negative * positive
        a = -16'sd64;  // -1.0
        b = 16'sd128;  // 2.0
        #10;
        $display("%0dns\t %d\t %d\t %d", $time, a, b, result);

        // Test 3: negative * negative
        a = -16'sd64;  // -1.0
        b = -16'sd128; // -2.0
        #10;
        $display("%0dns\t %d\t %d\t %d", $time, a, b, result);

        // Test 4: fractions
        a = 16'sd32;   // 0.5
        b = 16'sd32;   // 0.5
        #10;
        $display("%0dns\t %d\t %d\t %d", $time, a, b, result);
	
	// Test 5: random numbers
        a = 16'sd6465;   // 
        b = 16'sd482;  // 2.0 in Q10.6
        #10;
        $display("%0dns\t %d\t %d\t %d", $time, a, b, result);

        // Test 6: dividing by 0
        a = 16'sd64;  // 0.5
        b = 16'sd0;  // 0
        #10;
        $display("%0dns\t %d\t %d\t %d", $time, a, b, result);

        // Test 7: 0 divided by 0
        a = 16'sd0;  // 0
        b = 16'sd0; // 0
        #10;
        $display("%0dns\t %d\t %d\t %d", $time, a, b, result);

        $stop;
    end

endmodule
