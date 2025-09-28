module edge_function(
    input  wire signed [15:0] v0x,
    input  wire signed [15:0] v0y,
    input  wire signed [15:0] v1x,
    input  wire signed [15:0] v1y,
    input  wire signed [15:0] v2x,
    input  wire signed [15:0] v2y,
    input  wire signed [15:0] px,
    input  wire signed [15:0] py,
    output wire inside
);

    wire signed [31:0] m1, m2, m3, m4, m5, m6;
    wire signed [31:0] e1, e2, e3;

    fixed_point_mult mult1 (
	.a(px - v0x),
	.b(v1y - v0y),
	.result(m1)
    );
    fixed_point_mult mult2 (
	.a(py - v0y),
	.b(v1x - v0x),
	.result(m2)
    );
    assign e1 = m1 - m2;

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
    assign e2 = m3 - m4;

    fixed_point_mult mult5 (
	.a(px - v2x),
	.b(v0y - v2y),
	.result(m5)
    );
    fixed_point_mult mult6 (
	.a(py - v2y),
	.b(v0x - v2x),
	.result(m6)
    );
    assign e3 = m5 - m6;

    // Inside test (all edges non-negative)
    assign inside = (e1 >= 0) && (e2 >= 0) && (e3 >= 0);

endmodule
