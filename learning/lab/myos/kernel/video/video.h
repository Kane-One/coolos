#ifndef MYOS_VIDEO
#define MYOS_VIDEO

#include "../head.h"

// 线性地址0xffff800000a00000  代表屏幕地址 0
#define PIXEL_BASE_ADDRESS (BASE_ADDRESS + 0xa00000)
#define PIXEL_COLUMN_TOTAL 800
#define PIXEL_ROW_TOTAL 600
#define PIXEL_TOTAL 480000
#define PIXEL_MAX_ADDRESS (PIXEL_BASE_ADDRESS + PIXEL_TOTAL * 4)

typedef struct screen_struct
{
    int font_size;
    int position_x;
    int position_y;
} screen_t;

void init_screen();

void set_pixel(unsigned int row, int column, int color);

void print_line(unsigned int row, unsigned int color);

void print_8x8(char map[], unsigned int row_start, int column_start, int color);

void print_char(char letter, unsigned int row, int column, int color);

void print_ascii(int ascii_index, unsigned int row, int column, int color);

void print_string(char *string, unsigned int row, int column, int color);

void set_screen_color(int color);

void n2s(char *s, long n);

void b2s(char *s, long n, int size);

void prints(char *s);

void printl(char *s);


#endif