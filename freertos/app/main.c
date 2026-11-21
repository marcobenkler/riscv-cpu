#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

#define N_ITEMS 10

volatile uint64_t tohost __attribute__((aligned(8)));  /* Spike/HTIF-Exit */

static QueueHandle_t     xQueue;
static SemaphoreHandle_t xMutex;
static volatile uint32_t shared = 0;

static void vProducer(void *pv)
{
    uint32_t base = (uint32_t)pv;

    for (uint32_t i = 0; i < N_ITEMS; i++) {
        xSemaphoreTake(xMutex, portMAX_DELAY);
        uint32_t tmp = shared;
        taskYIELD();
        shared = tmp + 1;
        xSemaphoreGive(xMutex);

        uint32_t v = base + i;
        xQueueSend(xQueue, &v, portMAX_DELAY);
    }
    vTaskSuspend(NULL);
}

static void vConsumer(void *pv)
{
    (void)pv;
    uint32_t v, sum = 0;

    for (uint32_t i = 0; i < 2 * N_ITEMS; i++) {
        xQueueReceive(xQueue, &v, portMAX_DELAY);
        sum += v;
    }

    int ok = (sum == 3090) && (shared == 2 * N_ITEMS);
    tohost = ok ? 1 : 3;
    for (;;);
}

int main(void)
{
    xQueue = xQueueCreate(4, sizeof(uint32_t));
    xMutex = xSemaphoreCreateMutex();

    xTaskCreate(vConsumer, "C",  256, NULL,        2, NULL);
    xTaskCreate(vProducer, "P1", 256, (void *)100, 1, NULL);
    xTaskCreate(vProducer, "P2", 256, (void *)200, 1, NULL);

    vTaskStartScheduler();
    for (;;);
}