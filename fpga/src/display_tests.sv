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


module display_tests(output logic display_dotclk, display_de,
                     output logic display_hsync, display_vsync,
                     output logic [15:0] display_rgb565);
    
    logic int_osc; // 48MHz Clock; not very stable, might need to be replaced
    HSOSC #(.CLKHF_DIV("0b00")) hf_osc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    // DISPLAY LINE EBR START
    logic [7:0] displine_odd [239:0];
    logic [7:0] displine_even [239:0];

    // for now these colors are constant and will not change
    initial begin
        for (int i = 0; i < 120; i++) begin : init_left
            displine_odd[i]  = 8'h11; // #141414
            displine_even[i] = 8'h27; // #F0F0F0
        end
        for (int i = 120; i < 240; i++) begin : init_right
            displine_odd[i]  = 8'h0d; // #FF55FF
            displine_even[i] = 8'h8e; // #66FF33
        end
    end

    logic [7:0] displine_odd_idx, displine_even_idx;
    logic [7:0] displine_odd_col, displine_even_col;

    always_ff @(posedge int_osc) begin
        displine_odd_col <= displine_odd[displine_odd_idx];
        displine_even_col <= displine_even[displine_even_idx];
    end
    // DISPLAY LINE EBR END


    logic [3:0] decimated_clk; // 3MHz DOTCLK
    counter #('d15) counter0(int_osc, 'b0, 'b1, decimated_clk);
    logic [8:0] hpos_count; // Horizontal data is from 30 hpos_count to 269 hpos_count (inclusive)
    counter #('d279) counter1(int_osc, 'b0, decimated_clk == 15, hpos_count);
    logic [8:0] vpos_count; // Vertical data is from 4 vpos_count to 323 vpos_count (inclusive)
    counter #('d327) counter2(int_osc, 'b0, hpos_count == 279 && (decimated_clk == 15), vpos_count);

    // DOTCLK for the display (data latched on rising edge)
    // display data is written at the falling edge of DOTCLK in IC diagram
    assign display_dotclk = decimated_clk >= 8;
    // DE for the display (active high)
    assign display_de = valid_data_region;
    // HSYNC and VSYNC for the display (active low)
    assign display_hsync = ~(hpos_count < 10);
    assign display_vsync = ~(vpos_count < 2);

    // a FSM that determines whether we are in the data region or not
    logic valid_data_region;
    always_ff @(posedge int_osc) begin
        if (hpos_count >= 30 && hpos_count < 270 && vpos_count >= 4 && vpos_count < 324) begin
            valid_data_region <= 1;
        end
        else valid_data_region <= 0;
    end

    logic [7:0] read_px;
    logic [15:0] decoded_color;
    palette_decoder color_decoder(int_osc, read_px, decoded_color);

    always_comb begin
        if (valid_data_region && vpos_count[0] == 'b0) begin // even line
            // odd vs even line needs special logic
            displine_odd_idx = hpos_count - 9'd30;
            displine_even_idx = hpos_count - 9'd30;
            read_px = displine_even_col;
            display_rgb565 = decoded_color;
        end else if (valid_data_region && vpos_count[0] == 'b1) begin // odd line
            displine_odd_idx = hpos_count - 9'd30;
            displine_even_idx = hpos_count - 9'd30;
            read_px = displine_odd_col;
            display_rgb565 = decoded_color;
        end else begin
            displine_odd_idx = 0;
            displine_even_idx = 0;
            read_px = 0;
            display_rgb565 = 16'b0; // all black on the porches
        end
    end

endmodule

// hsync, vsync, and such might benefit from being combinational

