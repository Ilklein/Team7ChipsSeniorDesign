module area(
    input wire clk,
    input wire rst,
    input wire valid_data,
    input [15:0] xspan_pix,
    input [15:0] yspan_pix,
    output reg [15:0] area_012,
    output wire area_done
 );

    wire [3:0] msbx, msby;
    wire [15:0] area_012_temp;
    //reg area_done_temp;

    wire x_done;
    wire y_done;
    

findMSB x(.valid_data(valid_data), .rst(rst), .span(xspan_pix[8:0]), .msb(msbx), .done(x_done));
findMSB y(.valid_data(valid_data), .rst(rst), .span(yspan_pix[8:0]), .msb(msby), .done(y_done));
findArea a(.rst(rst), .x_done(x_done), .y_done(y_done), .msbx(msbx), .msby(msby), .area_012(area_012_temp), .area_done(area_done));
always @(posedge clk) begin 

    if(area_done) begin
        area_012 <= area_012_temp;
    end

end

endmodule


module findArea(
input reg rst,
input reg x_done,
input reg y_done,
input [3:0] msbx,
input [3:0] msby,
output reg area_done,
output reg [15:0] area_012
);


always @(*) begin
    area_012 = msbx + msby;
    area_done = 0;
    if(rst) begin 
        area_012 = 1;
        area_done = 0;
    end else 
    if(x_done && y_done) begin 
        area_012 = msbx + msby;
        area_done = 1;
    end else begin 
        ///area_012 = area_012;
        area_done = 0;
    end
end

endmodule

module findMSB(
    input reg valid_data,
    input reg rst,
    input reg [8:0] span,
    output reg [3:0] msb,
    output reg done
);

reg [8:0] temp;

always @(*) begin

    temp = span;

    done = 0;
    msb = 0;
    if(rst) begin 
        done = 0;
        msb = 0;
    end else if(valid_data) begin 

            temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end else begin
                done = 1;
            end

            temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end else begin
                done = 1;
            end

            temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end else begin
                done = 1;
            end

            temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end else begin
                done = 1;
            end

            temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end else begin
                done = 1;
            end

            temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end else begin
                done = 1;
            end

            temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end else begin
                done = 1;
            end

            temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end else begin
                done = 1;
            end

           temp = temp >> 1; //1
            if(temp != 0) begin 
                msb = msb + 1;
            end
                done = 1;
            

    end 

end

endmodule

