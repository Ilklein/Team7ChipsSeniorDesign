module rasterizer(
        input wire CLK,
        input wire RST,
        input wire START,
        input wire V0X,   // data is Q10.6 fixed point, format x0, y0, c0, x1, y1, c1, x2, y2, c2
        input wire V0Y,
        input wire C0,   // color is 16 bits, format R5, G5, B5, A1
        input wire V1X,
        input wire V1Y,
        input wire C1,
        input wire V2X,
        input wire V2Y,
        input wire C2,
        output wire C15_14,  // output color
        output wire C13_12,
        output wire C11_10,
        output wire C9_8,
        output wire C7_6,
        output wire C5_4,
        output wire C3_2,
        output wire C1_0,
        output wire PX9_8, // output pixel x coord
        output wire PX7_6,
        output wire PX5_4,
        output wire PX3_2,
        output wire PX1_0,
        output wire PY7_6,
        output wire PY5_4,
        output wire PY3_2,
        output wire PY1_0,
        output reg VALID, // output pixel valid
        output reg DONE // done with current triangle
);

parameter FRAC = 6; //number of fractional bits

wire signed [15:0] v0x, v0y; // wires for modules and regs to capture output values
reg signed [15:0] v0x_reg, v0y_reg;
wire signed [15:0] v1x, v1y;
reg signed [15:0] v1x_reg, v1y_reg;
wire signed [15:0] v2x, v2y;
reg signed [15:0] v2x_reg, v2y_reg;
wire [15:0] c0, c1, c2;
reg [15:0] c0_reg, c1_reg, c2_reg;

// values for iterating through bounding box
reg [9:0] xspan_pix;  // up to 320
reg [8:0] yspan_pix;  // up to 240
reg [9:0] xrem;
reg [8:0] yrem;

wire [15:0] xmax;
reg [8:0] xmax_reg;
wire [15:0] xmin;
reg [8:0] xmin_reg;
wire [15:0] ymax;
reg [7:0] ymax_reg;
wire [15:0] ymin;
reg [7:0] ymin_reg;

reg signed [15:0] A1, A2, A3;
reg signed [15:0] B1, B2, B3;
wire signed [31:0] e1, e2, e3;
reg signed [31:0] edge1, edge2, edge3;
reg signed [31:0] e1_row0, e2_row0, e3_row0; // edge function values at start of current row
wire signed [15:0] area_012;
wire signed [31:0] w0, w1, w2;
// reg signed [31:0] W0, W1, W2;

wire [4:0] R0 = c0_reg[15:11];
wire [4:0] G0 = c0_reg[10:6];
wire [4:0] BL0 = c0_reg[5:1];
wire       AL0 = c0_reg[0];
wire [4:0] R1 = c1_reg[15:11];
wire [4:0] G1 = c1_reg[10:6];
wire [4:0] BL1 = c1_reg[5:1];
wire       AL1 = c1_reg[0];
wire [4:0] R2 = c2_reg[15:11];
wire [4:0] G2 = c2_reg[10:6];
wire [4:0] BL2 = c2_reg[5:1];
wire       AL2 = c2_reg[0];

wire [21:0] r0p = R0 * w0[15:0];
wire [21:0] r1p = R1 * w1[15:0];
wire [21:0] r2p = R2 * w2[15:0];
wire [21:0] g0p = G0 * w0[15:0];
wire [21:0] g1p = G1 * w1[15:0];
wire [21:0] g2p = G2 * w2[15:0];
wire [21:0] b0p = BL0 * w0[15:0];
wire [21:0] b1p = BL1 * w1[15:0];
wire [21:0] b2p = BL2 * w2[15:0];

wire [22:0] Racc_full = r0p + r1p + r2p;
wire [22:0] Gacc_full = g0p + g1p + g2p;
wire [22:0] BLacc_full = b0p + b1p + b2p;

wire [15:0] Racc_hi = Racc_full[22:6];
wire [15:0] Gacc_hi = Gacc_full[22:6];
wire [15:0] BLacc_hi = BLacc_full[22:6];

