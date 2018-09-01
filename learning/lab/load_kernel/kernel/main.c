#include "graph/graph.h"

void Start_Kernel(void)
{

    print_line(300, 0xff0000);

    print_char('c', 0x10, 40, 0x00cc66);
    print_char('f', 0x20, 40, 0x666666);
    print_char('w', 0x30, 40, 0x666666);

    while (1)
        ;
}
