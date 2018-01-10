############################ Dockerfile for Logstash version 6.1.1 ###################################################
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
#######################################################################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
MAINTAINER LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)

WORKDIR "/root"
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-s390x/jre
# Install dependencies
RUN apt-get update && apt-get install -y \
    ant \
    gcc \
    make \
    openjdk-8-jdk \
    tar \
    unzip \
    wget \

# Download the logstash source from github and build it
 && wget https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.zip \
 && unzip -u logstash-6.1.1.zip \
 && wget https://github.com/jnr/jffi/archive/master.zip \
 && unzip master.zip && cd jffi-master && ant && cd .. \
 && mkdir logstash-6.1.1/vendor/jruby/lib/jni/s390x-Linux  \
 && cp jffi-master/build/jni/libjffi-1.2.so logstash-6.1.1/vendor/jruby/lib/jni/s390x-Linux/libjffi-1.2.so \
 && cp -r /root/jffi-master  /usr/share \
 && cp -r /root/logstash-6.1.1 /usr/share/logstash \

# Cleanup Cache data , unused packages and source files
 && apt-get remove -y \
    ant \
    make \
    unzip \
    wget \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /root/ \
 && rm -rf /var/lib/apt/lists/*

# Define mountable directory
VOLUME ["/data"]

# Expose ports
EXPOSE 514 5043 5000 9292

ENV PATH=/usr/share/logstash/bin:$PATH

CMD ["logstash"]
# End of Dockerfile
