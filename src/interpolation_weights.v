
module interpolation_weights(
    input  wire [15:0] v0x,
    input  wire [15:0] v0y,
    input  wire [15:0] v1x,
    input  wire [15:0] v1y,
    input  wire [15:0] v2x,
    input  wire [15:0] v2y,
    input  wire [15:0] px,
    input  wire [15:0] py,
    output wire [31:0] w0,
    output wire [31:0] w1,
    output wire [31:0] w2
);

    // Area of full triangle (v0,v1,v2)
    wire signed [31:0] m1, m2;
    fixed_point_mult mult1 (
        .a(v0x - v1x),       // x1 - x0
        .b(v2y - v1y),     // y2 - y0
        .result(m1)
    );
    fixed_point_mult mult2 (
        .a(v0y - v1y),     // y1 - y0
        .b(v2x - v1x),       // x2 - x0
        .result(m2)
    );
    wire signed [15:0] area_012 = (m1 - m2) >>> 6;

    // Area of triangle (p,v1,v2)
    wire signed [31:0] m3, m4;
    fixed_point_mult mult3 (
        .a(px - v1x),
        .b(v2y - v1y),
        .result(m3)
    );
    fixed_point_mult mult4 (
        .a(py - v1y),
        .b(v2x - v1x),
        .result(m4)
    );
    wire signed [15:0] area_p12 = (m3 - m4) >>> 6;

    // Area of triangle (v0,p,v2)
    wire signed [31:0] m5, m6;
    fixed_point_mult mult5 (
        .a(v0x - px),
        .b(v2y - py),
        .result(m5)
    );
    fixed_point_mult mult6 (
        .a(v0y - py),
        .b(v2x - px),
        .result(m6)
    );
    wire signed [15:0] area_0p2 = (m5 - m6) >>> 6;

    // Area of triangle (v0,v1,p)
    wire signed [31:0] m7, m8;
    fixed_point_mult mult7 (
        .a(v0x - v1x),
        .b(py - v1y),
        .result(m7)
    );
    fixed_point_mult mult8 (
        .a(v0y - v1y),
        .b(px - v1x),
        .result(m8)
    );
    wire signed [15:0] area_01p = (m7 - m8) >>> 6;

    // Divide to find ratios compared to entire triagle
    fixed_point_div div0 (
        .a(area_p12),
        .b(area_012),
        .result(w0)
    );
    fixed_point_div div1 (
        .a(area_0p2),
        .b(area_012),
        .result(w1)
    );
    fixed_point_div div2 (
        .a(area_01p),
        .b(area_012),
        .result(w2)
    );

endmodule