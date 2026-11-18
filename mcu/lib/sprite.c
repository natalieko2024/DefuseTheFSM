// sprite.c
// Natalie Ko
// nko@g.hmc.edu
// 17 Nov 2026
// Source code for sprite functions

#include "STM32L432KC_SPI.h"
#include "main.h"
#include "sprite.h"

// x, y is position data
// pix is pixel data
// n is pixel data size
void sendSprite(uint8_t x, uint8_t y, const uint8_t *pix, int n) {
    spiSendReceive(x);
    spiSendReceive(y);
    for (int i = 0; i < n; i++) spiSendReceive(pix[i]);
}

void sendMemAdr(uint8_t read, uint8_t mem, uint8_t type, uint8_t data) {
    uint8_t packet = ((read & 0x01) << 7) | ((mem  & 0x01) << 6) | ((type & 0x01) << 5) | (data  & 0x1F);
    spiSendReceive(packet);
}

void sendData(uint8_t x, uint8_t y, const uint8_t *pix, int n, uint8_t read, uint8_t mem, uint8_t type, uint8_t data) {
    digitalWrite(FPGA_CE_PIN, 0);                 // start 
    sendMemAdr(read, mem, type, data);
    sendSprite(x, y, pix, n);
    digitalWrite(FPGA_CE_PIN, 1);                 // end 
}