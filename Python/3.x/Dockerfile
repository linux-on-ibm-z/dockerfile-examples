# Building Python 3.7.x

Below versions of Python are available in respective distributions at the time of creation of these build instructions:
* SLES 12 SP3 has `3.4.6`
* SLES 15 has `3.6.5`
* Ubuntu 16.04 has `3.5.1`
* Ubuntu 18.04 has `3.7.1`

The instructions provided below specify the steps to build Python version 3.7.2 on Linux on IBM Z for following distributions:
* RHEL (6.10, 7.3, 7.4, 7.5)
* SLES (12 SP3, 15)
* Ubuntu (16.04, 18.04)

_**General Notes:**_  
* _When following the steps below please use a standard permission user unless otherwise specified._
* _A directory `/<source_root>/` will be referred to in these instructions, this is a temporary writable directory anywhere you'd like to place it._

## Step 1: Building and installing Python 3.7.x


#### 1.1) Build using script

   If you want to build Python using manual steps, go to STEP 1.2.

   Use the following commands to build Python using the build [script](https://github.com/linux-on-ibm-z/scripts/tree/master/Python3). Please make sure you have wget installed.
    
   ```shell
   wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Python3/build_python3.sh

   # Build Python
   bash build_python3.sh   
   ```	
	
If the build completes successfully, go to STEP 1.7. In case of error, check `logs` for more details or go to STEP 1.2 to follow manual build steps.

#### 1.2) Install dependencies  

  ```bash
  export SOURCE_ROOT=/<source_root>/
  ```  

* RHEL (6.10, 7.3, 7.4, 7.5)
  ```bash
  sudo yum install curl gcc gcc-c++ make ncurses patch xz xz-devel wget tar zlib zlib-devel libffi-devel git
  ```

* SLES (12 SP3, 15)
  ```bash
  sudo zypper install gcc gcc-c++ make ncurses patch wget tar zlib-devel zlib libffi-devel git
  ```

* Ubuntu (16.04, 18.04)
  ```bash
  sudo apt-get update
  sudo apt-get install gcc g++ make libncurses5-dev libreadline6-dev libssl-dev libgdbm-dev libc6-dev libsqlite3-dev libbz2-dev xz-utils patch wget tar zlib1g-dev libffi-dev
  ```
  
* Build OpenSSL 1.0.2(Only for RHEL and SLES)
	```
	cd $SOURCE_ROOT
	git clone git://github.com/openssl/openssl.git
	cd openssl
	git checkout OpenSSL_1_0_2l	 
	./config --prefix=/usr --openssldir=/usr/local/openssl shared
	make
	sudo make install
	export LC_ALL=C 			(Only for SLES) 
	```

#### 1.3) Download source code
```bash
cd $SOURCE_ROOT
wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tar.xz
tar -xvf Python-3.7.2.tar.xz
```

#### 1.4) Configure the build
Skipping the prefix will result in installing Python in default location `/usr/local`.
```bash
cd $SOURCE_ROOT/Python-3.7.2
./configure --prefix=<build-location> --exec-prefix=<build-location>
```
For instance,
```bash
cd $SOURCE_ROOT/Python-3.7.2
./configure --prefix=/usr/local --exec-prefix=/usr/local
```

#### 1.5) Build the source
```bash
cd $SOURCE_ROOT/Python-3.7.2
make
```

#### 1.6) Install the binaries
```bash
cd $SOURCE_ROOT/Python-3.7.2
sudo make install
```

#### 1.7) Verify Python3
```
python3 -V
```

## Step 2: Testing (Optional)
#### 2.1) Run the functional verification test suites
```bash
cd $SOURCE_ROOT/Python-3.7.2
make test
```

_**Note:** User can ignore intermittent test-case failures as it does not affect the functionality._


#### 2.2) Make verbose test suite
```bash
cd $SOURCE_ROOT/Python-3.7.2
./python Lib/test/regrtest.py -v test_<suite_name>
```
For instance,
```bash
cd $SOURCE_ROOT/Python-3.7.2
./python Lib/test/regrtest.py -v test_posix
```

## References:
[Release notes for Python 3.7.2](https://docs.python.org/3.7/whatsnew/changelog.html#python-3-7-2-final)
