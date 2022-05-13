#========================================================#
# Build the Boost dependencies for the project using 
# a specific version of python
#========================================================#
set(Boost_VERSION 1.77.0)
set(Boost_SHA256 fc9f85fc030e233142908241af7a846e60630aa7388de9a5fafb1f3a26840854)

string(REGEX REPLACE "beta\\.([0-9])$" "beta\\1" Boost_FOLDERNAME ${Boost_VERSION})
string(REPLACE "." "_" Boost_FOLDERNAME ${Boost_FOLDERNAME})
string(REPLACE "." "_" Python3_STR_VERSION ${Python3_VERSION})
set(Boost_FOLDERNAME boost_${Boost_FOLDERNAME})
set(Boost_INSTALL_DIR ${CMAKE_BINARY_DIR}/extern/python${Python3_STR_VERSION})

ExternalProject_Add(Boost
    PREFIX Boost
    URL  http://sourceforge.net/projects/boost/files/boost/${Boost_VERSION}/${Boost_FOLDERNAME}.tar.bz2/download
    URL_HASH SHA256=${Boost_SHA256}
    CONFIGURE_COMMAND ./bootstrap.sh
                                        --with-libraries=python
                                        --with-python=${Python3_EXECUTABLE}
    BUILD_COMMAND ./b2 install
                                        variant=release
                                        link=shared
                                        cxxflags='-fPIC'
                                        --prefix=${Boost_INSTALL_DIR}
                                        -d 0
                                        -j8
    INSTALL_COMMAND ""
    BUILD_IN_SOURCE 1
    )

set(Boost_LIBRARY_DIR ${Boost_INSTALL_DIR}/lib)
set(Boost_INCLUDE_DIR ${Boost_INSTALL_DIR}/include)
set(Boost_LIBRARIES -lboost_python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR})
