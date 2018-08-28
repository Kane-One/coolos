FROM alpine

RUN apk add curl bash procps gcc g++ libc-dev gdb nasm

RUN apk add dosfstools

RUN apk add make

COPY .bashrc /root/.bashrc



# 设置工作目录
WORKDIR /home/myos