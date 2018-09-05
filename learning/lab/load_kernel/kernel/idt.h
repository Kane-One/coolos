#ifndef KERNEL_CS

typedef unsigned long size_t;

#define KERNEL_CS 8

enum
{
    GATE_INTERRUPT = 0xE,
    GATE_TRAP = 0xF,
    GATE_CALL = 0xC,
    GATE_TASK = 0x5,
};

enum
{
    DESC_TSS = 0x9,
    DESC_LDT = 0x2,
    DESCTYPE_S = 0x10, /* !system */
};

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;

struct idt_bits
{
    // 共16位
    int ist : 3;  // 3 bit Interrupt Stack Table
    int zero : 5; // 5 bit
    int type : 5; // 4 bit type
    int dpl : 2;  // 2 bit Descriptor Privilege Level
    int p : 1;    // 1 bit Segment Present flag
};

typedef struct gate_struct
{
    u16 offset_low; //低16位偏移地址
    u16 segment;    //16位段选择子
    struct idt_bits bits;
    u16 offset_middle; // 中16位偏移地址
    u32 offset_high;   //  （64位才有）高32位偏移地址
    u32 reserved;      // （64位才有）保留位
} gate_desc;

struct idt_data
{
    unsigned int vector;
    unsigned int segment;
    struct idt_bits bits;
    const void *addr;
};

void *memcpy(void *dest, const void *src, size_t n);

void idt_init_desc(gate_desc *gate, const struct idt_data *d);
void set_intr_gate(int n, const void *addr);

void set_up_idt(void);

#endif