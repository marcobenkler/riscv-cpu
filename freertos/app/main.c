#include "FreeRTOS.h"
#include "task.h"
#include "config.h"
#include <stdint.h>

struct Car {
    char brand[30];
    int year;
};

struct Person {
    int age;
    char name[30];
};

int main( void )
{
    struct Car car = {"Toyota", 2020};

    
    int number = 5;
    if (car.year == 2019 || car.year < 2000) {
        number += 124;
    }
    number -= car.year;

    struct Person me = {42, "Tom"};

    if (me.age >= 40) {
        me.age += 4;
    }

    struct Person me1 = {42, "Tom"};

    if (me1.age >= 40) {
        me1.age += 4;
    }

    struct Person me2 = {42, "Tom"};

    if (me2.age >= 40) {
        me2.age += 4;
    }

    struct Person me3 = {42, "Tom"};

    if (me3.age >= 40) {
        me3.age += 4;
    }
}