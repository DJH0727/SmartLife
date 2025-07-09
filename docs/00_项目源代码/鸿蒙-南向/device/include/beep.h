#ifndef BEEPER_H
#define BEEPER_H
extern int Playing;
extern int StopPlaying;
void beep_init(void);

void Beep_On(void);
void Beep_Off(void);
void Beep_Operation_Complete(int operation);
#endif // BEEPER_H