ARG FROM_IMAGE=ghcr.io/tirrex-roboterrium/tirrex_workspace:full

FROM ${FROM_IMAGE}

# install all missing packages that you have specified into your package.xml
RUN --mount=type=bind,source=src,target=/tmp/src \
    apt-get update && \
    rosdep update && \
    rosdep install -iyr --from-paths /tmp/src && \
    rm -rf /var/lib/apt/lists/*

# you can add here ubuntu packages that you want to install (or uncomment the existing ones)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      # gdb \
      # gdbserver \
      # valgrind \
      # strace \
    && rm -rf /var/lib/apt/lists/*
