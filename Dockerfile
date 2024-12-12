FROM quay.io/large-scale-gxe-methods/ubuntu:focal-20210325

# Install basic dependencies
RUN apt update &&\
    apt install -y gpg-agent wget git gcc g++ gfortran make zlib1g-dev libzstd-dev dstat atop
                 # ^----------------^ ^-------------------^ ^--------------------^ ^--------^
                 #  For downloading       For compiling       Required libraries   Resource monitoring

# Install Intel Math Kernel Library
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list && \
    apt update && \
    apt install -y intel-oneapi-mkl intel-oneapi-mkl-devel

# Install Eigen3
RUN cd /tmp && \
  wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz && \
  tar -xf eigen-3.4.0.tar.gz && \
  cp -r eigen-3.4.0/Eigen /usr/local/include/ && \
  rm -rf *

# Install Boost
ENV PKG_CONFIG_PATH=/opt/intel/oneapi/mkl/latest/bin/mkl_link_tool
RUN wget -q https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/boost_1_71_0.tar.gz && \
    tar -xzf boost_1_71_0.tar.gz
RUN cd boost_1_71_0 && \
    ./bootstrap.sh && \
    ./b2 install

# Install GEM from source (and store version so cache rebuilds when GEM source code updates)
# Note: currently breaks cache if any branch updates, but could make this branch-specific with /GH/path/refs/heads/[BRANCH]
ADD https://api.github.com/repos/large-scale-gxe-methods/GEM/git/refs/heads version.json

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/intel/oneapi/tbb/latest/lib/gcc4.8:/opt/intel/oneapi/compiler/latest/lib:/opt/intel/oneapi/mkl/latest/lib
ENV       LIBRARY_PATH=$LIBRARY_PATH:/opt/intel/oneapi/tbb/latest/lib/gcc4.8:/opt/intel/oneapi/compiler/latest/lib:/opt/intel/oneapi/mkl/latest/lib
RUN ldconfig
RUN git clone https://github.com/large-scale-gxe-methods/GEM && \
    cd /GEM/src/ && \
    git checkout v1.5.3 && \
    env && \
    pwd && \
    ls -l && \
    make -j && \
    mv /GEM/src/GEM /GEM/GEM
