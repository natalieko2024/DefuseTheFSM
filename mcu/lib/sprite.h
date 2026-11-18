// sprite.h
// Natalie Ko
// nko@g.hmc.edu
// 17 Nov 2026
// Header for sprite functions

#ifndef sprite_H
#define sprite_H

#include <stdint.h>

void sendSprite(uint8_t x, uint8_t y, const uint8_t *pix, int n);
void sendMemAdr(uint8_t read, uint8_t mem, uint8_t type, uint8_t data);
void sendData(uint8_t x, uint8_t y, const uint8_t *pix, int n, uint8_t read, uint8_t mem, uint8_t type, uint8_t data);

#endif