#!/bin/bash

cd /ffmpeg/ffmpeg_sources || exit

mkdir lame
cd lame || exit
curl https://kumisystems.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz -o lame.tar.gz
tar -xf lame.tar.gz
cd lame-3.100|| exit
ls
./configure
make
make install