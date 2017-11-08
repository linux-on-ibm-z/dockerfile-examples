#################### Dockerfile for Beats 5.6.3 #############################
# Beats is the platform for single-purpose data shippers
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To create a container of Beats image run the below command:
# docker run --name <container_name> -it  <image_name>
#
# The following modules are present in beats: heartbeat ,filebeat ,metricbeat , packetbeat, libbeat
# docker run --name <container_name> -v /<host_path>:/root/templates -d <image_name> <beat_name> -e -path.config /root/templates -d "publish"
#
# To run a particular module like heartbeat run the following command:
# docker run --name <container_name> -v /<host_path>:/root/templates -d <image_name> heartbeat -e -path.config /root/templates -d "publish"
#
###########################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV GOROOT=$SOURCE_DIR/go
ENV PATH=$GOROOT/bin:$PATH
ENV GOPATH=$SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
    acl \
    gcc \
    git \
    libcap-dev \
    libpcap0.8-dev \
    libssh-dev \
    make \
    openssl \
    python  \
    python-openssl \
    python-setuptools \
    tar \
    wget \

# Install go and donload beats source code
 && python -m easy_install pip \
 && python -m pip install appdirs pyparsing six packaging setuptools wheel PyYAML termcolor ordereddict nose-timer MarkupSafe virtualenv \
 && wget https://storage.googleapis.com/golang/go1.9.linux-s390x.tar.gz  \
 && tar xvf go1.9.linux-s390x.tar.gz \
 && ln -sf /usr/bin/gcc /usr/bin/s390x-linux-gnu-gcc \
 && setfacl -dm u::rwx,g::r,o::r $GOPATH \
 && mkdir -p $GOPATH/src/github.com/elastic  \
 && cd $GOPATH/src/github.com/elastic  \
 && git clone https://github.com/elastic/beats.git  \
 && cd beats  \
 && git checkout v5.6.3  \

# Updtae ipv4 and ipv6 source code to add support for s390x
 && sed -i "61d" $GOPATH/src/github.com/elastic/beats/vendor/golang.org/x/net/ipv4/gen.go  \
 && sed -i '60a case runtime.GOOS == "linux" && (runtime.GOARCH == "arm64" || runtime.GOARCH == "mips64" || runtime.GOARCH == "mips64le" || runtime.GOARCH == "ppc64" || runtime.GOARCH == "ppc64le" || runtime.GOARCH == "s390x"):' $GOPATH/src/github.com/elastic/beats/vendor/golang.org/x/net/ipv4/gen.go \
 && sed -i "61d" $GOPATH/src/github.com/elastic/beats/vendor/golang.org/x/net/ipv6/gen.go  \
 && sed -i '60a case runtime.GOOS == "linux" && (runtime.GOARCH == "arm64" || runtime.GOARCH == "mips64" || runtime.GOARCH == "mips64le" || runtime.GOARCH == "ppc64" || runtime.GOARCH == "ppc64le" || runtime.GOARCH == "s390x"):' $GOPATH/src/github.com/elastic/beats/vendor/golang.org/x/net/ipv6/gen.go \
 && cp $GOPATH/src/github.com/elastic/beats/vendor/golang.org/x/net/ipv6/zsys_linux_amd64.go $GOPATH/src/github.com/elastic/beats/vendor/golang.org/x/net/ipv6/zsys_linux_s390x.go \
 && cp $GOPATH/src/github.com/elastic/beats/vendor/golang.org/x/net/ipv4/zsys_linux_amd64.go $GOPATH/src/github.com/elastic/beats/vendor/golang.org/x/net/ipv4/zsys_linux_s390x.go \
 
 # Building heartbeat
 && cd $GOPATH/src/github.com/elastic/beats/heartbeat  \
 && make  \

# Building filebeat
 && cd $GOPATH/src/github.com/elastic/beats/filebeat  \
 && make  \

# Building packetbeat
 && cd $GOPATH/src/github.com/elastic/beats/packetbeat  \
 && make  \

# Building metricbeat
 && cd $GOPATH/src/github.com/elastic/beats/metricbeat \
 && make  \

# Building libbeat
 && cd $GOPATH/src/github.com/elastic/beats/libbeat  \
 && make  \
 && cp -r $GOPATH/src/github.com/elastic/beats /opt/beats \
 && ln -s /opt/beats/heartbeat/heartbeat /usr/bin/heartbeat \
 && ln -s /opt/beats/packetbeat/packetbeat /usr/bin/packetbeat \
 && ln -s /opt/beats/libbeat/libbeat /usr/bin/libbeat \
 && ln -s /opt/beats/metricbeat/metricbeat /usr/bin/metricbeat \
 && ln -s /opt/beats/filebeat/filebeat /usr/bin/filebeat \

# Tidy and clean up
 && rm -rf $SOURCE_DIR \
 && apt-get remove -y \
    acl \
    gcc \
    git \
    libssh-dev \
    make \
    openssl \
    python  \
    python-openssl \
    python-setuptools \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/* \
 && mkdir /root/templates && cd /opt/beats &&  cp -n **/*.yml **/*.template*.json /root/templates/

# Create mount point for configuration files
VOLUME /root/templates
