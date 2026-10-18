#ifndef __CONFIG_OS__
#define __CONFIG_OS__

#include "FreeRTOS.h"
#include "task.h"

void vApplicationStackOverflowHook( TaskHandle_t pxTask, char * pcTaskName );
void vApplicationMallocFailedHook( void );

#endif