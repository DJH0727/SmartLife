#include <stdio.h>
#include <unistd.h>
#include "ohos_init.h"
#include "cmsis_os2.h"
#include "wifiiot_gpio.h"
#include "wifiiot_gpio_ex.h"
#include "wifiiot_pwm.h"
#include "hi_pwm.h"
#include "common.h"
#include "beep.h"
#include "wifiiot_errno.h"

#define NOTE_AS4  466  
#define NOTE_C4   262
#define NOTE_D4   294
#define NOTE_E4   330
#define NOTE_F4   349
#define NOTE_G4   392
#define NOTE_A4   440
#define NOTE_B4   494
#define NOTE_C5   523
#define NOTE_A4   440


#define DELAY_MS(ms) osDelay((ms) / 10)
#define DELAY_S(s)   osDelay((s) * 100)


int Playing = 0;
int StopPlaying = 0;

void beep_init(void)
{
    GpioInit();
    // 蜂鸣器引脚 设置为 PWM功能
    IoSetFunc(WIFI_IOT_IO_NAME_GPIO_9, WIFI_IOT_IO_FUNC_GPIO_9_PWM0_OUT);
    PwmInit(WIFI_IOT_PWM_PORT_PWM0);
}

// 关闭蜂鸣器
void Beep_Off(void)
{
    PwmStop(WIFI_IOT_PWM_PORT_PWM0);
}



// 操作完成提示音1: 单击声（滴）
void Beep_Completion_Single(void)
{
    uint16_t freqDivisor = 34052; 

    PwmStart(WIFI_IOT_PWM_PORT_PWM0, freqDivisor / 2, freqDivisor);
    DELAY_MS(100);
    PwmStop(WIFI_IOT_PWM_PORT_PWM0);
    DELAY_MS(200);
}

// 操作完成提示音2: 双击声（滴滴）
void Beep_Completion_Double(void)
{
    uint16_t freqDivisor = 34052; 

    // 第一次“滴”声
    PwmStart(WIFI_IOT_PWM_PORT_PWM0, freqDivisor / 2, freqDivisor);
    DELAY_MS(100);
    PwmStop(WIFI_IOT_PWM_PORT_PWM0);
    DELAY_MS(200);

    // 第二次“滴”声
    PwmStart(WIFI_IOT_PWM_PORT_PWM0, freqDivisor / 2, freqDivisor);
    DELAY_MS(100);
    PwmStop(WIFI_IOT_PWM_PORT_PWM0);
}

void PlayNote(int frequency, int duration_ms)
{
    if (frequency == 0) {
        Beep_Off();
    } else {
        uint16_t freqDivisor = 40000000 / frequency; 
        PwmStart(WIFI_IOT_PWM_PORT_PWM0, freqDivisor / 2, freqDivisor);
    }

    usleep(duration_ms * 1000);
    Beep_Off();
    usleep(20000); 
}

void PlayBirthdaySong(void)
{
    int notes[] = {
        NOTE_C4, NOTE_C4, NOTE_D4, NOTE_C4, NOTE_F4, NOTE_E4,
        NOTE_C4, NOTE_C4, NOTE_D4, NOTE_C4, NOTE_G4, NOTE_F4,
        NOTE_C4, NOTE_C4, NOTE_C5, NOTE_A4, NOTE_F4, NOTE_E4, NOTE_D4,
        NOTE_AS4, NOTE_AS4, NOTE_A4, NOTE_F4, NOTE_G4, NOTE_F4
    };

    int durations[] = {
        400, 400, 800, 800, 800, 1600,
        400, 400, 800, 800, 800, 1600,
        400, 400, 800, 800, 800, 800, 1600,
        400, 400, 800, 800, 800, 1600
    };

    int length = sizeof(notes) / sizeof(notes[0]);
    while(1){
        if(Playing){
            for (int i = 0; i < length; i++) {
                if(StopPlaying){
                    StopPlaying = 0;
                    break;
                }
                PlayNote(notes[i], durations[i]);
            }
            Playing = 0;
        }
        else {
            osDelay(100); // 避免空转
        }
    }

}


void Beep_Operation_Complete(int operation)
{
    if (operation == 1)
    {
        Beep_Completion_Single();
    }
    else if (operation == 2)
    {
        Beep_Completion_Double();
    }
    else if (operation == 3)
    {
        PlayBirthdaySong();
    }
}

