module boundingbox_tb();
    
    input en;
    input clk;
    input in;

    output [15:0] xmin;
    output [15:0] xmax;
    output [15:0] ymin,
    output [15:0] ymax

    wire [143:0] out;
    
    sipo sipo_test (
        .in(in),
        .clk(clk),
        .en(en),
        .out(out)
    )

    boundingbox boundingbox_test (
        .v0x(out[15:0]),
        .v1x(out[31:16]),
        .v2x(out[47:32]),
        .v0y(out[63:48]),
        .v1y(out[79:64]),
        .v2y(out[95:80]),
        .clk(clk),
        .xmin(xmin),
        .xmax(xmax),
        .ymin(ymin),
        .ymax(ymax)
    )
 


    task sendserial;
        input message[143:0];
        int i;
        for(i = 0; i < 143; i++) begin
            in = message[i];
            #2;
        end
    endtask

    always begin
        clk = 1;
        #1;
        clk = 0;
        #1;
    end

    initial begin 

        en <= 1;
        inp [143:0] = 1111111111000000
                      0000000000111111
                      1010101010101010
                      0000000000111111
                      1111111111000000
                      0101010101010101
        
        $display("v0x: %d.%d",inp[15:6],inp[5:0]);
        $display("v1x: %d.%d",inp[31:22],inp[21:16]);
        $display("v2x: %d.%d",inp[47:38],inp[37:32]);
        sendserial(inp);
        $display("v0x: %d.%d",xmax[15:6],xmax[5:0]);



    end





endmodule