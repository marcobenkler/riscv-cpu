/*
 * FreeRTOS Kernel <DEVELOPMENT BRANCH>
 * Copyright (C) 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * SPDX-License-Identifier: MIT
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

/*******************************************************************************
 * This file provides an example FreeRTOSConfig.h header file, inclusive of an
 * abbreviated explanation of each configuration item.  Online and reference
 * documentation provides more information.
 * https://www.freertos.org/a00110.html
 *
 * Constant values enclosed in square brackets ('[' and ']') must be completed
 * before this file will build.
 *
 * Use the FreeRTOSConfig.h supplied with the RTOS port in use rather than this
 * generic file, if one is available.
 ******************************************************************************/

#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

/******************************************************************************/
/* RISCV Uniques **************************************************************/
/******************************************************************************/

#define configMTIME_BASE_ADDRESS        ( 0x0200BFF8UL )
#define configMTIMECMP_BASE_ADDRESS     ( 0x02004000UL )

/******************************************************************************/
/* Hardware description related definitions. **********************************/
/******************************************************************************/

/* In most cases, configCPU_CLOCK_HZ must be set to the frequency of the clock
 * that drives the peripheral used to generate the kernels periodic tick
 * interrupt. The default value is set to 20MHz and matches the QEMU demo
 * settings.  Your application will certainly need a different value so set this
 * correctly. This is very often, but not always, equal to the main system clock
 * frequency. */


/* CHANGE WHEN ADJUSTING CLOCKLSPEED*/
#define configCPU_CLOCK_HZ    ( ( unsigned long ) 80000000 )

/* configSYSTICK_CLOCK_HZ is an optional parameter for ARM Cortex-M ports only.
 *
 * By default ARM Cortex-M ports generate the RTOS tick interrupt from the
 * Cortex-M SysTick timer. Most Cortex-M MCUs run the SysTick timer at the same
 * frequency as the MCU itself - when that is the case configSYSTICK_CLOCK_HZ is
 * not needed and should be left undefined. If the SysTick timer is clocked at a
 * different frequency to the MCU core then set configCPU_CLOCK_HZ to the MCU
 * clock frequency, as normal, and configSYSTICK_CLOCK_HZ to the SysTick clock
 * frequency.  Not used if left undefined.
 * The default value is undefined (commented out).  If you need this value bring
 * it back and set it to a suitable value. */

/*
 #define configSYSTICK_CLOCK_HZ                  [Platform specific]
 */

/******************************************************************************/
/* Scheduling behaviour related definitions. **********************************/
/******************************************************************************/

/*Increases CMP each interrupt by 80k: interrupt each ~1ms*/
#define configTICK_RATE_HZ                         1000

//Task with higher priority wins
#define configUSE_PREEMPTION                       1

//Tasks with same priority get 1ms each
#define configUSE_TIME_SLICING                     0

//Sets how the next task is found, but needs special hw => disable
#define configUSE_PORT_OPTIMISED_TASK_SELECTION    0

//Disable clock in idle, not implemented => disable
#define configUSE_TICKLESS_IDLE                    0

//Number of priority stages
#define configMAX_PRIORITIES                       5

//Define minimal stack size in words
#define configMINIMAL_STACK_SIZE                   256

//Max length for a task
#define configMAX_TASK_NAME_LEN                    16

//Width of the tick counter: with cur settings overflow in ~49d
#define configTICK_TYPE_WIDTH_IN_BITS              TICK_TYPE_WIDTH_32_BITS

//If task with prio 0 exists, the idle task switches before tick ends
#define configIDLE_SHOULD_YIELD                    1

//Count how many notifications a task can get
#define configTASK_NOTIFICATION_ARRAY_ENTRIES      1

//Useless without debugger
#define configQUEUE_REGISTRY_SIZE                  0

//Creates old api names, useless for a new project
#define configENABLE_BACKWARD_COMPATIBILITY        0

//Count of pointers for ie own bibs => non required here
#define configNUM_THREAD_LOCAL_STORAGE_POINTERS    0

//Decreases list size and safes mem
#define configUSE_MINI_LIST_ITEM                   1

//Datatype for stack and message sizes
#define configSTACK_DEPTH_TYPE                     size_t
#define configMESSAGE_BUFFER_LENGTH_TYPE           size_t

//Overrides freed memory with '0', got for security and debugging, bad for perormance
#define configHEAP_CLEAR_MEMORY_ON_FREE            1

//???
#define configSTATS_BUFFER_MAX_LENGTH              0xFFFF

//gives each task it's own newlib structure => slow
#define configUSE_NEWLIB_REENTRANT                 0

/******************************************************************************/
/* Software timer related definitions. ****************************************/
/******************************************************************************/

//Enable software time, but requires timer.c file
#define configUSE_TIMERS                0

//Set priority of timer task
#define configTIMER_TASK_PRIORITY       ( configMAX_PRIORITIES - 1 )

//Used if USE_TIMERS = 1, size of timer storage
#define configTIMER_TASK_STACK_DEPTH    configMINIMAL_STACK_SIZE

//How many timer commands can get queued
#define configTIMER_QUEUE_LENGTH        10

/******************************************************************************/
/* Event Group related definitions. *******************************************/
/******************************************************************************/

//Enable envent groups, but requires event_group.c file
#define configUSE_EVENT_GROUPS    0

