FROM alpine:latest
RUN apk --no-cache add bash curl

RUN curl -LO https://github.com/large-scale-gxe-methods/GEM/releases/download/v2.1.2/GEM_2.1.1_Intel && \
    mv GEM_2.1.1_Intel GEM && \
    chmod +x GEM
