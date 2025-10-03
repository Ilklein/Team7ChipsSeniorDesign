module rasterizer_tb()

//         input wire CLK,
//         input wire RST,
//         input wire D,   // data is Q10.6 fixed point, format x1, y1, c1, x2, y2, c2, x3, y3, c3
//         output wire C,  // output color
//         output wire PX, // output pixel x coord
//         output wire PY, // output pixel y coord
//         output reg VALID, // output pixel valid
//         output reg DONE // done with current triangle

input clk;
input rst;
input d;
output c;
output px;
output py;
output valid;
output done;

logic [15:0] x1;
logic [15:0] x2;
logic [15:0] x3;
logic [15:0] y1;
logic [15:0] y2;
logic [15:0] y3;
logic [15:0] c1 = 16'b1111100000000001; //red 
logic [15:0] c2 = 16'b0000011111000001; //green
logic [15:0] c3 = 16'b0000000000111110; //blue
logic [143:0] in;

logic [15:0] screen [239:0][319:0];
logic [8:0] x;
logic readx = 0;
logic [8:0] y;
logic ready = 0;
logic [15:0] color;
logic readc = 0;
int fileDescriptor;

logic read;

rasterizer chip (.CLK(clk), .RST(rst), .D(d), .C(c), .PX(px), .PY(py), .VALID(valid), .DONE(done)); //instaniate register

task makeTriangle;
    output x1 [15:0];
    output x2 [15:0];
    output x3 [15:0];
    output y1 [15:0];
    output y2 [15:0];
    output y3 [15:0];


    wire xa [9:0];
    wire xb [9:0];
    wire xc [9:0];
    wire ya [9:0];
    wire yb [9:0];
    wire yc [9:0];

    wire xg [5:0];
    wire xh [5:0];
    wire xi [5:0];
    wire yg [5:0];
    wire yh [5:0];
    wire yi [5:0];


    int a,b,c,d,e,f;
    a = {$random} % 321;
    b = {$random} % 321;
    c = {$random} % 321;

    d = {$random} % 241;
    e = {$random} % 241;
    f = {$random} % 241;
    counterclockwise(.a(a), .b(b), .c(c), .x1(xa), .x2(xb), .x3(xc));
    ya = d >>> 22;
    yb = e >>> 22;
    yc = f >>> 22;

    int g, h, i, j, k, l;
    g = {$random} % 64;
    h = {$random} % 64;
    i = {$random} % 64;

    j = {$random} % 64;
    k = {$random} % 64;
    l = {$random} % 64;

    xg = i >>> 26;
    xh = j >>> 26;
    xi = k >>> 26;

    x1 = {xa,xg};
    x2 = {xb,xh};
    x3 = {xc,xi};

    y1 = {ya,yg};
    y2 = {yb,yh};
    x3 = {yc,yi};

endtask

task counterclockwise;
    input a;
    input b;
    input c;


    output x1 [9:0];
    output x2 [9:0];
    output x3 [9:0];


    if(b > a && b > c) begin  //b is rightmost 
        x1 = b >>> 22;
        y1 = e >>>
        if(a > c) begin //c is leftmost
            x2 = c >>> 22;
            x3 = a >>> 22;
        end else begin //a is leftmost
            x2 = a >>> 22;
            x3 = c >>> 22;
        end
    end
    else if(c > a && c > b) begin //c is rightmost
        x1 = c >>> 22;
        if(b > a) begin //a is leftmost
            x2 = a >>> 22;
            x3 = b >>> 22;
        end else begin //b is leftmost
            x2 = b >>> 22;
            x3 = a >>> 22;
        end
    end 
    else begin //a is rightmost
        x1 = a >>> 22;
        if(b > c) begin //c is leftmost
            x2 = c >>> 22;
            x3 = b >>> 22;
        end
        else begin //b is leftmost
            x2 = b >>> 22;
            x3 = c >>> 22;
        end

    end

endtask

task sendserial;
    input message[143:0];
    int i;
    for(i = 0; i < 143; i++) begin
        in = message[i];
        #2;
    end
endtask

task read;

    input toRead;
    output [15:0] parallel;

    for(int i = 0; i < 16; i++) begin
    parallel <= {toRead, parallel[15:1]};
    end


endtask

always begin
    clk = 1;
    #1;
    clk = 0;
    #1;
end

initial begin

    makeTriangle(.x1(x1), .x2(x2), .x3(x3), .y1(y1), .y2(y2), .y3(y3));
    in = {x1,x2,x3,y1,y2,y3,c1,c2,c3};
    sendserial(in); 
    
end

    always@(posedge clk) begin 
        if(chip.out_ready) begin 
            read(px, readx, x);
            read(py, ready, y);
            read(c, readc, color);

            if(readx && ready && readc) begin
                screen[y][x] = color;
                ready = 0;
                readx = 0;
                readz = 0;
            end
        end
        if(done) begin // I think this is everything has been outputted
            //Dump to file;
            fileDescriptor = $fopen("out.txt","w");

            if(fileDescriptor == 0) begin
                $display("File NOT opened succesfully");
            end

            for(int i = 0; i < 240; i++) begin
                for(int j = 0; j < 320; j++) begin
                    $write(screen[i][j]);
                    $fwrite(fileDescriptor,"%d,", screen[i][j]);
                end
                $write("\n");
            end



        $fclose(fileDescriptor);

        end//start reading outputs

    end




endmodule