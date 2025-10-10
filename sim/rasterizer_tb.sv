module rasterizer_tb();

//         input wire CLK,
//         input wire RST,
//         input wire D,   // data is Q10.6 fixed point, format x1, y1, c1, x2, y2, c2, x3, y3, c3
//         output wire C,  // output color
//         output wire PX, // output pixel x coord
//         output wire PY, // output pixel y coord
//         output reg VALID, // output pixel valid
//         output reg DONE // done with current triangle


//Inputs to rasterizer
logic clk;
logic rst;
logic d;

//Outputs of rasterizer
logic c;
logic px;
logic py;
logic valid;
logic done;


logic [15:0] x1;
logic [15:0] x2;
logic [15:0] x3;
logic [15:0] y1;
logic [15:0] y2;
logic [15:0] y3;
logic [15:0] c1 = 16'b1111100000000001; //red 
logic [15:0] c2 = 16'b0000011111000001; //green
logic [15:0] c3 = 16'b0000000000111110; //blue
logic [143:0] vec;

logic [15:0] screen [239:0][319:0];
logic [15:0] x;
logic readx = 0;
logic [15:0] y;
logic ready = 0;
logic [15:0] color;
logic readc = 0;
int fileDescriptor;
logic [15:0] y_display, x_display, color_display;
assign color_display = chip.color;
assign x_display = chip.xpos_out;
assign y_display = chip.ypos_out;

//logic read;

rasterizer chip (.CLK(clk), .RST(rst), .D(d), .C(c), .PX(px), .PY(py), .VALID(valid), .DONE(done)); //instaniate register


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
            x2 = c;
            x3 = a;
        end else begin //a is leftmost
            x2 = a;
            x3 = c;
        end
    end
    else if(c > a && c > b) begin //c is rightmost
        x1 = c;
        if(b > a) begin //a is leftmost
            x2 = a;
            x3 = b;
        end else begin //b is leftmost
            x2 = b;
            x3 = a;
        end
    end 
    else begin //a is rightmost
        x1 = a;
        if(b > c) begin //c is leftmost
            x2 = c;
            x3 = b;
        end
        else begin //b is leftmost
            x2 = b;
            x3 = c;
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
    input [143:0] message;
    integer i;
    begin
    for(i = 0; i < 144; i++) begin
        d = message[i];
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
    begin
    for(int i = 0; i < 16; i++) begin
    parallelx = {px, parallelx[15:1]};
    parallely = {py, parallely[15:1]};
    parallelc = {c, parallelc[15:1]};
    #2;
    end
    end
    donex <= 1;
    doney <= 1;
    donec <= 1;

endtask


always begin
    clk = 1;
    #1;
    clk = 0;
    #1;
end

initial begin
    //makeTriangle(.x1(x1), .x2(x2), .x3(x3), .y1(y1), .y2(y2), .y3(y3));
    // x1 = 16'b0000111111000000;
    // x2 = 16'b0000000000000000;
    // x3 = 16'b0000000001000000;

    // y1 = 16'b0000111111000000;
    // y2 = 16'b0000000000000000;
    // y3 = 16'b0000000001000000;
    for (int i = 0; i < 240; i++) begin
        for (int j = 0; j < 320; j++) begin
            screen[i][j] = 16'b0;
        end
    end
    //$display("PWD: %s", $getcwd());
    fileDescriptor = $fopen("./out.txt", "w");
    //$display("FD: %d",fileDescriptor);


    x1 = {10'd0,6'd0};
    x2 = {10'd8,6'd0};
    x3 = {10'd8,6'd0};

    y1 = {10'd0,6'd0};
    y2 = {10'd0,6'd0};
    y3 = {10'd8,6'd0};

    vec = {x1, x2, x3, y1, y2, y3, c1, c2, c3};
    rst = 1;
    #4;
    rst = 0;
    sendserial(.message(vec));
    
end

always@(negedge clk) begin
        if (done) begin
            for (int i = 0; i < 10; i++) begin
                for (int j = 0; j < 10 ; j++) begin
                    //if(screen[i][j]) begin
                    $write( "%d,", screen[i][j]);
                    //end
                    $fwrite(fileDescriptor, "%d,", screen[i][j]);
                    //$fwrite(fileDescriptor, "Foundone");
                end
                $display("\n");
                $fwrite(fileDescriptor, "\n");
            end
            $display("File write complete");
            $fclose(fileDescriptor);
            $stop;
        end

    end

always @(posedge clk) begin
    // if(done) begin
    //     $display("Done");
    // end
    if (valid) begin
        
        read(.parallelx(x), .parallely(y), 
        .parallelc(color), .donex(readx), .doney(ready), .donec(readc));
        //$display("test");
        //y_display = chip.ypos;
        //x_display = chip.xpos;
        //color_display = chip.color;
        //$display("Valid Pixel (%d,%d)",y_display >>> 6,x_display >>> 6);
        //screen[y_display[15:6]][x_display[15:6]] <= color_display;
        screen[y_display[15:6]][x_display[15:6]] <= color;
        ready  <= 0;
        readx  <= 0;
        readc  <= 0;

   end



end






endmodule