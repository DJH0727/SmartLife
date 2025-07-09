#include <stdio.h>
#include <unistd.h>

#include "ohos_init.h"
#include "cmsis_os2.h"


#include "mqtt1.h"
#include "beep.h"
#include "speaker.h"

#define DELAY_MS(ms) osDelay((ms) / 10)
#define DELAY_S(s)   osDelay((s) * 100)

#define DEVICE_ID "dev102"
#define DEVICE_TYPE "speaker"
#define DEVICE_NAME "Edifier R201T Speaker"


#define DEVICE_HEARTBEAT_TOPIC "/devices/dev102/heartbeat"
#define DEVICE_HEARTBEAT_PAYLOAD "pong"
#define DEVICE_SET_TOPIC "/devices/dev102/set"

int is_mqtt1_connected = 0;
int set_status = 0;


void set_receive_callback(MessageData* msg_data) {
    MQTTMessage* message = msg_data->message;
    printf("[SP][Receive] [%.*s]: %.*s\n",
        msg_data->topicName->lenstring.len,
        msg_data->topicName->lenstring.data,
        message->payloadlen,
        (char*)message->payload);
    set_status = 1;
}
static void mqtt1_init_task_run(void *arg)
{
    (void)arg;
    int rc = mqtt1_connect();
    if(rc == 0){is_mqtt1_connected = 1;}
    sleep(1);
    mqtt1_subscribe(DEVICE_SET_TOPIC, 0, set_receive_callback);
}
static void start_mqtt1_init_task(void)
{
    osThreadAttr_t attr;
    attr.name = "mqtt1_init_task";
    attr.attr_bits = 0U;
    attr.cb_mem = NULL;
    attr.cb_size = 0U;
    attr.stack_mem = NULL;
    attr.stack_size = 4096; 
    attr.priority = osPriorityBelowNormal; 
    if (osThreadNew(mqtt1_init_task_run, NULL, &attr) == NULL)
    {
        printf("[EnvironmentDemo] Failed to create mqtt1_init_task!\n");
    }
    printf("mqtt1_init_task started\n");
}

static void mqtt1_response_task_run(void *arg)
{
    (void)arg;
    while(1){
        if(is_mqtt1_connected == 0){
            DELAY_MS(100);
            continue;
        }
        
        if(set_status){
            Beep_Operation_Complete(1);
            sleep(1);
            set_status=0;
            if(Playing == 0){
                Playing = 1;
            }
            else{
                StopPlaying=1;
            }
        }

        osDelay(100);
    }
}
static void start_mqtt1_response_task(void){
    osThreadAttr_t attr;
    attr.name = "mqtt1_response_task";
    attr.attr_bits = 0U;
    attr.cb_mem = NULL;
    attr.cb_size = 0U;
    attr.stack_mem = NULL;
    attr.stack_size = 2048;
    attr.priority = osPriorityNormal;
    if (osThreadNew(mqtt1_response_task_run, NULL, &attr) == NULL)
    {
        printf("[EnvironmentDemo] Falied to create mqtt1_response_task!\n");
    }
    printf("This is mqtt1_response_task demo running\n");
}

static void speaker_heartbeat_task_run(void *arg)
{
    (void)arg;
    while (1) {
        if(is_mqtt1_connected == 0){
            DELAY_MS(100);
            continue;
        }
        mqtt1_publish(DEVICE_HEARTBEAT_TOPIC, DEVICE_HEARTBEAT_PAYLOAD, 0);
        DELAY_S(10); // 10s 发送一次心跳
    }
}

static void start_speaker_heartbeat_task(void)
{
    osThreadAttr_t attr;
    attr.name = "speaker_heartbeat_task";
    attr.attr_bits = 0U;
    attr.cb_mem = NULL;
    attr.cb_size = 0U;
    attr.stack_mem = NULL;
    attr.stack_size = 2048; // 心跳线程逻辑轻量，2048 足够
    attr.priority = osPriorityBelowNormal; // 心跳优先级可以低一点
    if (osThreadNew(speaker_heartbeat_task_run, NULL, &attr) == NULL)
    {
        printf("[EnvironmentDemo] Failed to create speaker_heartbeat_task!\n");
    }
    printf("speaker_heartbeat_task started\n");
}



static void song_task_run(void *arg)
{
    (void)arg;
    Beep_Operation_Complete(3);
}


static void start_song_task(void)
{
    osThreadAttr_t attr;
    attr.name = "song_task";
    attr.attr_bits = 0U;
    attr.cb_mem = NULL;
    attr.cb_size = 0U;
    attr.stack_mem = NULL;
    attr.stack_size = 2048; // 歌曲播放线程逻辑轻量，2048 足够
    attr.priority = osPriorityBelowNormal; // 歌曲播放优先级可以低一点
    if (osThreadNew(song_task_run, NULL, &attr) == NULL)
    {
        printf("[EnvironmentDemo] Failed to create song_task!\n");
    }
    printf("song_task started\n");
}






void speaker_task(void){
    sleep(1);
    start_mqtt1_init_task();
    start_mqtt1_response_task();
    start_speaker_heartbeat_task();
    start_song_task();
}