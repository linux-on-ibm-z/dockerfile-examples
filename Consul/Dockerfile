### Building Consul


The following version of Consul are available in the respective distribution at the time of creation of these build instructions:

* Ubuntu (17.04, 17.10) has `0.6.4`

The instructions provided below specify the steps to build Consul v1.0.1 on Linux on IBM Z for following distributions:  

*    RHEL (7.1, 7.2, 7.3, 7.4)
*    SLES (12, 12 SP1, 12 SP2, 12 SP3)
*    Ubuntu (16.04, 17.04, 17.10)

_**General Notes:**_

* _When following the steps below please use a standard permission user unless otherwise specified._
* _A directory `/<source_root>/` will be referred to in these instructions, this is a temporary writable directory anywhere you'd like to place it._


## Step 1: Building and Installing Consul

#### 1) Install dependencies

*    RHEL (7.1, 7.2, 7.3, 7.4)

     ```
     sudo yum install -y gcc git make tar unzip vim wget zip curl
     ```

*    SLES (12, 12 SP1, 12 SP2, 12 SP3)

     ```
     sudo zypper install -y gcc git make tar unzip vim wget zip curl 
     ```
    
*    Ubuntu (16.04, 17.04, 17.10)

     ```
     sudo apt-get update
     sudo apt-get install -y gcc git make tar unzip vim wget zip curl 
     ```

#### 2) Install GO 1.9+ locally and Set GOPATH Environment Variables
   
```
cd /<source_root>/
wget https://storage.googleapis.com/golang/go1.9.2.linux-s390x.tar.gz
tar -xzf go1.9.2.linux-s390x.tar.gz
export GOPATH=/<source_root>
export PATH=$PATH:$GOPATH/bin:$GOPATH/go/bin
export GOROOT=/<source_root>/go
export CC=gcc
```

#### 3) Get the source code

```
mkdir -p $GOPATH/src/github.com/hashicorp
cd $GOPATH/src/github.com/hashicorp
git clone https://github.com/hashicorp/consul.git
cd consul && git checkout tags/v1.0.1
go get github.com/mitchellh/gox
```

#### 4) Apply below git patch to add `s390x` support to `$GOPATH/src/github.com/mitchellh/gox` tool:

```
cd $GOPATH/src/github.com/mitchellh/gox
git checkout v0.4.0
wget https://github.com/mitchellh/gox/pull/85.patch
git am 85.patch
```

_**Note**: A PR is already created which includes changes mentioned in above patch and expected to get merged in later versions of Consul._

#### 5) Reinstall `gox` tool

```
cd $GOPATH/src/github.com/mitchellh/
go install ./... 
```

#### 6) Build consul

```
cd $GOPATH/src/github.com/hashicorp/consul
gox -os=linux -arch=s390x -output=s390x/consul
```

#### 7) Verify build success

```
cd $GOPATH/src/github.com/hashicorp/consul/s390x/
./consul
```

## Step 2: Testing
#### 1) Run test cases (Optional)

```
cd $GOPATH/src/github.com/hashicorp/consul/
make test
```
_**Note:** There are few test case failures which are intermittent and may pass on multiple run._

## Step 3: Verification 

#### 1) Run Consul Agent

* Start the Consul agent in development mode
```
cd $GOPATH/src/github.com/hashicorp/consul/s390x/
nohup ./consul agent -dev &
```

* Check the members of the Consul cluster
```
cd $GOPATH/src/github.com/hashicorp/consul/s390x/
./consul members
```
#### 2) Defining and Querying the service through Consul 

* Define a service named "web" running on port 80. Additionally, we'll give it a tag we can use as an additional way to query the service:
```
cd $GOPATH/src/github.com/hashicorp/consul/s390x/
sudo mkdir /etc/consul.d
echo '{"service": {"name": "web", "tags": ["web_service"], "port": 80}}' \
    | sudo tee /etc/consul.d/web.json
```

* Restart the agent, providng the configuration directory

```
cd $GOPATH/src/github.com/hashicorp/consul/s390x/
nohup ./consul agent -dev -config-dir=/etc/consul.d &
```

* Use HTTP API to query services

```
curl http://localhost:8500/v1/catalog/service/web
```

* You will get output similar to this

```JSON
[
    {
        "ID": "4bec0f38-0845-b071-1f50-ba41ebd4fe90",
        "Node": "096395b9eee8",
        "Address": "127.0.0.1",
        "Datacenter": "dc1",
        "TaggedAddresses": {
            "lan": "127.0.0.1",
            "wan": "127.0.0.1"
        },
        "NodeMeta": {},
        "ServiceID": "web",
        "ServiceName": "web",
        "ServiceTags": [
            "rails"
        ],
        "ServiceAddress": "",
        "ServicePort": 80,
        "ServiceEnableTagOverride": false,
        "CreateIndex": 5,
        "ModifyIndex": 5
    }
]
```

**_Note:_** To start a consul cluster please refer to this [link](https://www.consul.io/intro/getting-started/join.html)
### References:

  [How to write go code](https://golang.org/doc/code.html)  
  [Building Go for z System](https://github.com/linux-on-ibm-z/docs/wiki/Building-Go)  
  [Consul Source Code](https://github.com/hashicorp/consul)  
  [Godeps](https://github.com/tools/godep)  
  [gox](https://github.com/mitchellh/gox)  
  [Consul Website](https://www.consul.io/)
