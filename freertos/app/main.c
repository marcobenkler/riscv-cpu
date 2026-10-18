#include "FreeRTOS.h"
#include "task.h"
#include "config.h"
#include <stdint.h>

volatile uint32_t test1;
volatile uint32_t test2;

int main( void )
{
    test1 = 0xDEADBEEF;
    test2 = 0x12345678;
    test2 = 0xAAAAAAAA;

    for( ; ;){}
}