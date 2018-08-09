# myos开发日志

## 2018.08.05

啥也不懂，就想自己动手写个操作系统，x86 64位，会很难吗？不知道，试试看呗，又不会死。

先准备点工具，装个docker，再做个Linux docker镜像（位于tools/linux），作为开发环境。再装一个virtualbox来跑做出来的os。

然后就毫无头绪了，先试着规划一下。

- 启动
- 内存管理
- 进程管理
- 中断、异常
- 文件系统
- 网络
- Shell

还有啥？不管，先搞定启动再说。好像要写汇编，完全不会。

先整个helloword吧。看看书先...

一头雾水，pdf下了不少，比较老旧，还是先买本书吧，《一个64位操作系统的设计与实现》，后面简称《操作系统》。

## 2018.08.07

书到了，刚好也是从boot引导开始，但是解释的太粗糙了，妈蛋，先去了解一下寄存器。

大致翻了下王爽的《汇编原理》，年代是久远了点，原理应该差不多，没找到更适合入门的。

寄存器这么多，先记几个目前要用的：

- AX/BX/CX/DX 通用寄存器
- DS 数据段寄存器（data segment）
- ES 附加段寄存器（extra segment）
- SS 堆栈段寄存器（stack segment）
- SP 堆栈指针寄存器（stack pointer）
- BP 基址指针寄存器（base pointer）

64位的寄存器，当然都是64位的。容量大，数量多，估计有些古老的用法都不需要了。

OK，这样helloworld引导程序可以看懂了。代码和注释在`learning/helloworld/boot.asm`里。

然后用nasm编译成bin文件 `nasm boot.asm -o boot.bin`。

接着需要制作一张软盘镜像，折腾了一圈，没成功，困，睡觉。

## 2018.08.08

百度了一圈，原来linux自带了制作镜像的命令，一行命令就搞定：`dd if=boot.bin of=boot.img bs=512 count=2880`。比《操作系统》里用的Bochs虚拟机方便多了。

然后用virtualbox创建一个自定义的64位虚拟机，添加一个虚拟软盘，镜像选择上面生成的helloworld.img镜像文件，启动，我擦，居然成功了。

![image](https://raw.githubusercontent.com/Kane-One/myos/master/learning/res/helloworld.jpg)

不过堂堂64位系统用中学时代的软盘来启动，简直跟20岁妹子让60岁老汉拱了一样，妹子能尽兴吗？后面找时间看看能不能改成USB。

这里只实现了引导，即BIOD正确识别、加载并执行了引导盘的引导扇区的内容。然而引导扇区容量仅为512个字节，能做的事比较有限，相当于火箭发射的点火阶段而已，接下来开始启动。具体要怎么做未知，大致翻了下《操作系统》，应该分下面几个主要阶段：

- 从文件系统找到启动程序并载入内存
- 从实模式切换到保护模式
- 从32位切换到64位
- 从启动程序跳转到内核程序

第一步看着就蛋疼，这就开始文件系统了？

《操作系统》中有几处低级错误：
> FAT12文件系统的表项位宽为12 bit…… 

应该是12 byte（字节）。

计算根目录占用的扇区数的方法有点莫名其妙，应该是根目录最多允许224个文件，每个占12个字节，每个扇区512个字节，所以算法应该是`224 * 12 / 512 = 14`才对。

又涉及到新的寄存器，花样真多：

- sp：16位（esp的低16位）
- esp：32位（rsp的低32位）
- rsp：64位

更多玩法参照 [x64-architecture](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/x64-architecture)。

介绍下软盘的结构，《操作系统》里讲的不是很清楚，看的云里雾里。

![image](https://raw.githubusercontent.com/Kane-One/myos/master/learning/res/softdisk.jpeg)

以3.5英寸1.44MB的软盘为例，有18个扇面，80个磁道（磁轨），且双面都可读写，每一面有一个磁头。这样就形成`18 * 80 * 2 = 2880`个扇区。

《操作系统》把扇面和扇区混为一谈，令人费解。

每个扇区的容量都是512个字节，所以一共有`512Byte * 2880 = 1.44MB`的容量。个人猜测可能是越靠近边缘的磁道越窄。

扇面号（0到17），磁道号（0到79），磁头号（0和1）三个参数共同决定扇区号。

了解这些，书中读取扇区的程序才读的通。

另外需要了解一下[读取磁盘扇区的中断](http://www.ousob.com/ng/asm/ng79205.php)。

整个启动的代码都在`learning/helloworld/boot_loader.asm`里。