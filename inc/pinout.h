#pragma once
#include "stm32f0xx_hal_gpio.h"

#define BUTTON0_PIN GPIO_PIN_8                                     /* PA8 */
#define BUTTON1_PIN GPIO_PIN_9                                     /* PA9 */
#define BUTTON2_PIN GPIO_PIN_10                                    /* PA10 */
#define BUTTON_GPIO_PORT GPIOA
#define BUTTON_GPIO_MODE GPIO_MODE_IT_RISING_FALLING
#define BUTTON_GPIO_PULL GPIO_PULLDOWN
