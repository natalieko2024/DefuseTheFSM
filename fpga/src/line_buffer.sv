// Comment to be made blah blah blah

module line_buffer(input logic clk, write,
                   input logic [7:0] line_index,
                   input logic [7:0] data_in,
                   output logic [7:0] data_out);

    logic [7:0] display_line [239:0];

    initial begin
        for (int i = 0; i < 240; i++) begin : init
            // color ramp #5555FF #55FF55 #55FFFF #FF5555 #FF55FF #FFFF55
            display_line[i]  = ((i/4) % 6) + 9; 
        end
    end

    always_ff @(posedge clk) begin
        if (write) begin
            display_line[line_index] <= data_in;
        end else begin
            data_out <= display_line[line_index];
        end
    end

endmodule
