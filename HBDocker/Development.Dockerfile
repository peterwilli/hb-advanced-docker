FROM debian:bullseye-slim
MAINTAINER Peter Willemsen <peter@codebuffet.co>
RUN echo "Installing dependencies..." && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libssl-dev git wget curl build-essential && \
	rm -rf /var/lib/apt/lists/*

# This is an example, you can use anything you 
RUN echo "Installing Rust (for compiling native modules)" && \
    curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain 1.61.0

RUN bash -c 'set -ex && \
    ARCH=`uname -m` && \
    echo "Installing Conda on $ARCH" && \
    if [ "$ARCH" == "x86_64" ]; then \
        wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh; \
    elif [ "$ARCH" == "aarch64" ]; then \
        # This is the latest I was able to install on my Pi 4...
        wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-aarch64.sh -O ~/miniconda.sh; \
    else \
        echo "Unsupported architecture: $ARCH!" && \
        exit; \
    fi; \
    /bin/bash ~/miniconda.sh -b -p /opt/conda'

COPY ./start.sh /usr/bin/start.sh
COPY ./install_hummingbot /usr/bin
COPY ./custom_installation /usr/bin
ENV CONDA_DIR /opt/conda
ENV PATH="$CONDA_DIR/bin:/root/.cargo/bin:${PATH}"
WORKDIR /opt/hummingbot
RUN conda init bash
ENTRYPOINT ["/usr/bin/start.sh"]