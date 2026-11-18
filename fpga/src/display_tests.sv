// top-level module for testing the display and displaying a static pattern on the display

// For now using typical parameters
// HSYNC: 10 DOTCLK
// HBP: 20 DOTCLK
// HAdr (data): 240 DOTCLK
// HFP: 10 DOTCLK
// VSYNC: 2 Lines
// VBP: 2 Lines
// VAdr (data): 320
// VFP: 4 Lines
//
// Back porch comes before data, front porch comes after
// Display is 240 horizontal pixels and 320 vertical pixels
//
// HSYNC, Back Porch, Data, Front porch

// be sure to write pixel data on the falling edge of dotclock

module display_tests(output logic display_dotclk, display_de,
                     output logic display_hsync, display_vsync,
                     output logic [15:0] display_rgb565);

    logic int_osc; // 48MHz Clock; not very stable, might need to be replaced
    HSOSC #(.CLKHF_DIV("0b00")) hf_osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));


    logic [7:0] current_pixel, odd_pixel, even_pixel;
    line_buffer odd_line(int_osc, 1'b0, hpos_count - 9'd31, 8'b0, odd_pixel); // figure all of this stuff out
    line_buffer even_line(int_osc, 1'b0, hpos_count - 9'd31, 8'b0, even_pixel);

    assign current_pixel = ((hpos_count - 9'd30) & 1'b1) ? odd_pixel : even_pixel;

    // These all become 0 at same clock tick
    logic [3:0] decimated_clk; // 3MHz DOTCLK
    counter #('d15) counter0(int_osc, 'b0, 'b1, decimated_clk);
    logic [8:0] hpos_count;
    counter #('d279) counter1(int_osc, 'b0, decimated_clk == 15, hpos_count);
    logic [8:0] vpos_count;
    counter #('d327) counter2(int_osc, 'b0, hpos_count == 279 && (decimated_clk == 15), vpos_count);

    logic [15:0] decoded_color;
    palette_decoder color_decoder(int_osc, current_pixel, decoded_color);

    // intermediate data
    logic valid_data_region;
    assign valid_data_region = (hpos_count >= 31 && hpos_count < 271 && vpos_count >= 4 && vpos_count < 324) ? 1 : 0;
    // TODO figure out why these numbers are weird (why does this make stuff kinda blank?)

    // check pg 49 in ILI9341V PDF
    // synchrynous display logic
    always_ff @(posedge int_osc) begin
        if (decimated_clk == 3) begin // falling edge of dotclk
            display_dotclk <= 0;
        end else if (decimated_clk == 5) begin // a bit after falling edge of dotclk
            display_de <= valid_data_region;
            display_rgb565 <= valid_data_region ? decoded_color : 16'b0; // all black on the porches
            display_hsync <= ~(hpos_count < 10); // which clock edge do we want to update at?
            display_vsync <= ~(vpos_count < 2);
        end else if (decimated_clk == 11) begin // rising edge of dotclk
            display_dotclk <= 1;
        end
    end

endmodule

