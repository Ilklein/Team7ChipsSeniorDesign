module PISO4 (
    input wire clk,
    input wire rst,
    input wire [3:0] in,
    input wire valid_data,
    output reg piso_done,
    output reg out
);

reg [1:0] count;
reg [3:0] temp;
reg busy;

always @(posedge clk) begin
    if (rst) begin
        temp <=0;
        count <= 0;
        busy <= 0;
        piso_done <= 0;
        out <= 0;
    end
    else if (valid_data && !busy) begin
        temp <= in;
        count <= 0;
        busy <= 1;
        piso_done <= 0;
    end
    else if (busy) begin
        out <= temp[0];
        temp <= {1'b0, temp[3:1]};
        count <= count + 1;

        if (count == 3) begin
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