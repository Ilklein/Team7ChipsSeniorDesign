module rasterizer_tb();

        // input wire CLK,
        // input wire RST,
        // input wire START,
        // input wire V0X,   // data is Q10.6 fixed point, format x0, y0, c0, x1, y1, c1, x2, y2, c2
        // input wire V0Y,
        // input wire C0,   // color is 16 bits, format R5, G5, B5, A1
        // input wire V1X,
        // input wire V1Y,
        // input wire C1,
        // input wire V2X,
        // input wire V2Y,
        // input wire C2,
        // output wire C,  // output color
        // output wire PX, // output pixel x coord
        // output wire PY, // output pixel y coord
        // output reg VALID, // output pixel valid
        // output reg DONE // done with current triangle

//Inputs to rasterizer
logic clk;
logic rst;
logic start;
logic v0x;
logic v0y;
logic c0;
logic v1x;
logic v1y;
logic c1;
logic v2x;
logic v2y;
logic c2;


//Outputs of rasterizer
logic c;
logic px;
logic py;
logic valid;
logic done;


logic [15:0] x0;
logic [15:0] x1;
logic [15:0] x2;

logic [15:0] y0;
logic [15:0] y1;
logic [15:0] y2;

logic [15:0] cp0;
logic [15:0] cp1;
logic [15:0] cp2;

real x0dec;
real x1dec;
real x2dec;

real y0dec;
real y1dec;
real y2dec;

int c0dec;
int c1dec;
int c2dec;

logic [143:0] vec;

logic [15:0] screen [239:0][319:0];
string weights_screen [239:0][319:0];
string area_screen [239:0][319:0];
string edge_screen [239:0][319:0];

string e0;
string e1;
string e2;

int tempe0;
int tempe1;
int tempe2;



string a0;
string a1;
string a2;

int tempa0;
int tempa1;
int tempa2;


string w0;
string w1;
string w2;

int tempw0;
int tempw1;
int tempw2;

logic [15:0] x;
logic readx = 0;
logic [15:0] y;
logic ready = 0;
logic [15:0] color;
logic readc = 0;
int fileDescriptor;
int triangleList;
logic [15:0] y_display, x_display, color_display;
int triangle_count = 0;
int total_triangles;
int check;
int vis;
int weights;
int triangleCheck;
int area;
int edge_fun;
string ln;
assign color_display = chip.color;
assign x_display = chip.xpos_out;
assign y_display = chip.ypos_out;

//logic read;

//logic d;
rasterizer chip (.CLK(clk), .RST(rst), .START(start), .V0X(v0x), .V1X(v1x), .V2X(v2x), .V0Y(v0y), .V1Y(v1y), .V2Y(v2y),
.C0(c0), .C1(c1), .C2(c2),
.C(c), .PX(px), .PY(py), .VALID(valid), .DONE(done)); //instaniate register


task counterclockwise;
    input [9:0] a;
    input [9:0] b;
    input [9:0] c;
    output [9:0] x1;
    output [9:0] x2;
    output [9:0] x3;


    if(b > a && b > c) begin  //b is rightmost 
        x1 = b;
        if(a > c) begin //c is leftmost
            x3 = c;
            x2 = a;
        end else begin //a is leftmost
            x3 = a;
            x2 = c;
        end
    end
    else if(c > a && c > b) begin //c is rightmost
        x1 = c;
        if(b > a) begin //a is leftmost
            x3 = a;
            x2 = b;
        end else begin //b is leftmost
            x3 = b;
            x2 = a;
        end
    end 
    else begin //a is rightmost
        x1 = a;
        if(b > c) begin //c is leftmost
            x3 = c;
            x2 = b;
        end
        else begin //b is leftmost
            x3 = b;
            x2 = c;
        end

    end

endtask


