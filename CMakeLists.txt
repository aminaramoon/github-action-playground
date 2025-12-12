cmake_minimum_required(VERSION 4.1)

project(github-playground CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

include(SanitizerSettings)

find_package(Catch2 3 REQUIRED)
find_package(Threads REQUIRED)


add_subdirectory(cpp)

