// Decodes the color pallete to the bits that go into the display (lookup table)
// Bits will be streamed out directly into the display

// currently no assumptions about alpha are made here, might want to add another output for it to be
// alpha so that a set color (say all-black) could still be outputted. This is an extra bit, don't
// consider for now.

module palette_decoder(input logic clk,
                       input logic [7:0] color_index,
                       output logic [15:0] color_rgb565);

    logic [15:0] color_palette [255:0];

    initial begin
        $readmemh("color_palette.mem", color_palette);
    end

    always_ff @(posedge clk) begin
        color_rgb565 <= color_palette[color_index];
    end

endmodule
