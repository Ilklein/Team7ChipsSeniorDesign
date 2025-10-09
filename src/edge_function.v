module edge_function(
    input wire clk,
    input wire rst,
    input wire valid_data,
    input wire signed [15:0] v0x,
    input wire signed [15:0] v0y,
    input wire signed [15:0] v1x,
    input wire signed [15:0] v1y,
    input wire signed [15:0] v2x,
    input wire signed [15:0] v2y,
    input wire signed [15:0] px,
    input wire signed [15:0] py,
    input wire signed [15:0] a1,
    input wire signed [15:0] a2,
    input wire signed [15:0] a3,
    input wire signed [15:0] b1,
    input wire signed [15:0] b2,
    input wire signed [15:0] b3,
    output reg signed [31:0] e1,
    output reg signed [31:0] e2,
    output reg signed [31:0] e3,
    output reg edge_done
);
    
reg [2:0] count;
reg busy;
reg signed [15:0] A, B;
wire signed [31:0] mult_result;
reg signed [31:0] m1, m2;

fixed_point_mult mult (
    .a(A),
    .b(B),
    .result(mult_result)
);

always @(posedge clk) begin
    edge_done <= 0;
    if (rst) begin
        e1 <= 32'sd0;
        e2 <= 32'sd0;
        e3 <= 32'sd0;
        m1 <= 32'sd0;
        m2 <= 32'sd0;
        A <= 16'sd0;
        B <= 16'sd0;
        count <= 3'd0;
        busy <= 0;
    end else begin
        if (valid_data && !busy) begin
            count <= 3'd0;
            busy <= 1;
            A <= px - v0x;
            B <= a1;
        end
        else if (busy) begin
            if (count == 0) begin
                m1 <= mult_result;
                A <= py - v0y;
                B <= b1;
            end else if (count == 1) begin
                m2 <= mult_result;
                A <= px - v1x;
                B <= a2;
            end else if (count == 2) begin
                e1 <= m1 + m2;
                m1 <= mult_result;
                A <= py - v1y;
                B <= b2;
            end else if (count == 3) begin
                m2 <= mult_result;
                A <= px - v2x;
                B <= a3;
            end else if (count == 4) begin
                e2 <= m1 + m2;
                m1 <= mult_result;
                A <= py - v2y;
                B <= b3;
            end else if (count == 5) begin
                m2 <= mult_result;
            end else if (count == 6) begin
                e3 <= m1 + m2;
                count <= 3'd0;
                edge_done <= 1;
                busy <= 0;
            end 
            count <= count + 1;
        end  
    end
end

endmodule
