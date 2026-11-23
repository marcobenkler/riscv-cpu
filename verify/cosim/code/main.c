#include <stdint.h>

#define UART_BASE    0x10000000u
#define UART_TX_DATA (*(volatile uint32_t *)(UART_BASE + 0x00)) // get reg_addr, get pointer on that addr, get value from pointer
#define UART_STATUS  (*(volatile uint32_t *)(UART_BASE + 0x04))
#define UART_RX_DATA (*(volatile uint32_t *)(UART_BASE + 0x08))
#define UART_TX_READY (1u << 0)
#define UART_RX_READY (1u << 1)

/*
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
    */

static char pull_char(){
    while (!(UART_STATUS & UART_RX_READY));
    return UART_RX_DATA;
}

static void store_input(char* buf) {
    int i = 0;
    char c;

    while ((c = pull_char()) != '\r') {
        buf[i++] = c;
    }
    buf[i] = '\0';
}

static void put_char(uint8_t c) {
    while(!(UART_STATUS & UART_TX_READY));
    UART_TX_DATA = c;
}

void print_string(const char* buf) {
    while (*buf) put_char((uint8_t)*buf++);
}

static void wait(volatile uint32_t n) {
    while (n--);
}

int main(void){
    char buf[64]; // store max of 64 chars
    while(1) {
        print_string("> ");
        store_input(buf);
        print_string("You wrote: ");
        print_string(buf);
        print_string("\r\n");
        wait(10000);
    }
}