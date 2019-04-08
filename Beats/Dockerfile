# © Copyright IBM Corporation 2017, 2019.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

#################### Dockerfile for Beats 6.2.4 #############################
# Beats is the platform for single-purpose data shippers
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To create a container of Beats image run the below command:
# docker run --name <container_name> -it  <image_name>
#
# The following modules are present in beats: heartbeat ,filebeat ,metricbeat , packetbeat, libbeat, auditbeat
# docker run --name <container_name> -e BEATSNAME=<beat_name> -d <image_name>
#
# To run a particular module like heartbeat run the following command:
# docker run --name <container_name> -e BEATSNAME=heartbeat -d <image_name>
#
# Note : To run auditbeat use options : --cap-add=AUDIT_CONTROL --cap-add=AUDIT_READ --pid=host to docker run 
# docker run --cap-add=AUDIT_CONTROL --cap-add=AUDIT_READ --pid=host --name <container_name> -e BEATSNAME=auditbeat -d <image_name>
###########################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

# Set environment variable
ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR
ENV PATH=$PATH:/usr/lib/go-1.9/bin/
ENV GOPATH=$SOURCE_DIR

# Install dependencies
RUN apt-get update && apt-get install -y \
    acl \
    gcc \
    git \
    golang-1.9 \
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
    libffi-dev \
    libssl-dev \
    python-dev \
# Install go and donload beats source code
 && python -m easy_install pip \
 && python -m pip install appdirs pyparsing six packaging setuptools wheel PyYAML termcolor ordereddict nose-timer MarkupSafe virtualenv cffi==1.4.1 \
 && setfacl -dm u::rwx,g::r,o::r $GOPATH \
 && mkdir -p $GOPATH/src/github.com/elastic  \
 && cd $GOPATH/src/github.com/elastic  \
 && git clone https://github.com/elastic/beats.git  \
 && cd beats  \
 && git checkout v6.2.4  \
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
 && make \
# Building auditbeat
 && sed -i '32i var \(' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/audit.go \
 && sed -i '33i\\tbyteOrder = GetEndian\(\)' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/audit.go \
 && sed -i '34i \)' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/audit.go \
 && sed -i 's/binary.LittleEndian/byteOrder/g' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/audit.go \
 && sed -i '20d' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/netlink.go \
 && sed -i 's/^\tbinary.LittleEndian/\tbyteOrder/g' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/netlink.go \
 && sed -i 's/binary.LittleEndian/GetEndian\(\)/g' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/netlink.go \
 && sed -i '7i\\t\"github.com/elastic/go-libaudit\"' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/rule/binary.go \
 && sed -i '17s/binary.LittleEndian/libaudit.GetEndian\(\)/g' $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/rule/binary.go \
 && echo  "package libaudit\n\nimport (" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && echo  "\t\"encoding/binary\"\n\t\"unsafe\"\n)" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && echo  "func GetEndian() binary.ByteOrder {" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && echo  "\tvar i int32 = 0x1" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && echo  "\tv := (*[4]byte)(unsafe.Pointer(&i))" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && echo  "\tif v[0] == 0 {" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && echo  "\t\treturn binary.BigEndian" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && echo  "\t} else {" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && echo  "\t\treturn binary.LittleEndian\n\t}\n}" >> $GOPATH/src/github.com/elastic/beats/vendor/github.com/elastic/go-libaudit/endian.go \
 && cd $GOPATH/src/github.com/elastic/beats/auditbeat \
 && make \
 && cp -r $GOPATH/src/github.com/elastic/beats /opt/beats \
 && ln -s /opt/beats/heartbeat/heartbeat /usr/bin/heartbeat \
 && ln -s /opt/beats/packetbeat/packetbeat /usr/bin/packetbeat \
 && ln -s /opt/beats/libbeat/libbeat /usr/bin/libbeat \
 && ln -s /opt/beats/metricbeat/metricbeat /usr/bin/metricbeat \
 && ln -s /opt/beats/filebeat/filebeat /usr/bin/filebeat \
 && ln -s /opt/beats/auditbeat/auditbeat /usr/bin/auditbeat \
# Tidy and clean up
 && apt-get remove -y \
    acl \
    git \
    libssh-dev \
    make \
    wget \
 && apt-get autoremove -y \
 && apt autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* $SOURCE_DIR \
 && mkdir /Beats \
 && cd /opt/beats \
 && cp -n **/*.yml /Beats

# Create mount point for configuration files
VOLUME /Beats

CMD $BEATSNAME -e -path.config /Beats -d "publish"
