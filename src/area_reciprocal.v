module area_reciprocal(
    input wire clk,
    input wire rst,
    input wire valid_data,
    input signed [15:0] v0x,
    input signed [15:0] v0y,
    input signed [15:0] v1x,
    input signed [15:0] v1y,
    input signed [15:0] v2x,
    input signed [15:0] v2y,
    output reg signed [15:0] area_012_reciprocal,
    output reg area_done
 );

reg [1:0] count;
reg busy;
reg signed [15:0] A, B;
wire signed [31:0] mult_result;
wire signed [15:0] C;
assign C = 16'sd128;
reg signed [15:0] D;
wire signed [31:0] div_result;
reg signed [31:0] m1, m2;

fixed_point_mult mult (
    .a(A),
    .b(B),
    .result(mult_result)
);

fixed_point_div div (
    .a(C),
    .b(D),
    .result(div_result)
);

always @(posedge clk) begin
    area_done <= 0;
    if (rst) begin
        area_012_reciprocal <= 16'sd0;
        m1 <= 32'sd0;
        m2 <= 32'sd0;
        A <= 16'sd0;
        B <= 16'sd0;
        D <= 16'sd0;
        count <= 2'd0;
        busy <= 0;
    end else begin
        if (valid_data && !busy) begin
            count <= 2'd0;
            busy <= 1;
            A <= v1x - v0x;
            B <= v2y - v0y;
        end
        else if (busy) begin
            if (count == 0) begin
                m1 <= mult_result;
                A <= v0y - v1y;
                B <= v2x - v0x;
            end else if (count == 1) begin
                m2 <= mult_result;
            end else if (count == 2) begin    
                D <= (m1 + m2) >>> 6;
            end else if (count == 3) begin
                area_012_reciprocal <= div_result;
                count <= 2'd0;
                area_done <= 1;
                busy <= 0;
            end 
            count <= count + 1;
        end  
    end
end

endmodule

