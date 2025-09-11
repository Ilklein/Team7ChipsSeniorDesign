// verified
module fixed_point_mult(
     input wire signed [15:0] a,
     input wire signed [15:0] b,
     output wire signed [31:0] result
 );
     assign result = (a * b) >>> 6;
endmodule