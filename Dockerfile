# RDKit inspired by https://github.com/mcs07/docker-rdkit/blob/master/Dockerfile
FROM ubuntu:eoan AS rdkit-build-env
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    ca-certificates \
    build-essential \
    cmake \
    wget \
    libboost-all-dev \
    libcairo2-dev \
    libeigen3-dev \
    python3-dev \
    python3-numpy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
ARG RDKIT_VERSION=Release_2019_09_1
RUN wget --quiet https://github.com/rdkit/rdkit/archive/${RDKIT_VERSION}.tar.gz \
 && tar -xzf ${RDKIT_VERSION}.tar.gz \
 && mv rdkit-${RDKIT_VERSION} rdkit \
 && rm ${RDKIT_VERSION}.tar.gz
RUN mkdir /rdkit/build
WORKDIR /rdkit/build
# RDK_OPTIMIZE_NATIVE=ON assumes container will be run on the same architecture on which it is built
RUN cmake -Wno-dev \
  -D RDK_INSTALL_INTREE=OFF \
  -D RDK_INSTALL_STATIC_LIBS=OFF \
  -D RDK_BUILD_INCHI_SUPPORT=ON \
  -D RDK_BUILD_AVALON_SUPPORT=ON \
  -D RDK_BUILD_PYTHON_WRAPPERS=ON \
  -D RDK_BUILD_CAIRO_SUPPORT=ON \
  -D RDK_USE_FLEXBISON=OFF \
  -D RDK_BUILD_THREADSAFE_SSS=ON \
  -D RDK_OPTIMIZE_NATIVE=ON \
  -D PYTHON_EXECUTABLE=/usr/bin/python3 \
  -D PYTHON_INCLUDE_DIR=/usr/include/python3.7 \
  -D PYTHON_NUMPY_INCLUDE_PATH=/usr/lib/python3/dist-packages/numpy/core/include \
  -D CMAKE_INSTALL_PREFIX=/usr \
  -D CMAKE_BUILD_TYPE=Release \
  ..
RUN make -j $(nproc) \
 && make install
FROM ubuntu:bionic AS rdkit-env
# install runtime dependencies
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    libboost-atomic1.67.0 \
    libboost-chrono1.67.0 \
    libboost-date-time1.67.0 \
    libboost-python1.67.0 \
    libboost-regex1.67.0 \
    libboost-serialization1.67.0 \
    libboost-system1.67.0 \
    libboost-thread1.67.0 \
    libboost-iostreams1.67.0 \
    libcairo2-dev \
    python3-dev \
    python3-numpy \
    python3-cairo \
    python3-setuptools \
    python3-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
# copy rdkit installation from rdkit-build-env
COPY --from=rdkit-build-env /usr/lib/libRDKit* /usr/lib/
COPY --from=rdkit-build-env /usr/lib/cmake/rdkit/* /usr/lib/cmake/rdkit/
COPY --from=rdkit-build-env /usr/share/RDKit /usr/share/RDKit
COPY --from=rdkit-build-env /usr/include/rdkit /usr/include/rdkit
COPY --from=rdkit-build-env /usr/lib/python3/dist-packages/rdkit /usr/lib/python3/dist-packages/rdkit
# workaround to load boost dynamically
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_python-py37.so.1.67.0 /usr/lib/x86_64-linux-gnu/libboost_python3-py37.so.1.65.1
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_serialization.so.1.67.0 /usr/lib/x86_64-linux-gnu/libboost_serialization.so.1.65.1
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_iostreams.so.1.67.0 /usr/lib/x86_64-linux-gnu/libboost_iostreams.so.1.65.1
# update python packages
RUN pip3 install --upgrade --no-cache-dir pip setuptools
CMD /bin/bash
