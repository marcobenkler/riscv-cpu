#include "FreeRTOS.h"
#include "task.h"
#include "config.h"

void vApplicationMallocFailedHook( void )
{
    taskDISABLE_INTERRUPTS();

    for( ; ; ){}
}

void vApplicationStackOverflowHook( TaskHandle_t pxTask, char * pcTaskName )
{
    volatile char * pcOverflowTask = pcTaskName;
    ( void ) pcOverflowTask;
    ( void ) pxTask;

    taskDISABLE_INTERRUPTS();

    for( ; ; ){}
}