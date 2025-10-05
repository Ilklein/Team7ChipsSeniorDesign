module SIPO (
    input wire clk,
    input wire rst,
    input wire in,
    input reg [7:0] count,
    input wire valid_data,
    output reg sipo_done,
    output reg [143:0] out
);
    
//reg [7:0] count = 0;
reg busy = 0;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        out <= 144'b0;
        //count <= 0;
        sipo_done <= 0;
        busy <= 0;
    end
    else begin
        if (!busy) begin
            out <= {in, out[143:1]};
            if(count == 143) begin
                sipo_done <= 1;
                busy <= 1;         // prevent counting again
            end 
            // else begin
            //     count <= count + 1;
            // end
        end
        else begin
            sipo_done <= 0;
            if(valid_data) begin // wait to start new triangle
                //count <= 0;
                busy <= 0;
            end
        end
    end
end
endmodule
