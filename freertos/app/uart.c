#define UART_BASE    0x10000000u
#define UART_TX_DATA (*(volatile uint32_t *)(UART_BASE + 0x00)) // get reg_addr, get pointer on that addr, get value from pointer
#define UART_STATUS  (*(volatile uint32_t *)(UART_BASE + 0x04))
#define UART_RX_DATA (*(volatile uint32_t *)(UART_BASE + 0x08))



static void vPrint() {

};

int main(void) {
    xTaskCreate(vPrint, "A", 256, 1, NULL)
};