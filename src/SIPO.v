
module SIPO (
    input in, //format x1,x2,x3, y1,y2,y3, c1,c2,c3
    input clk,
    input en,
    output reg [143:0] out
);
    always @ (posedge clk) begin
        if(en) begin //EN must be pulled high one clock cycle before we want to start sending data
            out <= {in, out[143:1]};
        end
    end
endmodule