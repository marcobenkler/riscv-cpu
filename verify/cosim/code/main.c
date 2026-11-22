#include <stdint.h>

#define UART_BASE    0x10000000u
#define UART_TX_DATA (*(volatile uint32_t *)(UART_BASE + 0x00)) // get reg_addr, get pointer on that addr, get value from pointer
#define UART_STATUS  (*(volatile uint32_t *)(UART_BASE + 0x04))
#define UART_RX_DATA (*(volatile uint32_t *)(UART_BASE + 0x08))
#define UART_TX_READY (1u << 0)
#define UART_RX_READY (1u << 1)

void uart_write(uint8_t letter){
    while (!(UART_STATUS & UART_TX_READY));
    UART_TX_DATA = letter;
}

int main(void) {
    uint8_t test = 'A';
    for (;;) {
        uart_write(test);
    }
}