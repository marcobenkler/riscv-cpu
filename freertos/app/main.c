#include "FreeRTOS.h"
#include "task.h"
#include "config.h"
#include <stdint.h>

struct Car {
    char brand[30];
    int year;
};

void vTask1( void *pvParameters)
{
    struct Car car = {"Audi", 500};
    (void)pvParameters;
    for (;;){
        for (int i = 0; i < 20; i++) {
            car.year += 20;
        }
        taskYIELD();
    }
}

int main( void )
{
    TaskHandle_t hTask1;

    xTaskCreate(vTask1, "Start", 128, NULL, 2, &hTask1);
    vTaskPrioritySet(hTask1, 3);
    vTaskStartScheduler();
    for (;;);
}