/******************************************************************************/
/* Stream Buffer related definitions. *****************************************/
/******************************************************************************/

//Enable stream_bufffer, but requires steam_buffer.c file
#define configUSE_STREAM_BUFFERS    0

/******************************************************************************/
/* Memory allocation related definitions. *************************************/
/******************************************************************************/

//Enable manual allocation with malloc
#define configSUPPORT_STATIC_ALLOCATION              1

//Enable manual creation of tasks with xTaskCreate()
#define configSUPPORT_DYNAMIC_ALLOCATION             1

//Set total heap size
#define configTOTAL_HEAP_SIZE                        4096

//1: application allocates heap, 0: linker allocates heap
#define configAPPLICATION_ALLOCATED_HEAP             0

//Split heap in sram and bram => We use only bram
#define configSTACK_ALLOCATION_FROM_SEPARATE_HEAP    0

//Obfuscate heap for mem protection, requires heap4 or 5 (we use 1)
#define configENABLE_HEAP_PROTECTOR                  0

/******************************************************************************/
/* Interrupt nesting behaviour configuration. *********************************/
/******************************************************************************/

//Cortex-M config, not relevant for us
#define configKERNEL_INTERRUPT_PRIORITY          0
#define configMAX_SYSCALL_INTERRUPT_PRIORITY     0
#define configMAX_API_CALL_INTERRUPT_PRIORITY    0

/******************************************************************************/
/* Hook and callback function related definitions. ****************************/
/******************************************************************************/

//Enable functions in idle for i.e wfi to sleep the cpu
#define configUSE_IDLE_HOOK                   0

//Enable functions that don't require a full task
#define configUSE_TICK_HOOK                   0

//Return error, when heap overflows for debugging
//Requires vApplicationMallocFailedHook()
#define configUSE_MALLOC_FAILED_HOOK          1

//Code that runs at the start of a timer task
#define configUSE_DAEMON_TASK_STARTUP_HOOK    0

//Enable own callbacks per stream buffer
#define configUSE_SB_COMPLETED_CALLBACK       0

//Write a pattern at the end of each stack and check at context change if it's still intact
//Usefull for debugging, requires vApplicationStackOverflowHook()
#define configCHECK_FOR_STACK_OVERFLOW        2

/******************************************************************************/
/* Run time and task stats gathering related definitions. *********************/
/******************************************************************************/

//Capture how long each task takes !!!COULD BE INTERESTING!!!
#define configGENERATE_RUN_TIME_STATS           0

//Generate info for trace tools
#define configUSE_TRACE_FACILITY                0
#define configUSE_STATS_FORMATTING_FUNCTIONS    0

/******************************************************************************/
/* Co-routine related definitions. ********************************************/
/******************************************************************************/

//Legacy don't use
#define configUSE_CO_ROUTINES              0
#define configMAX_CO_ROUTINE_PRIORITIES    1

/******************************************************************************/
/* Debugging assistance. ******************************************************/
/******************************************************************************/

//Checks in kernel for things linke pointer != null, if error jumps in loop => good for debugging
/* *INDENT-OFF* */
#define configASSERT( x )         \
    if( ( x ) == 0 )              \
    {                             \
        taskDISABLE_INTERRUPTS(); \
        for( ; ; )                \
        ;                         \
    }
/* *INDENT-ON* */

//Kernel allocates memory itself
#define configKERNEL_PROVIDED_STATIC_MEMORY    1

/* Set configENABLE_FPU to 1 to enable the Floating Point Unit (FPU), or 0
 * to leave the Floating Point Unit disabled. */
#define configENABLE_FPU                  0

/******************************************************************************/
/* Definitions that include or exclude functionality. *************************/
/******************************************************************************/

/* Set the following configUSE_* constants to 1 to include the named feature in
 * the build, or 0 to exclude the named feature from the build. */
#define configUSE_TASK_NOTIFICATIONS           1
#define configUSE_MUTEXES                      1
#define configUSE_RECURSIVE_MUTEXES            1
#define configUSE_COUNTING_SEMAPHORES          1
#define configUSE_QUEUE_SETS                   0
#define configUSE_APPLICATION_TASK_TAG         0

/* USE_POSIX_ERRNO enables the task global FreeRTOS_errno variable which will
 * contain the most recent error for that task. */
#define configUSE_POSIX_ERRNO                  0

/* Set the following INCLUDE_* constants to 1 to include the named API function,
 * or 0 to exclude the named API function.  Most linkers will remove unused
 * functions even when the constant is 1. */
#define INCLUDE_vTaskPrioritySet               1
#define INCLUDE_uxTaskPriorityGet              1
#define INCLUDE_vTaskDelete                    1
#define INCLUDE_vTaskSuspend                   1
#define INCLUDE_xTaskDelayUntil                1
#define INCLUDE_vTaskDelay                     1
#define INCLUDE_xTaskGetSchedulerState         1
#define INCLUDE_xTaskGetCurrentTaskHandle      1
#define INCLUDE_uxTaskGetStackHighWaterMark    0
#define INCLUDE_xTaskGetIdleTaskHandle         0
#define INCLUDE_eTaskGetState                  0
#define INCLUDE_xTimerPendFunctionCall         0
#define INCLUDE_xTaskAbortDelay                0
#define INCLUDE_xTaskGetHandle                 0
#define INCLUDE_xTaskResumeFromISR             1

#endif /* FREERTOS_CONFIG_H */
