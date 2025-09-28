module fixed_point_div(
     input wire signed [15:0] a,
     input wire signed [15:0] b,
     output wire signed [31:0] result
 );
     assign result = (a <<< 6) / b;
endmodule