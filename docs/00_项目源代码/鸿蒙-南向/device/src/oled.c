#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include "ohos_init.h"
#include "cmsis_os2.h"
#include "wifiiot_gpio.h"
#include "wifiiot_gpio_ex.h"
#include "oled_ssd1306.h"
#include "oled.h"


void oled_init(void){
    OledInit();
    oled_display_clear();
}
void oled_display_clear(void)
{
    OledFillScreen(0x00);
}

void oled_display_show_text_align(const char *text, int row, OledAlign align)
{
    if (row < 0 || row >= 8) {
        printf("[OledDisplay] Invalid row: %d\n", row);
        return;
    }
    if (text == NULL) {
        printf("[OledDisplay] Null text pointer\n");
        return;
    }

    // OLED屏幕宽度像素，假设128
    const int oled_width_px = 128;
    const int char_width_px = 6;   // FONT6x8字体宽度
    int text_len = strlen(text);
    int text_width_px = text_len * char_width_px;
    int x = 0;

    switch (align) {
        case OLED_ALIGN_LEFT:
            x = 0;
            break;
        case OLED_ALIGN_CENTER:
            x = (oled_width_px - text_width_px) / 2;
            if (x < 0) x = 0; // 防止文本太长导致负值
            break;
        case OLED_ALIGN_RIGHT:
            x = oled_width_px - text_width_px;
            if (x < 0) x = 0;
            break;
        default:
            x = 0;
            break;
    }

    OledShowString(x, row, text, FONT6x8);
}

