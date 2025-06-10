FROM quay.io/large-scale-gxe-methods/ubuntu:focal-20210325

RUN apt update &&\
    apt install -y atop curl dstat

RUN curl -LO https://github.com/large-scale-gxe-methods/GEM/releases/download/v2.1.2/GEM_2.1.2_Intel && \
    mv GEM_2.1.2_Intel GEM && \
    chmod +x GEM
