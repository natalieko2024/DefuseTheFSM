// ILI9341V.c
// Natalie Ko
// nko@g.hmc.edu
// 10 Nov 2026
// Source code for display functions

#include "ILI9341V.h"
#include "STM32L432KC_SPI.h"
#include "STM32L432KC_GPIO.h"
#include "main.h"

void initDisplay(void) {
    // 8.3.1 in datasheet
    // write RGB interface signal control register address
    spiSendReceive(0xB0);
    // Bit 7: 0 for data straight to shift register, 1 for data to GRAM
    // Bit 6:5: 10 for DE, 11 for SYNC
    // Bit 4: tied 0
    // Bit 3: VSYNC polarity, 0 for active low, 1 for active high
    // Bit 2: HSYNC polarity, 0 for active low, 1 for active high
    // Bit 1: data sampling, 0 for rising edge of DOTCLK, 1 for falling edge of DOTCLK
    // Bit 0: DE polarity (“0”= High enable for RGB interface, “1”= Low enable for RGB interface) honestly idk what this means
    spiSendReceive(0b0110000);

    // 8.3.28 in datasheet
    // write interface control register address
    spiSendReceive(0xF6);
    // 1st parameter default
    spiSendReceive(0b00000001);
    // 2nd parameter default
    spiSendReceive(0b00000000);
    // 3rd parameter
    // Bit 7:6: 00 default
    // Bit 5: 0 for MSB first, 1 for LSB first
    // Bit 4: 0 default
    // Bit 3:2: 01 for RGB interface mode
    // Bit 1: 0 for System interface/VSYNC interface accessing GRAM, 1 for RGB interface accessing GRAM
    // Bit 0: 0 for 18/16-bit RGB with 1 transfer per pixel
    spiSendReceive(0b00000110);

    // 8.3.33 in datasheet
    spiSendReceive(0x3A);

}