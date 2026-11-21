module spi(input logic clk,
           input  logic sck, sdi, cs,
           output logic sdo,
           output  logic display_configured);

    // shift registers so that sdi_sync[1] lines upu with sck_sync[1]
    logic [2:0] sck_sync, cs_sync;
    logic [1:0] sdi_sync;

    always_ff @(posedge clk) begin
        sck_sync <= {sck_sync[1:0], sck};
        cs_sync <= {cs_sync[1:0], cs};
        sdi_sync <= {sdi_sync[0], sdi};
    end

    // control signals
    logic cs_active, frame_start, frame_end, sck_rise;
    assign cs_active = ~cs_sync[1];
    assign frame_start = (cs_sync[2:1] == 2'b10);
    assign frame_end = (cs_sync[2:1] == 2'b01);
    assign sck_rise = cs_active & (sck_sync[2:1] == 2'b01);
    
    logic [2:0] clk_count; // count SCK edges to determine which bit of the frame we're on
    logic [7:0] receive_shift; // shift register for receiving data
    logic [7:0] receive_data; // copy of received data packet
    logic receive_flag; // flag to indicate full packet received
    logic stall; // flag to indicate gap between CS falling and CS rising edge
    
    always_ff @(posedge clk) begin
        // packet receiving (check CS edges)
        if (frame_start) begin
            stall <= 1'b1;
            receive_flag <= 1'b0;
        end else if (frame_end && stall) begin
            stall <= 1'b0;
            if (receive_flag && receive_data == 8'b01000001) display_configured <= 1'b1; // display is configured
        end

        // bit receiving (check SCK edges)
        if (!cs_active) clk_count <= 3'b000;
        else if (sck_rise) begin
            receive_shift <= {receive_shift[6:0], sdi_sync[1]};
            clk_count <= clk_count + 3'b001;
            if (clk_count == 3'b111 && !receive_flag) begin //8th bit of byte and full next packet first byte
                receive_data <= {receive_shift[6:0], sdi_sync[1]}; // save full byte
                receive_flag <= 1'b1; // set flag to indicate full byte received
            end
        end
    end

    // send nothing back
    assign sdo = 1'b0;
endmodule