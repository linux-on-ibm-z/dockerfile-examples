# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
#
# This dockerfile is no longer supported. Please find latest information from https://www.ibm.com/community/z/open-source-software/
#
######### Dockerfile for PostgreSQL 11.5 #########
#
# PostgreSQL is an open source relational database management system ( DBMS ) developed by a worldwide team of volunteers.
#
# To build PostgreSQL image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To create container of PostgreSQL image with default configuration run the below command
# docker run --name <container name> -p <port to export>:5432 -d <postgres_image>
# Example: docker run --name sample_container -p 5432:5432 -d  postgresql_ubuntu
# 
# To create container of PostgreSQL image with config file, run the below command
# docker run --name <container_name> -v /home/postgresql.conf:/usr/local/pgsql/data/postgresql.conf -d <image_name> postmaster -D /usr/local/pgsql/data -c config_file=/usr/local/pgsql/data/postgresql.conf
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
#####################################################################

# Base image
FROM s390x/ubuntu:16.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV SOURCE_DIR=/tmp/source
WORKDIR $SOURCE_DIR

# Installing Dependencies
RUN apt-get update && apt-get install -y \
    bison \
    flex \
    git \
    gcc \
    libreadline-dev \
    make \
    wget \
    zlib1g-dev \
&& groupadd -r postgres \
&& useradd -r -m -g postgres postgres \
&& mkdir /usr/local/pgsql && chmod -R 777 /usr/local/pgsql \
&& mkdir -p /usr/local/pgsql/data \
&& chown postgres:postgres /usr/local/pgsql/data
# Clone PostgreSQL and build it
RUN cd $SOURCE_DIR \
&& git clone git://github.com/postgres/postgres.git \
&& cd postgres/ \
&& git checkout REL_11_5 \
&& ./configure \
&& make \
&& make install \
# Tidy and clean up
&& rm -rf $SOURCE_DIR \
&& apt-get remove -y \
    bison \
    flex \
    git \
    make \
    wget \
    zlib1g-dev \
&& apt-get autoremove -y \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Initialize PostgreSQL data directory as postgres user
USER postgres
RUN /usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data/

# Expose Port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

ENV PATH $PATH:/usr/local/pgsql/bin

# Start the PostgreSQL service
CMD ["postmaster", "-D", "/usr/local/pgsql/data", "-c", "config_file=/usr/local/pgsql/data/postgresql.conf"]

# End of Dockerfile
