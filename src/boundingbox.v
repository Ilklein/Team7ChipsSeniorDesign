module boundingbox(
    input D, //format x1,x2,x3, y1,y2,y3, c1,c2,c3
    input EN,
    input CLK,
    output wire XMINI,
    output wire XMAXI,
    output wire YMINI,
    output wire YMAXI
);



    wire [143:0] p;
    wire [8:0] ma,mi;
    wire [4:0] count;
    wire xory;

    wire [8:0] XMAX;
    wire [8:0] XMIN;
    wire [8:0] YMIN;
    wire [8:0] YMAX;



    sipo points (CLK,D,EN,p);
    maximum max (p[8:0], p[17:9], p[26:18],ma);
    minimum min (p[8:0], p[17:9], p[26:18],mi);
    counter counter_27 (CLK, EN, count, xory);
    select s (CLK, xory, ma, mi, count, XMIN, XMAX, YMIN, YMAX);
    muxouput s1 (OSEL, XMIN[8:0], XMAX[8:0], YMIN[8:0], YMAX[8:0], count, p, ma, xory, OMUX);
    pisox xmi (CLK, xory, count, XMIN, XMINI);
    pisox xma (CLK, xory, count, XMAX, XMAXI);
    pisoy ymi (CLK, xory, count, YMIN, YMINI);
    pisoy yma (CLK, xory, count, YMAX, YMAXI);

