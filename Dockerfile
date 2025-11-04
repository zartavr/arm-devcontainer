# FROM ubuntu:24.04
# Use local image because of network issues
FROM ubuntu-local:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOT
    apt-get update
    apt-get install locales
    locale-gen en_US.UTF-8
EOT

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Zephyr SDK dependances
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git \
    cmake \
    ninja-build \
    make \
    wget \
    xz-utils

RUN apt-get install --no-install-recommends -y ca-certificates && \
    update-ca-certificates

USER root

# Install ARM Toolchain
ARG ARM_TOOLCHAIN_VERSION=14.3.rel1
ARG ARM_TOOLCHAIN_ARCHIVE=arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-x86_64-arm-none-eabi.tar.xz
ARG ARM_TOOLCHAIN_URL=https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_TOOLCHAIN_VERSION}/binrel/${ARM_TOOLCHAIN_ARCHIVE}

RUN <<EOT
    mkdir -p /opt/arm
	cd /opt/arm
	wget ${ARM_TOOLCHAIN_URL}
    tar -xf ${ARM_TOOLCHAIN_ARCHIVE}
	rm ${ARM_TOOLCHAIN_ARCHIVE}
EOT

ENV PATH=/opt/arm/arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-x86_64-arm-none-eabi/bin:$PATH

# Install Clangd Language server
ARG CLANGD_VERSION=21.1.0

RUN <<EOT
    cd /opt
    apt install unzip
    wget https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/clangd-linux-${CLANGD_VERSION}.zip
    unzip clangd-linux-${CLANGD_VERSION}.zip
    rm clangd-linux-${CLANGD_VERSION}.zip
    ls
    mv clangd_${CLANGD_VERSION} clangd
EOT

ENV PATH=/opt/clangd/bin:$PATH

# Create 'user' account
ARG USERNAME=developer
ARG UID=1001
ARG GID=$UID

RUN <<EOT 
    apt-get update && apt-get install --no-install-recommends -y sudo
    groupadd --gid $GID $USERNAME
    useradd --uid $UID --gid $GID -m $USERNAME
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME}
    chmod 0440 /etc/sudoers.d/$USERNAME
    usermod -a -G plugdev ${USERNAME}
EOT

# User settings
USER ${USERNAME}

# Install openocd
ARG OPENOCD_VERSION=0.12.0

RUN <<EOT 
    sudo apt install openocd -y
EOT