wire [4:0] Rout = (Racc_hi > 16'd31) ? 5'd31 : Racc_hi[4:0];
wire [4:0] Gout = (Gacc_hi > 16'd31) ? 5'd31 : Gacc_hi[4:0];
wire [4:0] BLout = (BLacc_hi > 16'd31) ? 5'd31 : BLacc_hi[4:0];

wire [15:0] ALacc = (AL0 ? w0[15:0] : 16'd0)
                  + (AL1 ? w1[15:0] : 16'd0)
                  + (AL2 ? w2[15:0] : 16'd0);
wire        ALout = (ALacc >= 16'd32);

wire sipo1_done; // control signals
wire sipo2_done;
wire sipo3_done;
wire sipo4_done;
wire sipo5_done;
wire sipo6_done;
wire sipo7_done;
wire sipo8_done;
wire sipo9_done;
assign wire sipos_done = sipo1_done && sipo2_done && sipo3_done && sipo4_done && sipo5_done && sipo6_done && sipo7_done && sipo8_done && sipo9_done;
reg area_start;
wire area_done;
reg ef_start;
wire edge_done;
reg iw_start;
wire interp_done;
reg coloring_ready;
reg pixel_done;
wire piso1_done;
wire piso2_done;
wire piso3_done;
wire piso4_done;
wire piso5_done;
wire piso6_done;
wire piso7_done;
wire piso8_done;
wire piso9_done;
wire piso10_done;
wire piso11_done;
wire piso12_done;
wire piso13_done;
wire piso14_done;
wire piso15_done;
wire piso16_done;
wire piso17_done;
assign wire pisos_done = piso1_done && piso2_done && piso3_done && piso4_done && piso5_done && piso6_done && piso7_done && piso8_done && piso9_done && piso10_done && piso11_done && piso12_done && piso13_done && piso14_done && piso15_done && piso16_done && piso17_done;


reg signed [15:0] xpos, ypos; // current values to go to the 3 PISO modules
reg signed [15:0] xpos_out, ypos_out;
reg [15:0] color;

SIPO9 s1 (
    .clk(CLK),
    .rst(RST),
    .in(V0X),
    .valid_data(START),
    .sipo_done(sipo1_done),
    .out(v0x)
);
SIPO9 s2 (
    .clk(CLK),
    .rst(RST),
    .in(V0Y),
    .valid_data(START),
    .sipo_done(sipo2_done),
    .out(v0y)
);
SIPO9 s3 (
    .clk(CLK),
    .rst(RST),
    .in(C0),
    .valid_data(START),
    .sipo_done(sipo3_done),
    .out(c0)
);
SIPO9 s4 (
    .clk(CLK),
    .rst(RST),
    .in(V1X),
    .valid_data(START),
    .sipo_done(sipo4_done),
    .out(v1x)
);
SIPO9 s5 (
    .clk(CLK),
    .rst(RST),
    .in(V1Y),
    .valid_data(START),
    .sipo_done(sipo5_done),
    .out(v1y)
);
SIPO9 s6 (
    .clk(CLK),
    .rst(RST),
    .in(C1),
    .valid_data(START),
    .sipo_done(sipo6_done),
    .out(c1)
);
SIPO9 s7 (
    .clk(CLK),
    .rst(RST),
    .in(V2X),
    .valid_data(START),
    .sipo_done(sipo7_done),
    .out(v2x)
);
SIPO9 s8 (
    .clk(CLK),
    .rst(RST),
    .in(V2Y),
    .valid_data(START),
    .sipo_done(sipo8_done),
    .out(v2y)
);
SIPO9 s9 (
    .clk(CLK),
    .rst(RST),
    .in(C2),
    .valid_data(START),
    .sipo_done(sipo9_done),
    .out(c2)
);

boundingbox bb (
    .v0x(v0x_reg),
    .v0y(v0y_reg),
    .v1x(v1x_reg),
    .v1y(v1y_reg),
    .v2x(v2x_reg),
    .v2y(v2y_reg),
    .XMIN(xmin),
    .XMAX(xmax),
    .YMIN(ymin),
    .YMAX(ymax)
);

edge_function ef (
    .clk(CLK),
    .rst(RST),
    .valid_data(ef_start),
    .v0x(v0x_reg),
    .v0y(v0y_reg),
    .v1x(v1x_reg),
    .v1y(v1y_reg),
    .v2x(v2x_reg),
    .v2y(v2y_reg),
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

area ar (
    .clk(CLK),
    .rst(RST),
    .valid_data(area_start),
    .v0x(v0x_reg),
    .v0y(v0y_reg),
    .v1x(v1x_reg),
    .v1y(v1y_reg),
    .v2x(v2x_reg),
    .v2y(v2y_reg),
    .area_012(area_012),
    .area_done(area_done)
);

wire [15:0] area_p12 = (edge1 >>> FRAC);
wire [15:0] area_0p2 = (edge2 >>> FRAC);
wire [15:0] area_01p = (edge3 >>> FRAC);
interpolation_weights_old iw (
    .clk(CLK),
    .rst(RST),
    .valid_data(iw_start),
    .area_012(area_012),
    .area_p12(area_p12[15:0]),
    .area_0p2(area_0p2[15:0]),
    .area_01p(area_01p[15:0]),
    .w0(w0),
    .w1(w1),
    .w2(w2),
    .interp_done(interp_done)
);  

PISO p1 (
    .clk(CLK),
    .rst(RST),
    .in(xpos_out[15:14]),
    .valid_data(VALID),
    .piso_done(piso1_done),
    .out(PX9_8)
);
PISO p2 (
    .clk(CLK),
    .rst(RST),
    .in(xpos_out[13:12]),
    .valid_data(VALID),
    .piso_done(piso2_done),
    .out(PX7_6)
);
PISO p3 (
    .clk(CLK),
    .rst(RST),
    .in(xpos_out[11:10]),
    .valid_data(VALID),
    .piso_done(piso3_done),
    .out(PX5_4)
);
PISO p4 (
    .clk(CLK),
    .rst(RST),
    .in(xpos_out[9:8]),
    .valid_data(VALID),
    .piso_done(piso4_done),
    .out(PX3_2)
);
PISO p5 (
    .clk(CLK),
    .rst(RST),
    .in(xpos_out[7:6]),
    .valid_data(VALID),
    .piso_done(piso5_done),
    .out(PX1_0)
);
PISO p6 (
    .clk(CLK),
    .rst(RST),
    .in(ypos_out[13:12]),
    .valid_data(VALID),
    .piso_done(piso6_done),
    .out(PY7_6)
);
PISO p7 (
    .clk(CLK),
    .rst(RST),
    .in(ypos_out[11:10]),
    .valid_data(VALID),
    .piso_done(piso7_done),
    .out(PY5_4)
);
PISO p8 (
    .clk(CLK),
    .rst(RST),
    .in(ypos_out[9:8]),
    .valid_data(VALID),
    .piso_done(piso8_done),
    .out(PY3_2)
);
PISO p9 (
    .clk(CLK),
    .rst(RST),
    .in(ypos_out[7:6]),
    .valid_data(VALID),
    .piso_done(piso9_done),
    .out(PY1_0)
);
PISO p10 (
    .clk(CLK),
    .rst(RST),
    .in(color[15:14]),
    .valid_data(VALID),
    .piso_done(piso10_done),
    .out(C15_14)
);
PISO p11 (
    .clk(CLK),
    .rst(RST),
    .in(color[13:12]),
    .valid_data(VALID),
    .piso_done(piso11_done),
    .out(C13_12)
);
PISO p12 (
    .clk(CLK),
    .rst(RST),
    .in(color[11:10]),
    .valid_data(VALID),
    .piso_done(piso12_done),
    .out(C11_10)
);
PISO p13 (
    .clk(CLK),
    .rst(RST),
    .in(color[9:8]),
    .valid_data(VALID),
    .piso_done(piso13_done),
    .out(C9_8)
);
PISO p14 (
    .clk(CLK),
    .rst(RST),
    .in(color[7:6]),
    .valid_data(VALID),
    .piso_done(piso14_done),
    .out(C7_6)
);
PISO p15 (
    .clk(CLK),
    .rst(RST),
    .in(color[5:4]),
    .valid_data(VALID),
    .piso_done(piso15_done),
    .out(C5_4)
);
PISO p16 (
    .clk(CLK),
    .rst(RST),
    .in(color[3:2]),
    .valid_data(VALID),
    .piso_done(piso16_done),
    .out(C3_2)
);
PISO p17 (
    .clk(CLK),
    .rst(RST),
    .in(color[1:0]),
    .valid_data(VALID),
    .piso_done(piso17_done),
    .out(C1_0)
);

always @(posedge CLK) begin
    VALID <= 0; // should valid stay high for 16 cycles?
    DONE <= 0; // pulses high when done with triangle
    iw_start <= 0;
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
        v0x_reg <= 0;
        v0y_reg <= 0;
        v1x_reg <= 0;  
        v1y_reg <= 0;
        v2x_reg <= 0;
        v2y_reg <= 0;
        c0_reg <= 0;
        c1_reg <= 0;
        c2_reg <= 0;
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
        pixel_done <= 0;
    end
    else if(sipos_done) begin //after 144 cycles, we have the full triangle, calculate bounding box
        v0x_reg <= v0x; // outputs of SIPO are regiesters so do I need to store them in other registers?
        v0y_reg <= v0y;
        v1x_reg <= v1x;
        v1y_reg <= v1y;
        v2x_reg <= v2x;
        v2y_reg <= v2y;
        c0_reg <= c0; // store colors
        c1_reg <= c1;
        c2_reg <= c2;
        area_start <= 1;
    end
    else if(area_done && !ef_start && !edge_done && !coloring_ready) begin // wait for bounding box to be calculated
        A1 <= v0y_reg - v1y_reg; // edge function coefficients
        A2 <= v1y_reg - v2y_reg; // reset?
        A3 <= v2y_reg - v0y_reg;
        B1 <= v1x_reg - v0x_reg;
        B2 <= v2x_reg - v1x_reg;
        B3 <= v0x_reg - v2x_reg;
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
    if(coloring_ready && (pisos_done || !pixel_done)) begin // wait for PISOs to finish before changing inputs
        if(yrem != 0) begin
            xpos_out <= xpos;
            ypos_out <= ypos;
            if(xrem != 0) begin
                if(edge1 >= 0 && edge2 >= 0 && edge3 >= 0) begin // check edges, pixels should be input CCW on screen(CW in coord system)
                    if(interp_done) begin // wait for interpolation weights to be calculated
                        color <= {Rout, Gout, BLout, ALout};
                        VALID <= 1; // pixel is in triangle
                        pixel_done <= 1;
                        iw_start <= 1; // trigger new interpolation weight calculation next cycle
                    end
                end
                else begin
                    VALID <= 0; // pixel not in triangle
                    iw_start <= 1; // still need to calculate new interpolation weights
                    pixel_done <= 0;
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
