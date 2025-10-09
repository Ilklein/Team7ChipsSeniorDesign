module SIPO9 (
    input wire clk,
    input wire rst,
    input wire in,
    input wire valid_data,
    output reg sipo_done,
    output reg [15:0] out
);
    
reg [3:0] count;
reg busy;

always @(posedge clk) begin
    if (rst) begin
        out <= 16'b0;
        count <= 0;
        sipo_done <= 0;
        busy <= 0;
    end
    else begin
        if (!busy) begin
            out <= {out[14:0], in};
            count <= count + 1;
            if(count == 4'd15) begin
                sipo_done <= 1;
                busy <= 1;         // prevent counting again
            end
        end
        else begin
            sipo_done <= 0;
            if(valid_data) begin // once start is triggered, start new triangle
                count <= 0;
                busy <= 0;
            end
        end
    end
end
endmodule
