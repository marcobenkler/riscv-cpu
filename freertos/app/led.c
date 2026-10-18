#include "FreeRTOS.h"
#include "task.h"
#include "led.h"

static void vBlinkTask( void * pvParameters )
{
    ( void ) pvParameters;

    for( ; ;)
    {
        LED_TOGGLE();
        vTaskDelay( pdMS_TO_TICKS( 500 ));
    }
}