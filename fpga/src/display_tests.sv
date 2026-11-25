// top-level module for testing the display and displaying a static pattern on the display

module display_tests(input logic sck, sdi, cs,
                     output logic display_dotclk = 'b0, display_de = 'b0,
                     output logic display_hsync = 'b0, display_vsync = 'b0,
                     output logic [15:0] display_rgb565 = 'b0,
                     output logic testing_flag);

    localparam int HSYNC = 10; // DOTCLK
    localparam int HBP = 22; // DOTCLK (20 by default)
    localparam int HDAT = 240; // DOTCLK
    localparam int HFP = 10; // DOTCLK (currently "effectively" 8)
    localparam int VSYNC = 2; // Lines
    localparam int VBP = 2; // Lines
    localparam int VDAT = 320; // Lines
    localparam int VFP = 4; // Lines

    logic int_osc; // 48MHz Clock; not very stable, might need to be replaced
    HSOSC #(.CLKHF_DIV("0b00")) hf_osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    logic display_configured;
    spi spi_peripheral(.clk(int_osc), .sck, .sdi, .cs, .sdo(), .display_configured);

    logic [8:0] hpos_count;

    logic [7:0] current_pixel, odd_pixel, even_pixel;
    line_buffer odd_line(int_osc, 1'b0, hpos_count - 9'(HSYNC+HBP), 8'b0, odd_pixel);
    line_buffer even_line(int_osc, 1'b0, hpos_count - 9'(HSYNC+HBP), 8'b0, even_pixel);

    logic [8:0] x_pos;
    assign x_pos = (hpos_count >= 9'(HSYNC+HBP)) ? (hpos_count - 9'(HSYNC+HBP)) : 9'd0;
    assign current_pixel = x_pos[0] ? odd_pixel : even_pixel;

    // These all become 0 at same clock tick
    logic [3:0] decimated_clk; // 3MHz DOTCLK
    counter #('d15) counter0(int_osc, 'b0, display_configured, decimated_clk);
    counter #(HSYNC+HBP+HDAT+HFP-1) counter1(int_osc, 'b0, decimated_clk == 15, hpos_count); // this counter still does not add up??
    logic [8:0] vpos_count;
    counter #(VSYNC+VBP+VDAT+VFP-1) counter2(int_osc, 'b0, hpos_count == (HSYNC+HBP+HDAT+HFP-1) && (decimated_clk == 15), vpos_count);

    logic [15:0] decoded_color;
    palette_decoder color_decoder(int_osc, current_pixel, decoded_color);


    // check pg 49 in ILI9341V PDF
    // synch display logic
    always_ff @(posedge int_osc) begin
        if (decimated_clk == 3) begin
            display_dotclk <= 0;
        end else if (decimated_clk == 4) begin // a bit after falling edge of dotclk
            display_de <= (hpos_count >= 9'(HSYNC+HBP) && hpos_count < 9'(HSYNC+HBP+HDAT) && 
                           vpos_count >= 9'(VSYNC+VBP) && vpos_count < 9'(VSYNC+VBP+VDAT));
            display_rgb565 <= (hpos_count >= 9'(HSYNC+HBP) && hpos_count < 9'(HSYNC+HBP+HDAT) && 
                               vpos_count >= 9'(VSYNC+VBP) && vpos_count < 9'(VSYNC+VBP+VDAT)) ? 
                               decoded_color : 16'b0; // all black on the porches
            display_hsync <= ~(hpos_count < HSYNC); // which clock edge do we want to update at?
            display_vsync <= ~(vpos_count < VSYNC);
        end else if (decimated_clk == 11) begin
            display_dotclk <= 1;
        end
    end

    // test the multiplication
    logic [17:0] dsp_test_prod;
    logic mult_test;
    always_ff @(posedge int_osc) begin
        dsp_test_prod <= hpos_count * vpos_count;
        mult_test     <= ^dsp_test_prod; // Reduction XOR keeps all 18 bits alive
    end

    assign testing_flag = display_configured;

endmodule

