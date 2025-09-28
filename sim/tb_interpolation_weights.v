
`timescale 1ns/1ps

module tb_interpolation_weights;

    // Inputs
    reg signed [15:0] v0x, v0y;
    reg signed [15:0] v1x, v1y;
    reg signed [15:0] v2x, v2y;
    reg signed [15:0] px, py;

    // Outputs
    wire [31:0] w0;
    wire [31:0] w1;
    wire [31:0] w2;

    // Instantiate DUT
    interpolation_weights uut (
        .v0x(v0x), 
        .v0y(v0y), 
        .v1x(v1x), 
        .v1y(v1y), 
        .v2x(v2x), 
        .v2y(v2y), 
        .px(px), 
        .py(py), 
        .w0(w0), 
        .w1(w1), 
        .w2(w2)
    );

    initial begin
        // Initialize all inputs to avoid X's at t=0
        v0x = 16'sd0; v0y = 16'sd0;
        v1x = 16'sd0; v1y = 16'sd6400;
        v2x = 16'sd6400; v2y = 16'sd0;
        px  = 0; py  = 0;

        $display("Time | v0(v0x,v0y)  v1(v1x,v1y)  v2(v2x,v2y)  p(px,py) | w0	w1	w2");

        // Test 1: point at v0 (0, 0)
        #5;
        px  = 16'sd0; py  = 16'sd0;
        #10;
        $display("%0dns | (%d,%d)  (%d,%d)  (%d,%d)  (%d,%d) | %d	%d	%d",
                 $time,
                 v0x>>>6, v0y>>>6,
                 v1x>>>6, v1y>>>6,
                 v2x>>>6, v2y>>>6,
                 px>>>6,  py>>>6,
                 (w0*100/128), (w1*100/128), (w2*100/128));

        // Test 2: Point in the center (50, 50)
        px = 16'sd3200; py = 16'sd3200;
        #10;
        $display("%0dns | (%d,%d)  (%d,%d)  (%d,%d)  (%d,%d) | %d	%d	%d",
                 $time,
                 v0x>>>6, v0y>>>6,
                 v1x>>>6, v1y>>>6,
                 v2x>>>6, v2y>>>6,
                 px>>>6,  py>>>6,
                 (w0*100/128), (w1*100/128), (w2*100/128));

        // Test 3: point on the edge between v1 and v2 ()
        px = 16'sd1600; py = 16'sd1600;
        #10;
        $display("%0dns | (%d,%d)  (%d,%d)  (%d,%d)  (%d,%d) | %d	%d	%d",
                 $time,
                 v0x>>>6, v0y>>>6,
                 v1x>>>6, v1y>>>6,
                 v2x>>>6, v2y>>>6,
                 px>>>6,  py>>>6,
                 (w0*100/128), (w1*100/128), (w2*100/128));

	// Test 4: random point inside
        px = 16'sd2312; py = 16'sd508;
        #10;
        $display("%0dns | (%d,%d)  (%d,%d)  (%d,%d)  (%d,%d) | %d	%d	%d",
                 $time,
                 v0x>>>6, v0y>>>6,
                 v1x>>>6, v1y>>>6,
                 v2x>>>6, v2y>>>6,
                 px>>>6,  py>>>6,
                 (w0*100/128), (w1*100/128), (w2*100/128));
        $stop;
    end

endmodule