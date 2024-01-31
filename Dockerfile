FROM ubuntu:focal

RUN apt-get update && apt-get install -qy gnupg
RUN apt-key update
RUN apt-get install -qy software-properties-common && \
    apt-get install -qy libgs-dev && \
    apt-get install -qy ghostscript && \
    apt-get install -qy imagemagick --fix-missing && \
    apt-get install -qy libc6 libstdc++6 zlib1g libpng16-16 libjpeg-turbo8 \
                        libssl-dev libfreetype6 libicu-dev fontconfig \
                        libx11-6 libxext6 libxrender1 libxcb1 xfonts-base xfonts-75dpi wget git pdftk xvfb \
                        libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev libjemalloc-dev curl

RUN apt-add-repository -y ppa:brightbox/ruby-ng

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN wget --quiet -O - https://deb.nodesource.com/setup_15.x | bash -
RUN wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -qy nodejs libpq-dev postgresql-9.6 postgresql-contrib-9.6 build-essential yarn gnupg2

SHELL ["/bin/bash", "-l", "-c"]
# Ruby and dependencies
# Install RVM, Ruby, and Bundler
RUN gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    \curl -sSL https://get.rvm.io | bash -s stable

# Add RVM to PATH
ENV PATH /usr/local/rvm/bin:$PATH

RUN rvm requirements && \
    rvm install 2.6.9 -C --with-jemalloc && \
    rvm --default use 2.6.9

# Verify that Ruby is using jemalloc
RUN ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']"
RUN ruby -r rbconfig -e "puts RbConfig::CONFIG['MAINLIBS']"

RUN gem install bundler -v '~> 1.17.3'

# Install wkhtmltopdf
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb && \
    dpkg -i wkhtmltox_0.12.5-1.focal_amd64.deb && \
    apt-get -f install

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*