ARG arch=amd64
FROM advanced_hummingbot_dev_$arch:latest AS build
COPY ["./hummingbot", "/opt/hummingbot"]
RUN install_hummingbot
RUN conda run -n hummingbot bash /usr/bin/install_custom_deps

# Rebuild without all the cache (Just copy over binary files)
FROM debian:bullseye-slim
LABEL maintainer="Peter Willemsen <peter@codebuffet.co>"
COPY --from=build /opt/conda /opt/conda
COPY --from=build /opt/hummingbot /opt/hummingbot
COPY --from=build /root/.cache/pip /root/.cache/pip
ENV CONDA_DIR /opt/conda
ENV PATH="$CONDA_DIR/bin:${PATH}"
WORKDIR /opt/hummingbot
RUN conda init bash
COPY ./HBDocker/on_install /opt/on_install
COPY ./HBDocker/install_custom_deps /usr/bin/install_custom_deps
RUN conda run -n hummingbot bash /usr/bin/install_custom_deps --global-only
RUN touch /usr/share/.hummingbot_installed
COPY --from=build /usr/bin/start.sh /usr/bin/start.sh
RUN echo "conda activate hummingbot" >> /root/.bashrc
ENTRYPOINT ["/usr/bin/start.sh"]