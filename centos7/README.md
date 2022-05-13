Description:
============

```
./some
	/cmake
	/lib
		libsome.so # you will build a new one during this example
	/src
		/headers
			some.h
		example.cpp
		some.cpp
	CMakeLists.txt
	test.py
```

We are going to build a simple library from ```some.cpp some.h```. This might be any library for which you want to create bindings. Result from this step: ```lib/libsome.so```

Next we will create bindings for ```libsome.so``` and its headers ```some.h```. The implementation of bindings is located in ```example.cpp```. Result from this step: ```example.so```

Then we can use ```example.so``` in python as regulat module like ```>>> import example```


Tested on:
----------

CentOS Linux release 7.9.2009 (Core)

Boost 1.77.0

Python 3.8.8

Cmake >= 3.17.5

gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-44)


Prerequisites:
==============

```bash
sudo yum -y update
sudo yum -y install wget
sudo yum -y install cmake3
```

Python:
-------

We are going to install a separate python interpreter Python 3.8.8. So the best way to use a separate location for it. I use ```/usr/local``` but it might be any place where you have permissions (I hope :) )

For other versions of Python3 everythin will be similar, but don't forget to change minor version in scripts below


``` bash
export Python3_INSTALL_DIR=/usr/local
export Python3_LIB_DIR=/usr/local/lib
```

Note: I didnt test it with installing in home folder

Install (You have to build your Python with shared libraries!):

``` bash
wget https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tgz
tar xvf Python-3.8.8.tgz
cd Python-3.8.8
./configure --enable-optimizations --enable-shared --prefix=${Python3_INSTALL_DIR} LDFLAGS="-Wl,-rpath ${Python3_LIB_DIR}"
sudo make altinstall  # altinstall skips creating the python link and the manual pages links, install will hide the system binaries and manual pages
cd ..
sudo rm -rf Python-3.8.8 Python-3.8.8.tgz
python3.8 --version
```


Build with gcc:
===============

Install Boost:
--------------

Got to https://sourceforge.net/projects/boost/files/boost/1.77.0/ and download ```boost_1_77_0.tar.bz2```

Then create a folder where Boost.Python will be installed ```mkdir ~/boost_install_dir```. And create env var for it

``` bash
export Boost_INSTALL_DIR=~/boost_install_dir # default path /usr/local or /usr
```

Install:

``` bash
tar --bzip2 -xf boost_1_77_0.tar.bz2
cd boost_1_77_0
./bootstrap.sh --with-libraries=python --with-python=${Python3_INSTALL_DIR}/bin/python3.8 --prefix=${Boost_INSTALL_DIR}
./b2 install variant=release link=shared cxxflags='-fPIC' --prefix=${Boost_INSTALL_DIR} -d 0 -j8
cd ..
rm -rf ./boost_1_77_0 boost_1_77_0.tar.bz2
```

Build:
------

A location of ```./some```:

``` bash
export MY_PROJECT_DIR=/home/antonkav/boost/helloworld/some
```

Build ```some.cpp```:

``` bash
g++ -fPIC -shared src/some.cpp -o lib/libsome.so
```

Build bindings (```example.cpp```):

``` bash
g++ -Wall -g3 -v -fPIC -shared -L${Boost_INSTALL_DIR}/lib -L${Python3_INSTALL_DIR}/lib -L${MY_PROJECT_DIR}/lib -I${Boost_INSTALL_DIR}/include -I${Python3_INSTALL_DIR}/include/python3.8  -Wl,-rpath,${Boost_INSTALL_DIR}/lib:${Python3_INSTALL_DIR}/lib:${MY_PROJECT_DIR}/lib -lpython3.8 -lboost_python38 -lsome src/example.cpp -o example.so
```

* ```-L${Python3_INSTALL_DIR}/lib```: location of ```libpython3.8.so``` 
* ```-L${Boost_INSTALL_DIR}/lib```: Location and ```libboost_python38.so```
* ```-L${MY_PROJECT_DIR}```: location of ```libsome.so```
* ```-I${Python3_INSTALL_DIR}/include/python3.8```: location of python .h files, for example ```pyconfig.h```
* ```-I${Boost_INSTALL_DIR}/include```: location of folder ```boost``` with .hpp files
* ```-Wall -g3 -v```: Warnings, optimization, verbose
* ```-Wl,-rpath```: Dirs fro libs for linker
* ```-fPIC```: Generate position-independent code (PIC) suitable for use in a shared library. If supported for the target machine, emit position-independent code, suitable for dynamic linking and avoiding any limit on the size of the global offset table. https://man7.org/linux/man-pages/man1/g++.1.html


Build with Cmake:
=================

This is a very convenient way for crossplatrom building using Cmake. 

```./some/cmake/Modules/BuildBoost.cmake``` - downloads and build Boost locally from the Internet
```./some/CMakeLists.txt``` - build bindings (```example.cpp```)

Please be careful: ```${Boost_INSTALL_DIR}``` and ```${Python3_INSTALL_DIR}``` are defined in ```./some/cmake/Modules/BuildBoost.cmake``` and ```./some/CMakeLists.txt```. Change them for your machine and for machine where it will be used. In this repo a default path of Boost install is ```/some/build/extern/python3_8_8```

```CMakeList.txt``` will try to fing a certain (or higher) version of Boost.Python **OR** download it and install in ```${CMAKE_BINARY_DIR}/extern/python${Python3_STR_VERSION}```. But you can also uncomment lines before ```find_package(Boost ...``` to provide a path to already installed Boost (see ```${Boost_INSTALL_DIR}``` in **Build with gcc:** section)

Build:
------

``` bash
cd ./some
```

Build ```some.cpp```:

``` bash
g++ -fPIC -shared src/some.cpp -o lib/libsome.so
```

``` bash
mkdir build && cd build
cmake3 ..
cmake3 --build . # dont use "make install" it can make your linux dirty 
mv example.so ../example.so
cd ..
```

Debug:
======

you can check dependencies:

``` bash
ldd example.so
```

Test:
=====

You shold not see error messages :)

``` bash
python3.8 test.py
```

or

```bash
$ python3.8 -c "import example; print(dir(example))"
['Some', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__spec__']
```

Distribution:
=============

If you want to run ```example.so``` on another machine you have to locate all dependencies (which is only ```libsome.so``` for this example). There are several ways to do it. Please discuss it with your DevOps guys.

Way 1:
------

```
./some
	/lib
		libsome.so
	example.so
```

And set:

``` bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:path/to/some/lib
```

Way 2:
------

Put ```libsome.so``` in ```/usr/local/lib```