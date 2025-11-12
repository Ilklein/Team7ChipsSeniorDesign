module PISO (
    input wire clk,
    input wire rst,
    input wire [1:0] in,
    input wire valid_data,
    output reg piso_done,
    output reg out
);

reg count;
//reg temp;
reg busy;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        //temp <=0;
        count <= 0;
        busy <= 0;
        piso_done <= 0;
        out <= 0;
    end
    else if (valid_data && !busy) begin
        //temp <= in[1];
        out <= in[0];
        count <= 1;
        busy <= 1;
        piso_done <= 0;
    end
    else if (busy) begin
        //count <= count + 1;

        if (count == 1) begin
            out <= in[1];
            busy <= 0;
            piso_done <= 1;
            count <= 0;
        end
        else begin
            piso_done <= 0;
        end
    end
    else begin
        count <=0;
        piso_done <= 0;
        out <=0;
    end
end
endmodule