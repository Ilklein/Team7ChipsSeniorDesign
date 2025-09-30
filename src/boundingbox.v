module boundingbox(
    input wire signed [15:0] v0x, 
    input wire signed [15:0] v1x,
    input wire signed [15:0] v2x,
    input wire signed [15:0] v0y,
    input wire signed [15:0] v1y,
    input wire signed [15:0] v2y,
    output wire signed [15:0] XMIN,
    output wire signed [15:0] XMAX,
    output wire signed [15:0] YMIN,
    output wire signed [15:0] YMAX
);

    wire signed [15:0] xmax_unrounded, xmin_unrounded, ymax_unrounded, ymin_unrounded;
    
    assign xmax_unrounded = (v0x > v1x) ? ((v0x > v2x) ? v0x : v2x) : ((v1x > v2x) ? v1x : v2x);
    assign xmin_unrounded = (v0x < v1x) ? ((v0x < v2x) ? v0x : v2x) : ((v1x < v2x) ? v1x : v2x);
    assign ymax_unrounded = (v0y > v1y) ? ((v0y > v2y) ? v0y : v2y) : ((v1y > v2y) ? v1y : v2y);
    assign ymin_unrounded = (v0y < v1y) ? ((v0y < v2y) ? v0y : v2y) : ((v1y < v2y) ? v1y : v2y);

    round_fixed_point rounded_xmax (
        .unrounded(xmax_unrounded),
        .rounded(XMAX)
    );
    round_fixed_point rounded_xmin (
        .unrounded(xmin_unrounded),
        .rounded(XMIN)
    );
    round_fixed_point rounded_ymax (
        .unrounded(ymax_unrounded),
        .rounded(YMAX)
    );
    round_fixed_point rounded_ymin (
        .unrounded(ymin_unrounded),
        .rounded(YMIN)
    );
    
endmodule

module round_fixed_point(
    input wire [15:0] unrounded,
    output wire [15:0] rounded
); 
    assign rounded = {unrounded[15:6], 6'b0} + 64*unrounded[5];
endmodule