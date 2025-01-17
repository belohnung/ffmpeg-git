#!/bin/bash

# Compile and install ffmpeg.
# Environment setup and packages dependencies are handled by the Dockerfile.

#---------------
# Compile ffmpeg
#---------------
cd /ffmpeg/ffmpeg_sources/ffmpeg || exit
./configure \
  --disable-debug \
    --enable-lto \
    --enable-openssl \
    --enable-gpl \
    --enable-nonfree \
    --enable-libmp3lame \
    --enable-libopus \
    --disable-doc \
    --disable-nvenc \
    --disable-swscale \
    --disable-xvmc \
    --disable-ffplay
    
make -j "$(nproc)"
make install
hash -r
