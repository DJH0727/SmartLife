#ifndef KEY__H
#define KEY__H

#include <stdint.h>

typedef enum {
    NO_KEY = 0,
    KEY_1,
    KEY_2,
    KEY_3
} KeyId;


KeyId WaitKeyPress(uint32_t timeout_ms);

#endif