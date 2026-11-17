// ILI9341V.c
// Natalie Ko
// nko@g.hmc.edu
// 10 Nov 2026
// Source code for display functions

#include "ILI9341V.h"
#include "STM32L432KC_SPI.h"
#include "STM32L432KC_TIM.h"
#include "STM32L432KC_GPIO.h"
#include "main.h"

void initDisplay(void) {
    // configure selector pin
    pinMode(REGDATA_PIN, GPIO_OUTPUT);
    // configure reset pin
    pinMode(LCD_RST, GPIO_OUTPUT);

    // reset display
    digitalWrite(LCD_RST, 0); // need to delay at least 10µs
    delay_millis(TIM16, 1);
    digitalWrite(LCD_RST, 1); // need to delay at least 120ms
    delay_millis(TIM16, 120);

    // Display off
    writeRegister(0x28);
    // stop sleep mode
    writeRegister(0x11); // need to delay 120ms
    delay_millis(TIM16, 120);
    
    // Newhaven Init Code
    writeRegister(0xCB); // Power Control A
    writeData(0x39);
    writeData(0x2C);
    writeData(0x00);
    writeData(0x34);
    writeData(0x02);
    writeRegister(0xCF); // Power Control B
    writeData(0x00);
    writeData(0x81);
    writeData(0x30);
    writeRegister(0xC0); // Power Control 1
    writeData(0x26);
    writeData(0x04);
    writeRegister(0xC1); // Power Control 2
    writeData(0x11);
    writeRegister(0xC5); // VCOM Control 1
    writeData(0x35);
    writeData(0x3E);
    writeRegister(0x36); // Memory Access Control (BGR)
    writeData(0x88);
    writeRegister(0xB1); // Frame Rate Control
    writeData(0x00);
    writeData(0x18);
    writeRegister(0x21); // Display inversion off -> **datasheet mismatch, if it looks wrong we try 0x20**
    writeRegister(0xC7); // VCOM Control 2
    writeData(0xBE);
    writeRegister(0xF2); // 3G Gamma Control (Off)
    writeData(0x02);
    writeRegister(0x26); // Gamma Curve 3
    writeData(0x01);
    writeRegister(0x2A); // Column Address Set
    writeData(0x00);
    writeData(0x00);
    writeData(0x00);
    writeData(0xEF);
    writeRegister(0x2B); // Page Address Set
    writeData(0x00);
    writeData(0x00);
    writeData(0x01);
    writeData(0x3F);
    
    // 8.3.1 in datasheet
    // write RGB interface signal control register address
    writeRegister(0xB0);
    // Bit 7: 0 for data straight to shift register, 1 for data to GRAM
    // Bit 6:5: 10 for DE, 11 for SYNC **we are using DE**
    // Bit 4: tied 0
    // Bit 3: VSYNC polarity, 0 for active low, 1 for active high
    // Bit 2: HSYNC polarity, 0 for active low, 1 for active high
    // Bit 1: data sampling, 0 for rising edge of DOTCLK, 1 for falling edge of DOTCLK
    // Bit 0: DE polarity (“0”= High enable for RGB interface, “1”= Low enable for RGB interface) honestly idk what this means
    writeData(0b01000000);

    // 8.3.28 in datasheet
    // write interface control register address
    writeRegister(0xF6);
    // 1st parameter default
    writeData(0b00000001);
    // 2nd parameter default
    writeData(0b00000000);
    // 3rd parameter
    // Bit 7:6: 00 default
    // Bit 5: 0 for MSB first, 1 for LSB first
    // Bit 4: 0 default
    // Bit 3:2: 01 for RGB interface mode
    // Bit 1: 0 for System interface/VSYNC interface accessing GRAM, 1 for RGB interface accessing GRAM
    // Bit 0: 0 for 18/16-bit RGB with 1 transfer per pixel
    writeData(0b00000110);

    // 8.2.33 in datasheet
    // pixel format register address
    writeRegister(0x3A);
    // Bit 7: 0 default
    // Bit 6:4: RBG interface format DPI, 101 for 16 bits/px, 110 for 18 bits/px
    // Bit 3: 0 default
    // Bit 2:0: MCU interface format DBI, 101 for 16 bits/px, 110 for 18 bits/px
    writeData(0b01010101);
    
    // 8.3.6 in datasheet -> register 0xB5 only matters for SYNC mode

    // 8.3.7 in datasheet
    // display function control register address
    writeRegister(0xB6);
    // 1st parameter - default
    writeData(0x0A);
    // 2nd parameter - default (display not controller datasheet)
    writeData(0xA2);
    // 3rd parameter - default
    writeData(0x27);
    // 4th parameter
    // Bit 7:6: 00 default
    // Bit 5:0 divide DOTCLK down to internal clock
    // internal clock freq = DOTCLK/(2*(PCDIV+1))
    writeData(0b00000010); // <- for 30Hz frame rate 3MHz DOTCLK
    
    // NOTE 18.3.5 gives DOTCLK, sync, DE timing limits

    // turn display on
    writeRegister(0x29);
}