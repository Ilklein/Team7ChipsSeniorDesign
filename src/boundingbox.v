module boundingbox(
    input wire signed [15:0] v0x, 
    input wire signed [15:0] v1x,
    input wire signed [15:0] v2x,
    input wire signed [15:0] v0y,
    input wire signed [15:0] v1y,
    input wire signed [15:0] v2y,
    output wire signed [15:0] XMIN,
    output wire signed [15:0] XMAX,
    output wire signed [15:0] YMIN,
    output wire signed [15:0] YMAX
);

    wire signed [15:0] xmax_unrounded, xmin_unrounded, ymax_unrounded, ymin_unrounded;
    
    // assign xmax_unrounded = (v0x > v1x) ? ((v0x > v2x) ? v0x : v2x) : ((v1x > v2x) ? v1x : v2x);
    // assign xmin_unrounded = (v0x < v1x) ? ((v0x < v2x) ? v0x : v2x) : ((v1x < v2x) ? v1x : v2x);
    // assign ymax_unrounded = (v0y > v1y) ? ((v0y > v2y) ? v0y : v2y) : ((v1y > v2y) ? v1y : v2y);
    // assign ymin_unrounded = (v0y < v1y) ? ((v0y < v2y) ? v0y : v2y) : ((v1y < v2y) ? v1y : v2y);
    
    maximum xmax_mod (.p1(v0x), .p2(v1x), .p3(v2x), .max(xmax_unrounded));
    minimum xmin_mod (.p1(v0x), .p2(v1x), .p3(v2x), .min(xmin_unrounded));
    maximum ymax_mod (.p1(v0y), .p2(v1y), .p3(v2y), .max(ymax_unrounded));
    minimum ymin_mod (.p1(v0y), .p2(v1y), .p3(v2y), .min(ymin_unrounded));

    round_fixed_point rounded_xmax (
        .unrounded(xmax_unrounded),
        .rounded(XMAX)
    );
    round_fixed_point rounded_xmin (
        .unrounded(xmin_unrounded),
        .rounded(XMIN)
    );
    round_fixed_point rounded_ymax (
        .unrounded(ymax_unrounded),
        .rounded(YMAX)
    );
    round_fixed_point rounded_ymin (
        .unrounded(ymin_unrounded),
        .rounded(YMIN)
    );
    
endmodule

module round_fixed_point( // Only works for positive numbers
    input wire [15:0] unrounded,
    output wire [15:0] rounded
); 
    assign rounded = {unrounded[15:6], 6'b0} + 64*unrounded[5];
endmodule

    module maximum(
        input [15:0] p1,
        input [15:0] p2,
        input [15:0] p3,
        //input [7:0] count,
        output reg [15:0] max
        );

        always @(*) begin
            //if(count == 95) begin
                if(p1[15:6] > p2[15:6]) begin
                    if(p1[15:6] > p3[15:6]) begin
                        max = p1;
                    end 
                    else begin
                        max = p3;
                    end 
                end
                else begin//(p2>=p1)
                    if(p2[15:6] > p3[15:6]) begin
                        max = p2;
                    end
                    else begin //(p3>=p2) 
                        max = p3;
                    end
                end
            end
       // end
    endmodule

    module minimum(
        input [15:0] p1,
        input [15:0] p2,
        input [15:0] p3,
        //input [7:0] count,
        output reg [15:0] min
        );
        always @(*) begin
            //if(count == 95) begin
                if(p1[15:6] < p2[15:6]) begin
                    if(p1[15:6] < p3[15:6]) begin
                        min = p1;
                    end 
                    else begin
                        min = p3;
                    end 
                end
                else begin//(p2<=p1)
                    if(p2[15:6] < p3[15:6]) begin
                        min = p2;
                    end
                    else begin //(p3<=p2) 
                        min = p3;
                    end
                end
            end
        //end
    endmodule