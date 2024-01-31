FROM ubuntu:trusty

RUN apt-key update && apt-get update && \
    apt-get install -qy software-properties-common && \
    apt-get install -qy libgs-dev && \
    apt-get install -qy ghostscript && \
    apt-get install -qy imagemagick --fix-missing && \
    apt-get install -qy libc6 libstdc++6 zlib1g libpng12-0 libjpeg-turbo8 \
                        libssl1.0.0 libfreetype6 libicu52 fontconfig \
                        libx11-6 libxext6 libxrender1 libxcb1 xfonts-base xfonts-75dpi wget git pdftk xvfb \
                        libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev libjemalloc-dev

RUN apt-add-repository -y ppa:brightbox/ruby-ng
RUN add-apt-repository ppa:ecometrica/servers

RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN wget --quiet -O - https://deb.nodesource.com/setup_15.x | sudo -E bash -
RUN wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

RUN  apt-get update && apt-get upgrade -y

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.trusty_amd64.deb && \
    sudo dpkg -i wkhtmltox_0.12.5-1.trusty_amd64.deb && \
    sudo apt-get -f install

# Ruby and dependencies
# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby with jemalloc
ENV RUBY_CONFIGURE_OPTS="--with-jemalloc"
RUN /bin/bash -c "source ~/.bashrc && rbenv install 2.6.9 && rbenv global 2.6.9"

# Verify that Ruby is using jemalloc
RUN ruby -r rbconfig -e "puts RbConfig::CONFIG['LIBS']"

RUN apt-get install -qy --force-yes curl nodejs libpq-dev postgresql-9.6 postgresql-contrib-9.6 build-essential yarn

RUN gem install bundler

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*