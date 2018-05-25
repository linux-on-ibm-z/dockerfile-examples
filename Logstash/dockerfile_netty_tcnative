# Â© Copyright IBM Corporation 2017, 2018.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

############################ Dockerfile for Logstash v6.2.4 with netty-tcnative v2.0.7.Final ###################################################
#
# This Dockerfile builds a basic installation of Logstash
#
# Logstash is a tool for managing events and logs. When used generically the term
# encompasses a larger system of log collection, processing, storage and searching activities.
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# Start Logstash using the below command
# docker run --name <container name> -v <path_on_host>/logstash.conf:/etc/logstash/logstash.conf -d <logstash_image>
#
# To include SSL support, build netty-tcnative. This can be verified with below sample input.txt file. 
# docker run --name <container name>  -v <host_path>/input.txt:/etc/logstash/logstash.conf -d <logstash_image> 
#
########################### Sample input.txt ######################################
#	input {
#                                 beats {
#                                 port => 5044
#                                 ssl => true
#                                 ssl_certificate_authorities => ["/etc/ca.crt"]
#                                 ssl_certificate => "/etc/server.crt"
#                                 ssl_key => "/etc/server.key"
#                                 ssl_verify_mode => "force_peer"
#                                 }
#                               }
########################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"
ENV JAVA_HOME=/root/jdk8u162-b12_openj9-0.8.0/ 
ENV PATH=/usr/share/logstash/bin:$JAVA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=/root/netty-tcnative/boringssl-static/target/native-build/.libs/:/root/netty-tcnative/libressl-static/target/native-build/.libs/:/root/netty-tcnative/openssl-static/target/native-build/.libs/:/root/netty-tcnative/openssl-dynamic/target/native-build/.libs/:/root/jffi-jffi-1.2.16/build/jni/:$LD_LIBRARY_PATH


# Install dependencies
RUN apt-get update && apt-get install -y \
    ant \
	autoconf \
	automake \
	cmake \
    gcc \
	git \
	golang \
	libapr1-dev \
	libssl-dev \
	libtool \
    make \
	maven \
	ninja-build \
	perl \
    tar \
    unzip \
    wget \

# Download OpenJDK8 with Eclipse OpenJ9
 && wget https://github.com/AdoptOpenJDK/openjdk8-openj9-releases/releases/download/jdk8u162-b12_openj9-0.8.0/OpenJDK8-OPENJ9_s390x_Linux_jdk8u162-b12_openj9-0.8.0.tar.gz \
 && tar -xvf OpenJDK8-OPENJ9_s390x_Linux_jdk8u162-b12_openj9-0.8.0.tar.gz \
	
# Download the logstash source from github and build it
 && wget https://artifacts.elastic.co/downloads/logstash/logstash-6.2.4.zip \
 && unzip -u logstash-6.2.4.zip \
 && wget https://github.com/jnr/jffi/archive/jffi-1.2.16.zip \
 && unzip -u jffi-1.2.16.zip \
 && cd jffi-jffi-1.2.16 \
 && ant \
 && cd .. \
 && cp -r /root/logstash-6.2.4 /usr/share/logstash \
 
# Download and install Netty-tcnative
 && git clone https://github.com/netty/netty-tcnative.git \
 && cd netty-tcnative \
 && git checkout netty-tcnative-parent-2.0.7.Final \
 
# Apply required patches for s390x support
 && sed -i '209d' openssl-static/pom.xml \
 && sed -i '208a\\t\t\t<arg line="xfvz ${project.build.directory}/old/1.0.2/openssl-${opensslVersion}.tar.gz" />' openssl-static/pom.xml \
 && mvn install -DskipTests 2 >&1 | tee build.log \ 
 && sed -i '338a\elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "s390x")' boringssl-static/target/boringssl-chromium-stable/CMakeLists.txt \
 && sed -i '339a\  set(ARCH "s390x")' boringssl-static/target/boringssl-chromium-stable/CMakeLists.txt \
 && sed -i '108a\#elif defined(__s390x__)' boringssl-static/target/boringssl-chromium-stable/include/openssl/base.h \
 && sed -i '109a\#define OPENSSL_64_BIT' boringssl-static/target/boringssl-chromium-stable/include/openssl/base.h \
 && mvn install -DskipTests \
 
# Cleanup Cache data , unused packages and source files
 && apt-get remove -y \
    ant \
	autoconf \
	automake \
	cmake \
    gcc \
	git \
    make \
	maven \
    unzip \
    wget \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /root/logstash-6.2.4 \
 && rm /root/logstash-6.2.4.zip \
 && rm /root/jffi-1.2.16.zip \
 && rm -rf /var/lib/apt/lists/*

# Define mountable directory
VOLUME ["/data"]

# Expose ports
EXPOSE 514 5043 5000 9292

CMD ["logstash", "-f", "/etc/logstash/logstash.conf"]
# End of Dockerfile
