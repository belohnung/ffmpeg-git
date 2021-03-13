# Custom ffmpeg Dockerfile

# Versions:

# ffmpeg      - git master HEAD
# libvmaf    - 2.1.1
# libzimg    - git master HEAD
# libopus    - git master HEAD
# libx264    - git master HEAD
# libx265    - git master HEAD
# libsvthevc - git master HEAD
# libsvtvp9  - git master HEAD
# libsvtav1  - git master HEAD
# libaom     - git master HEAD


# Use Debian for our base image
FROM docker.io/debian:stable-slim AS build

# Set the working directory to /app
WORKDIR /app

#--------------------------------
# Update and install dependencies
#--------------------------------
# No, we're not going to version every apt package dependency.
# That's a bad idea in practice and will cause problems.
# hadolint ignore=DL3008
RUN \
apt-get update && \
apt-get install -y \
  --no-install-recommends \
  autoconf \
  curl \
  automake \
  build-essential \
  ca-certificates \
  openssl \
  gnutls-bin \
  libssl-dev \
  cmake \
  doxygen \
  libasound2 \
  libnuma-dev \
  libtool-bin \
  libsdl2-dev \
  libtool \
  pkg-config \
  texinfo \
  zlib1g-dev \
  git-core \
  nasm \
  yasm
#--------------
# Install rust
#--------------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ > rustup.sh && chmod +x rustup.sh && ./rustup.sh -y --no-modify-path --profile minimal --default-toolchain stable && rm rustup.sh
#------------------
# Setup directories
#------------------
RUN mkdir -p /input /output /ffmpeg/ffmpeg_sources
#-------------
# Build ffmpeg
#-------------

# Clone sources
RUN cd /ffmpeg/ffmpeg_sources || exit && git clone --depth 1 https://github.com/xiph/opus.git && git clone https://github.com/FFmpeg/FFmpeg ffmpeg

#----------------
# Compile libopus
#----------------
RUN cd /ffmpeg/ffmpeg_sources/opus || exit && ./autogen.sh && ./configure && make -j "$(nproc)" && make install

# Copy the current directory contents into the container at /app
COPY . /app
RUN ./build-lame.sh
RUN ./build-ffmpeg.sh

#----------------------------------------------------
# Clean up directories and packages after compilation
#----------------------------------------------------
RUN pip3 uninstall meson -y
RUN apt-get purge -y \
  autoconf \
  automake \
  build-essential \
  cmake \
  doxygen \
  pkg-config \
  texinfo \
  git-core

RUN apt-get autoremove -y && \
apt-get install -y \
  --no-install-recommends \
  libsdl2-dev && \
apt-get clean && \
apt-get autoclean && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /ffmpeg



#---------------------------------------
# Run ffmpeg when the container launches
#---------------------------------------
CMD ["ffmpeg"]
