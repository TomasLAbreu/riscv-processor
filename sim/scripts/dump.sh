#!/bin/bash

infile=../sim/test_all.s
outfile=../sim/riscvtest.txt

riscv64-unknown-linux-gnu-as -o a.elf $infile
riscv64-unknown-linux-gnu-objcopy -O binary -j .text a.elf
od -An -t x4 a.elf > $outfile
sed -i 's/ /\n/g' $outfile
sed -i '/^$/d' $outfile
rm a.elf
