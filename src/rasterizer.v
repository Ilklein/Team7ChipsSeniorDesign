module rasterizer(
        input wire CLK,
        input wire RST,
        input wire START,
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

// values for iterating through bounding box
reg [9:0] xspan_pix;  // up to 320
reg [8:0] yspan_pix;  // up to 240
reg [9:0] xrem;
reg [8:0] yrem;

wire [15:0] xmax;
wire [15:0] xmin;
wire [15:0] ymax;
wire [15:0] ymin;
reg signed [15:0] A1, A2, A3;
reg signed [15:0] B1, B2, B3;
wire signed [31:0] e1, e2, e3;
reg signed [31:0] edge1, edge2, edge3;
reg signed [31:0] e1_row0, e2_row0, e3_row0; // edge function values at start of current row
wire signed [15:0] area_012_reciprocal;
wire signed [31:0] w0, w1, w2;
// reg signed [31:0] W0, W1, W2;


wire [4:0] R0 = C0[15:11];
wire [4:0] G0 = C0[10:6];
wire [4:0] B0 = C0[5:1];
wire AL0 = C0[0];
wire [4:0] R1 = C1[15:11];
wire [4:0] G1 = C1[10:6];
wire [4:0] B1 = C1[5:1];
wire AL1 = C1[0];
wire [4:0] R2 = C2[15:11];
wire [4:0] G2 = C2[10:6];
wire [4:0] B2 = C2[5:1];
wire AL2 = C2[0];

wire [31:0] Racc = R0*w0 + R1*w1 + R2*w2;
wire [31:0] Gacc = G0*w0 + G1*w1 + G2*w2;
wire [31:0] Bacc = B0*w0 + B1*w1 + B2*w2;
wire [31:0] ALacc = (AL0 ? {w0} : 32'd0)
                 + (AL1 ? {w1} : 32'd0)
                 + (AL2 ? {w2} : 32'd0);

wire [4:0] Rout = (Racc >> 16) > 31 ? 5'd31 : (Racc >> 16)[4:0];
wire [4:0] Gout = (Gacc >> 16) > 31 ? 5'd31 : (Gacc >> 16)[4:0];
wire [4:0] Bout = (Bacc >> 16) > 31 ? 5'd31 : (Bacc >> 16)[4:0];
wire ALout = (ALacc[31:16] >= 16'd32768);

wire sipo_done; // control signals
reg area_start;
reg area_done;
reg ef_start;
wire edge_done;
reg iw_start;
wire interp_done;
reg coloring_ready;
wire piso1_done;
wire piso2_done;
wire piso3_done;

reg signed [15:0] xpos, ypos; // current values to go to the 3 PISO modules
reg [15:0] color;

SIPO s1 (
    .clk(CLK),
    .rst(RST),
    .in(D),
    .valid_data(START),
    .sipo_done(sipo_done),
    .out({v0x, v0y, c0, v1x, v1y, c1, v2x, v2y, c2})
);

boundingbox bb (
    .v0x(V0X),
    .v0y(V0Y),
    .v1x(V1X),
    .v1y(V1Y),
    .v2x(V2X),
    .v2y(V2Y),
    .XMIN(xmin),
    .XMAX(xmax),
    .YMIN(ymin),
    .YMAX(ymax)
);

edge_function ef (
    .clk(CLK),
    .rst(RST),
    .valid_data(ef_start),
    .v0x(V0X),
    .v0y(V0Y),
    .v1x(V1X),
    .v1y(V1Y),
    .v2x(V2X),
    .v2y(V2Y),
    .px(xpos + 16'd32), // +32 = +0.5 in fixed point to sample at pixel center
    .py(ypos + 16'd32),
    .a1(A1),
    .a2(A2),
    .a3(A3),
    .b1(B1),
    .b2(B2),
    .b3(B3),
    .e1(e1),
    .e2(e2),
    .e3(e3),
    .edge_done(edge_done)
);

area_reciprocal ar (
    .clk(CLK),
    .rst(RST),
    .valid_data(area_start),
    .v0x(V0X),
    .v0y(V0Y),
    .v1x(V1X),
    .v1y(V1Y),
    .v2x(V2X),
    .v2y(V2Y),
    .area_012_reciprocal(area_012_reciprocal),
    .area_done(area_done)
);

interpolation_weights iw (
    .clk(CLK),
    .rst(RST),
    .valid_data(iw_start),
    .area_012_reciprocal(area_012_reciprocal),
    .area_p12(edge1),
    .area_0p2(edge2),
    .area_01p(edge3),
    .w0(w0),
    .w1(w1),
    .w2(w2),
    .interp_done(interp_done)
);  

PISO p1 (
    .clk(CLK),
    .rst(RST),
    .in(xpos),
    .valid_data(VALID),
    .piso_done(piso1_done),
    .out(PX)
);
PISO p2 (
    .clk(CLK),
    .rst(RST),
    .in(ypos),
    .valid_data(VALID),
    .piso_done(piso2_done),
    .out(PY)
);
PISO p3 (
    .clk(CLK),
    .rst(RST),
    .in(color),
    .valid_data(VALID),
    .piso_done(piso3_done),
    .out(C)
);

always @(posedge CLK or posedge RST) begin
    VALID <= 0; // should valid stay high for 16 cycles?
    DONE <= 0; // pulses high when done with triangle
    if(RST) begin
        xspan_pix <= 0;
        yspan_pix <= 0;
        xrem <= 0;
        yrem <= 0;
        xpos <= 0;
        ypos <= 0;
        color <= 0;
        edge1 <= 0;
        edge2 <= 0;
        edge3 <= 0;
        e1_row0 <= 0;
        e2_row0 <= 0;
        e3_row0 <= 0;
        V0X <= 0;
        V0Y <= 0;
        V1X <= 0;  
        V1Y <= 0;
        V2X <= 0;
        V2Y <= 0;
        C0 <= 0;
        C1 <= 0;
        C2 <= 0;
        A1 <= 0;
        A2 <= 0;
        A3 <= 0;
        B1 <= 0;
        B2 <= 0;
        B3 <= 0;
        area_start <= 0;
        ef_start <= 0;
        iw_start <= 0;
        coloring_ready <= 0;
    end
    else if(sipo_done) begin //after 144 cycles, we have the full triangle, calculate bounding box
        V0X <= v0x; // outputs of SIPO are regiesters so do I need to store them in other registers?
        V0Y <= v0y;
        V1X <= v1x;
        V1Y <= v1y;
        V2X <= v2x;
        V2Y <= v2y;
        C0 <= c0; // store colors
        C1 <= c1;
        C2 <= c2;
        area_start <= 1;
    end
    else if(area_done && !ef_start && !edge_done && !coloring_ready) begin // wait for bounding box to be calculated
        A1 <= V0Y - V1Y; // edge function coefficients
        A2 <= V1Y - V2Y; // reset?
        A3 <= V2Y - V0Y;
        B1 <= V1X - V0X;
        B2 <= V2X - V1X;
        B3 <= V0X - V2X;
        xspan_pix <= ( (xmax - xmin) >>> FRAC ) + 10'd1; // values for iteration, +1 to round up
        yspan_pix <= ( (ymax - ymin) >>> FRAC ) + 9'd1;
        xrem <= ( (xmax - xmin) >>> FRAC ) + 10'd1;
        yrem <= ( (ymax - ymin) >>> FRAC ) + 9'd1;
        xpos <= xmin;
        ypos <= ymin;
        area_start <= 0;
        ef_start <= 1; // triggers ef calculation next cycle
    end
    else if(edge_done) begin //after 145 cycles, we have the bounding box, calculate edge functions at top-left corner
        edge1 <= e1;
        edge2 <= e2;
        edge3 <= e3;
        e1_row0 <= e1;
        e2_row0 <= e2;
        e3_row0 <= e3;
        iw_start <= 1; // triggers interpolation weight calculation next cycle
        ef_start <= 0;
        coloring_ready <= 1;
    end
    
    // simplified using De Morgan's from !((!piso1_done || !piso2_done || !piso3_done) && VALID)
    if(coloring_ready && ((piso1_done && piso2_done && piso3_done) || !VALID)) begin // wait for PISOs to finish before changing inputs
        if(yrem != 0) begin
            if(xrem != 0) begin
                if(edge1 >= 0 && edge2 >= 0 && edge3 >= 0) begin // check edges, pixels should be input CCW on screen(CW in coord system)
                    if(interp_done) begin // wait for interpolation weights to be calculated
                        color <= {Rout, Gout, Bout, ALout}; // change if interpolation is added
                        VALID <= 1; // pixel is in triangle
                        iw_start <= 1; // trigger new interpolation weight calculation next cycle
                    end
                end
                else begin
                    VALID <= 0; // pixel not in triangle
                    iw_start <= 1; // still need to calculate new interpolation weights
                end

                if(interp_done) begin
                    xpos <= xpos + 16'd64;
                    xrem <= xrem - 1; // decrement by 1
                    edge1 <= edge1 + A1; // update edge functions using linear increments
                    edge2 <= edge2 + A2;
                    edge3 <= edge3 + A3;
                end
            end 
            else begin
                xpos <= xmin;
                ypos <= ypos + 16'd64;
                xrem <= xspan_pix; // reset x remainder
                yrem <= yrem - 1; // decrement by 1

                e1_row0 <= e1_row0 + B1; // update row 0 edge functions
                e2_row0 <= e2_row0 + B2;
                e3_row0 <= e3_row0 + B3;

                edge1 <= e1_row0 + B1; // update edge functions for new row (uses old value of row 0 because nonblocking)
                edge2 <= e2_row0 + B2;
                edge3 <= e3_row0 + B3;
            end
        end 
        else begin
            VALID <= 0;
            coloring_ready <= 0;
            DONE <= 1;
        end
    end
    else begin
        VALID <= 0;
        DONE <= 0;
        area_start <= 0;
        ef_start <= 0;
        iw_start <= 0;
    end
end

endmodule