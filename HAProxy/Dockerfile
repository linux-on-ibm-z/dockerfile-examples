# Building HAProxy

Below versions of HAProxy are available in respective distributions at the time of creation of these build instructions:


* SLES 12 SP2 has `1.6.9`
* SLES 12 SP3 has `1.6.11`
* Ubuntu 16.04 has `1.6.3`
* Ubuntu 18.04 has `1.8.4`


The instructions provided below specify the steps to build HAProxy version 1.8.8 on Linux on IBM Z for following distributions:
* RHEL (6.9, 7.3, 7.4, 7.5)
* SLES (11 SP4, 12 SP2, 12 SP3)
* Ubuntu (16.04, 18.04)

_**General Notes:**_ 	 
* _When following the steps below please use a standard permission user unless otherwise specified._
* _A directory `/<source_root>/` will be referred to in these instructions, this is a temporary writable directory anywhere you'd like to place it._

## Step 1: Building and Installing HAProxy
#### 1.1) Install the build dependencies
* RHEL (6.9, 7.3, 7.4, 7.5)
  ```bashnod
  sudo yum install wget tar make gcc unzip curl
  ```

* SLES (11 SP4, 12 SP2, 12 SP3)
  ```bash
  sudo zypper install -y tar make gcc curl wget unzip awk
  ```

* Ubuntu (16.04, 18.04)
  ```bash
  sudo apt-get update
  sudo apt-get install wget tar make gcc curl
  ```
  
#### 1.2) Download and unpack the required HAProxy source package
```bash
cd /<source_root>/
wget http://www.haproxy.org/download/1.8/src/haproxy-1.8.8.tar.gz
tar xzvf haproxy-1.8.8.tar.gz
cd haproxy-1.8.8
```

#### 1.3) Build and install HAProxy 
```bash
make TARGET=linux26
sudo make install
```

_**Note:** HAProxy will be installed in `/usr/local/sbin`. Depending upon user preferences and conventions, it may be necessary to either update PATH or create links to the executable files._

## Step 2: Testing - Simple Round-Robin Load Balancing Test

_Adapted from [Servers for Hackers](https://serversforhackers.com/load-balancing-with-haproxy)_

#### 2.1) Prepare a simple set of servers serving the same webpage

For example, this simple `node.js` script will serve a small text page, including the serving address and port, on the machine's ports 9000-9002:
```js
var http = require('http');

function serve(ip, port){
    http.createServer(function (req, res){
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.write(JSON.stringify(req.headers));
        res.end("\nThere's no place like "+ip+":"+port+"\n");
    }).listen(port, ip);
    console.log('Server running at http://'+ip+':'+port+'/');
}

// Create three servers for
// the load balancer, listening on any
// network on the following three ports
serve('0.0.0.0', 9000);
serve('0.0.0.0', 9001);
serve('0.0.0.0', 9002);
```

_**Note:** For RHEL and SLES, download Node.js v6.12.2 from [here](https://nodejs.org/dist/v6.12.2/), for Ubuntu run `sudo apt-get install nodejs` to install Node.js._

_**Note:** For RHEL6.9, Node.js requires GCC 4.8 or newer. So it is necessary to build and install a newer GCC._
	
* Install GCC 4.8.2 (For RHEL 6.9)
 ```bash 
 cd /<source_root>/
 sudo yum install -y subversion gcc-c++ binutils-devel bzip2
 wget http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2
 tar xvf gcc-4.8.2.tar.bz2
 cd gcc-4.8.2
 ./contrib/download_prerequisites
 mkdir /<source_root>/gccbuild
 cd /<source_root>/gccbuild
 ../gcc-4.8.2/configure  --prefix="/opt/gcc"  --enable-shared --with-system-zlib --enable-threads=posix  --enable-__cxa_atexit --enable-checking --enable-gnu-indirect-function  --enable-languages="c,c++" --disable-bootstrap --disable-multilib
 make all
 sudo make install
 export PATH=/opt/gcc/bin:$PATH
 export LD_LIBRARY_PATH=/opt/gcc/lib64:/opt/gcc/lib:$LD_LIBRARY_PATH
 sudo mv /usr/bin/gcc /usr/bin/gcc.bkup
 sudo ln -s /opt/gcc/bin/gcc /usr/bin/gcc
 gcc --version
 ```

#### 2.2) Create a file `haproxy.config` to serve as the configuration file for the test in the  `/<source_root>/` directory

This is a simple round-robin configuration using three servers:

```config
global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http-in
    bind *:80
    default_backend neo4j

backend neo4j
    mode http
    balance roundrobin
    option forwardfor
    http-request set-header X-Forwarded-Port %[dst_port]
    option httpchk HEAD / HTTP/1.1\r\nHost:localhost
    server s1 127.0.0.1:9000 maxconn 32
    server s2 127.0.0.1:9001 maxconn 32
    server s3 127.0.0.1:9002 maxconn 32

listen admin
    bind *:8080
    stats enable
```

_**Note:** This assumes that the node.js script from step 2.1 is being run on the same machine, serving three almost-identical webpages on ports 9000-9002. If this is not the case, replace the declarations for s1-s3 accordingly._

#### 2.3) Run HAProxy with the provided configuration

```    
cd /<source_root>/
haproxy -f haproxy.config
```

_**Note:** This will normally need to be done as root, or HAProxy will not have authority to access one or more ports, such as 80 and 8080._

#### 2.4) Navigate a web browser to the address of the server running HAProxy 

The browser displays the webpage from the list of the servers in `haproxy.config`. If the browser is refreshed, it should cycle through the provided servers in a round-robin fashion. If the node.js script from step 2.1 was used, the serving port number should change visibly with these refreshes.

## References:
* [HAProxy.org](http://www.haproxy.org/)
