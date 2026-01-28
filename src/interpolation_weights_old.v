// module interpolation_weights_old(
//     input wire clk,
//     input wire rst,
//     input wire valid_data,
//     input wire signed [15:0] area_012,
//     input wire signed [15:0] area_p12,
//     input wire signed [15:0] area_0p2,
//     input wire signed [15:0] area_01p,
//     output reg [31:0] w0,
//     output reg [31:0] w1,
//     output reg [31:0] w2,
//     output reg interp_done
// );

// reg [1:0] count;
// reg busy;
// reg signed [15:0] A, B;
// wire signed [31:0] div_result;

// fixed_point_div div (
//     .a(A),
//     .b(B),
//     .result(div_result)
// );

// always @(posedge clk) begin
//     if(valid_data) begin 
//         interp_done <= 0;
//     end
    
//     if (rst) begin
//         w0 <= 32'sd0;
//         w1 <= 32'sd0;
//         w2 <= 32'sd0;
//         A <= 16'sd0;
//         B <= 16'sd0;
//         count <= 2'd0;
//         busy <= 0;
//     end else begin
//         if (valid_data && !busy) begin
//             count <= 2'd0;
//             busy <= 1;
//             A <= area_p12[15:0];
//             B <= area_012[15:0];
//         end
//         else if (busy) begin
//             if (count == 0) begin
//                 w0 <= div_result;
//                 A <= area_0p2[15:0];
//                 B <= area_012[15:0];
//                 count <= count + 1;
//             end else if (count == 1) begin
//                 w1 <= div_result;
//                 A <= area_01p[15:0];
//                 B <= area_012[15:0];
//                 count <= count + 1;
//             end else if (count == 2) begin
//                 w2 <= div_result;
//                 //count <= 2'd0;
//                 interp_done <= 1;
//                 busy <= 0;
//                 count <= count + 1;
//             end
//             // if(count == 3) begin 
//             //     interp_done <= 0;
//             // end
//         end 
//         else begin
//             interp_done <= 0; 
//         end
//     end
// end

// endmodule

module interpolation_weights_old(
    input wire clk,
    input wire rst,
    input wire valid_data,
    input wire [15:0] area_012,
    input wire [15:0] area_p12,
    input wire [15:0] area_0p2,
    input wire [15:0] area_01p,
    output reg [31:0] w0,
    output reg [31:0] w1,
    output reg [31:0] w2,
    output reg interp_done
);


wire [15:0] divisor;
assign divisor = area_012;
always @(posedge clk) begin
    if(interp_done) begin 
        interp_done <= 0;
    end 
    else if (rst) begin
        w0 <= 32'sd0;
        w1 <= 32'sd0;
        w2 <= 32'sd0;

    end 
    else if (valid_data) begin
            w0 <= (area_p12 << 6) >> divisor;
            w1 <= (area_0p2 << 6) >> divisor;
            w2 <= (area_01p << 6) >> divisor;
            interp_done <= 1;
    end

end
endmodule