module rasterizer (
input IN,
input CLK,
input EN,
output OUT
)
//FIX EACH FUNCTIONS IO
//ADD CONTROL SIGNALS


reg [143:0] parallel;
reg [15:0] xmin, xmax, ymin, ymax;
reg [7:0] counter;
reg inside;
reg[15:0] e0, e1, e2;
reg[15:0] l0, l1, l2;


counter #(.MAX(143), .WIDTH(8)) cntr_144(.clk(CLK), .en(EN), .out(count));
SIPO sipo (.in(IN), .clk(CLK), .en(EN), .out(parallel) );
boundingbox bb (
                .v0x(parallel[15:0]), 
                .v1x(parallel[31:16]),
                .v2x(parallel[47:32]),
                .v0y(parallel[63:48]), 
                .v1y(parallel[79:64]),
                .v2y(parallel[95:80]),
                .counter(counter),
                .clk(CLK),
                .xmin(xmin),
                .xmax(xmax),
                .ymin(ymin),
                .ymax(ymax)                
                );
edge_function edgefunc (
                        .v0x(parallel[15:0]), 
                        .v1x(parallel[31:16]),
                        .v2x(parallel[47:32]),
                        .v0y(parallel[63:48]), 
                        .v1y(parallel[79:64]),
                        .v2y(parallel[95:80]),
                        .xmax(xmax),
                        .xmin(xmin),
                        .ymax(ymax),
                        .ymin(ymin)
                        .e0(e0),
                        .e1(e1),
                        .e2(e2),
                        .inside(inside)
                        );

interpolator_weights interpolator ( 
                                    .v0x(parallel[15:0]), 
                                    .v1x(parallel[31:16]),
                                    .v2x(parallel[47:32]),
                                    .v0y(parallel[63:48]), 
                                    .v1y(parallel[79:64]),
                                    .v2y(parallel[95:80]),
                                    .e0(e0),
                                    .e1(e1),
                                    .e2(e2),
                                    .xmax(xmax),
                                    .xmin(xmin),
                                    .ymax(ymax),
                                    .ymin(ymin),
                                    .inside(inside)
                                    .l0(l0),
                                    .l1(l1),
                                    .l2(l2)
                                    );

colorer color(
            .xmax(xmax), 
            .xmin(xmin), 
            .ymax(ymax), 
            .ymin(ymin), 
            .color0(), 
            .color1(),
            .color2(),
            .l0(),
            .l1(),
            .l2(),
            .inside(inside),
                        

            );




endmodule


module boundingbox(
    input [15:0] v0x, //format x1,x2,x3, y1,y2,y3, 
    input [15:0] v1x,
    input [15:0] v2x,
    input [15:0] v0y,
    input [15:0] v1y,
    input [15:0] v2y,
    input clk,
    output [15:0] xmin,
    output [15:0] xmax,
    output [15:0] ymin,
    output [15:0] ymax
    );

    wire [15:0] xma, xmi, yma, ymi;
    
    maximum xmaximum (.p1(v0x), .p2(v1x), .p3(v2x), .count(count), .max(xma));
    minimum xminimum (.p1(v0x), .p2(v1x), .p3(v2x), .count(count), .min(xmi));
    maximum ymaximum (.p1(v0y), .p2(v1y), .p3(v2y), .count(count), .max(ymi));
    minimum yminimum (.p1(v0y), .p2(v1y), .p3(v2y), .count(count), .min(ymi));

    round_fixed_point rounded_xmax(.unrounded(xma, .rounded(XMAX)));
    round_fixed_point rounded_xmin(.unrounded(xmi, .rounded(XMIN)));
    round_fixed_point rounded_ymax(.unrounded(yma, .rounded(YMAX)));
    round_fixed_point rounded_ymin(.unrounded(ymi, .rounded(YMIN)));    
endmodule

module round_fixed_point(
    input wire [15:0] unrounded,
    output wire [15:0] rounded
    ); 
    assign rounded = {unrounded[15:6], 6'b0} + 64*unrounded[5];
endmodule
   
module maximum(
    input [15:0] p1,
    input [15:0] p2,
    input [15:0] p3,
    input [7:0] count,
    output reg [15:0] max
    );

    always @(posedge CLK) begin
        if(count == 95) begin
            if(p1>p2) begin
                if(p1>p3) begin
                    max <= p1;
                end 
                else begin
                    max <= p3;
                end 
            end
            else begin//(p2>=p1)
                if(p2 > p3) begin
                    max <= p2;
                end
                else begin //(p3>=p2) 
                    max <= p3;
                end
            end
        end
    end
endmodule

module minimum(
    input [15:0] p1,
    input [15:0] p2,
    input [15:0] p3,
    input [7:0] count,
    output reg [15:0] min
    );
    always @(posedge CLK) begin
        if(count == 95) begin
            if(p1<p2) begin
                if(p1<p3) begin
                    min = p1;
                end 
                else begin
                    min = p3;
                end 
            end
            else begin//(p2<=p1)
                if(p2 < p3) begin
                    min = p2;
                end
                else begin //(p3<=p2) 
                    min = p3;
                end
            end
        end
    end
endmodule


 
