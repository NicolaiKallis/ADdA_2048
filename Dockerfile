FROM ubuntu:24.04

ARG ALIRE_VERSION=2.1.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
        git \
        build-essential \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/alire \
    && curl -fsSL -o /tmp/alr.zip \
        https://github.com/alire-project/alire/releases/download/v${ALIRE_VERSION}/alr-${ALIRE_VERSION}-bin-x86_64-linux.zip \
    && unzip /tmp/alr.zip -d /opt/alire \
    && rm /tmp/alr.zip \
    && ALR_BIN=\"$(find /opt/alire -type f -name alr -perm -111 | head -n 1)\" \
    && ln -s \"${ALR_BIN}\" /usr/local/bin/alr

WORKDIR /workspace
COPY . /workspace

# Default: build and run the game. Override with `docker run ... alr build` or `alr exec -- gnatprove ...`.
CMD ["alr", "run"]
