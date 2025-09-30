module counter #(
    parameter MAX = 143,
    parameter WIDTH = 8
) (
    input clk,
    input en,
    output reg [WIDTH-1:0] count
);
    
    always @(posedge clk) begin
        if(en && (count != MAX)) begin 
            count <= count + 1;
        end 
        else begin
            count <= 0;
        end
    end
endmodule
