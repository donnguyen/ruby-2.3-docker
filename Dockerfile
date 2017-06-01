FROM ubuntu:16.04
LABEL maintainer don@spiderbox.design

RUN apt-get update && apt-get install -y --no-install-recommends \
		software-properties-common \
		libgs-dev \
		ghostscript \
		imagemagick --fix-missing \
		libc6 libstdc++6 zlib1g libpng12-0 libjpeg-turbo8 \
		libssl1.0.0 libfreetype6 libicu55 fontconfig \
		libx11-6 libxext6 libxrender1 libxcb1 xfonts-base xfonts-75dpi \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-setuptools \
        python-scipy

RUN apt-add-repository -y ppa:brightbox/ruby-ng && \
	sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' && \
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
	wget --quiet -O - https://deb.nodesource.com/setup_6.x | bash - && \
	wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -qy curl nodejs libpq-dev postgresql-9.5 postgresql-contrib-9.5 build-essential \
                        ruby2.3 ruby2.3-dev yarn

RUN gem install bundler --no-ri --no-rdoc

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

RUN git clone https://github.com/donnguyen/caffe-textmaps.git . && \
    pip install --upgrade pip && \
    cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd .. && \
    mkdir build && cd build && \
    cmake -DCPU_ONLY=1 .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig
