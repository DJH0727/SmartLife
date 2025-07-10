#include <stdio.h>
#include <unistd.h>

#include "ohos_init.h"
#include "cmsis_os2.h"


#include "mqtt.h"
#include "oled.h"
#include "beep.h"
#include "key.h"

#include "ac.h"

#define DELAY_MS(ms) osDelay((ms) / 10)
#define DELAY_S(s)   osDelay((s) * 100)


#define DEVICE_ID "dev101"
#define DEVICE_TYPE "air_conditioner"
#define DEVICE_NAME "Gree Air Conditioner"


#define UNBOUND_REQUEST_TOPIC "/devices/unbound/request"
#define UNBOUND_RESPONSE_TOPIC "/devices/unbound/response"
#define UNBOUND_RESPONSE_PAYLOAD "{\"id\":\"dev101\",\"type\":\"air_conditioner\",\"name\":\"Gree Air Conditioner\",\"isBind\":0}"
#define UNBOUND_RESPONSE_PAYLOAD_HUM "{\"id\":\"dev103\",\"type\":\"humidifier\",\"name\":\"Gree Humidifier\",\"isBind\":0}"
#define UNBOUND_RESPONSE_PAYLOAD_LIGHT "{\"id\":\"dev104\",\"type\":\"light\",\"name\":\"Smart Light\",\"isBind\":0}"

#define BOUND_REQUEST_TOPIC "/devices/dev101/bound/request"
#define BOUND_RESPONSE_TOPIC "/devices/dev101/bound/response"
#define BOUND_RESPONSE_PAYLOAD "{\"result\":0,\"message\":\"success\"}"
#define BOUND_RESPONSE_PAYLOAD_CANCEL "{\"result\":1,\"message\":\"failed\"}"

#define DEVICE_HEARTBEAT_TOPIC "/devices/dev101/heartbeat"
#define DEVICE_HEARTBEAT_PAYLOAD "pong"

#define DEVICE_SET_TOPIC "/devices/dev101/set"


int isBind = 0;

int is_mqtt_connected = 0;
int UNBOUND_STATE = 0;
int BOUND_STATE = 0;
int SET_STATE = 0;

static char *requester = "HarmonyOS App";


// MQTT 消息回调
void unbound_request_message(MessageData* msg_data) {
    MQTTMessage* message = msg_data->message;

    printf("[AC][Receive] [%.*s]: %.*s\n",
        msg_data->topicName->lenstring.len,
        msg_data->topicName->lenstring.data,
        message->payloadlen,
        (char*)message->payload);
    if(isBind == 1){return;}
    UNBOUND_STATE = 1;
}
void bound_request_message(MessageData* msg_data) {
    MQTTMessage* message = msg_data->message;

    printf("[AC][Receive] [%.*s]: %.*s\n",
        msg_data->topicName->lenstring.len,
        msg_data->topicName->lenstring.data,
        message->payloadlen,
        (char*)message->payload);
    if(isBind == 1){return;}
    BOUND_STATE = 1;
}
void set_request_message(MessageData* msg_data) {
    MQTTMessage* message = msg_data->message;
    printf("[AC][Receive] [%.*s]: %.*s\n",
        msg_data->topicName->lenstring.len,
        msg_data->topicName->lenstring.data,
        message->payloadlen,
        (char*)message->payload);
    if(isBind == 0){return;}
    SET_STATE = 1;
}


//初始化
static void mqtt_init_task_run(void *arg)
{
    (void)arg;
    int rc = mqtt_connect();
    if(rc == 0){is_mqtt_connected = 1;}
    sleep(1);
    mqtt_subscribe(UNBOUND_REQUEST_TOPIC, 0, unbound_request_message);
    mqtt_subscribe(BOUND_REQUEST_TOPIC, 0, bound_request_message);
    mqtt_subscribe(DEVICE_SET_TOPIC, 0, set_request_message);
}
static void start_mqtt_init_task(void){
    osThreadAttr_t attr;
    attr.name = "mqtt_init_task";
    attr.attr_bits = 0U;
    attr.cb_mem = NULL;
    attr.cb_size = 0U;
    attr.stack_mem = NULL;
    attr.stack_size = 4096;
    attr.priority = osPriorityNormal;
    if (osThreadNew(mqtt_init_task_run, NULL, &attr) == NULL)
    {
        printf("[EnvironmentDemo] Falied to create mqtt_init_task!\n");
    }
    printf("This is mqtt_init_task demo running\n");
}


