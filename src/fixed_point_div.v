module fixed_point_div(
     input wire signed [15:0] a,
     input wire signed [15:0] b,
     output reg signed [31:0] result
 );
 always @(*) begin
    
    result = (a <<< 6) / b;

 end
endmodule