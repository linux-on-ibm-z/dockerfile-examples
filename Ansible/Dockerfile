# © Copyright IBM Corporation 2017, 2020.
# LICENSE: Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

################### Dockerfile for Ansible latest version ##################################
#
# This Dockerfile builds a basic installation of Ansible.
#
# Ansible, a free-software platform for configuring and managing computers,
# combines multi-node software deployment,
# ad hoc task execution, and configuration management
#
# To build this image, from the directory containing this Dockerfile
# (assuming that the file is named Dockerfile):
# docker build -t <image_name> .
#
# To simply run the resultant image, and provide a bash shell:
# docker run  --name <container_name> -it <image_name> /bin/bash
#
# Use below command to use Ansible:
#  docker run --rm=true --name <container_name> -v <playbook_file_path_in_host>:<playbook_file_path_in_container>  -it <image_name>  ansible-playbook  <playbook_file_path_in_container>
#  For ex. docker run --rm=true --name <container_name> -v `pwd`/playbook.yml:/playbook.yml  -it <image_name>  ansible-playbook  /playbook.yml
#
# This Dockerfile is no longer maintained. For the list of maintained Build Instructions and Dockerfiles,
# please refer to https://www.ibm.com/community/z/open-source-software/
########################### Sample playbook.yml ######################################
#
#---
#- hosts: localhost
#  tasks:
#    - name: Installs nginx web server
#      apt: pkg=nginx state=latest update_cache=true
#      notify:
#        - start nginx
#
#  handlers:
#    - name: start nginx
#      service: name=nginx state=started
#
########################################################################################

# Base image
FROM s390x/ubuntu:18.04

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/community/z/usergroups/opensource)"

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
# Install ansible
 && apt-add-repository ppa:ansible/ansible \
 && apt-get update && apt-get -y install \
    ansible \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# This dockerfile does not have a CMD statement as the image is intended to be
# used as a base for building an application. If desired it may also be run as
# a container e.g. as shown in the header comment above.

# End of Dockerfile