task makeTriangle;
    output [15:0] x1;
    output [15:0] x2;
    output [15:0] x3;
    output [15:0] y1;
    output [15:0] y2;
    output [15:0] y3;


    logic [9:0] xa;
    logic [9:0] xb;
    logic [9:0] xc;
    logic [9:0] ya;
    logic [9:0] yb;
    logic [9:0] yc;

    logic [5:0] xg;
    logic [5:0] xh;
    logic [5:0] xi;
    logic [5:0] yg;
    logic [5:0] yh;
    logic [5:0] yi;


    logic[31:0] a,b,c,d,e,f;
    logic [5:0] g, h, i, j, k, l;

    a = $urandom_range(0,320);
    b = $urandom_range(0,320);
    c = $urandom_range(0,320);

    d = $urandom_range(0,240);
    e = $urandom_range(0,240);
    f = $urandom_range(0,240);



    counterclockwise(.a(a[9:0]), .b(b[9:0]), .c(c[9:0]), .x1(xa), .x2(xb), .x3(xc));

    
    ya = d[9:0];
    yb = e[9:0];
    yc = f[9:0];
   

    g = $urandom_range(0,64);
    h = $urandom_range(0,64);
    i = $urandom_range(0,64);

    j = $urandom_range(0,64);
    k = $urandom_range(0,64);
    l = $urandom_range(0,64);

    xg = g[5:0];
    xh = h[5:0];
    xi = i[5:0];

    yg = j[5:0];
    yh = k[5:0];
    yi = l[5:0];

    x1 = {xa,xg};
    x2 = {xb,xh};
    x3 = {xc,xi};

    y1 = {ya,yg};
    y2 = {yb,yh};
    y3 = {yc,yi};



endtask


task sendserial;
    input [15:0] x0;
    input [15:0] x1;
    input [15:0] x2;

    input [15:0] y0;
    input [15:0] y1;
    input [15:0] y2;

    input [15:0] ci0;
    input [15:0] ci1;
    input [15:0] ci2;

    integer i;
    begin
        // start = 1;
        // #2;
        // start = 0;
    for(i = 0; i <= 15; i++) begin
        v0x = x0[i];
        v1x = x1[i];
        v2x = x2[i];

        v0y = y0[i];
        v1y = y1[i];
        v2y = y2[i];

        c0 = ci0[i];
        c1 = ci1[i];
        c2 = ci2[i];

        #2;
    end
    end
endtask

task  read;

    // input toReadx;
    // input toReady;
    // input toReadc;

    output [15:0] parallelx;
    output [15:0] parallely;
    output [15:0] parallelc;

    output donex;
    output doney;
    output donec;
    donex = 0;
    doney = 1;
    donec = 1;
    begin
    for(int i = 0; i <= 15; i++) begin
        
        parallelx = {px, parallelx[15:1]};
        parallely = {py, parallely[15:1]};
        parallelc = {c, parallelc[15:1]};
    #2;
    end
    end
    // donex <= 1;
    // doney <= 1;
    // donec <= 1;

endtask

task sendTriangle;

    check = $fscanf(triangleList, "%d.%d,%d.%d,%d.%d,%d.%d,%d.%d,%d.%d\n", 
                        x0[15:6],x0dec, x1[15:6],x1dec, x2[15:6],x2dec, y0[15:6],y0dec, y1[15:6],y1dec, y2[15:6],y2dec);
    
    x0[5:0] = (x0dec / 100) * 64;
    
    x1[5:0] = (x1dec / 100) * 64;
    x2[5:0] = (x2dec / 100) * 64;

    y0[5:0] = (y0dec / 100) * 64;
    y1[5:0] = (y1dec / 100) * 64;
    y2[5:0] = (y2dec / 100) * 64;
    // $display(x0[5:0]);
    // $display(x1[5:0]);
    // $display(x2[5:0]);

    // $display(y0[5:0]);
    // $display(y1[5:0]);
    // $display(y2[5:0]);




    // c0[5:0] = (c0dec / 100) * 64;
    // c1[5:0] = (c1dec / 100) * 64;
    // c2[5:0] = (c2dec / 100) * 64;
    
endtask


always begin
    clk = 1;
    #1;
    clk = 0;
    #1;
end

initial begin

    for (int i = 0; i < 240; i++) begin
        for (int j = 0; j < 320; j++) begin
            area_screen[i][j] = "(0,0,0)";
            weights_screen[i][j] = "(0,0,0)";//16'b0;
            screen[i][j] = 16'b0;
            edge_screen[i][j] = "(0,0,0)";
        end
    end

    triangleCheck = $fopen("../../users/isaac/Documents/Chips/rasterizer/triangles.txt", "r");
    while($fgets(ln,triangleCheck) != 0) begin
        total_triangles++;
    end
    $fclose(triangleCheck);
    
    edge_fun = $fopen("./out_edge_func.txt", "w");
    fileDescriptor = $fopen("./out.txt", "w");
    weights = $fopen("./out_weights.txt", "w");
    area = $fopen("./out_area.txt", "w");
    vis = $fopen("./out_screen.txt", "w");
    triangleList = $fopen("../../users/isaac/Documents/Chips/rasterizer/triangles.txt", "r");
    
    cp0 = 16'b1111100000000001; //red 
    cp1 = 16'b0000011111000001; //green
    cp2 = 16'b0000000000111111; //blue

    sendTriangle();


    //vec = {x1, x2, x3, y1, y2, y3, c1, c2, c3};
    rst = 1;
    //total_triangles = 1;
    #4;
    rst = 0;
    //start = 1;
    //while(triangle_count != 0)
    
    sendserial(.x0(x0), .x1(x1), .x2(x2), .y0(y0), .y1(y1), .y2(y2), .ci0(cp0), .ci1(cp1), .ci2(cp2));



