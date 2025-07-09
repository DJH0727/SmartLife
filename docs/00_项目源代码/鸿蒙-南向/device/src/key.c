#include <stdio.h>
#include <unistd.h>
#include "ohos_init.h"
#include "cmsis_os2.h"

#include "wifiiot_adc.h"
#include "wifiiot_errno.h"
#include "key.h"

#define ADC_KEY_CHANNEL WIFI_IOT_ADC_CHANNEL_2
#define DELAY_MS(ms) osDelay((ms) / 10)


KeyId ReadKey(void)
{
    unsigned short data = 0;
    if (AdcRead(ADC_KEY_CHANNEL, &data, WIFI_IOT_ADC_EQU_MODEL_4, WIFI_IOT_ADC_CUR_BAIS_DEFAULT, 0) != WIFI_IOT_SUCCESS) {
        return NO_KEY;
    }

    //KEY(S3,USSR), KEY(S1 in OLED), KEY(S2 in OLED)
    // KEY3: ~128，KEY1: ~332，KEY2: ~560
    if (data > 100 && data < 150) return KEY_3;
    if (data > 300 && data < 360) return KEY_1;
    if (data > 530 && data < 590) return KEY_2;
    
    return NO_KEY;
}

// 阻塞等待按键输入，带超时（单位：ms）
KeyId WaitKeyPress(uint32_t timeout_ms)
{
    const uint32_t interval_ms = 50;
    uint32_t waited = 0;

    while (waited < timeout_ms) {
        KeyId key = ReadKey();
        if (key != NO_KEY) {
            return key;
        }
        DELAY_MS(interval_ms);
        waited += interval_ms;
    }
    return NO_KEY;
}

