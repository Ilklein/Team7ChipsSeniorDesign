module rasterizer(
        input wire CLK,
        input wire RST,
        input wire D,   // data is Q10.6 fixed point, format x1, y1, c1, x2, y2, c2, x3, y3, c3
        output wire C,  // output color
        output wire PX, // output pixel x coord
        output wire PY, // output pixel y coord
        output reg VALID, // output pixel valid
        output reg DONE // done with current triangle
);

parameter FRAC = 6; //number of fractional bits

wire signed [15:0] v0x, v0y; // wires for modules and regs to capture output values
reg signed [15:0] V0X, V0Y;
wire signed [15:0] v1x, v1y;
reg signed [15:0] V1X, V1Y;
wire signed [15:0] v2x, v2y;
reg signed [15:0] V2X, V2Y;
wire [15:0] c0, c1, c2;
reg [15:0] C0, C1, C2;

//wire [15:0] w0, w1, w2;

reg [8:0] xcount, ycount; // counts for iterating through bounding box
reg signed [15:0] xdiff; // width of bounding box
reg signed [15:0] ydiff;

wire [15:0] xmax;
wire [15:0] xmin;
wire [15:0] ymax;
wire [15:0] ymin;
wire signed [15:0] a1, a2, a3;
reg signed [15:0] A1, A2, A3;
wire signed [15:0] b1, b2, b3;
reg signed [15:0] B1, B2, B3;
wire signed [31:0] e1, e2, e3;
reg signed [31:0] edge1, edge2, edge3;

reg sipo_done; // control signals
reg bb_done;
reg coloring_ready;
reg out_ready;
reg piso1_done;
reg piso2_done;
reg piso3_done;

reg [15:0] xpos; // current values to go to the 3 PISO modules
reg [15:0] ypos;
reg [15:0] color;

SIPO s1 (
    .clk(CLK),
    .rst(RST),
    .in(D),
    .valid_data(DONE),
    .sipo_done(sipo_done),
    .out({v0x, v0y, c0, v1x, v1y, c1, v2x, v2y, c2})
);

boundingbox bb (
    .v0x(v0x),
    .v0y(v0y),
    .v1x(v1x),
    .v1y(v1y),
    .v2x(v2x),
    .v2y(v2y),
    .XMIN(xmin),
    .XMAX(xmax),
    .YMIN(ymin),
    .YMAX(ymax)
);

edge_function ef (
    .v0x(V0X),
    .v0y(V0Y),
    .v1x(V1X),
    .v1y(V1Y),
    .v2x(V2X),
    .v2y(V2Y),
    .px(xpos + 32), // +32 = +0.5 in fixed point to sample at pixel center
    .py(ypos + 32),
    .e1(e1),
    .e2(e2),
    .e3(e3),
    .a1(a1),
    .a2(a2),
    .a3(a3),
    .b1(b1),
    .b2(b2),
    .b3(b3)
);

/*
interpolation_weights iw (
    .v0x(v0x),
    .v0y(v0y),
    .v1x(v1x),
    .v1y(v1y),
    .v2x(v2x),
    .v2y(v2y),
    .px(px),
    .py(py),
    .w0(w0),
    .w1(w1),
    .w2(w2)
);  
*/

PISO p1 (
    .clk(CLK),
    .rst(RST),
    .in(xpos),
    .valid_data(out_ready),
    .piso_done(piso1_done),
    .out(PX)
);
PISO p2 (
    .clk(CLK),
    .rst(RST),
    .in(ypos),
    .valid_data(out_ready),
    .piso_done(piso2_done),
    .out(PY)
);
PISO p3 (
    .clk(CLK),
    .rst(RST),
    .in(color),
    .valid_data(out_ready),
    .piso_done(piso3_done),
    .out(C)
);

always @(posedge CLK or posedge RST) begin
    VALID <= 0; // should valid stay high for 16 cycles?
    DONE <= 0; // pulses high when done with triangle
    if(RST) begin
        xcount <= 0;
        ycount <= 0;
        xpos <= 0;
        ypos <= 0;
        color <= 0;
        bb_done <= 0;
        coloring_ready <= 0;
        out_ready <= 0;
    end
    else if(sipo_done && !bb_done) begin //after 144 cycles, we have the full triangle, calculate bounding box
        V0X <= v0x;
        V0Y <= v0y;
        V1X <= v1x;
        V1Y <= v1y;
        V2X <= v2x;
        V2Y <= v2y;
        C0 <= c0;
        C1 <= c1;
        C2 <= c2;
        xdiff <= xmax - xmin;
        ydiff <= ymax - ymin;
        xpos <= xmin;
        ypos <= ymin;
        bb_done <= 1;
    end
    else if(bb_done && !coloring_ready) begin //after 145 cycles, we have the bounding box, calculate edge functions at top-left corner
        edge1 <= e1;
        edge2 <= e2;
        edge3 <= e3;
        A1 <= a1;
        A2 <= a2;
        A3 <= a3;
        B1 <= b1;
        B2 <= b2;
        B3 <= b3;
        bb_done <= 0;
        coloring_ready <= 1;
    end
    
    if(coloring_ready && !((!piso1_done || !piso2_done || !piso3_done) && out_ready)) begin // wait for PISOs to finish before changing inputs
        if(ycount != ydiff) begin
            if(xcount != xdiff) begin
                if(edge1 >= 0 && edge2 >= 0 && edge3 >= 0) begin // check edges, pixels should be input CCW on screen(CW in coord system)
                    color <= c0; 
                    VALID <= 1;
                    out_ready <= 1;
                end
                else begin
                    color <= 16'b0; //background color
                    VALID <= 0; // pixel not in triangle
                    out_ready <= 1;
                end
                xpos <= xpos + 64;
                xcount <= xcount + 1; // increment by 1 in fixed point
                edge1 <= edge1 + A1; // update edge functions using linear increments
                edge2 <= edge2 + A2;
                edge3 <= edge3 + A3;
            end 
            else begin
                xpos <= xpos - xdiff;
                ypos <= ypos + 64;
                xcount <= 0;
                ycount <= ycount + 1;
                edge1 <= edge1 + B1 - ((xdiff * A1) >>> FRAC); // update edge functions for new row
                edge2 <= edge2 + B2 - ((xdiff * A2) >>> FRAC);
                edge3 <= edge3 + B3 - ((xdiff * A3) >>> FRAC);
            end
        end 
        else begin
            xcount <= 0;
            ycount <= 0;
            out_ready <= 0;
            coloring_ready <= 0;
            DONE <= 1;
        end
    end
end

endmodule