module boundingbox(
    input [95:0] coordinates, //format x1,x2,x3, y1,y2,y3, 
    input CLK,
    output [15:0] XMINI,
    output [15:0] XMAXI,
    output [15:0] YMINI,
    output [15:0] YMAXI
);

    wire [15:0] xma, xmi, yma, ymi;
    wire [7:0] count;

    counter counter_143 #(
        MAX = 143,
        WIDTH = 8
    ) (CLK, EN, count);

    maximum xmaximum (.p1(coordinates[15:0]), .p2(coordinates[31:16]), .p3(coordinates[47:32]), .count(count), .max(xma));
    minimum yminimum (.p1(coordinates[15:0]), .p2(coordinates[31:16]), .p3(coordinates[47:32]), .count(count), .min(xmi));
    maximum ymaximum (.p1(coordinates[63:48]), .p2(coordinates[79:64]), .p3(coordinates[95:80]), .count(count), .max(ymi));
    minimum yminimum (.p1(coordinates[63:48]), .p2(coordinates[79:64]), .p3(coordinates[95:80]), .count(count), .min(ymi));

    round_fixed_point rounded_xmax(.unrounded(xma, .rounded(XMAX)));
    round_fixed_point rounded_xmin(.unrounded(xmi, .rounded(XMIN)));
    round_fixed_point rounded_ymax(.unrounded(yma, .rounded(YMAX)));
    round_fixed_point rounded_ymin(.unrounded(ymi, .rounded(YMIN)));
    
    //select s (CLK, xory, ma, mi, count, XMIN, XMAX, YMIN, YMAX);

endmodule

module round_fixed_point(
    input [15:0] unrounded,
    output reg [15:0] rounded
); 

    if(unrounded[5])
    begin
        assign unrounded[5:0] = 6'b0;
        assign unrounded = unrounded + 1;
    end
    else
        assign unrounded[5:0] = 6'b0;

endmodule
   

    // module select(
    //     input CLK,
    //     input xory, 
    //     input[8:0] ma,
    //     input[8:0] mi,
    //     input[4:0] count,
    //     output reg [8:0] XMIN, 
    //     output reg [8:0] XMAX, 
    //     output reg [8:0] YMIN, 
    //     output reg [8:0] YMAX);

    //     //every 27 clock cycles we sample all 
    //         always@(posedge CLK) begin
    //             if(count == 27) begin //1 cycle delay is necessary but must be considered
    //                 if(xory==1) begin
    //                     //call XMAX
    //                     XMAX <= ma;
    //                     //call XMIN
    //                     XMIN <= mi;
    //                 end 
    //                 else begin
    //                     //call YMAX
    //                     YMAX <= ma;
    //                     //call YMIN
    //                     YMIN <= mi;
    //                 end           
    //             end
    //         end
    // endmodule

   
    module maximum(
        input [15:0] p1,
        input [15:0] p2,
        input [15:0] p3,
        input [7:0] count,
        output reg [15:0] max
        );

        always @(posedge clk) begin
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
        always @(posedge clk) begin
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
