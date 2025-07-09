#include <stdio.h>
#include <unistd.h>

#include "ohos_init.h"
#include "cmsis_os2.h"
#include "wifiiot_gpio.h"
#include "wifiiot_gpio_ex.h"
#include "wifiiot_errno.h"
#include "wifiiot_i2c.h" 

#include "aht20.h"
#include "mq_2.h"
#include "mqtt1.h"
#include "oled.h"
#include "ems.h"


static void ems_task_run(void *arg){
    (void)arg;

    uint32_t retval = 0;
    int gas = 0;              // 用于保存可燃气体浓度的变量
    float humidity = 0.0f;    // 用于保存湿度的变量
    float temperature = 0.0f; // 用于保存温度的变量

        // 发送初始化校准命令
    while (WIFI_IOT_SUCCESS != AHT20_Calibrate())
    {
        printf("AHT20 sensor init failed!\r\n");
        usleep(1000);
    }
    while (1)
    {
        // 发送 触发测量 命令，开始测量
        retval = AHT20_StartMeasure();
        if (retval != WIFI_IOT_SUCCESS)
        {
            printf("trigger measure failed!\r\n");
        }
        else
        {
            // 接收测量结果，拼接转换为标准值
            retval = AHT20_GetMeasureResult(&temperature, &humidity);
        }
        sleep(1);
        if(ADC_GetGasData(&gas) == 0){
           gas = gas;
        }
        sleep(1);
        
        
        char json_payload[128];
        int stat = 0; // 0: 正常, 1: 警告, 2: 危险

        // 根据简单的阈值规则判断状态
        if (gas > 800 || temperature > 60 || humidity > 90) {
            stat = 2; // 危险
        } else if (gas > 500 || temperature > 50 || humidity > 80) {
            stat = 1; // 警告
        } else {
            stat = 0; // 正常
        }
        snprintf(json_payload, sizeof(json_payload),
            "{\"stat\":%d,\"gas\":%d,\"temp\":%.1f,\"hum\":%.1f}", stat, gas, temperature, humidity);
        // 发送MQTT消息
        mqtt1_publish("ems", json_payload, 1);

    }
}

static void start_ems_task(void)
{
    osThreadAttr_t attr;
    attr.name = "ems_task";
    attr.attr_bits = 0U;
    attr.cb_mem = NULL;
    attr.cb_size = 0U;
    attr.stack_mem = NULL;
    attr.stack_size = 4096;
    attr.priority = osPriorityNormal;
    if (osThreadNew(ems_task_run, NULL, &attr) == NULL)
    {
        printf("[EnvironmentDemo] Falied to create ems_task!\n");
    }
    printf("This is ems_task demo running\n");
}



void ems_task(void){
    start_ems_task();
}