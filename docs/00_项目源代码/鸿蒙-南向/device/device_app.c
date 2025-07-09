#include <stdio.h>
#include <unistd.h>

#include "ohos_init.h"
#include "cmsis_os2.h"

#include "wifi.h"
#include "oled.h"
#include "beep.h"
#include "i2c.h"

#include "ac.h"
#include "speaker.h"
#include "ems.h"

#define DELAY_MS(ms) osDelay((ms) / 10)
#define DELAY_S(s)   osDelay((s) * 100)

void init(void)
{
    i2c_init();
    oled_init();
    beep_init();
}


static void all_task(void)
{
   init();
   connect_wifi();
   sleep(1);
   ac_task();
   sleep(1);
   speaker_task();
   sleep(1);
   ems_task();
}


SYS_RUN(all_task);
