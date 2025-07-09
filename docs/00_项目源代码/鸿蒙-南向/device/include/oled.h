#ifndef OLED_H
#define OLED_H

typedef enum {
    OLED_ALIGN_LEFT = 0,
    OLED_ALIGN_CENTER,
    OLED_ALIGN_RIGHT,
} OledAlign;

void oled_init(void);
//清屏函数
void oled_display_clear(void);
//在指定行显示文本
void oled_display_show_text_align(const char *text, int row, OledAlign align);
#endif // OLED_H