FROM ruby:2.6.9-buster

RUN apt-get update && apt-get install -qy gnupg ca-certificates-java
RUN apt-key update
RUN apt-get install -qy software-properties-common && \
    apt-get install -qy libgs-dev && \
    apt-get install -qy ghostscript && \
    apt-get install -qy imagemagick --fix-missing && \
    apt-get install -qy libc6 libstdc++6 zlib1g libpng16-16 libjpeg62-turbo \
                        libssl-dev libfreetype6 libicu-dev fontconfig \
                        libx11-6 libxext6 libxrender1 libxcb1 xfonts-base xfonts-75dpi wget git pdftk xvfb \
                        libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev libjemalloc-dev libjemalloc2 curl gnupg2 lsb-release

# Add the NodeJS repository
RUN wget --quiet -O - https://deb.nodesource.com/setup_15.x | bash -
RUN wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Add the PostgreSQL repository
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
RUN curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -qy nodejs libpq-dev postgresql-client build-essential yarn

# Inject jemalloc
ENV LD_PRELOAD=libjemalloc.so.2

# Install wkhtmltopdf
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb && \
    dpkg -i wkhtmltox_0.12.5-1.buster_amd64.deb && \
    apt-get -f install

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*