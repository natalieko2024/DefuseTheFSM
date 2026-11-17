// main.h
// Natalie Ko
// nko@g.hmc.edu
// 15 Nov 2026
// Main header: general defines and selected portions of CMSIS files

#ifndef MAIN_H
#define MAIN_H

#include "STM32L432KC.h"

// SPI pins
#define MOSI_PIN PB5
#define MISO_PIN PB4
#define SCK_PIN PB3
#define CE_PIN PB0
#define REGDATA_PIN     PA8//todo

// reset display pin
# define LCD_RST        PA11//todo

#define BUFF_LEN 32

#endif // MAIN_H