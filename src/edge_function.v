module edge_function(
    input  wire signed [15:0] v0x,
    input  wire signed [15:0] v0y,
    input  wire signed [15:0] v1x,
    input  wire signed [15:0] v1y,
    input  wire signed [15:0] v2x,
    input  wire signed [15:0] v2y,
    input  wire signed [15:0] px,
    input  wire signed [15:0] py,
    output wire signed [31:0] e1,
    output wire signed [31:0] e2,
    output wire signed [31:0] e3,
    output wire signed [15:0] a1,
    output wire signed [15:0] a2,
    output wire signed [15:0] a3,
    output wire signed [15:0] b1,
    output wire signed [15:0] b2,
    output wire signed [15:0] b3
);
    
    wire signed [31:0] m1, m2, m3, m4, m5, m6;

    assign a1 = v0y - v1y;
    assign b1 = v1x - v0x;
    fixed_point_mult mult1 (
	.a(px - v0x),
	.b(a1),
	.result(m1)
    );
    fixed_point_mult mult2 (
	.a(py - v0y),
	.b(b1),
	.result(m2)
    );

    assign a2 = v1y - v2y;
    assign b2 = v2x - v1x;
    fixed_point_mult mult3 (
	.a(px - v1x),
	.b(a2),
	.result(m3)
    );
    fixed_point_mult mult4 (
	.a(py - v1y),
	.b(b2),
	.result(m4)
    );

    assign a3 = v2y - v0y;
    assign b3 = v0x - v2x;
    fixed_point_mult mult5 (
	.a(px - v2x),
	.b(a3),
	.result(m5)
    );
    fixed_point_mult mult6 (
	.a(py - v2y),
	.b(b3),
	.result(m6)
    );
        
    assign e1 = m1 + m2;
    assign e2 = m3 + m4;
    assign e3 = m5 + m6;

endmodule
