# CMake minimum requirement (mandatory)
cmake_minimum_required(VERSION 3.12)

# Project name / version / description / language
project(example VERSION 1.0 DESCRIPTION "Python.Boost -> Shared library" LANGUAGES CXX)

# Adding customized cmake module for building boost
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# Set C++ standard
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_VERBOSE_MAKEFILE ON)

# Find default python libraries and interpreter
find_package(Python3 3.8 EXACT REQUIRED COMPONENTS Interpreter Development)

# Find Boost
# if you built Boost in a non standard path you can uncommend following lines
# check README.md for ${Boost_INSTALL_DIR}
# Note: You will have a Warning message on $ cmake3 .. 
# This is because of add_dependencies(${PROJECT_NAME} Boost)
# Just ignore it. I didn't figure out why
# ---
# set(Boost_ROOT $ENV{Boost_INSTALL_DIR})
# set(Boost_INCLUDE_DIR $ENV{Boost_INSTALL_DIR}/include)
# set(Boost_LIBRARY_DIR $ENV{Boost_INSTALL_DIR}/lib)
# set(Boost_LIBRARIES -lboost_python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR})
# set(Boost_NO_BOOST_CMAKE ON)
# ---

set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
set(Boost_USE_DYN_LIBS ON )
add_definitions(-DBOOST_ALL_DYN_LINK)
find_package(Boost 1.77 COMPONENTS python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR})

# If cannot find Boost, install it using /cmake/Modules/BuildBoost.cmake file
if(NOT Boost_FOUND)
    # Adding customized cmake module for building boost
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
    # Add capacity of using external ".cmake" projects
    include(ExternalProject)
    # Include custom module to build Boost dependencies using a specific python version
    include(BuildBoost)
endif()

message("______________________________________________")
message("_________________PYTHON INFOS_________________")
message("Python found: \t\t${Python3_FOUND}")
message("Python version: \t${Python3_VERSION}")
message("Python libraries: \t${Python3_LIBRARIES}")
message("Python executable: \t${Python3_EXECUTABLE}")
message("Python include dirs: \t${Python3_INCLUDE_DIRS}")
message("Python library dirs: \t${Python3_LIBRARY_DIRS}")
message("")

message("______________________________________________")
message("_________________BOOST INFOS__________________")
message("Boost found: \t\t${Boost_FOUND}")
message("Boost version: \t\t${Boost_VERSION}")
message("Boost libraries: \t${Boost_LIBRARIES}")
message("Boost library dir: \t${Boost_LIBRARY_DIR}")
message("Boost include dirs: \t${Boost_INCLUDE_DIR}")
message("______________________________________________")
message("")

add_library(${PROJECT_NAME} SHARED 
    src/example.cpp
    )
target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIR} ${Python3_INCLUDE_DIRS} ${CMAKE_SOURCE_DIR}/src/headers)
target_link_libraries(${PROJECT_NAME} PRIVATE ${Boost_LIBRARIES} ${Python3_LIBRARIES} -lsome)
target_link_directories(${PROJECT_NAME} PRIVATE ${Boost_LIBRARY_DIR} ${Python3_LIBRARY_DIRS} ${CMAKE_SOURCE_DIR}/lib)

add_dependencies(${PROJECT_NAME} Boost)

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")
set_target_properties(${PROJECT_NAME} PROPERTIES SUFFIX .so)
