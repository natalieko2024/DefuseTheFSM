// main.c
// Natalie Ko
// nko@g.hmc.edu
// 15 Nov 2026

#include "STM32L432KC.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "main.h"
#include "ILI9341V.h"

int main(void) {

    configureFlash();
    configureClock();

    gpioEnable(GPIO_PORT_A);
    gpioEnable(GPIO_PORT_B);
    gpioEnable(GPIO_PORT_C);

    RCC->APB2ENR |= (RCC_APB2ENR_TIM16EN);
    initTIM(TIM16);

    RCC->APB2ENR |= (RCC_APB2ENR_SPI1EN);
    // we have 80MHz clock. br set by f_clk/value
    // ILI9341V needs at least 100 ns per clock when writing, so 10 MHz maximum. Read needs 150 ns, so ~6.6 MHz maximum (Section 18.3)
    // br = 0b011 gives 5 MHz -> choosing this bc within both
    initSPI(0b011, 0, 0);

    initDisplay();

    while(1) {
        
    }

}