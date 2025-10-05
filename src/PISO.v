module PISO (
    input wire clk,
    input wire rst,
    input wire [15:0] in,
    input wire valid_data,
    output reg piso_done,
    output reg out
);

reg [3:0] count;
reg [15:0] temp;
reg busy;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        temp <=0;
        count <= 0;
        busy <= 0;
        piso_done <= 0;
        out <= 0;
    end
    else if (valid_data && !busy) begin
        temp <= {1'b0, in[15:1]};
        out <= in[0];
        count <= 0;
        busy <= 1;
        piso_done <= 0;
    end
    else if (busy) begin
        out <= temp[0];
        temp <= {1'b0, temp[15:1]};
        count <= count + 1;

        if (count == 14) begin
            busy <= 0;
            piso_done <= 1;
            count <= 0;
        end
        else begin
            piso_done <= 0;
        end
    end
    else begin
        piso_done <= 0;
    end
end
endmodule