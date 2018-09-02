#ifndef PIXEL_BASE_ADDR

// 线性地址0xffff800000000000  代表物理地址 0
// 线性地址0xffff800000a00000  代表屏幕地址 0
#define PIXEL_BASE_ADDRESS 0xffff800000a00000
#define PIXEL_COLUMN_TOTAL 800
#define PIXEL_ROW_TOTAL 600
#define PIXEL_TOTAL 480000

void print_pixel(unsigned int row, int column, int color);

void print_line(unsigned int row, unsigned int color);

void print_8x8(char map[], unsigned int row_start, int column_start, int color);

void print_char(char letter, unsigned int row, int column, int color);

void print_ascii(int ascii_index, unsigned int row, int column, int color);

void print_string(char *string, unsigned int row, int column, int color);

void set_screen_color(int color);

#endif