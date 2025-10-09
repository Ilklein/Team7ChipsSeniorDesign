module interpolation_weights(
    input wire clk,
    input wire rst,
    input wire valid_data,
    input wire signed [15:0] area_012_reciprocal,
    input wire signed [15:0] area_p12,
    input wire signed [15:0] area_0p2,
    input wire signed [15:0] area_01p,
    output reg [31:0] w0,
    output reg [31:0] w1,
    output reg [31:0] w2,
    output reg interp_done
);

reg [1:0] count;
reg busy;
reg signed [15:0] A, B;
wire signed [31:0] mult_result;

fixed_point_mult mult (
    .a(A),
    .b(B),
    .result(mult_result)
);

always @(posedge clk) begin
    interp_done <= 0;
    if (rst) begin
        w0 <= 32'sd0;
        w1 <= 32'sd0;
        w2 <= 32'sd0;
        A <= 16'sd0;
        B <= 16'sd0;
        count <= 2'd0;
        busy <= 0;
    end else begin
        if (valid_data && !busy) begin
            count <= 2'd0;
            busy <= 1;
            A <= area_p12[15:0];
            B <= area_012_reciprocal[15:0];
        end
        else if (busy) begin
            if (count == 0) begin
                w0 <= mult_result;
                A <= area_0p2[15:0];
                B <= area_012_reciprocal[15:0];
            end else if (count == 1) begin
                w1 <= mult_result;
                A <= area_01p[15:0];
                B <= area_012_reciprocal[15:0];
            end else if (count == 2) begin
                w2 <= mult_result;
                count <= 2'd0;
                interp_done <= 1;
                busy <= 0;
            end 
            count <= count + 1;
        end  
    end
end

endmodule