static void mqtt_response_task_run(void *arg)
{
    (void)arg;
    while(1){
        if(is_mqtt_connected == 0){
            DELAY_MS(100);
            continue;
        }
        if(UNBOUND_STATE){
            mqtt_publish(UNBOUND_RESPONSE_TOPIC, UNBOUND_RESPONSE_PAYLOAD, 0);
            sleep(1);
            mqtt_publish(UNBOUND_RESPONSE_TOPIC, UNBOUND_RESPONSE_PAYLOAD_LIGHT, 0);
            sleep(1);
            mqtt_publish(UNBOUND_RESPONSE_TOPIC, UNBOUND_RESPONSE_PAYLOAD_HUM, 0);
            UNBOUND_STATE=0;
        }
        if(BOUND_STATE){
            Beep_Operation_Complete(1);// 提示音
            oled_display_clear();
            oled_display_show_text_align("Device bound", 0, OLED_ALIGN_LEFT);
            oled_display_show_text_align("Requst From:", 1, OLED_ALIGN_LEFT);
            oled_display_show_text_align(requester, 2, OLED_ALIGN_LEFT);
            oled_display_show_text_align("Please confirm", 6, OLED_ALIGN_LEFT);
            oled_display_show_text_align("Confirm   Cancel", 7, OLED_ALIGN_LEFT);
            KeyId key = WaitKeyPress(8000); // 等待用户操作
            if (key!=KEY_1)//S1确认
            {
                mqtt_publish(BOUND_RESPONSE_TOPIC, BOUND_RESPONSE_PAYLOAD_CANCEL, 0);
                BOUND_STATE=0;
                oled_display_clear();
                continue;
            }
            mqtt_publish(BOUND_RESPONSE_TOPIC, BOUND_RESPONSE_PAYLOAD, 0);
            BOUND_STATE=0;
            oled_display_clear();
            isBind = 1;
        }
        if(SET_STATE){
            Beep_Operation_Complete(2);
            SET_STATE=0;
        }

        osDelay(100);
    }
}
static void start_mqtt_response_task(void){
    osThreadAttr_t attr;
    attr.name = "mqtt_response_task";
    attr.attr_bits = 0U;
    attr.cb_mem = NULL;
    attr.cb_size = 0U;
    attr.stack_mem = NULL;
    attr.stack_size = 4096;
    attr.priority = osPriorityNormal;
    if (osThreadNew(mqtt_response_task_run, NULL, &attr) == NULL)
    {
        printf("[EnvironmentDemo] Falied to create mqtt_response_task!\n");
    }
    printf("This is mqtt_response_task demo running\n");
}

static void device_heartbeat_task_run(void *arg)
{
    (void)arg;
    while (1) {
        if(is_mqtt_connected == 0){
            DELAY_MS(100);
            continue;
        }
        mqtt_publish(DEVICE_HEARTBEAT_TOPIC, DEVICE_HEARTBEAT_PAYLOAD, 0);
        DELAY_S(10); // 10s 发送一次心跳
    }
}

static void start_device_heartbeat_task(void)
{
    osThreadAttr_t attr;
    attr.name = "device_heartbeat_task";
    attr.attr_bits = 0U;
    attr.cb_mem = NULL;
    attr.cb_size = 0U;
    attr.stack_mem = NULL;
    attr.stack_size = 2048; // 心跳线程逻辑轻量，2048 足够
    attr.priority = osPriorityBelowNormal; // 心跳优先级可以低一点
    if (osThreadNew(device_heartbeat_task_run, NULL, &attr) == NULL)
    {
        printf("[EnvironmentDemo] Failed to create device_heartbeat_task!\n");
    }
    printf("device_heartbeat_task started\n");
}



void ac_task(void)
{
    start_mqtt_init_task();
    start_mqtt_response_task();
    start_device_heartbeat_task();
}

