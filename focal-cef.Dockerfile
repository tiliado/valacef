FROM docker.io/library/ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get --yes update \
 && apt-get install --yes \
    bison \
    build-essential \
    ca-certificates \
    curl \
    default-jre \
    flex \
    g++ \
    git-core \
    git-svn \
    gperf \
    libasound2-dev \
    libcairo2-dev \
    libcups2-dev \
    libdrm-dev \
    libgbm-dev \
    libglib2.0-dev \
    libglu1-mesa-dev \
    libgtk-3-dev \
    libgtkglext1-dev \
    libkrb5-dev \
    libnspr4-dev \
    libnss3-dev \
    libpci-dev \
    libpulse-dev \
    libva-dev \
    libxss-dev \
    mesa-common-dev \
    python \
    python-setuptools \
    uuid-dev \
 && rm -rf /var/lib/apt/lists/*

ENV \
    GN_DEFINES="is_official_build=true use_allocator=none symbol_level=1 ffmpeg_branding=Chrome proprietary_codecs=true use_gnome_keyring=false" \
    CFLAGS="-Wno-error" \
    CXXFLAGS="-Wno-error" \
    CEF_ARCHIVE_FORMAT=tar.bz2

RUN apt-get --yes update \
 && apt-get install --yes \
    libxshmfence-dev \
 && rm -rf /var/lib/apt/lists/*
