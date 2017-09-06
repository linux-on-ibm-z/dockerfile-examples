################# Dockerfile for RabbitMQ version 3.6.11 ################################
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

# Install the build dependencies
RUN apt-get update && apt-get install -y \
    ant \
    curl \
    erlang \
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

# Download and install rabbitmq
 && mkdir $SOURCE_DIR && cd $SOURCE_DIR \
 && wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.11/rabbitmq-server-3.6.11.tar.xz \
 && git clone https://github.com/elixir-lang/elixir \
 && cd elixir && git checkout v1.3.4 && make && make install \
 && cd /opt && tar xf $SOURCE_DIR/rabbitmq-server-3.6.11.tar.xz \
 && cd rabbitmq-server-3.6.11 && make all && make install \
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

WORKDIR /opt/rabbitmq-server-3.6.11

# Expose RabbitMQ management console port and RabbitMQ server port
EXPOSE 15672 5672

# Enable RabbitMQ management plugin and start RabbitMQ server
ENTRYPOINT deps/rabbit/scripts/rabbitmq-plugins enable rabbitmq_management && deps/rabbit/scripts/rabbitmq-server

# End of Dockerfile