end

always@(negedge clk) begin

    if (triangle_count == total_triangles) begin
        for (int i = 0; i < 240; i++) begin
            for (int j = 0; j < 320 ; j++) begin
                //if(screen[i][j]) begin
                //$write( "%d,", screen[i][j]);
                //end
                $fwrite(vis, "%d,", screen[i][j]);
                $fwrite(weights, "%s,", weights_screen[i][j]);
                $fwrite(area, "%s,", area_screen[i][j]);
                $fwrite(edge_fun, "%s,", edge_screen[i][j]);
                //$fwrite(fileDescriptor, "Foundone");
            end
            //$display("\n");
            $fwrite(area, "\n");
            $fwrite(vis, "\n");
            $fwrite(weights, "\n");
            $fwrite(edge_fun, "\n");
        end
        $display("File write complete");
        $fclose(edge_fun);
        $fclose(area);
        $fclose(weights);
        $fclose(vis);
        $fclose(fileDescriptor);
        $fclose(triangleList);
        $stop;
    end

    end

always @(posedge clk) begin
    // if(done) begin
    //     $display("Done");
    // end
    // if(done) begin
    //     triangle_count++;
    // end
    // if(start) begin
    //     start = 0;
 
    // end
    if(done) begin
        triangle_count++;
        if(triangle_count != total_triangles) begin
            //$display(triangle_count);
            start = 1;
            sendTriangle();
            #4;
            sendserial(.x0(x0), .x1(x1), .x2(x2), .y0(y0), .y1(y1), .y2(y2), .ci0(cp0), .ci1(cp1), .ci2(cp2));
            start = 0;
        end
        //#3;
        
        
        //start = 0;
    end
    
    if (valid) begin
        #2;
        readx<=1;
        read(.parallelx(x), .parallely(y), 
        .parallelc(color), .donex(readx), .doney(ready), .donec(readc));

        //$display("Valid Pixel (%d,%d)",y >>> 6,x >>> 6);

        //screen[y_display[15:6]][x_display[15:6]] <= color_display;

        

        tempw0 = int'(chip.w0);
        tempw1 = int'(chip.w1);
        tempw2 = int'(chip.w2);

        w0 = $sformatf("%0d", tempw0);
        w1 = $sformatf("%0d", tempw1);
        w2 = $sformatf("%0d", tempw2);

        tempa0 = int'(chip.area_p12);
        tempa1 = int'(chip.area_0p2);
        tempa2 = int'(chip.area_01p);

        a0 = $sformatf("%0d", tempa0);
        a1 = $sformatf("%0d", tempa1);
        a2 = $sformatf("%0d", tempa2);

        tempe0 = int'(chip.edge1);
        tempe1 = int'(chip.edge2);
        tempe2 = int'(chip.edge3);

        e0 = $sformatf("%0d", tempe0);
        e1 = $sformatf("%0d", tempe1);
        e2 = $sformatf("%0d", tempe2);

        weights_screen[y[15:6]][x[15:6]] <= {"(", w0, ",", w1, ",", w2, ")"};

        area_screen[y[15:6]][x[15:6]] <= {"(", a0, ",", a1, ",", a2, ")"};

        edge_screen[y[15:6]][x[15:6]] <= {"(", e0, ",", e1, ",", e2, ")"};


        screen[y[15:6]-1][x[15:6]-1] <= color;
        //$display("Valid Pixel (%d,%d)",y[15:6],x[15:6]);

        $fwrite(fileDescriptor, "%d,%d,%d\n", x[15:6], y[15:6], color);
        // ready  <= 0;
        // readx  <= 0;
        // readc  <= 0;

   end



end






endmodule