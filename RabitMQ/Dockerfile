# © Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################# Dockerfile for RabbitMQ version 3.7.5 ################################
#
# RabbitMQ is an open source message broker software (sometimes called message-oriented middleware)
# that implements the Advanced Message Queuing Protocol (AMQP).
#
# To build RabbitMQ image from the directory containing this Dockerfile
# (assuming that the file is named "Dockerfile"):
# docker build -t <image_name> .
#
# To start the RabbitMQ server run the below command
# docker run --name <container_name> -p 15672:15672 -d <image_name>
#
# To start the RabbitMQ server by providing rabbitmq-configuration
# docker run --name <container_name> -v <path_to_rabbitmq.config_file_on_host>:/etc/rabbitmq/rabbitmq.config -p 15672:15672 -d <image_name>
#
# We can view the RabbitMQ management UI at http://<rabbitmq-host-IP>:15672
#
#########################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

ENV SOURCE_DIR=/tmp/source

# Install the build dependencies for RabbitMQ
RUN apt-get update && apt-get install -y \
    ant \
    curl \
    git \
    make \
    openssl \
    python \
    rsync \
    tar \
    wget \
    xsltproc \
    xz-utils \
    zip \

# Install the build dependencies for Erlang
 && apt-get install -y \
    g++ \
    gcc \
  libncurses-dev \
    libncurses5-dev \
    libssl-dev \   
    openjdk-8-jdk \   
    perl \   
    unixodbc \
    unixodbc-dev \
 
# Download and build Erlang
 && wget http://www.erlang.org/download/otp_src_20.0.tar.gz \
 && tar zxf otp_src_20.0.tar.gz && cd otp_src_20.0 \
 && export ERL_TOP=$(pwd) && ./configure --prefix=/usr \
 && make && make install \

	
# Download and install rabbitmq
 && mkdir $SOURCE_DIR && cd $SOURCE_DIR \
 && wget https://dl.bintray.com/rabbitmq/all/rabbitmq-server/3.7.5/rabbitmq-server-3.7.5.tar.xz \
 && git clone git://github.com/elixir-lang/elixir \
 && cd elixir && git checkout v1.6.1 && make && make install \
 && cd ../ && git clone git://github.com/hexpm/hex.git \
 && cd hex &&  git checkout v0.17.7 && mix install \
 
 && cd /opt && tar xf $SOURCE_DIR/rabbitmq-server-3.7.5.tar.xz \
 && cp $SOURCE_DIR/hex/_build/dev/lib/hex/ebin/*  rabbitmq-server-3.7.5/deps/.mix/archives/hex-0.17.7/hex-0.17.7/ebin/ \
 && cd rabbitmq-server-3.7.5  && make && make install \
 && mkdir -p /etc/rabbitmq \
 && echo "[{rabbit, [{loopback_users, []}]}]." | tee /etc/rabbitmq/rabbitmq.config \
 && rm -rf deps/rabbit/plugins && ln -s  $PWD/plugins deps/rabbit/plugins \

# Clean up of unused packages and source directory.
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    ant \
    curl \
    git \
    make \
	openjdk-8-jdk \
    openssl \
    python \
    rsync \
    wget \
    xsltproc \
    xz-utils \
    zip \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/rabbitmq-server-3.7.5

# Expose RabbitMQ management console port and RabbitMQ server port
EXPOSE 15672 5672

# Enable RabbitMQ management plugin and start RabbitMQ server
ENTRYPOINT deps/rabbit/scripts/rabbitmq-plugins enable rabbitmq_management && deps/rabbit/scripts/rabbitmq-server

# End of Dockerfile
