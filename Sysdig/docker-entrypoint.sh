#!/bin/bash
#
# Copyright (C) 2013-2024 Draios Inc dba Sysdig.
#
# This file is part of sysdig .
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#set -e

echo "* Setting up /usr/src links from host"

if [[ "ubuntu" == $(awk -F'=' '/^ID=/ {print tolower($2)}' $SYSDIG_HOST_ROOT/etc/os-release 2> /dev/null) ]]
then
        echo "Detected Ubuntu. Installing linux-headers...";
        apt-get update -y;
        apt-get install -y linux-headers-generic;
        if [ $? -ne 0 ]
        then
                echo "*** Unable to install linux-headers-$(uname -r) , the sysdig command may not work properly.";
        fi
fi

for i in $(ls $SYSDIG_HOST_ROOT/usr/src)
do
        ln -s $SYSDIG_HOST_ROOT/usr/src/$i /usr/src/$i
done

/usr/bin/scap-driver-loader

exec "$@"