endmodule

    module counter(
        input CLK,
        input EN,
        output reg [4:0] count,
        output reg xory
        );
        

        always@(posedge CLK) begin

            if(EN) begin
                count <= count + 1; 
            end 
            else begin
                count <= 5'b00000;
                xory <= 1'b1;
            end
            if(count == 27) begin
                xory <= ~xory;
                count <= 5'b00001;
            end

        end
    endmodule

    module select(
        input CLK,
        input xory, 
        input[8:0] ma,
        input[8:0] mi,
        input[4:0] count,
        output reg [8:0] XMIN, 
        output reg [8:0] XMAX, 
        output reg [8:0] YMIN, 
        output reg [8:0] YMAX);

        //every 27 clock cycles we sample all 
            always@(posedge CLK) begin
                if(count == 27) begin //1 cycle delay is necessary but must be considered
                    if(xory==1) begin
                        //call XMAX
                        XMAX <= ma;
                        //call XMIN
                        XMIN <= mi;
                    end 
                    else begin
                        //call YMAX
                        YMAX <= ma;
                        //call YMIN
                        YMIN <= mi;
                    end           
                end
            end
    endmodule

    module sipo(
        input CLK,
        input D,
        input EN,
        output reg [26:0] p
        );
        always @ (posedge CLK) begin
            if(EN) begin //when enable goes high we can start to write on the next clock cycle. must wait or raise it a bit before (not on rising edge or it will be delayed a clock cycle)
            p <= {p[25:0],D};
            end
        end
    endmodule

    module pisox(
            input CLK,
            input xory,
            input[4:0] count,
            input [8:0] P,
            output reg S
            );

            reg [8:0] temp;

            always @ (posedge CLK) begin

                if(count == 1 && !xory) begin //not sure if this is the correct way to do it will have to test. MIGHT HAVE TO BE 28 TOO
                    temp <= P; 

                end else begin
                S <= temp[8];
                temp <= temp << 1; 
                end
            end
    endmodule

        module pisoy(
            input CLK,
            input xory,
            input[4:0] count,
            input [8:0] P,
            output reg S
            );

            reg [8:0] temp;

            always @ (posedge CLK) begin

                if(count == 1 && xory) begin //not sure if this is the correct way to do it will have to test. MIGHT HAVE TO BE 28 TOO
                    temp <= P; 

                end else begin
                S <= temp[8];
                temp <= temp << 1; 
                end
            end
    endmodule

    module maximum(
        input [8:0] p1,
        input [8:0] p2,
        input [8:0] p3,
        output reg [8:0] ma
        );

        always @(*) begin
            if(p1>p2) begin
                if(p1>p3) begin
                    ma = p1;
                end 
                else begin
                    ma = p3;
                end 
            end
            else begin//(p2>=p1)
                if(p2 > p3) begin
                    ma = p2;
                end
                else begin //(p3>=p2) 
                    ma = p3;
                end
            end
        end
    endmodule

    module minimum(
        input [8:0] p1,
        input [8:0] p2,
        input [8:0] p3, 
        output reg [8:0] mi
        );
        always @(*) begin
        if(p1<p2) begin
                if(p1<p3) begin
                    mi = p1;
                end 
                else begin
                    mi = p3;
                end 
            end
            else begin//(p2<=p1)
                if(p2 < p3) begin
                    mi = p2;
                end
                else begin //(p3<=p2) 
                    mi = p3;
                end
            end
        end
    endmodule

    module muxouput(  
            input [6:0] S,
            input [8:0] XMIN,
            input [8:0] XMAX,
            input [8:0] YMIN,
            input [8:0] YMAX,
            input [4:0] counter,
            input [26:0] p,
            input [8:0] xmaxpre,
            input xory,
            output reg omux
            );

            always @(*) begin
            case (S)
            7'd0:  omux = XMAX[0];
            7'd1:  omux = XMAX[1];
            7'd2:  omux = XMAX[2];
            7'd3:  omux = XMAX[3];
            7'd4:  omux = XMAX[4];
            7'd5:  omux = XMAX[5];
            7'd6:  omux = XMAX[6];
            7'd7:  omux = XMAX[7];
            7'd8:  omux = XMAX[8];

            7'd9:  omux = XMIN[0];
            7'd10: omux = XMIN[1];
            7'd11: omux = XMIN[2];
            7'd12: omux = XMIN[3];
            7'd13: omux = XMIN[4];
            7'd14: omux = XMIN[5];
            7'd15: omux = XMIN[6];
            7'd16: omux = XMIN[7];
            7'd17: omux = XMIN[8];

            7'd18: omux = YMAX[0];
            7'd19: omux = YMAX[1];
            7'd20: omux = YMAX[2];
            7'd21: omux = YMAX[3];
            7'd22: omux = YMAX[4];
            7'd23: omux = YMAX[5];
            7'd24: omux = YMAX[6];
            7'd25: omux = YMAX[7];
            7'd26: omux = YMAX[8];

            7'd27: omux = YMIN[0];
            7'd28: omux = YMIN[1];
            7'd29: omux = YMIN[2];
            7'd30: omux = YMIN[3];
            7'd31: omux = YMIN[4];
            7'd32: omux = YMIN[5];
            7'd33: omux = YMIN[6];
            7'd34: omux = YMIN[7];
            7'd35: omux = YMIN[8];

            7'd36: omux = p[0];
            7'd37: omux = p[1];
            7'd38: omux = p[2];
            7'd39: omux = p[3];
            7'd40: omux = p[4];
            7'd41: omux = p[5];
            7'd42: omux = p[6];
            7'd43: omux = p[7];
            7'd44: omux = p[8];
            7'd45: omux = p[9];
            7'd46: omux = p[10];
            7'd47: omux = p[11];
            7'd48: omux = p[12];
            7'd49: omux = p[13];
            7'd50: omux = p[14];
            7'd51: omux = p[15];
            7'd52: omux = p[16];
            7'd53: omux = p[17];
            7'd54: omux = p[18];
            7'd55: omux = p[19];
            7'd56: omux = p[20];
            7'd57: omux = p[21];
            7'd58: omux = p[22];
            7'd59: omux = p[23];
            7'd60: omux = p[24];
            7'd61: omux = p[25];
            7'd62: omux = p[26];

            7'd63: omux = xmaxpre[0];
            7'd64: omux = xmaxpre[1];
            7'd65: omux = xmaxpre[2];
            7'd66: omux = xmaxpre[3];
            7'd67: omux = xmaxpre[4];
            7'd68: omux = xmaxpre[5];
            7'd69: omux = xmaxpre[6];
            7'd70: omux = xmaxpre[7];
            7'd71: omux = xmaxpre[8];

            7'd72: omux = counter[0];
            7'd73: omux = counter[1];
            7'd74: omux = counter[2];
            7'd75: omux = counter[3];
            7'd76: omux = counter[4];

            7'd77: omux = xory;


                
                default: omux = 0;
            endcase

            end
    endmodule
