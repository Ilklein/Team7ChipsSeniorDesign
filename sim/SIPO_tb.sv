

module SIPO_tb();

    reg en;
    reg clk;
    reg in;

    reg [143:0] out;
    


    SIPO sipo_test (.in(in), .clk(clk), .en(en), .out(out));

    task sendserial;
        input [143:0] message;
        int i;
        for(i = 0; i < 143; i++) begin
            in <= message[i];
            #2;
        end
    endtask

    

    always begin
        clk <= 1;
        #1;
        clk <= 0;
        #1;
    end

    initial begin
        logic [143:0] inp;
        #2;
        en <= 1;
        inp = {
                      16'b1111111111000000,
                      16'b0000000000111111,
                      16'b1010101010101010,
                      16'b0000000000111111,
                      16'b1111111111000000,
                      16'b0101010101010101
                      
        };
        $display("v0x: %d.%d",inp[15:6],inp[5:0]);
        $display("v1x: %d.%d",inp[31:22],inp[21:16]);
        $display("v2x: %d.%d",inp[47:38],inp[37:32]);
        $display("v0y: %d.%d",inp[63:54],inp[53:48]);
        $display("v1y: %d.%d",inp[79:70],inp[69:64]);
        $display("v2y: %d.%d",inp[95:86],inp[85:80]);
        sendserial(inp);
        #2;
        $display("v0x: %d.%d",out[15:6],out[5:0]);
        $display("v1x: %d.%d",out[31:22],out[21:16]);
        $display("v2x: %d.%d",out[47:38],out[37:32]);
        $display("v0y: %d.%d",out[63:54],out[53:48]);
        $display("v1y: %d.%d",out[79:70],out[69:64]);
        $display("v2y: %d.%d",out[95:86],out[85:80]);
        

    end


endmodule
