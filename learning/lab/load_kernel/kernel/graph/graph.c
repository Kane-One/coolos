 // 线性地址0xffff800000000000  代表物理地址 0
 // 线性地址0xffff800000a00000  代表屏幕地址 0
long base_addr = 0xffff800000000000;

int letter_map[1][8][8] = {
    {
        {1,1,1,1,1,1,0,0},
        {0,1,1,0,0,1,1,0},
        {0,1,1,0,0,1,1,0},
        {0,1,1,1,1,1,0,0},
        {0,1,1,0,0,1,1,0},
        {0,1,1,0,0,1,1,0},
        {1,1,1,1,1,1,0,0},
        {0,0,0,0,0,0,0,0}
    }
};

void print_pixel(unsigned int row, int column, int color){
    int column_total = 1440;
    int pixel_index = column_total * (row - 1) + column;
    long memory_address = base_addr + 0xa00000 + pixel_index * 4;
    int *addr = (int *)memory_address;
    *addr = color;
}

void print_line(unsigned int row, unsigned int color){
    int i;

    for(i = 0;i < 1440;i++){
        print_pixel(row,i,color);
    }
}

void print_letter_b(){
    int column_total = 1440;
    int row_start = 100;
    int column_start = 100;
    
    int i;
    int j;
    int flag;
    int column;
    int row = row_start;

    for(i = 0;i < 8;i++){
        column = column_start;
        for(j = 0;j < 8;j++){
            flag = letter_map[0][i][j];
            if(flag == 1){
                print_pixel(row,column,0xabcdef);
            }
            column++;
        }
        row++;
    }
}
