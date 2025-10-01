module rasterizer (
input IN,
input CLK,
input EN,
output [23:0] OUT
);

//FIX EACH FUNCTIONS IO
//ADD CONTROL SIGNALS


wire [143:0] parallel_in;
wire [15:0] xmin, xmax, ymin, ymax;
wire [7:0] count;
wire inside;
wire[15:0] e0, e1, e2;
wire[15:0] l0, l1, l2;
wire [15:0] color;
wire [7:0] p;
wire [23:0] parallel_out = {color,p};


counter #(.MAX(143), .WIDTH(8)) cntr_144(.clk(CLK), .en(EN), .out(count));

SIPO sipo (.in(IN), .clk(CLK), .en(EN), .out(parallel_in) );

boundingbox bb (
                .v0x(parallel_in[15:0]), 
                .v1x(parallel_in[31:16]),
                .v2x(parallel_in[47:32]),
                .v0y(parallel_in[63:48]), 
                .v1y(parallel_in[79:64]),
                .v2y(parallel_in[95:80]),
                .counter(count),
                .clk(CLK),
                .xmin(xmin),
                .xmax(xmax),
                .ymin(ymin),
                .ymax(ymax)                
                );

edge_function edgefunc (
                        .v0x(parallel_in[15:0]), 
                        .v1x(parallel_in[31:16]),
                        .v2x(parallel_in[47:32]),
                        .v0y(parallel_in[63:48]), 
                        .v1y(parallel_in[79:64]),
                        .v2y(parallel_in[95:80]),
                        .xmax(xmax),
                        .xmin(xmin),
                        .ymax(ymax),
                        .ymin(ymin),
                        .e0(e0),
                        .e1(e1),
                        .e2(e2),
                        .inside(inside)
                        );

interpolator_weights interpolator ( 
                                    .v0x(parallel_in[15:0]), 
                                    .v1x(parallel_in[31:16]),
                                    .v2x(parallel_in[47:32]),
                                    .v0y(parallel_in[63:48]), 
                                    .v1y(parallel_in[79:64]),
                                    .v2y(parallel_in[95:80]),
                                    .e0(e0),
                                    .e1(e1),
                                    .e2(e2),
                                    .xmax(xmax),
                                    .xmin(xmin),
                                    .ymax(ymax),
                                    .ymin(ymin),
                                    .inside(inside),
                                    .l0(l0),
                                    .l1(l1),
                                    .l2(l2)
                                    );

colorer color(
            .xmax(xmax), 
            .xmin(xmin), 
            .ymax(ymax), 
            .ymin(ymin), 
            .color0(parallel_in[111:96]), 
            .color1(parallel_in[127:112]),
            .color2(parallel_in[143:128]),
            .l0(l0),
            .l1(l1),
            .l2(l2),
            .inside(inside),
            .color(color),
            .pixel(p)                 
            );


PISO piso (.data(parallel_out), .out(OUT));
    
endmodule

